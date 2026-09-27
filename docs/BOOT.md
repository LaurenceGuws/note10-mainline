# First mainline BOOT envelope

This document records the offline envelope for the first d2s mainline UFS
diagnostic candidate. It is not flash authorization.

## Inputs

The candidate currently composes:

- physical rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`
  at `57,671,680` bytes;
- UFS candidate Linux commit:
  `0f909c956f4f5d3ebfd5217dd22b73d9b4f4fa82`;
- mainline `Image`:
  `e85f0ab067162d25b6af2df6f79ac2648f81285e1939bbf03bc2f711a47cf35e`;
- d2s DTB:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- diagnostic initramfs:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`;
- uniLoader upstream commit:
  `f45d73b344ce9ae8dab191836933ebfbed287afb`;
- resulting reference uniLoader:
  `b998894b983bd2091080dd8a0621fe3de611c91d7a1ad3da15ba0a0d1eba9d12`;
- MagiskBoot 30.7 host binary:
  `a18ecbd7981179494b7d281453d6c4e25b5c719e7d2ef7f6eba3c6be3043c58e`.

All generated binaries remain in the active workstream.

## Why uniLoader

The accepted Android BOOT is header v1 and its kernel field contains no appended
FDT. The mainline kernel needs the d2s DTB and diagnostic initramfs, so replacing
that field with a bare Linux `Image` would not provide the complete boot
contract.

uniLoader embeds the Linux `Image`, DTB and initramfs. It relocates itself,
copies the real kernel and initramfs to their configured addresses, patches the
DTB with `linux,initrd-start` and `linux,initrd-end`, and enters the kernel with
the DTB in `x0`.

The first candidate deliberately uses upstream's unmodified
`beyond1lte_defconfig` rather than inventing d2s loader support before hardware
proof. That reference configuration already matches the useful d2s geometry:

- loader relocation: `0x89000000..0x8bac3000`;
- initramfs target: `0x84000000..0x84001e10`;
- Linux Image target: `0x90000000..0x92a32a00`;
- simple framebuffer: `0xca000000`, `1440x3040`, four-byte pixels.

Those three load/relocation ranges are disjoint and lie inside the first d2s
DRAM range. They do not overlap the framebuffer or ramoops reserved regions.

The loader's DECON address `0x19030000` and trigger-control offset `0x70`
correlate with the Exynos9825 vendor source. The literal write value `0x1281`
is still borrowed from the Galaxy S10 loader and is **not** yet a durable d2s
hardware fact. A successful physical proof can earn a proper d2s uniLoader
delta later.

The reference loader is built with system Clang 22.1.8 and Zig's LLD 22.1.4.
uniLoader normally injects the wall clock into `VER_TAG`, so this repository's
helper pins `GIT_VERSION_TAG=f45d73b` and
`BUILD_DATE="2026-09-24 04:45:35 UTC"` (the upstream commit time normalized to
UTC). Two independent detached-worktree builds were byte-identical.

```sh
tools/build-uniloader \
  /path/to/uniLoader-git-checkout \
  /path/to/Image \
  /path/to/exynos9825-d2s.dtb \
  /path/to/initramfs.cpio.gz \
  /path/to/empty-output-directory
```

## Preserve the BOOT layout

The raw uniLoader is `44,838,912` bytes, smaller than the accepted Android
kernel field (`48,424,984` bytes). Repacking it at its natural length moves the
AVB footer earlier while retaining the old descriptor's image-size metadata.
That first packing attempt is therefore rejected.

The candidate pads uniLoader with `3,586,072` zero bytes to the exact original
kernel-field size before MagiskBoot repacks the image. uniLoader's own linked
relocation size remains `44,838,912` bytes, so the padding is never part of its
relocation or payload contract.

Reproduce the BOOT envelope with explicit inputs:

```sh
tools/build-boot-candidate \
  /path/to/current-live-boot.img \
  /path/to/magiskboot-x86_64 \
  /path/to/uniLoader \
  /path/to/empty-output-directory
```

The helper never contacts, flashes or reboots the phone.

## Frozen offline candidate

Current padded candidate:

`044459f40f1dac78f7ab57980d1caed8202c9f0c9186edebb08df81865cf095c`

The base was physically re-verified on the phone immediately before this
freeze as `/dev/block/by-name/boot` -> `/dev/block/sda14`, SHA-256
`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`.
The then-current `note10-platform` documentation still named `b5b6f5cc...`;
that documentation mismatch is not used as the rollback boundary for this
candidate.

Offline validation proves:

- total image size remains `57,671,680` bytes;
- Android BOOT header remains v1 with the original kernel/ramdisk field sizes,
  load addresses, page size, OS metadata and command line;
- header drift is confined to the legacy checksum/id field;
- candidate kernel prefix is the exact uniLoader binary and all slot padding is
  zero;
- the compressed Android ramdisk region is byte-identical to the accepted base;
- every byte after the ramdisk region, including the existing AVB/VBMeta tail,
  is byte-identical to the accepted base;
- `avbtool info_image` output is identical between base and candidate;
- both base and candidate reproduce the already-accepted stale AVB hash
  descriptor (`verify_image` rc 1), while footer and `NONE` VBMeta structure
  verify. This is parity with the current physical BOOT, not a new regression.

MagiskBoot's second unpack heuristically splits the embedded mainline bytes into
`kernel`/`kernel_dtb`. That is not the BOOT layout. AOSP `unpack_bootimg.py`
reads the raw kernel field as one `48,424,984`-byte slot and the byte-range
verification above is the authority for this candidate.

## First-test observability

The kernel has `FB_SIMPLE`, framebuffer console, Samsung serial console,
pstore/ramoops and printk timing built in. The tiny diagnostic initramfs emits
JSON to the inherited console and never writes UFS.

USB gadget composition is currently modular (`libcomposite`/configfs functions)
and those modules are not present in the tiny initramfs. Do not claim USB
networking as a first-test recovery or observation channel. The first visible
path is therefore the inherited framebuffer console (plus UART where physically
available); ramoops is secondary crash evidence.

## Promotion boundary

No physical mutation has occurred.

Before an attended BOOT flash, an independent review must verify at least:

