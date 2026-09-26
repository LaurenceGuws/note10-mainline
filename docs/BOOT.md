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
