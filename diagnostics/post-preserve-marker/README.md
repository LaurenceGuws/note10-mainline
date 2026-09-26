# Post-preserve_boot_args split-stripe diagnostic

This is the next offline candidate after the 2026-09-26 physical proof that
Linux reaches `primary_entry` and can hold there stably for at least three
minutes.

The loader side is unchanged from the accepted copy-to-primary_entry tranche.
It still prints `COPY_DONE / JUMP_READY` only after the Image and initramfs
copies, records the handoff state, and then uses the unchanged final `br x4`.

## Kernel delta

Parent marker commit:

`f11b2430102d78735ff9761fb09c2bc9aaf34466`

Post-preserve marker commit:

`efb241e6c40183263002f9e4839864a5864b7c31`

Export:

- `kernel-post-preserve-marker.patch`
- SHA-256:
  `d31f5b8535d245b38898bc6c1dc7813930bae34b697840ea6643f25625a99356`
- stable patch-id: `d9a8dfe2825361504d2d496d98d1dae249a55ec2`

The delta changes only `arch/arm64/kernel/head.S`:

1. keep the proven rows 512..639 magenta marker and cache clean at the first
   body instructions of `primary_entry`;
2. remove that marker's deliberate hold;
3. execute the original `record_mmu_state` and `preserve_boot_args` unchanged;
4. immediately after `preserve_boot_args` returns, before `early_init_stack`
   or any idmap work, overwrite only framebuffer rows 576..639 cyan;
5. clean exactly that cyan range to PoC, execute `dsb sy; isb`, then
   deliberately hold in `wfe`.

Both marker paths use only `x9` through `x14`. In particular, the second marker
does not touch `x19`, which carries the MMU-at-entry result, or `x21`, which
carries the preserved FDT pointer.

The cyan range is:

`0xca32a000..0xca384000`

It is exactly 64 rows at the established 5760-byte framebuffer stride and is
wholly inside the reserved framebuffer.

Linked disassembly confirms the order is:

- magenta marker + clean/barrier;
- `bl record_mmu_state`;
- `bl preserve_boot_args`;
- cyan lower-half marker + clean/barrier;
- `wfe` hold;
- only after the unreachable hold, the original `early_init_stack` setup.

Source `git diff --check` passes and strict checkpatch reports 0 errors,
0 warnings and 0 checks.

## Frozen build

Kernel build uses the same Android clang 21 `r563880c` and byte-identical
config as the physically proven entry-marker candidate:

- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`
- Image SHA-256:
  `8a76b2e8108fdf6a5bcb51968c4b31990f0d63be5b150ccab8e060d5af012bbc`
- Image size: `44,247,552` bytes
- Image header remains `text_offset=0`, `image_size=0x2b10000`, flags `0xa`,
  ARM64 magic
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`

The loader source remains the reviewed commit:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Two independent builds embedding this new Image produced the same
44,838,912-byte uniLoader:

`a31761613b6f4512976ab5b180f0538b3922560dc167d23415da48b544a60d60`

The payload offsets are unchanged:

- Image: `0xc000`
- DTB: `0x2a3f000`
- initramfs: `0x2a44000`

## Frozen BOOT envelope

Rollback/base BOOT:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Post-preserve marker candidate:

`138a314e5e3108f58d1b432cadd63e34c48cbad00e1b7fb8b26e5746cae0fd09`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/post-preserve-marker-a/candidate.img`

The BOOT package was independently reproduced byte-for-byte. It preserves the
48,424,984-byte kernel slot, 3,586,072 bytes of zero padding, the exact Android
ramdisk region, every post-ramdisk byte including the AVB/VBMeta tail, and the
same checksum/id-only header drift. `avbtool info_image` is identical to the
rollback image, and both images reproduce the same accepted stale descriptor
verify result.

After freezing this candidate, the phone was read-only rechecked and still ran
the exact `1a78...` BOOT with Android `sys.boot_completed=1`. This candidate
has **not** been flashed or otherwise applied to the phone.

## Future physical interpretation

When Captain is available for the attended BOOT-only test:

- `JUMP_READY` but no magenta: regression at the already-proven entry boundary;
- full magenta with no cyan lower half: failure/hang inside
  `record_mmu_state` + `preserve_boot_args`; split that small boundary next;
- magenta upper half + cyan lower half stable: both routines, including the
  observed MMU-off `preserve_boot_args` cache invalidation path, are proven;
- split marker then reset: investigate only the just-crossed
  record/preserve/cache-maintenance boundary before advancing.

No UFS, DTB, initramfs, watchdog, clock, power, display setup or later kernel
subsystem change belongs in this tranche.
