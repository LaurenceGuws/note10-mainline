# start_kernel entry marker diagnostic

This tranche follows the physically proven white hold immediately before
`bl start_kernel`.

Accepted parent diagnostic commit:

`6eb4fa9a81ab027fc373ad1f3c874ddb7a6507cd`

New kernel diagnostic commit:

`fbf4fedfc4f45d5fbdfadafb3e38c3aa42ce4eb0`

The accepted diagnostic TTBR0 framebuffer identity mapping remains unchanged.

## Proven-checkpoint parentage

Latest proven MAINLINE checkpoint and normal rollback target:

`bc4a78a9dfad41992777b42913394735e893a709e52e06309d482478a1307f94`

Immutable Android RECOVERY checkpoint:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The promoted mainline checkpoint is the progression/rollback authority. The
Android recovery BOOT remains the canonical deterministic Android BOOT
envelope template because `magiskboot unpack` trims the already-embedded
uniLoader/padding representation from promoted mainline images. That extractor
behavior does not alter progression authority.

The final rose candidate is therefore constructed from the canonical envelope
template and separately verified to preserve the proven mainline parent's
ramdisk, post-ramdisk tail, geometry, AVB metadata and checksum/id-only header
drift.

## Diagnostic change

The proven white marker remains, but only its deliberate hold is removed so
the original `bl start_kernel` executes.

Inside `start_kernel()` itself, the first explicit source statement is one
diagnostic-only arm64 extended-inline-assembly block. It:

- has no C operands;
- calls no helper;
- physically uses only `x9..x14` in marker machine instructions;
- additionally declares `x0` as a compiler-only clobber so Clang cannot
  hoist the following `&init_task` argument materialization across the rose
  statement;
- declares condition flags and compiler memory state clobbered;
- does not name or modify `x18`, `sp`, `x29`, or `x30`;
- reuses rows 672..703, exact range `0xca3b1000..0xca3de000`;
- paints rose `ARGB8888 0xffff4080`;
- uses the established raw CTR D-cache-line-size derivation plus `dc cvac`,
  `dsb sy; isb` visibility sequence;
- deliberately holds in `wfe` immediately after the marker becomes visible.

No ordinary `start_kernel` source operation is intended to execute before the
marker. `set_task_stack_end_magic()` and all later generic initialization must
remain unreachable.

## Linked compiler entry

The exact linked `start_kernel` entry is:

```text
str x30, [x18], #8
sub sp, sp, #0x30
stp x29, x30, [sp, #0x10]
stp x20, x19, [sp, #0x20]
add x29, sp, #0x10
str xzr, [sp, #0x8]
<rose marker>
<rose hold>
adrp x0, init_task
add  x0, x0, ...
bl set_task_stack_end_magic
```

The first six instructions are compiler-generated SCS/frame/stack-auto-init
work expected by the plan review. The one-line compiler-only `x0` clobber
forces the `&init_task` `adrp/add` pair to remain after the unreachable rose
hold, so rose now precedes all code attributable to
`set_task_stack_end_magic(&init_task)` as required by the strict placement
contract. The marker itself still emits no x0 instruction and does not modify
x18/SCS, `sp`, `x29`, or `x30`.

## Frozen source/build gates

- patch: `kernel-start-kernel-entry-marker.patch`;
- patch SHA-256:
  `e928a4b056a498c136ccb18f7ba9c7f3ffb3a6dbeb1382eb40f1ec3a72dde8c8`;
- stable patch-id: `db10d9d0bd69a58ee0da4134bf7d576e762acbfd`;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `869d4dd7bc469e3ac5b30d7bedd54abe91c7a563e026d9e640efbef1304223ae`;
- Image size: `44,247,552` bytes;
- arm64 Image header remains `text_offset=0`, `image_size=0x2b10000`, flags
  `0xa`, ARM64 magic;
- linked `start_kernel`: `ffff800082210468`;
- linked `set_task_stack_end_magic`: `ffff8000800d10a0`;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

## Frozen loader and BOOT

Two independent builds of the unchanged reviewed JUMP_READY loader source are
byte-identical:

`aa34ed8eeb4a88db2db02bf24d34daa87248c4123bc3e9bb326c2866f1e3ca05`

The loader remains 44,838,912 bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Frozen candidate BOOT:

`3992fcbfd834db4e63da7a6350f4a7d99a4002528e636ccc053faf3a63051c0e`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/start-kernel-entry-fixed-a/candidate.img`

Two complete packaging runs reproduced the candidate byte-for-byte.

Against the proven MAINLINE parent `bc4a78a9...`:

- BOOT image size and header geometry are unchanged;
- Android ramdisk region is byte-identical;
- post-ramdisk tail is byte-identical;
- header drift remains checksum/id-only;
- only the kernel field contains the expected changed bytes;
- AVB metadata is identical;
- parent and candidate both reproduce the accepted stale hash-descriptor rc=1
  while footer and `NONE` vbmeta structure verify.

## Intended physical interpretation

- proven white remains, no rose:
  execution reached the proven pre-call boundary but did not complete enough of
  the original call/target fetch/start_kernel compiler entry to execute the
  rose marker;
- rose stable:
  `start_kernel` was genuinely entered, its compiler SCS/frame/auto-init entry
  work completed, the first explicit source marker executed through the still
  valid TTBR0 framebuffer mapping, and no ordinary start_kernel call executed;
- rose appears but does not remain stable for the agreed attended interval:
  entry is proven but the candidate is not promotable until the held state is
  stable.

On physical PASS, this exact BOOT becomes the new proven MAINLINE checkpoint
and remains installed. On FAIL, routine rollback target is the prior proven
mainline checkpoint `bc4a78a9...`, not Android recovery.

No generic `start_kernel` initialization, `setup_arch`,
`cpu_uninstall_idmap`, UFS, DTB-content, initramfs policy, clock/power/watchdog,
normal framebuffer policy, console, driver, or later-subsystem change belongs
in this candidate.