1. the exact base/candidate/tool/source hashes above;
2. the UFS PRDT semantic delta and its offline gates;
3. uniLoader component offsets and d2s memory-range non-overlap;
4. the borrowed `0x1281` DECON write is understood as an experiment, not an
   established d2s fact;
5. the padded BOOT byte-range proof and AVB parity;
6. the initramfs contains no storage write path;
7. the exact current `note10-platform` BOOT has not changed since this snapshot.

The attended physical success gate is deliberately narrow: reach `/init` and
obtain repeated successful read-only `/dev/sda`/GPT probes. Writable rootfs,
touch, GPU and desktop bring-up remain later tranches.

## First physical result

The reviewed candidate was tested once on 2026-09-26. uniLoader reached
`Booting kernel...`, then the phone reset before the diagnostic `/init` became
visible. The exact `1a78e511...` BOOT was restored successfully and verified
on-device afterward.

Review of the loader call order corrected one important interpretation:
`Booting kernel...` is printed before the Image/initramfs copies, so that first
test did **not** prove the final `br x4` into Linux. See
`docs/2026-09-26-first-mainline-boot.md`.

The earned next problem is therefore the copy-to-`primary_entry` boundary, not
another speculative UFS change.

That boundary is now resolved. The reviewed two-sided marker candidate showed
`COPY_DONE / JUMP_READY`, then painted and held a magenta stripe from the first
body instructions of `primary_entry` for at least three minutes. Handoff state
was EL1 with `SCTLR_EL1.M=0`, `C=0`, `I=0`; the loader target was exactly
`0x90000000` and `x0=0x8ba476e0`.

The exact `1a78e511...` BOOT was restored afterward and verified on-device.
The next earned tranche is one bounded stage deeper in the original arm64
entry path, not a loader/UFS/watchdog redesign.

That next tranche was frozen under
`diagnostics/post-preserve-marker/`. It keeps the proven loader and first-body
magenta marker, executes only the original `record_mmu_state` and
`preserve_boot_args`, then paints the lower half cyan and deliberately holds
before stack/idmap setup. Independent review caught and rejected an offline
cyan-range construction error before any phone mutation; the corrected
reproducible BOOT candidate was `ac54bba7...`. R1 follow-up review returned
`FINAL ACCEPT`.

The attended physical test then produced the expected magenta/cyan split and
held stably for about five minutes. This proves `record_mmu_state` and
`preserve_boot_args` returned successfully, including the observed MMU-off
boot-argument cache invalidation path. See
`docs/2026-09-26-post-preserve-proof.md`.

The exact `1a78e511...` rollback BOOT was restored afterward and verified
on-device with Android `sys.boot_completed=1`. The earned next boundary is now
the early stack + init-idmap creation and its MMU-off page-table cache
invalidation, still before `init_kernel_el`.

That next offline candidate now brackets early stack/idmap construction and the
observed MMU-off page-table cache invalidation with yellow/green breadcrumbs in
rows 608..639, while preserving the already-proven magenta/cyan history. It
holds before `init_kernel_el`. See
`diagnostics/idmap-breadcrumb-marker/README.md`.

The attended test produced the expected final green lower quarter and remained
stable for at least three minutes. This physically proves early stack setup,
`__pi_create_init_idmap`, the expected `x19=0` path, and the MMU-off page-table
`dcache_inval_poc` return. See
`docs/2026-09-26-idmap-invalidation-proof.md`.

The exact `1a78e511...` rollback BOOT was restored afterward and re-verified
with Android `sys.boot_completed=1`. The earned next boundary is now
`init_kernel_el` / `__cpu_setup`, still before `__primary_switch` and MMU
enable.

The next offline candidate now brackets those two calls directly. It paints
rows 640..671 red only after `init_kernel_el` returns and its boot-mode result
has been saved in `x20`, then overwrites those rows white only after
`__cpu_setup` returns. The white path deliberately holds before
`__primary_switch`, so MMU enable is unreachable. See
`diagnostics/init-kernel-el-cpu-setup-marker/README.md`.

The attended test produced the expected final white rows 640..671 and remained
stable for at least three minutes. This physically proves `init_kernel_el` and
`__cpu_setup` both returned, while `__primary_switch` and `__enable_mmu`
remained unreachable. See
`docs/2026-09-26-init-kernel-el-cpu-setup-proof.md`.

The exact `1a78e511...` rollback BOOT was restored afterward and re-verified
with Android `sys.boot_completed=1`. The earned next boundary is now
`__primary_switch` / `__enable_mmu` itself.

The next offline candidate adds one diagnostic-only 2 MiB Normal-NC identity
mapping for the framebuffer to the transient TTBR0 init idmap. Final linked
page-table accounting is 7 of the existing 8 reserved pages. It brackets
`__primary_switch` / `__enable_mmu` with blue/yellow/red/orange rows 672..703
and deliberately holds after `__enable_mmu` returns, before
`__pi_early_map_kernel`. DT `no-map` and normal framebuffer mappings remain
unchanged. See `diagnostics/primary-switch-enable-mmu-marker/README.md`.

The attended test produced the expected final orange band and remained stable
for at least three minutes. This physically proves entry into
`__primary_switch`, the TTBR setup, the complete MMU-enable macro, and a
successful return from `__enable_mmu` with the MMU enabled. See
`docs/2026-09-26-mmu-enable-proof.md`.

The exact `1a78e511...` rollback BOOT was restored afterward and re-verified
with Android `sys.boot_completed=1`. The earned next boundary is now
`__pi_early_map_kernel` / relocation.

The next offline candidate keeps the accepted transient framebuffer idmap and
uses the same rows 672..703 for violet immediately before
`__pi_early_map_kernel`, cyan immediately after it returns, and lime as the
first body instructions of `__primary_switched`, where it deliberately holds.
No internal early-map C instrumentation is added. See
`diagnostics/early-map-relocation-marker/README.md`.

The attended test produced the expected final lime marker and it remained
stable for at least three minutes. This physically proves
`__pi_early_map_kernel` returned, the untouched final virtual branch succeeded,
and the first `__primary_switched` body instructions executed under the final
kernel mapping. See
`docs/2026-09-26-early-map-relocation-proof.md`.

The exact `1a78e511...` rollback BOOT was restored afterward and re-verified
with Android `sys.boot_completed=1`. The earned next boundary is now the early
`__primary_switched` state setup, still before `start_kernel`.

