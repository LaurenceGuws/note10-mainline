# Copy-to-primary_entry diagnostic

This directory freezes the smallest second physical diagnostic earned by the
2026-09-26 first mainline BOOT. It changes no UFS, DTB, initramfs, rootfs or
later subsystem behavior.

## Question

The first candidate displayed uniLoader `Booting kernel...` and then reset.
That string is emitted before `arch_load_kernel()` copies the Image and
initramfs, so the experiment did not prove that the copies completed or that
the final arm64 branch executed.

The second candidate places one marker on each side of that boundary.

### Loader side

uniLoader commit:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

The loader performs the existing Image and initramfs copies, then immediately
prints:

`COPY_DONE / JUMP_READY`

It also records the branch target, DTB pointer (`x0`), `CurrentEL`, `DAIF`, and
the `SCTLR_ELx` matching the current exception level before calling the
unchanged `load_kernel_and_jump()` path.

Export:

- `uniloader-jump-ready.patch`
- SHA-256:
  `4f2d1aef42dee9b11241406192ef40237d0ce1b64d6c901e0712b8386ef3dfeb`
- stable patch-id: `b7d892c59ce165233f24ffd5956995a3a6da25e6`

The compiled object proves the order is Image copy, initramfs copy, state
capture/marker prints, then `load_kernel_and_jump()`.

### Kernel side

Linux commit:

`f11b2430102d78735ff9761fb09c2bc9aaf34466`

The first body instructions at arm64 `primary_entry` paint framebuffer rows
512 through 639 at physical `0xca000000` with a solid magenta stripe. The
marker then cleans the touched range to PoC with `dc cvac`, executes `dsb sy`
and `isb`, and intentionally holds in `wfe` forever. It does not call C, use a
stack, alter `x0`, or enter normal kernel initialization.

The stripe range is `0xca2d0000..0xca384000`, wholly inside the d2s reserved
framebuffer. Placing it below the top edge also avoids depending on the cracked
top of the physical display.

Export:

- `kernel-primary-entry-marker.patch`
- SHA-256:
  `769c8ba87a23632a3016def2855774dec707b93c897fa18da75218510d072e52`
- stable patch-id: `3e5858c107fe472a53831092dbb59c5b59f7423c`

The source delta passes `git diff --check` and strict kernel checkpatch with
zero errors, warnings or checks. Disassembly confirms the marker begins at
linked `primary_entry` and the deliberate hold precedes the original
`record_mmu_state` call.

## Frozen build

Kernel inputs remain identical to the first candidate except for the one
`head.S` marker commit:

- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`
- Android clang: 21.0.0 `r563880c`
- Image SHA-256:
  `0e176d174b423e940680505526fc029fd8987185dae3d3cfedb790bf48214533`
- Image size: `44,247,552` bytes, unchanged
- Image header: `text_offset=0`, `image_size=0x2b10000`, flags `0xa`, arm64
  magic unchanged
- d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`,
  byte-identical to the first candidate
- initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`,
  unchanged

Two independent uniLoader builds from the exact loader marker commit, with the
same pinned metadata and the diagnostic Image above, produced the identical
44,838,912-byte binary:

`c814b452a4803b59f36297856375dc1a1ca855b6779cce57565e5f58bc4d8319`

The embedded payload offsets remain:

- Image: `0xc000`
- DTB: `0x2a3f000`
- initramfs: `0x2a44000`

## Frozen BOOT envelope

Physical rollback/base BOOT:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Diagnostic BOOT candidate:

`9b8f39426860c64b28cc676ea52489ea5bed552cf6f5c7d6d418b936d9e91477`

Workstream candidate:

`~/.local/state/workstreams/note10-mainline/boot-candidate/copy-primary-marker-a/candidate.img`

The complete BOOT packaging was independently repeated and produced the same
candidate bytes. The loader remains zero-padded to the original 48,424,984-byte
kernel field, the Android ramdisk and all post-ramdisk bytes remain identical
to the physical rollback image, and base/candidate `avbtool info_image` output
is identical. Both preserve the already-accepted stale hash-descriptor
verification behavior: rc 1 while the footer and `NONE` vbmeta structure
verify.

## Physical interpretation

The next attended BOOT has only four useful outcomes:

- no `JUMP_READY`: failure remains in the copy/pre-branch loader path;
- `JUMP_READY`, no magenta stripe: investigate the branch/arm64 entry contract;
- magenta stripe remains stable: `primary_entry` executed and no immediate
  reset source kills the deliberate hold; move the marker later next;
- magenta stripe appears then the device resets: investigate watchdog/reset
  ownership before moving deeper into Linux.

No UFS result is expected from this intentionally held diagnostic kernel.

## Physical result

The reviewed candidate was tested on 2026-09-26 and produced the strongest
outcome: both loader and kernel markers were visible, and the magenta
`primary_entry` stripe remained unchanged for at least three minutes.

Captain transcribed the loader-side handoff receipt as:

```text
target=0x0000000090000000
x0=0x000000008ba476e0
CurrentEL=EL1
DAIF=0x00000000000002c0
SCTLR=0x0000000030c5083a
```

Relevant decoded entry state:

- `SCTLR_EL1.M=0`: MMU off;
- `SCTLR_EL1.C=0`: data cache off;
- `SCTLR_EL1.I=0`: instruction cache off;
- `SCTLR_EL1.EE=0`: little-endian;
- `DAIF.D=1`, `I=1`, `F=1`, `A=0`.

This proves the Image and initramfs copies completed, the final `br x4`
executed, and the first instructions of Linux `primary_entry` ran. The stable
deliberate hold also proves there is no unavoidable immediate reset at the
entry point under this inherited state.

After observation, the exact rollback BOOT
`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`
was restored to `BOOT` only and re-hashed on-device. Android subsequently
reached `sys.boot_completed=1` on the expected 4.14 kernel.

The next diagnostic should therefore move the deliberate marker/hold one
bounded stage deeper into the original arm64 entry path rather than changing
the loader, UFS, DTB, initramfs or watchdog state.
