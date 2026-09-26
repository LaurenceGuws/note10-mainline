# __primary_switch / __enable_mmu transient-idmap diagnostic

This is the first Note10 mainline diagnostic that crosses the initial MMU
enable boundary. The previous physical checkpoint proved `init_kernel_el` and
`__cpu_setup` both return and held stably immediately before
`__primary_switch`.

Accepted parent diagnostic commit:

`60be558145979e17338f36e39dcc5d7b76dc8ac3`

New kernel diagnostic commit:

`a0d33b3e53965104a18f487d5707b0e69ea00f1d`

The reviewed JUMP_READY loader source remains unchanged at:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

## Why the evidence sink changes here

All earlier framebuffer breadcrumbs used physical `0xca...` accesses while the
MMU was off. The d2s framebuffer reservation is `no-map`, and the normal
initial identity map covers only the kernel image/data plus FDT, so raw
framebuffer writes are not a valid post-enable proof by default.

This diagnostic therefore adds one transient TTBR0 identity mapping only inside
`create_init_idmap()`:

`0xca200000..0xca400000` VA == PA

The mapping uses `PROT_NORMAL_NC` with the same `clrmask` handling as the
existing init-idmap mappings. It is writable, PXN/UXN, Normal-NC. The d2s DT,
its `no-map` framebuffer reservation, normal kernel mappings and
`__pi_early_map_kernel` remain unchanged.

The range is exactly one 2 MiB-aligned PMD block and contains all existing
breadcrumb rows plus the new rows 672..703.

## Initial-idmap page budget

The final linked Image remains loaded at physical `0x90000000` with:

- runtime `_stext`: `0x90010000`;
- runtime `__initdata_begin`: `0x92350000`;
- runtime `_end`: `0x92b10000`.

Replaying the kernel's actual `map_range()` allocation rules against those
linked ranges gives:

- existing init idmap: **6 pages**;
- added framebuffer block: **1 PMD-table page** at the new 1 GiB PUD slot;
- diagnostic init idmap: **7 pages**;
- linked reservation: **8 pages / 0x8000**;
- spare pages: **1**.

The linked reservation remains:

- `__pi_init_idmap_pg_dir = ffff800082350000`;
- `__pi_init_idmap_pg_end = ffff800082358000`.

`INIT_IDMAP_DIR_SIZE` is unchanged. Because the new `map_range()` advances the
same returned `ptep`, the existing MMU-off page-table `dcache_inval_poc`
automatically includes the newly allocated PMD-table page before MMU enable.

## New visible band

All physically proven breadcrumb history through rows 640..671 is retained.
The previous white hold is removed.

This tranche uses only rows 672..703:

- exact range: `0xca3b1000..0xca3de000`;
- exact length: `0x2d000`.

Every new marker uses only `x9..x14` and the already-proven raw cache-line
clean sequence (`dc cvac`, `dsb sy`, `isb`). Live `x0`, `x20`, `x21`, `sp`,
`x29`, and `x30` are preserved wherever relevant.

### Stage 0: enter __primary_switch

At the first body instructions of `__primary_switch`, before its page-table
register setup, rows 672..703 are painted blue (`ARGB8888 0xff0000ff`).

There is no hold. Blue proves execution branched from the previously proven
white boundary into `__primary_switch`.

### Stage 1: immediately before MMU enable

Inside `__enable_mmu`, the original granule checks, `phys_to_ttbr`, TTBR0
write and TTBR1 load run unchanged. Immediately after `load_ttbr1` and before
`set_sctlr_el1 x0`, rows 672..703 are overwritten yellow
(`ARGB8888 0xffffff00`).

This preserves live `x0`, the future SCTLR_EL1-on value.

### Stage 2: MMU enabled inside __enable_mmu

Immediately after the complete `set_sctlr_el1 x0` macro, including its:

```text
msr sctlr_el1
isb
ic iallu
dsb nsh
isb
```