The next offline candidate removes only the lime hold and reuses rows 672..703
for amber after `init_cpu_task`, blue after VBAR installation, and white after
FDT/kimage/boot-mode/final-EL setup plus the original frame pop. The white path
deliberately holds immediately before `start_kernel`. See
`diagnostics/primary-switched-state-marker/README.md`.

The attended test produced the expected final white marker and it remained
stable for at least three minutes. This physically proves every remaining
pre-`start_kernel` `__primary_switched` state operation completed while
`start_kernel` itself remained unreachable. See
`docs/2026-09-26-primary-switched-state-proof.md`.

The exact `1a78e511...` rollback BOOT was restored afterward and re-verified
with Android `sys.boot_completed=1`. The earned next boundary is now
`start_kernel` entry itself.

From this point, physically successful mainline diagnostics are promoted as the
new proven MAINLINE checkpoint and normally remain installed. Android
`1a78e511...` is retained as the immutable recovery floor rather than the
routine rollback target. See `docs/PROVEN-CHECKPOINTS.md`.

The next offline candidate removes only the proven white hold, executes the
original `bl start_kernel`, and places a direct arm64 rose framebuffer marker
as the first explicit source statement inside `start_kernel`, followed by an
immediate hold. It deliberately keeps every ordinary `start_kernel` operation
unreachable. See `diagnostics/start-kernel-entry-marker/README.md`.

The attended test produced the expected rose (`0xffff4080`) rows 672..703 and
they remained stable for at least three minutes. This physically proves genuine
`start_kernel` entry, including its compiler SCS/frame/auto-init entry work,
while every ordinary `start_kernel` operation remains unreachable. See
`docs/2026-09-26-start-kernel-entry-proof.md`.

The exact BOOT
`3992fcbfd834db4e63da7a6350f4a7d99a4002528e636ccc053faf3a63051c0e`
is promoted as the newest proven MAINLINE checkpoint and remains installed.
No Android rollback occurs after this PASS.

The next offline candidate removes only the rose hold, lets the first ordinary
`start_kernel` cluster execute through `boot_cpu_init()`, then paints rows
672..703 pure green (`0xff00ff00`) and deliberately holds before banner
printing or `setup_arch()`. See
`diagnostics/start-kernel-ordinary-marker/README.md`.

The attended test produced the expected pure-green rows 672..703 and they
remained stable for at least three minutes. This physically proves the first
ordinary `start_kernel` cluster through `boot_cpu_init()`, including CPU0
publication / its printk path and IRQ-disable publication, while banner
printing and `setup_arch()` remain unreachable. See
`docs/2026-09-26-ordinary-start-kernel-proof.md`.

The exact BOOT
`8dd7d4d2a160b1072f76c2d84ee30dce1bbaa8523fa53a4ecb72f9143f07d591`
is promoted as the newest proven MAINLINE checkpoint and remains installed.

The next offline candidate removes only the pure-green hold, lets the kernel
banner print and safe arm64 `setup_arch()` work complete through
`local_daif_restore()`, then paints rows 672..703 pure blue (`0xff0000ff`) and
holds before **any** `cpu_uninstall_idmap()` / TTBR0-teardown preparation.
See `diagnostics/setup-arch-pre-idmap-marker/README.md`.

The attended test produced the expected pure-blue rows 672..703 and they
remained stable for at least three minutes. This physically proves banner
printing returned and every safe pre-teardown `setup_arch()` operation
completed through `local_daif_restore()`, while zero
`cpu_uninstall_idmap()`-attributable linked instruction executed. See
`docs/2026-09-26-setup-arch-pre-idmap-proof.md`.

The exact BOOT
`6f7c807ef733582d1f200a38aac11285d82b0c055447b20071352a058e713204`
is promoted as the newest proven MAINLINE checkpoint and remains installed.

This is also the end of the current low-TTBR0 framebuffer evidence sink. Any
diagnostic after `cpu_uninstall_idmap()` must first establish or prove a new
mapping/evidence mechanism.

The next offline candidate proves that replacement sink without crossing
`cpu_uninstall_idmap()`: after the established blue marker, it creates a
temporary TTBR1 fixmap of the exact visible framebuffer band with
`early_memremap_prot(..., PROT_NORMAL_NC)`, matching the existing low alias,
then paints the band pure yellow (`0xffffff00`) through the returned high VA
and holds. NULL preserves blue and holds. `early_memunmap()` and
`cpu_uninstall_idmap()` remain unreachable. See
`diagnostics/post-idmap-evidence-bridge/README.md`.

The yellow high-TTBR1 bridge checkpoint then became the evidence sink for one
bounded post-idmap / pre-paging phase. Three reviewed physical checkpoints
advanced the original `setup_arch()` path without replacing or unmapping that
bridge:

1. P1 removed only the yellow hold, executed `cpu_uninstall_idmap()` in full,
   rebound the surviving ordinary C bridge state to `x9`, painted pure red
   (`0xffff0000`), and held before `xen_early_init()`. The red hold remained
   stable for at least three minutes. Exact promoted BOOT:
   `f4383f57b057543b9f5eb10d7d8fe568f12e28fb37eafca0b2826c1ae70fdd8a`.
2. P2 removed only the red hold, executed the original `xen_early_init()` and
   `efi_init()` plus the untouched runtime-selected EFI warning/taint
   continuation, then painted violet (`0xff8000ff`) and held before
   `arm64_memblock_init()`. Physical PASS was recorded and exact BOOT
   `21f25494c348ea886717128762a6e371e9428aff43c448f630fca359297e82de`
   was promoted.
3. P3 removed only the violet hold, executed the original
   `arm64_memblock_init()` unchanged, rebound the surviving bridge `x20 -> x9`,
   painted pure cyan (`0xff00ffff`), and held before `paging_init()`. The cyan
   hold remained unchanged for at least three minutes. Exact promoted BOOT:
   `3a66d98bcfa76de7f9f598eba839f5ccc4a096c4ca50f6cacd5e44fe87eb6d27`.

The final linked P3 boundary is:

```text
ffff800082214bd8  bl arm64_memblock_init
ffff800082214bdc  mov x9, x20
ffff800082214be0  cyan marker begins
ffff800082214c0c  dsb sy
ffff800082214c10  wfe
ffff800082214c14  b ffff800082214c10

-- unreachable --

ffff800082214c18  bl paging_init
```

