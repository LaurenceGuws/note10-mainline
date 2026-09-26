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
