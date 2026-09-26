# 2026-09-27 corrected pre-slab earlyfb proof

This phase started from physically proven post-`paging_init()` MAINLINE and
crossed the early `earlyfb_console_init()` boundary without crossing
`acpi_table_upgrade()`.

## Starting authority

Starting proven MAINLINE:

`213b61315c94e37f942532c6fdbe5f6dcd158a851dbe9177258036265d2ec803`

That checkpoint proved `paging_init()` returned normally to `setup_arch()` and
the ordinary setup_arch framebuffer bridge remained visibly writable.

Immutable Android recovery remained:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

## E1: earlyfb entry and helper return

E1 source:

`0f851813ba1708e37c64ec7fdf759779e1de0aad`

E1 BOOT:

`fcf1a6b751f49c5ef675cb883859feebacdb73ed03e059076815b47d129ba050`

E1 removed only the spring-green hold and entered `earlyfb_console_init()`.
The current bootargs select the existing `d2s_wdt_setup("early", true)` path.
The helper remained source-unchanged and instruction-equivalent to the proven
parent.

After that helper call returned, E1 freshly reloaded the already-proven bridge
and painted amber `0xffffa000` before the first `earlyfb_map` decision.

Captain observed amber, described visually as dirty orange, and confirmed it
remained unchanged for at least three minutes.

This proves the selected helper call returned and the existing bridge remained
visibly writable. It does not prove every internally tolerated WDT/PMU mapping
or MMIO arm operation succeeded.

## Original E2 physical failure

Failed E2 source:

`2dc8806f7b70c8d40e0d001be126c5c311ff78d6`

Failed E2 BOOT:

`bbfcac8fd57778e7cd489a84ddcb71966971d6e4fdee53e9150f8e39182f184e`

E2 removed only the amber hold, preserved the original first-call
`earlyfb_map` check, executed the original full framebuffer
`ioremap_wc(0xca000000, 0x10b3000)` path, and planned to paint azure through
the returned mapping before `memset_io()`.

Physical observation was:
- amber/orange appeared briefly;
- no stable azure appeared;
- the device then reset / boot-looped.

The accepted E2 criterion required stable azure, so E2 was a FAIL and proven
E1 was restored immediately.

## Conclusive allocator diagnosis

On arm64:

`ioremap_wc(...)` -> `__ioremap_prot(..., PROT_NORMAL_NC)` ->
`generic_ioremap_prot()`.

`generic_ioremap_prot()` begins with:

```c
if (WARN_ON_ONCE(!slab_is_available()))
    return NULL;
```

The current `earlyfb_console_init()` invocation runs inside `setup_arch()`.
`start_kernel()` calls `setup_arch()` before `mm_core_init()`.

Inside `mm_core_init()`:
- `kmem_cache_init()` eventually sets `slab_state = UP`;
- `slab_is_available()` is exactly `slab_state >= UP`;
- later, `vmalloc_init()` sets `vmap_initialized = true`.

The ordinary vmap allocator also rejects allocations before
`vmap_initialized` becomes true.

Therefore full ordinary `ioremap_wc()` cannot succeed at the current
`setup_arch()` call site.

This also applies to the watchdog helper's own ordinary `ioremap()` calls, so
the early helper can return without establishing those mappings. That explains
why the physically proven E1 hold survived three minutes without a watchdog
reset.

A full early-remap replacement is not viable. The framebuffer size
`0x10b3000` is 4275 pages, while one arm64 early-ioremap slot permits only 65
pages.

## E2D: explicit pre-slab deferral and genuine return

Corrected E2D restarted directly from proven E1.

E2D source:

`a12563a55083651b11db5963d6f3064c07d7991a`

Image:

`037ddf95d9402cf09a3f5bf905f687ede9c871a3aed0cc4a2893fddcdcb551af`

Loader:

`0bd4919bbf0595d7fc75550afb85104847b23b02e31c088d3cf277d525a75f56`

BOOT:

`10eb19209719a38b677e01f5dc5afa89b14839312b2d8eae7d295f344f0068cc`

The E2D source does only three semantic things:
1. remove only the E1 amber deliberate hold;
2. preserve the original `earlyfb_map` check and add
   `if (!slab_is_available()) return;` immediately before full
   `ioremap_wc()`;
3. after genuine `earlyfb_console_init()` return, paint teal in the caller
   immediately before `acpi_table_upgrade()`.

The final linked earlyfb seam is:

```text
ffff80008221548c  ldr x8, [x19, #0x2e8]
ffff800082215490  cbnz x8, ffff8000822154d0
ffff800082215494  bl slab_is_available
ffff800082215498  tbz w0, #0x0, ffff8000822154d0

-- full framebuffer __ioremap_prot only if slab-true --

ffff8000822154d0  ldr x19, [sp, #0x10]
ffff8000822154d4  ldp x29, x30, [sp], #0x20
ffff8000822154d8  ldr x30, [x18, #-0x8]!
ffff8000822154f4  ret
```

The caller then resumes:

```text
ffff800082214c1c  bl earlyfb_console_init
ffff800082214c20  mov x9, x20
ffff800082214c24  mov x10, x9
ffff800082214c28  mov x11, #0xc0c0
ffff800082214c2c  movk x11, #0xff00, lsl #16
ffff800082214c30  movk x11, #0xc0c0, lsl #32
ffff800082214c34  movk x11, #0xff00, lsl #48
ffff800082214c38  mov x12, #0x20000
ffff800082214c3c  movk x12, #0xd000
ffff800082214c40  add x12, x10, x12
ffff800082214c44  str x11, [x10], #0x8
ffff800082214c48  cmp x10, x12
ffff800082214c4c  b.lo ffff800082214c44
ffff800082214c50  dsb sy
ffff800082214c54  wfe
ffff800082214c58  b ffff800082214c54

-- unreachable --

ffff800082214c5c  bl acpi_table_upgrade
```

The marker is exact teal ARGB8888 `0xff00c0c0`, duplicated as
`0xff00c0c0ff00c0c0`, over the exact existing `0x2d000` bridge band.

Captain observed teal, described visually as dirty blue, and confirmed it
remained unchanged for at least three minutes.

This physically proves:
- all E1 facts remain true;
- the pre-slab earlyfb invocation deferred before the impossible full
  framebuffer ioremap;
- `earlyfb_console_init()` executed its genuine epilogue/SCS restoration and
  returned to `setup_arch()`;
- the ordinary setup_arch bridge survived and remained visibly writable;
- `acpi_table_upgrade()` did not execute.

It does not prove full framebuffer ioremap, framebuffer clear, console
registration, printbuffer replay, or watchdog arming.

## Reproducibility and standing invariants

Accepted config remained:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE` remained:

`2026-09-26 01:21:56 UTC`

Two clean E2D loader builds and two BOOT packaging runs were byte-identical.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail remained
byte-identical relative to proven E1, with checksum/id-only header drift and
unchanged accepted AVB/stale-descriptor behavior.

Both canonical MAINLINE pointer surfaces were verified against exact proven E1
before E2D freeze.

## Promotion and next boundaries

Exact E2D BOOT:

`10eb19209719a38b677e01f5dc5afa89b14839312b2d8eae7d295f344f0068cc`

is the newest proven MAINLINE checkpoint and remains installed.

The failed original E2 BOOT remains preserved as failure evidence:

`bbfcac8fd57778e7cd489a84ddcb71966971d6e4fdee53e9150f8e39182f184e`

This closes the corrected pre-slab earlyfb phase.

The immediate next `setup_arch()` boundary is `acpi_table_upgrade()`. Do not
cross it without a new bounded phase plan/review.

Full framebuffer mapping, clear, console registration and replay are a separate
future problem. They must be planned only at a call site after complete
`mm_core_init()` has returned, when both slab and vmap are initialized.