This closes the post-idmap / pre-paging phase. The next architectural boundary
is `paging_init()`. It requires a new bounded phase plan/review before physical
work crosses that call. See
`docs/2026-09-26-post-idmap-pre-paging-proof.md`.

The next accepted phase crossed `paging_init()` itself in three reviewed
physical checkpoints while preserving the same high-TTBR1
`PROT_NORMAL_NC` evidence bridge:

1. Q1 removed only the cyan hold, published the existing bridge pointer through
   the accepted diagnostic `__initdata` handoff, executed `map_mem()`
   completely, then loaded that handoff after return and painted gold
   (`0xffffb000`) before `memblock_allow_resize()`. Gold remained unchanged
   for at least three minutes. Exact promoted BOOT:
   `7c4cf029d91b2841e4705e06218d7780ed24a87ed69f39848568e46e0637e749`.
2. Q2 removed only the gold hold, executed the original
   `memblock_allow_resize()` and `create_idmap()`, freshly reloaded the bridge
   after `create_idmap()` returned, painted electric purple (`0xffc000ff`),
   and held before `declare_kernel_vmas()`. Electric purple remained unchanged
   for at least three minutes. Exact promoted BOOT:
   `7b12062945c4f47b8eb85b90f72d9fd57fdda6c7bf6a458f861f793876cbc1b5`.
3. Q3 removed only the electric-purple hold, executed unchanged
   `declare_kernel_vmas()`, let `paging_init()` restore its saved register,
   frame and SCS state and execute a genuine `ret`, then resumed in
   `setup_arch()`. The ordinary surviving bridge in callee-saved `x20` was
   freshly rebound `x20 -> x9`, painted spring green (`0xff00ff80`), and held
   before `earlyfb_console_init()`. Spring green remained unchanged for at
   least three minutes. Exact promoted BOOT:
   `213b61315c94e37f942532c6fdbe5f6dcd158a851dbe9177258036265d2ec803`.

The final linked Q3 return boundary is:

```text
ffff80008221c9b4  bl declare_kernel_vmas
ffff80008221c9b8  ldr x19, [sp, #0x10]
ffff80008221c9bc  ldp x29, x30, [sp], #0x20
ffff80008221c9c0  ldr x30, [x18, #-0x8]!
ffff80008221c9c4  mov x9, #0x0
ffff80008221c9c8  ret

ffff800082214c18  bl paging_init
ffff800082214c1c  mov x9, x20
ffff800082214c20  spring-green marker begins
ffff800082214c4c  dsb sy
ffff800082214c50  wfe
ffff800082214c54  b ffff800082214c50

-- unreachable --

ffff800082214c58  bl earlyfb_console_init
```

This closes the accepted `paging_init()` phase. The next architectural boundary
is `earlyfb_console_init()`. It requires a new bounded phase plan/review before
physical work crosses that call. See
`docs/2026-09-26-paging-init-proof.md`.

The next accepted phase crossed the pre-slab `earlyfb_console_init()` boundary,
then had to be corrected after one deliberately bounded physical failure.

1. E1 removed only the spring-green hold, entered `earlyfb_console_init()`,
   let the unchanged selected `d2s_wdt_setup("early", true)` helper call
   return, repainted the already-proven bridge amber (`0xffffa000`), and held
   before the first `earlyfb_map` decision. Amber remained unchanged for at
   least three minutes. Exact promoted BOOT:
   `fcf1a6b751f49c5ef675cb883859feebacdb73ed03e059076815b47d129ba050`.
2. The original E2 then removed only the amber hold and attempted the existing
   full framebuffer `ioremap_wc(0xca000000, 0x10b3000)` before painting
   azure through the returned mapping. Physical observation showed the amber
   breadcrumb briefly, no stable azure, then reset/boot-loop. Exact failed
   BOOT is preserved as evidence:
   `bbfcac8fd57778e7cd489a84ddcb71966971d6e4fdee53e9150f8e39182f184e`.
3. Static diagnosis showed the failure was architectural rather than a mystery
   display fault. `generic_ioremap_prot()` returns NULL while
   `slab_is_available()` is false, and this call still runs inside
   `setup_arch()` before `mm_core_init()`. `kmem_cache_init()` makes slab
   available later inside `mm_core_init()`, and `vmalloc_init()` later sets
   `vmap_initialized=true`. Full ordinary ioremap therefore cannot succeed
   at this call site. Full early-remap is also impossible because the
   0x10b3000 framebuffer requires 4275 pages while one arm64 early-ioremap
   slot is limited to 65 pages.
4. Corrected E2D restarted from proven E1, preserved the amber breadcrumb,
   preserved the original `earlyfb_map` check, then added the bounded
   `!slab_is_available()` defer gate before the impossible full
   `ioremap_wc()` call. On this pre-`mm_core_init()` invocation the gate
   returns through the genuine `earlyfb_console_init()` epilogue/SCS restore
   and `ret`. `setup_arch()` then freshly rebinds its surviving ordinary
   bridge `x20 -> x9`, paints teal (`0xff00c0c0`), and holds immediately
   before `acpi_table_upgrade()`. Teal remained unchanged for at least three
   minutes. Exact promoted BOOT:
   `10eb19209719a38b677e01f5dc5afa89b14839312b2d8eae7d295f344f0068cc`.

The final linked E2D boundary is:

```text
ffff80008221548c  ldr x8, [x19, #0x2e8]
ffff800082215490  cbnz x8, ffff8000822154d0
ffff800082215494  bl slab_is_available
ffff800082215498  tbz w0, #0x0, ffff8000822154d0

-- full framebuffer __ioremap_prot only on slab-true path --

ffff8000822154d0  ldr x19, [sp, #0x10]
ffff8000822154d4  ldp x29, x30, [sp], #0x20
ffff8000822154d8  ldr x30, [x18, #-0x8]!
ffff8000822154f4  ret

ffff800082214c1c  bl earlyfb_console_init
ffff800082214c20  mov x9, x20
ffff800082214c28  teal marker begins
ffff800082214c50  dsb sy
ffff800082214c54  wfe
ffff800082214c58  b ffff800082214c54

-- unreachable --

ffff800082214c5c  bl acpi_table_upgrade
```

