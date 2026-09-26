# init-idmap / MMU-off invalidation breadcrumb diagnostic

This is the next bounded arm64-entry candidate after the physical proof at
`22cca55` that `record_mmu_state` and `preserve_boot_args` complete on d2s and
that the observed MMU-off `preserve_boot_args` cache invalidation returns.

The loader remains the already-proven JUMP_READY source at:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

The kernel marker parent is the corrected accepted post-preserve commit:

`c70cfcf29ab35e30ddebfa455ce926355201101a`

The new diagnostic commit is:

`75cda79684ec1f21f26158f65fad76f0de6bd308`

## Marker sequence

The physically proven marker history is preserved:

- rows 512..575 remain magenta after first `primary_entry` execution;
- rows 576..607 remain cyan after `record_mmu_state` +
  `preserve_boot_args` return.

The current post-preserve hold is removed. The original early stack setup and
`__pi_create_init_idmap` call then run unchanged.

Immediately after `__pi_create_init_idmap` returns, before `cbnz x19, 0f`, the
diagnostic overwrites rows 608..639 yellow (`ARGB8888 0xffffff00`):

`0xca357000..0xca384000`

That exact range is cleaned to PoC with the already-proven raw cache-line size
plus `dc cvac`, `dsb sy`, `isb` sequence. There is no hold here. The breadcrumb
uses only `x9..x14`, leaving live `x0` intact as the returned end of the used
init-idmap page-table region, and leaving `x19`, `x21`, `sp`, and `x29`
unchanged.

The original observed `x19=0` path then runs unchanged through:

```text
cbnz x19, 0f
dmb sy
mov x1, x0
adrp x0, __pi_init_idmap_pg_dir
adr_l x2, dcache_inval_poc
blr x2
```

Immediately after that `blr x2` returns, before the following `b 1f`, the same
rows 608..639 are overwritten green (`ARGB8888 0xff00ff00`), cleaned to PoC,
and the CPU deliberately holds in `wfe`.

The `x19!=0` path and common label `1` are not instrumented. Therefore a green
marker specifically proves the physically expected MMU-off page-table
`dcache_inval_poc` call returned. `init_kernel_el` remains unreachable in this
candidate.

## Frozen source and build gates

- patch: `kernel-idmap-breadcrumb-marker.patch`
- patch SHA-256:
  `9b993f0011c9ee3cdd450c39821765a1d283f5f80060bc7b440ea9b1d4a9992d`
- stable patch-id: `3e2787ea57e0b1b164debfff34309a5b44ca38af`
- source `git diff --check`: pass
- strict checkpatch: 0 errors, 0 warnings, 0 checks
- Android clang: 21.0.0 `r563880c`
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`
- Image SHA-256:
  `417d5751f1bbe58d7d8a654464600b99e9c8d1e164131498c99c900da68e79ef`
- Image size: `44,247,552` bytes
- Image header: `text_offset=0`, `image_size=0x2b10000`, flags `0xa`, ARM64
  magic unchanged
- d2s DTB SHA-256, unchanged:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`
- initramfs SHA-256, unchanged:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`

Linked disassembly confirms the yellow breadcrumb begins only after
`__pi_create_init_idmap` returns, `cbnz x19` follows the yellow clean/barrier,
the original MMU-off `blr x2` remains intact, green begins only after that call
returns, and the deliberate hold precedes the common `init_kernel_el` path.

## Frozen loader and BOOT

Two independent builds of the unchanged JUMP_READY loader source embedding the
new Image produced the same 44,838,912-byte binary:

`9a19f42c03094868f0b427edf2bfacf933223b38a35b76784e187039c9530aee`

Payload offsets remain:

- Image: `0xc000`
- DTB: `0x2a3f000`
- initramfs: `0x2a44000`

Rollback/base BOOT remains:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The new BOOT candidate is:

`8da260e154b65be965fb44b929ec5eff5f8c4f4eb4e01e8c41a31faf1d0ce728`

Workstream candidate path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/idmap-breadcrumb-a/candidate.img`

The complete BOOT packaging was independently repeated and reproduced the
candidate byte-for-byte. The original 48,424,984-byte kernel slot is retained,
the 44,838,912-byte loader is followed by 3,586,072 zero bytes, the Android
ramdisk and every post-ramdisk byte remain identical to rollback, and header
drift remains checksum/id only. `avbtool info_image` is identical base versus
candidate; both preserve the accepted stale hash-descriptor rc=1 while the
footer and `NONE` vbmeta structure verify.

## Intended physical interpretation

- no JUMP_READY or no magenta: regression at an already-proven boundary;
- magenta + cyan only: early stack / `__pi_create_init_idmap` did not return;
- yellow lower quarter: stack + init-idmap creation completed, but the observed
  MMU-off page-table invalidation did not return;
- green lower quarter stable: early stack, `__pi_create_init_idmap`, the
  `x19=0` branch and page-table `dcache_inval_poc` are all proven; next move is
  the `init_kernel_el` / `__cpu_setup` boundary;
- reset after yellow or green remains scoped to this tranche and is not a
  generic watchdog conclusion.

No UFS, DTB-content, initramfs, watchdog, clock, power, display-setup,
`init_kernel_el`, `__cpu_setup`, `__primary_switch`, or MMU-enable change belongs
in this candidate.
