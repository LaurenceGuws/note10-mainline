# ordinary start_kernel cluster marker diagnostic

This tranche follows the physically proven rose `start_kernel` entry
checkpoint.

Accepted parent kernel diagnostic commit:

`fbf4fedfc4f45d5fbdfadafb3e38c3aa42ce4eb0`

New kernel diagnostic commit:

`4bba17ee5449b9d815f9ec99b5955d50d47f7dcb`

Current proven MAINLINE checkpoint / routine rollback target:

`3992fcbfd834db4e63da7a6350f4a7d99a4002528e636ccc053faf3a63051c0e`

Immutable Android RECOVERY checkpoint:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The accepted transient TTBR0 framebuffer identity mapping remains unchanged.

## Diagnostic change

The proven rose marker at `start_kernel` entry remains, but only its deliberate
hold is removed so ordinary initialization can continue.

The original first cluster then executes unchanged:

```text
set_task_stack_end_magic(&init_task)
smp_setup_processor_id()
init_vmlinux_build_id()
cgroup_init_early()
local_irq_disable()
early_boot_irqs_disabled = true
boot_cpu_init()
```

In this exact frozen config, source-level `debug_objects_early_init()` and
`page_address_init()` do not emit linked calls in this window.

Immediately after `boot_cpu_init()` returns and before banner printing or
`setup_arch()`, one direct arm64 extended-inline-assembly marker overwrites
rows 672..703 pure green:

`ARGB8888 0xff00ff00`

The marker then deliberately holds in `wfe`.

Banner printing, `setup_arch()`, `cpu_uninstall_idmap()`, and all later generic
initialization remain unreachable.

## Marker mechanism

The green marker:

- uses no C operands;
- calls no helper;
- machine instructions physically use only `x9..x14`;
- declares `x0` and `x1` as compiler-only scheduling clobbers;
- declares `x9..x14`, `cc`, and `memory` clobbered;
- does not modify `x18`, `sp`, `x29`, `x30`, or compiler-managed callee-saved
  state;
- leaves DAIF and the already-published `early_boot_irqs_disabled` value
  untouched;
- reuses exact framebuffer range `0xca3b1000..0xca3de000`, length `0x2d000`;
- uses the established CTR-derived cache-line-size calculation, `dc cvac`,
  `dsb sy; isb` visibility sequence;
- holds immediately after green becomes visible.

The compiler-only `x0`/`x1` clobbers prevent later banner/setup_arch argument
preparation from moving across the marker. They do not emit x0/x1 marker
instructions.

## Linked ordering proof

Final linked `start_kernel` ordering is:

```text
compiler SCS/frame/auto-init
rose marker
adrp/add &init_task
bl set_task_stack_end_magic
bl smp_setup_processor_id
bl init_vmlinux_build_id
bl cgroup_init_early
msr DAIFSet, #3
store early_boot_irqs_disabled = 1
bl boot_cpu_init
green marker
green visibility barriers
green wfe hold
banner argument preparation
bl _printk
prepare &command_line
bl setup_arch
```

The exact linked green marker begins immediately after the returning
`bl boot_cpu_init`. No banner or `setup_arch` preparation, memory access, or
call executes before green.

## Frozen source/build gates

- source delta: `init/main.c` only;
- patch: `kernel-start-kernel-ordinary-marker.patch`;
- patch SHA-256:
  `d22a491d45c4f01a2b137ff73c4d043a7c852fd06005c3e6085facac9a74a284`;
- stable patch-id:
  `8da37b3caa3ebc3e4f01484244230f7f70cc16b6`;
- patch applies cleanly to accepted parent;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `bde552bf46682a3006c3d0d947e38be7e8b291578a149c3b678a58b1286032d6`;
- Image size: `44,247,552` bytes;
- arm64 Image header remains `text_offset=0`, `image_size=0x2b10000`, flags
  `0xa`, ARM64 magic;
- linked `start_kernel`: `ffff800082210468`;
- linked `boot_cpu_init`: `ffff800082221f48`;
- linked `setup_arch`: `ffff800082214958`;
- linked `_printk`: `ffff800080018774`;
- accepted TTBR0 mapping source is byte-identical to the promoted rose parent;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

## Frozen loader and BOOT

Two independent builds of the unchanged reviewed JUMP_READY loader source are
byte-identical:

`2242d16fde9d993f8d21d96452b8c6c98c52f818681fb475d5d9cc5a57c9403c`

Loader size remains `44,838,912` bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Frozen diagnostic BOOT:

`8dd7d4d2a160b1072f76c2d84ee30dce1bbaa8523fa53a4ecb72f9143f07d591`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/start-kernel-ordinary-a/candidate.img`

Two complete packaging runs reproduce the candidate byte-for-byte.

Packaging uses immutable Android recovery only as the deterministic BOOT
envelope template. Progression/rollback authority remains current proven
MAINLINE `3992fcbf...`.

Against that current proven MAINLINE parent:

- total image size is identical;
- kernel size remains `48,424,984`;
- ramdisk size remains `1,458,687`;
- ramdisk region is byte-identical;
- post-ramdisk tail is byte-identical;
- header drift is checksum/id-only;
- AVB metadata is identical;
- template, parent and candidate all reproduce the accepted stale
  hash-descriptor rc=1 after footer and `NONE` vbmeta verification.

## Intended physical interpretation

- proven rose remains but green does not appear:
  `start_kernel` entry remains proven; failure is confined to the newly crossed
  ordinary cluster, including `set_task_stack_end_magic`,
  `smp_setup_processor_id` and its printk path, `init_vmlinux_build_id`,
  `cgroup_init_early`, IRQ-disable publication, `boot_cpu_init`, or the green
  marker itself;
- pure green `0xff00ff00` visible and stable:
  the complete first ordinary `start_kernel` cluster returned successfully,
  including the first real printk path and boot-CPU state publication, while
  banner printing and `setup_arch()` remain unreachable;
- green appears but does not remain stable:
  the cluster was reached, but the candidate is not promotable until held-state
  stability is resolved.

On physical PASS, promote exact `8dd7d4d2...` as the new proven MAINLINE
checkpoint and leave it installed. On FAIL, restore current proven MAINLINE
`3992fcbf...`, not Android recovery.

Do not cross `cpu_uninstall_idmap()`, add a replacement framebuffer mapping,
or expand into UFS, DTB/initramfs changes, clocks/power/watchdog, normal
framebuffer policy, console design, `setup_arch` internals, drivers, or later
generic kernel initialization in this tranche.