This closes the corrected pre-slab earlyfb phase. Full framebuffer
`ioremap_wc()`, clear, console registration and `CON_PRINTBUFFER` replay are
not proven here and are deliberately deferred to a separate future phase only
after complete `mm_core_init()` has returned.

The next immediate `setup_arch()` architectural boundary is
`acpi_table_upgrade()`. Crossing it requires a new bounded phase plan/review.
See `docs/2026-09-27-pre-slab-earlyfb-proof.md`.

The next accepted phase crossed the ACPI / DT-selection tranche in three
reviewed physical checkpoints while preserving the same ordinary setup_arch
bridge.

1. A1 removed only the teal hold, executed unchanged
   `acpi_table_upgrade()`, freshly rebound the surviving bridge and painted
   RED (technical marker `0xffff4040`) before `acpi_boot_table_init()`.
   RED remained unchanged for at least three minutes. Exact promoted BOOT:
   `e26a0fb30a652b51967bc978b32d0e3cb72f4911e4514852ed01ab78e2e55296`.
   The exact loader-passed Linux initrd is a 7,696-byte gzip with no preceding
   uncompressed newc archive and no ACPI override payload, so no early ACPI
   table override can be installed from this frozen input.
2. A2 removed only the RED hold, executed unchanged
   `acpi_boot_table_init()`, then inspected runtime `acpi_disabled`. The
   accepted exact bootargs had already been parsed inside arm64
   `setup_arch()`, contain no `acpi=` option, and use an explicit non-empty
   `earlycon=`. The exact d2s DTB has 26 root children with `aliases` first,
   making `dt_is_stub()` false. Unexpected `acpi_disabled == 0` was contained
   in an infinite RED-preserving hold before both DT unflatten and bootmem.
   The expected `acpi_disabled == 1` path painted BLUE (technical marker
   `0xff40c0ff`). BLUE remained unchanged for at least three minutes. Exact
   promoted BOOT:
   `cd180839ae4f0db71d3a250058a5e7347413385e26a21d3c78080fb9fe34d6a0`.
3. A3 removed only the BLUE hold, retained the unexpected-ACPI containment,
   entered the explicitly braced expected DT branch, executed unchanged
   `unflatten_device_tree()`, and only after that call returned freshly
   rebound the bridge and painted GREEN (technical marker `0xff80ff40`).
   GREEN remained unchanged for at least three minutes. Exact promoted BOOT:
   `8fa7d749e6aefc84f28465056488914111ffef38f27c683ce0fc17a1ecf13cd4`.

The final linked A3 boundary is:

```text
ffff800082214cd8  ldr w8, [x20, #0xeec]
ffff800082214cdc  cbz w8, ffff800082214d20

-- expected acpi_disabled == 1 DT branch --

ffff800082214ce0  bl unflatten_device_tree
ffff800082214ce4  mov x9, x19
ffff800082214cec  green marker begins
ffff800082214d14  dsb sy
ffff800082214d18  wfe
ffff800082214d1c  b ffff800082214d18

-- unreachable --

ffff800082214d20  bl bootmem_init
```

This closes the accepted ACPI / DT-selection phase. The next architectural
boundary is `bootmem_init()`. It begins the larger memory-init tranche including
PFN setup, early memory test, NUMA initialization, KVM reservation, DMA-limit
setup, CMA/crashkernel reservation and related memblock transitions.

Do not cross `bootmem_init()` without a new bounded phase plan/review. See
`docs/2026-09-27-acpi-dt-selection-proof.md`.

The next accepted phase crossed `bootmem_init()` in three reviewed physical
checkpoints.

1. M1 removed only the A3 GREEN hold and entered unchanged `bootmem_init()`.
   The exact bootargs contain no `memtest=`, so unchanged `early_memtest()`
   returned immediately. PFN globals were published, unchanged
   `arch_numa_init()` ran, and the exact DT with no `numa-node-id` forced the
   accepted dummy single-node fallback. Unexpected post-NUMA
   `numa_off == false` preserved GREEN and self-held. Expected
   `numa_off == true` freshly reloaded `note10_paging_bridge`, painted YELLOW
   (technical marker `0xffffff00`), and held before `kvm_hyp_reserve()`.
   YELLOW remained stable for at least three minutes. Exact promoted BOOT:
   `83104b850e38706cd03e36d7c4b3c2d535111f63e019a79489c0deff7999fd88`.
2. M2 removed only the YELLOW hold, preserved the NUMA containment, then
   executed unchanged `kvm_hyp_reserve()` and `dma_limits_init()`. Exact
   bootargs contain no `kvm-arm.mode=`, so protected-KVM reservation is not
   selected. With ACPI physically proven disabled, no compiled `dma-ranges`,
   and exact DRAM spanning `0x80000000..0xb00000000`, the expected runtime DMA
   limit is exactly `0x100000000`. Any mismatch preserved YELLOW and self-held.
   The exact 4 GiB path freshly reloaded the bridge, painted PURPLE (technical
   marker `0xffff00ff`), and held before `dma_contiguous_reserve()`. PURPLE
   remained stable for at least three minutes. Exact promoted BOOT:
   `653d937868e1abcac2c41b5b59133e569b42dc5ed5a3abb215da11441e22dead`.
3. M3 removed only the PURPLE hold and preserved both earlier containment
   checks. It executed unchanged `dma_contiguous_reserve()`,
   `arch_reserve_crashkernel()` and `memblock_dump_all()`, then completed the
   genuine `bootmem_init()` frame/callee-saved/SCS restore and `ret`.
   `setup_arch()` freshly rebound its surviving bridge `x19 -> x9` and painted
   WHITE (technical marker `0xffffffff`). Captain reported PASS under the
   accepted WHITE >=3-minute rule. Exact promoted BOOT:
   `b2799d78e4d90e670dd291922d458ea9827ccad86cd93df5d6416a7c591d18b4`.

The exact M3 linked return boundary is:

```text
ffff80008221bcf0  bl dma_contiguous_reserve
ffff80008221bcf4  bl arch_reserve_crashkernel
ffff80008221bcf8  bl memblock_dump_all
ffff80008221bcfc  ldp x20, x19, [sp, #0x20]
ffff80008221bd00  ldr x21, [sp, #0x10]
ffff80008221bd04  ldp x29, x30, [sp], #0x30
ffff80008221bd08  ldr x30, [x18, #-0x8]!
ffff80008221bd20  ret

ffff800082214d18  bl bootmem_init
ffff800082214d1c  mov x9, x19
ffff800082214d24  mov x11, #-1
ffff800082214d34  str x11, [x10], #8
ffff800082214d40  dsb sy
ffff800082214d44  wfe
ffff800082214d48  b ffff800082214d44

-- unreachable --

ffff800082214d4c  bl request_standard_resources
```

M3 deliberately does not claim successful generic CMA allocation. The exact
configuration selects a 32 MiB generic CMA attempt, but WHITE proves only that
the unchanged call returned. Exact bootargs contain no `crashkernel=`, so no
crashkernel reservation is requested, and no `memblock=debug`, so the memblock
dump remains disabled.

`CONFIG_KASAN` is not set, so there is no meaningful linked KASAN runtime
tranche between `bootmem_init()` return and `request_standard_resources()`.

This closes the accepted `bootmem_init()` phase. The next architectural boundary
is `request_standard_resources()`. It requires a new bounded phase plan/review
before physical work crosses that call. See
`docs/2026-09-27-bootmem-init-proof.md`.

The next phase crossed `request_standard_resources()` in two reviewed physical
checkpoints. The phase-plan gate itself used an explicit Captain process
exception because the phase-review prompt was accidentally sent back to the
worker. `reviews/resources-phase-review.md` is therefore self-review analysis
only and is not independent authority. The original bounded phase scope plus
the Captain exception remained the governing plan, and both frozen candidates
received normal independent candidate reviews before flashing.

1. R1 removed only the M3 WHITE hold and entered unchanged
   `request_standard_resources()`. It published kernel code/data physical
   bounds, let both fixed `insert_resource()` calls return, captured
   `memblock.memory.cnt`, calculated the exact `cnt * 64` backing size, and
   executed unchanged `memblock_alloc_or_panic()`. Only after the non-NULL
   allocation return was stored did it freshly load canonical
   `note10_paging_bridge` and paint ORANGE (technical marker `0xffff8000`).
   The `for_each_mem_region` loop remained unreachable. ORANGE remained stable
   for at least three minutes. Exact promoted BOOT:
   `fdc01a90fc95d24969370b6aeed33fca7ce6b1808c11cf60ab2f7e89877707d3`.
2. R2 removed only the ORANGE hold and executed the existing
   `for_each_mem_region` loop unchanged. Fast object normalization confirmed
   the loop through genuine function epilogue was 73/73 normalized lines
   identical to R1. Each reached region descriptor path completed and each
   reached per-region `insert_resource()` call returned. After loop
   termination, `request_standard_resources()` restored its compiler-managed
   callee-saved/frame/SCS state and executed genuine `ret`. Only after return
   did `setup_arch()` freshly rebind the surviving bridge `x19 -> x9` and
   paint PINK (technical marker `0xffff40c0`). PINK remained stable under the
   accepted >=3-minute rule. Exact promoted BOOT:
   `d9c62bb19c49932752fae10644f76f4166ed4ee8e9f2fc627e1690432ebe6194`.

The final linked R2 boundary is:

```text
ffff800082215100  str x9, [x8, #0x8]
ffff800082215104  bl insert_resource
ffff800082215108  ldr x8, [x20]
ffff80008221510c  ldr x9, [x20, #0x18]
ffff800082215110  add x22, x22, #0x18
ffff800082215114  add x23, x23, #0x40
ffff800082215118  madd x8, x8, x26, x9
ffff80008221511c  cmp x22, x8
ffff800082215120  b.lo ffff8000822150a4

ffff800082215124  ldp x20, x19, [sp, #0x50]
ffff800082215128  ldp x22, x21, [sp, #0x40]
ffff80008221512c  ldp x24, x23, [sp, #0x30]
ffff800082215130  ldp x26, x25, [sp, #0x20]
ffff800082215134  ldp x28, x27, [sp, #0x10]
ffff800082215138  ldp x29, x30, [sp], #0x60
ffff80008221513c  ldr x30, [x18, #-0x8]!
ffff800082215160  ret

ffff800082214d44  bl request_standard_resources
ffff800082214d48  mov x9, x19
ffff800082214d50  mov x11, #0x40c0
ffff800082214d54  movk x11, #0xffff, lsl #16
ffff800082214d58  movk x11, #0x40c0, lsl #32
ffff800082214d5c  movk x11, #0xffff, lsl #48
ffff800082214d6c  str x11, [x10], #8
ffff800082214d78  dsb sy
ffff800082214d7c  wfe
ffff800082214d80  b ffff800082214d7c

-- unreachable --

ffff800082214d84  bl early_ioremap_reset
```

The physical proof is intentionally narrow around `insert_resource()`.
Production ignores each return value, so ORANGE/PINK prove only that each
reached call returned and execution progressed. They do not prove successful
resource-tree insertion.

The backing allocation reserves memory through `memblock.reserved` and does not
change the `memblock.memory` iterator set/count used by the subsequent loop.

This closes `request_standard_resources()`. The source-level next call is
`early_ioremap_reset()`, but on this exact arm64 build it links to a bare
`ret`. arm64 defines `__early_set_fixmap` and `__late_set_fixmap` as the same
`__set_fixmap()` operation, and `__late_clear_fixmap` as the corresponding
`__set_fixmap(..., FIXMAP_PAGE_CLEAR)` form, so the `after_paging_init` state
is dead and the compiler removes the assignment entirely.

The next meaningful linked runtime boundary is therefore the already-proven
`acpi_disabled == 1` selection into `psci_dt_init()`. Crossing that PSCI DT
initialization requires a new bounded phase plan/review. See
`docs/2026-09-27-request-standard-resources-proof.md`.

The next accepted phase crossed PSCI DT initialization in two independently
reviewed physical checkpoints.

The exact Exynos9825 DT uses:

```text
psci {
    compatible = "arm,psci-0.2";
    method = "hvc";
};
```

