# Current system state

## Proven MAINLINE

Kernel commit:

`e7f654eec7cf60845aa6a5ba1069f0978e9c9526`

BOOT:

`0e5e5c2c61857f8648bd24c6a4aa9a742ed241a50df6295c168039b261be4974`

Proven boundary: `boot_cpu_hotplug_init()` genuinely returned and the public
booted-once mask validated as CPU0-only.

NH2 physically settled on MAGENTA / PINK `0xffff00ff` and Captain reported
the decoded PASS meaning.

That proves:

- promoted NH1 runtime NUMA publication remained intact;
- `boot_cpu_hotplug_init()` genuinely returned;
- `cpus_booted_once_mask` is exactly `0x1,0,0,0,0,0,0,0`;
- `TPIDR_EL1 == __per_cpu_offset[0]` still held after the target;
- a fresh `note10_paging_bridge` load remained non-NULL and writable;
- `print_kernel_cmdline(saved_command_line)` did not execute.

The production `boot_cpu_hotplug_init()` remained exact versus promoted NH1
at 66 instructions / 8 relocations. Its linked body retains the CPU0 mask set
and the internal boot-CPU hotplug state writes before genuine return.

## Previous proven MAINLINE

NH1:

`4734a2bd0d20ef81c5d63141bda90e7b606a8bf902a0f34b1f1c81c109848655`

Kernel source:

`8498fcece358e77f29873dc6f27ba0828a5259ab`

NH1 proves `early_numa_node_init()` through genuine return with runtime
`numa_node == 0` for possible CPU0..7.

## Current next boundary

`print_kernel_cmdline(saved_command_line)`.

Do not cross it until the next bounded phase plan has been independently accepted.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
