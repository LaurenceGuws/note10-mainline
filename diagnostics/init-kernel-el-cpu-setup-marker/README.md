# init_kernel_el / __cpu_setup breadcrumb diagnostic

This is the next bounded arm64-entry candidate after physical proof that early
stack setup, `__pi_create_init_idmap`, the expected `x19=0` path and the
MMU-off page-table `dcache_inval_poc` all complete on d2s.

The accepted parent diagnostic commit is:

`75cda79684ec1f21f26158f65fad76f0de6bd308`

The new kernel commit is:

`60be558145979e17338f36e39dcc5d7b76dc8ac3`

The reviewed JUMP_READY loader source remains unchanged at:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

## Marker sequence

All physically proven framebuffer history remains unchanged through the green
idmap/invalidation breadcrumb. The green deliberate hold is removed so the
original common path continues into:

```text
mov x0, x19
bl  init_kernel_el
mov x20, x0
```

Immediately after `mov x20, x0`, before `bl __cpu_setup`, rows 640..671 are
painted red (`ARGB8888 0xffff0000`) over exact range:

`0xca384000..0xca3b1000`

The exact `0x2d000` range is cleaned to PoC with the proven raw cache-line size
plus `dc cvac`, `dsb sy`, `isb` sequence. The marker uses only `x9..x14`, so
`x0`, `x19`, `x20`, `x21`, `sp`, and `x29` remain untouched. There is no hold
at this stage.

The original `bl __cpu_setup` then executes unchanged.

Immediately after `__cpu_setup` returns, before `b __primary_switch`, the same
rows 640..671 are overwritten white (`ARGB8888 0xffffffff`), cleaned to PoC,
and the CPU deliberately holds in `wfe`. This second marker also uses only
`x9..x14`, preserving live `x0`, which contains the future
`INIT_SCTLR_EL1_MMU_ON` value that the unreachable original path would pass to
`__enable_mmu`.

Therefore `__primary_switch` and MMU enable remain unreachable in this
candidate.

## Frozen source and build gates

- patch: `kernel-init-kernel-el-cpu-setup-marker.patch`
- patch SHA-256:
  `a661998c6d02d410cb9ecdfb8f53e163360d262e5d64eab1531c4f68d42ed0e4`
- stable patch-id: `ee8104843f66a8e62218f70f86a25cab8872ffe6`
- source `git diff --check`: pass
- strict checkpatch: 0 errors, 0 warnings, 0 checks
- Android clang: 21.0.0 `r563880c`
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`
- Image SHA-256:
  `a59e15c117e792c49de93654a904209a4810e1be378f403224cb0c817d12ab72`
- Image size: `44,247,552` bytes
- Image header remains `text_offset=0`, `image_size=0x2b10000`, flags `0xa`,
  ARM64 magic
- linked `primary_entry` remains `ffff8000822040a0`
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`

Compiled and linked disassembly confirms this exact order:

1. all prior proven marker/history paths;
2. `bl init_kernel_el`;
3. `mov x20, x0`;
4. red marker + clean/barrier;
5. `bl __cpu_setup`;
6. white marker + clean/barrier;
7. deliberate `wfe` hold;
8. only after the unreachable hold, `b __primary_switch`.

## Frozen loader and BOOT

Two independent loader builds embedding the new Image are byte-identical:

`1b4791acd16940b8078279a704b705bd790a60756301a3f18ee681276cdfe050`

The loader remains 44,838,912 bytes and payload offsets remain exact:

- Image: `0xc000`
- DTB: `0x2a3f000`
- initramfs: `0x2a44000`

Rollback/base BOOT remains:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The frozen candidate is:

`aca13ad11e80e0c791f4200400b30bf1dc4583b0a1f4f52e5cbaa4717341b530`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/init-kernel-el-cpu-setup-a/candidate.img`

The complete BOOT package reproduced byte-for-byte in a second run. It retains
the 48,424,984-byte kernel slot, 3,586,072 bytes of zero padding, exact Android
ramdisk, exact post-ramdisk/AVB tail, checksum/id-only header drift and
base/candidate `avbtool info_image` parity. Both base and candidate reproduce
the already-accepted stale hash-descriptor rc=1 while the footer and `NONE`
vbmeta structure verify.

## Intended physical interpretation

- missing prior green history: regression at an already-proven boundary;
- prior green remains, but no red/white: `init_kernel_el` did not return to the
  post-`mov x20, x0` point;
- red rows 640..671 but no white: `init_kernel_el` returned and its boot mode
  was preserved in `x20`, but `__cpu_setup` did not return;
- white rows 640..671 stable: both `init_kernel_el` and `__cpu_setup` returned,
  while `__primary_switch` / `__enable_mmu` remain unreachable;
- reset after red or white remains scoped to this just-crossed tranche.

No UFS, DTB-content, initramfs, clock, power, display, watchdog, page-table,
`__primary_switch`, `__enable_mmu`, or later-kernel change belongs here.