1. P1 removed only the proven PINK hold. The source-level
   `early_ioremap_reset()` call executed, but exact object/final linked code is
   only a bare `ret` on this arm64 build, so no runtime state transition is
   claimed there. The already-proven `acpi_disabled == 1` lane entered
   `psci_dt_init()`, completed unchanged PSCI node discovery and availability
   checks, assigned the selected match data to typed `psci_initcall_t init_fn`,
   and runtime-contained any `init_fn != psci_0_2_init` by preserving PINK and
   self-holding. Exact `psci_0_2_init` selection freshly reloaded the canonical
   bridge and painted BLUE (technical marker `0xff0000ff`) before the indirect
   init call. BLUE remained stable for at least three minutes. Exact promoted
   BOOT:
   `d74989d89b72e6e29acd6130cb64d7d9557316f24a10e94da3e64d1cd74fbadc`.
2. P2 removed only the BLUE hold. The production `psci_0_2_init`,
   `get_set_conduit_method`, `psci_probe` and `__invoke_psci_fn_hvc` bodies
   remained unchanged. Exact DT method `"hvc"` selected the HVC conduit and the
   production PSCI probe path ran. The original `psci_dt_init()` tail from the
   indirect init call through `of_node_put()`, frame/callee-saved/SCS restore
   and genuine `ret` remained equivalent to P1 across 25 normalized lines.
   Back in `setup_arch()`, nonzero return preserved BLUE and self-held; only
   return 0 freshly rebound the surviving bridge `x19 -> x9` and painted GREEN
   (technical marker `0xff00ff00`). GREEN remained stable under the accepted
   >=3-minute rule. Exact promoted BOOT:
   `0ecf7d177732160dca0d8e74d20074678510b8259db2fedb62558e6e773a7766`.

The final linked P2 boundary is:

```text
ffff8000822a2198  mov x0, x19
ffff8000822a219c  blr x15
ffff8000822a21a0  mov w20, w0
ffff8000822a21ac  mov x0, x19
ffff8000822a21b0  bl of_node_put
ffff8000822a21c8  mov w0, w20
ffff8000822a21cc  ldp x20, x19, [sp, #0x20]
ffff8000822a21d0  ldp x29, x30, [sp, #0x10]
ffff8000822a21d8  ldr x30, [x18, #-0x8]!
ffff8000822a21f0  ret

ffff800082214d90  bl psci_dt_init
ffff800082214d94  cbz w0, ffff800082214da0
ffff800082214d98  wfe
ffff800082214d9c  b ffff800082214d98

ffff800082214da0  mov x9, x19
ffff800082214da8  mov x11, #0xff00
ffff800082214dac  movk x11, #0xff00, lsl #16
ffff800082214db0  movk x11, #0xff00, lsl #32
ffff800082214db4  movk x11, #0xff00, lsl #48
ffff800082214dc4  str x11, [x10], #8
ffff800082214dd0  dsb sy
ffff800082214dd4  wfe
ffff800082214dd8  b ffff800082214dd4

-- unreachable --

ffff800082214ddc  bl arm64_rsi_init
```

Stable GREEN proves successful completion of the exact selected production
PSCI DT-init path sufficiently for `psci_dt_init()` to return 0. It does not
prove an exact PSCI firmware version, that every optional PSCI feature is
supported, or that ignored-return operations succeeded.

This closes PSCI DT initialization. The next architectural boundary is
`arm64_rsi_init()`. Crossing it requires a new bounded phase plan/review. See
`docs/2026-09-27-psci-dt-init-proof.md`.

The next accepted phase crossed `arm64_rsi_init()` as one physically reviewed
bypass checkpoint.

The accepted state proof established:
- `SMCCC_CONDUIT_NONE = 0`;
- `SMCCC_CONDUIT_SMC = 1`;
- `SMCCC_CONDUIT_HVC = 2`;
- SMCCC starts at version 1.0 / conduit NONE;
- the only repository caller of `arm_smccc_version_init()` is PSCI;
- physically proven PSCI P2 selected HVC;
- therefore the legitimate post-PSCI getter result is NONE or HVC, never SMC.

Production `arm64_rsi_init()` begins:

```c
if (arm_smccc_1_1_get_conduit() != SMCCC_CONDUIT_SMC)
    return;
```

S1 removed only the GREEN hold and left both `arm64_rsi_init()` and the SMCCC
getter untouched. Fast object comparison confirmed 121 RSI instructions and 9
getter instructions were unchanged. The function entered, called the unchanged
getter, and on the accepted state took the non-SMC branch directly to its
genuine frame/callee-saved/SCS restore and `ret`.

Only after genuine return did `setup_arch()` freshly rebind its surviving
bridge `x19 -> x9` and paint CYAN (technical marker `0xff00ffff`). CYAN
passed the accepted >=3-minute physical rule. Exact promoted BOOT:

`aab7bbe7663f0659ce7fd025fb3d3f814f282f0174bda951a030baf267c488e3`

The final linked S1 boundary is:

```text
ffff80008221a5a0  bl arm_smccc_1_1_get_conduit
ffff80008221a5a4  cmp w0, #0x1
ffff80008221a5a8  b.ne ffff80008221a5f8

-- SMC-only RSI body, unreachable on the accepted proven state --

ffff80008221a5e8  bl __arm_smccc_smc

-- accepted non-SMC return path --

ffff80008221a5f8  mrs x8, SP_EL0
ffff80008221a60c  ldp x29, x30, [sp, #0x40]
ffff80008221a610  ldr x19, [sp, #0x50]
ffff80008221a614  add sp, sp, #0x60
ffff80008221a618  ldr x30, [x18, #-0x8]!
ffff80008221a650  ret

ffff800082214dd4  bl arm64_rsi_init
ffff800082214dd8  mov x9, x19
ffff800082214de0  mov x11, #0xffff
ffff800082214de4  movk x11, #0xff00, lsl #16
ffff800082214de8  movk x11, #0xffff, lsl #32
ffff800082214dec  movk x11, #0xff00, lsl #48
ffff800082214dfc  str x11, [x10], #8
ffff800082214e08  dsb sy
ffff800082214e0c  wfe
ffff800082214e10  b ffff800082214e0c

-- unreachable --

ffff800082214e14  mov w0, wzr
ffff800082214e18  bl init_cpu_ops
```

Stable CYAN proves the unchanged RSI function entered and genuinely returned on
the accepted non-SMC path, so no RSI SMC/version/config/memory path executed
and `rsi_present` was not enabled by `arm64_rsi_init()` on this path. It does
not identify the getter result as specifically NONE or HVC and does not make a
global hardware-support claim.