and before `ret`, rows 672..703 are overwritten red
(`ARGB8888 0xffff0000`) through the new TTBR0 identity mapping.

Red is the first externally visible breadcrumb executed with the MMU enabled.

### Stage 3: __enable_mmu returned

Immediately after `bl __enable_mmu` returns in `__primary_switch`, before the
early stack reset and before `__pi_early_map_kernel`, rows 672..703 are
overwritten orange (`ARGB8888 0xffff8000`). The marker is made visible and the
CPU deliberately holds in `wfe`.

`__pi_early_map_kernel`, relocation and `__primary_switched` are unreachable in
this candidate.

## Frozen source and build gates

- patch: `kernel-primary-switch-enable-mmu-marker.patch`;
- patch SHA-256:
  `c88418855a4fda6b6e13fb550491ab0c7e4e7251768759eea0ed74da55d81a94`;
- stable patch-id: `11fd30ea554841a679a89bfd1030aaf65fc93c18`;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `d2e520e1e3c4b3c08253de58a5910118cd8880145820b151d67822b5708b9fef`;
- Image size: `44,247,552` bytes;
- arm64 Image header unchanged: `text_offset=0`, `image_size=0x2b10000`,
  flags `0xa`, ARM64 magic;
- linked `primary_entry`: `ffff8000822040a0`;
- linked `__enable_mmu`: `ffff8000822047d8`;
- linked `__primary_switch`: `ffff800082204918`;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

Compiled and linked disassembly confirms exactly:

1. blue at `__primary_switch` entry;
2. original TTBR setup;
3. yellow before `set_sctlr_el1`;
4. the full original MMU-enable macro;
5. red after that macro and before `ret`;
6. return to `__primary_switch`;
7. orange after return;
8. deliberate hold;
9. only after the unreachable hold, early stack reset and
   `__pi_early_map_kernel`.

## Frozen loader and BOOT

Two independent builds of the unchanged JUMP_READY loader source embedding the
new Image are byte-identical:

`23943495cf6b4cd7105071b20b4f15b0861ce6ce073662cb6ab639eee7aa26fd`

The loader remains 44,838,912 bytes with exact embedded offsets:

- Image: `0xc000`;
- DTB: `0x2a3f000`;
- initramfs: `0x2a44000`.

Rollback/base BOOT remains:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The frozen candidate is:

`fbb1b88599eb8466afcbab4a42dfbdbae6d9299acebf2240f19558c1d8fdf33f`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/primary-switch-enable-mmu-a/candidate.img`

The complete BOOT package reproduced byte-for-byte in a second run. The
48,424,984-byte kernel slot, 3,586,072 bytes of zero padding, Android ramdisk,
all post-ramdisk bytes, checksum/id-only header drift and base/candidate
`avbtool info_image` parity remain unchanged. Both base and candidate reproduce
the accepted stale hash-descriptor rc=1 while the footer and `NONE` vbmeta
structure verify.

## Intended physical interpretation

- any earlier breadcrumb missing: regression before this new boundary;
- prior white present, no blue: `__primary_switch` was not entered;
- blue, no yellow: pre-enable granule/TTBR setup did not reach the final
  pre-SCTLR point;
- yellow, no red: failure lies in the MMU transition or immediate post-enable
  I-cache/barrier sequence;
- red, no orange: MMU enabled and the complete `set_sctlr_el1` macro executed,
  but `ret` / return-to-caller / immediate post-return execution did not
  complete;
- orange stable: `__enable_mmu` returned successfully with the MMU enabled;
  next earned boundary is `__pi_early_map_kernel` / relocation;
- reset after any new color remains scoped to the interval after that color and
  before the next one.

No UFS, DTB-content, initramfs, clock, power, normal framebuffer policy,
watchdog, load-address, `__pi_early_map_kernel`, relocation,
`__primary_switched`, or later-subsystem change belongs in this candidate.
