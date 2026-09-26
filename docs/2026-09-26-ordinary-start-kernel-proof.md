# 2026-09-26 ordinary start_kernel cluster proof

The reviewed pure-green ordinary-`start_kernel` candidate was tested
physically on d2s:

- maintained source checkpoint:
  `cc648a1f98fd0654b657b79eeca6d3ec2108ad0c`
- kernel diagnostic commit:
  `4bba17ee5449b9d815f9ec99b5955d50d47f7dcb`
- BOOT candidate:
  `8dd7d4d2a160b1072f76c2d84ee30dce1bbaa8523fa53a4ecb72f9143f07d591`
- previous proven MAINLINE checkpoint:
  `3992fcbfd834db4e63da7a6350f4a7d99a4002528e636ccc053faf3a63051c0e`
- immutable Android RECOVERY checkpoint:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The proven rose marker remained at `start_kernel` entry, but its deliberate
hold was removed. The original first ordinary initialization cluster then ran
unchanged through `boot_cpu_init()`.

Immediately after `boot_cpu_init()` returned, the candidate painted rows
672..703 pure green:

`ARGB8888 0xff00ff00`

and deliberately held before banner printing and `setup_arch()`.

The final linked order was:

```text
start_kernel compiler SCS/frame/auto-init
rose entry marker

set_task_stack_end_magic
smp_setup_processor_id
init_vmlinux_build_id
cgroup_init_early
local IRQ masking
early_boot_irqs_disabled = true publication
boot_cpu_init

pure-green marker
green visibility barriers
green wfe hold

banner argument preparation
_printk(linux_banner)
setup_arch
```

Captain observed the expected pure-green band and it remained unchanged for at
least three minutes.

That stable green state physically proves:

1. the previously proven genuine `start_kernel` entry path completed;
2. `set_task_stack_end_magic(&init_task)` returned;
3. `smp_setup_processor_id()` returned, including MPIDR publication and its
   internal `_printk` path;
4. `init_vmlinux_build_id()` returned;
5. `cgroup_init_early()` returned;
6. local IRQ masking executed;
7. `early_boot_irqs_disabled = true` was published;
8. `boot_cpu_init()` returned;
9. the green marker executed through the still-valid transient TTBR0
   framebuffer mapping;
10. banner printing and `setup_arch()` remained unreachable.

The exact candidate:

`8dd7d4d2a160b1072f76c2d84ee30dce1bbaa8523fa53a4ecb72f9143f07d591`

is promoted as the newest proven MAINLINE checkpoint and remains installed.

It is now the normal progression parent and routine rollback target.

The previous rose MAINLINE checkpoint `3992fcbf...` remains preserved as a
historical proof checkpoint. Android `1a78e511...` remains the immutable
RECOVERY checkpoint only.

Because the promoted green checkpoint deliberately holds before
`setup_arch()`, no Android/ADB post-flash block-device re-read is expected.
Installed identity is established by the exact reviewed BOOT-only flash
transaction plus the candidate-specific stable green marker.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/start-kernel-ordinary-marker/`

The next earned frontier is banner printing followed by arm64
`setup_arch()`. The current low framebuffer evidence sink remains usable only
until `setup_arch()` reaches the inlined `cpu_uninstall_idmap()` TTBR0
replacement. The next plan must stop before that replacement unless it first
establishes a different evidence mechanism.