The old PINK source comment was also corrected as reviewer-approved comment-only
hygiene. An otherwise identical control build retaining the old comment
produced identical normalized executable disassembly including relocations.

This closes the arm64 RSI bypass phase. The next meaningful linked boundary is
the actual `bl init_cpu_ops` with argument 0, i.e. `init_bootcpu_ops()`. The
preceding compiler argument setup alone does not cross that boundary. Crossing
`init_cpu_ops(0)` requires a new bounded phase plan/review. See
`docs/2026-09-27-arm64-rsi-bypass-proof.md`.

The next accepted phase crossed only boot CPU operations selection.

The source wrapper is:

```c
static inline void __init init_bootcpu_ops(void)
{
    init_cpu_ops(0);
}
```

The exact frozen DTB CPU0 node contains:

```text
cpu@0 {
    device_type = "cpu";
    compatible = "arm,cortex-a55";
    reg = <0x00 0x00>;
    enable-method = "psci";
};
```

The DT-supported operations table remains:

```c
&smp_spin_table_ops,  // "spin-table"
&cpu_psci_ops,        // "psci"
NULL
```

B1 removed only the CYAN hold and executed the original
`init_bootcpu_ops() / init_cpu_ops(0)` call. Production
`init_cpu_ops()`, `cpu_read_enable_method()`, `cpu_get_ops()` and
`get_cpu_ops()` remained unchanged.

`cpu_ops[]` is static zero-initialized and has one writer. Both production
failure exits leave/store NULL. Thus the post-return pure
`get_cpu_ops(0) != NULL` check distinguishes successful selection from both
failure paths.

Combined with the exact frozen CPU0 `"psci"` property and unchanged lookup
table, that non-NULL result identifies `cpu_ops[0] == &cpu_psci_ops`.

The final linked B1 boundary is:

```text
ffff800082214e0c  mov w0, wzr
ffff800082214e10  bl init_cpu_ops

ffff800082214e14  mov w0, wzr
ffff800082214e18  bl get_cpu_ops
ffff800082214e1c  cbnz x0, ffff800082214e28

-- NULL preserves CYAN --

ffff800082214e20  wfe
ffff800082214e24  b ffff800082214e20

-- non-NULL only --

ffff800082214e28  mov x9, x19
ffff800082214e30  mov x11, #0x0
ffff800082214e34  movk x11, #0xffff, lsl #16
ffff800082214e38  movk x11, #0xffff, lsl #48
ffff800082214e48  str x11, [x10], #8
ffff800082214e54  dsb sy
ffff800082214e58  wfe
ffff800082214e5c  b ffff800082214e58

-- unreachable --

ffff800082214e60  bl smp_init_cpus
```

Captain observed bright RED upright for at least three minutes. A side-angle
view briefly appeared orange; because the upright direct view was stable bright
RED, this was recorded as a panel/viewing-angle effect rather than a marker
mismatch. Exact promoted BOOT:

`6abd2f0e776fa89f5023a5c5072261122263efa9339b098a91d25f0f5eacd1ef`

Stable RED proves:
- original `init_cpu_ops(0)` executed and returned;
- `get_cpu_ops(0)` returned non-NULL;
- exact CPU0 DT plus unchanged selector logic establishes
  `cpu_ops[0] == &cpu_psci_ops`;
- boot CPU operations selection completed successfully;
- no `cpu_psci_ops` callback ran before RED;
- no kernel PSCI `CPU_ON` occurred before RED;
- `smp_init_cpus()` did not execute.

This closes boot CPU operations selection. The next architectural boundary is
`smp_init_cpus()`. Crossing it requires a new bounded phase plan/review. See
`docs/2026-09-27-bootcpu-ops-selection-proof.md`.

The next accepted phase crossed `smp_init_cpus()` in one reviewed physical
checkpoint.

Exact frozen CPU topology:

```text
CPU0  0x000  psci
CPU1  0x001  psci
CPU2  0x002  psci
CPU3  0x003  psci
CPU4  0x004  psci
CPU5  0x005  psci
CPU6  0x100  psci
CPU7  0x101  psci
```

Exact bootargs contain no `nosmp`, `maxcpus=` or `nr_cpus=`.

The accepted starting-state proof also established:
- `CONFIG_INIT_ALL_POSSIBLE` absent;
- possible mask initially zero;
- only CPU0 marked possible before `setup_arch()`;
- CPUs 1-7 initially not possible;
- secondary logical maps initially `INVALID_HWID`;
- secondary CPU ops initially NULL.

S2 removed only the RED hold and ran original `smp_init_cpus()` unchanged.
After genuine return, it required the exact map vector, PSCI ops-pointer equality
for CPUs 1-7, and `cpu_possible()` for every secondary. Any failed check
preserved RED.

Final linked success boundary:

```text
ffff800082214e60  bl smp_init_cpus

# exact topology and per-secondary postconditions
...
ffff800082214f14  wfe
ffff800082214f18  b ffff800082214f14

# complete success only
ffff800082214f1c  mov x9, x19
ffff800082214f24  mov x11, #0xff00
ffff800082214f28  movk x11, #0xffff, lsl #16
ffff800082214f2c  movk x11, #0xff00, lsl #32
ffff800082214f30  movk x11, #0xffff, lsl #48
ffff800082214f40  str x11, [x10], #8
ffff800082214f4c  dsb sy
ffff800082214f50  wfe
ffff800082214f54  b ffff800082214f50

-- unreachable --

ffff800082214f58  bl smp_build_mpidr_hash
```

Captain reported YELLOW PASS under the accepted >=3-minute rule. Exact promoted
BOOT:

`5242447cfaa9fcda25358ac5aa08eabbda2d3fb59aef61195fcc8955348ede84`

Stable YELLOW proves successful PSCI `cpu_init` and possible-state publication
for CPUs 1-7, but not present/online state and not secondary boot. No
`cpu_prepare`, `cpu_boot` or kernel PSCI `CPU_ON` occurred.

This closes `smp_init_cpus()`. The next architectural boundary is
`smp_build_mpidr_hash()` and requires a new bounded phase plan/review. See
`docs/2026-09-27-smp-init-cpus-proof.md`.
