# start_kernel entry marker diagnostic

This tranche follows the physically proven white hold immediately before
`bl start_kernel`.

Accepted parent diagnostic commit:

`6eb4fa9a81ab027fc373ad1f3c874ddb7a6507cd`

New kernel diagnostic commit:

`d7d536f0f2449d805f3b232720a2e2e36a412b6b`

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
- clobbers only `x9..x14`, condition flags and compiler memory state;
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
adrp x0, init_task
add  x0, x0, ...
<rose marker>
<rose hold>
bl set_task_stack_end_magic
```

The first six instructions are compiler-generated SCS/frame/stack-auto-init
work expected by the plan review. Clang additionally hoists the pure
`&init_task` address materialization (`adrp/add`) ahead of the inline marker.
Those two instructions have no memory side effect and do not call or execute
`set_task_stack_end_magic`; the first ordinary call remains after the
unreachable rose hold.

This hoist is an explicit final-review question. It is not silently treated as
equivalent to the stricter review wording requiring the marker before all code
associated with `set_task_stack_end_magic`.

## Frozen source/build gates

- patch: `kernel-start-kernel-entry-marker.patch`;
- patch SHA-256:
  `35502adf5a0897f46695126af39a9d7d466f7849ae87d4f4c43428e15c5265bf`;
- stable patch-id: `af62e0e53128320d08ed14c5a507ede1c708e452`;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `5a14b7a46641a45367eaa55b84c3291da540cf9f23e522b439dac4f91f71251f`;
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

`671d0554044ce64d0cc8f9c7698a6112f116d9eae1ea16cf488dacdb9ff29fca`

The loader remains 44,838,912 bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Frozen candidate BOOT:

`794bf829dc3859289f152b70806538217258f572a25a920c40a00a0d08a007bc`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/start-kernel-entry-a/candidate.img`

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
