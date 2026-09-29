# Current system state

## Proven MAINLINE

Kernel commit:

`8498fcece358e77f29873dc6f27ba0828a5259ab`

BOOT:

`4734a2bd0d20ef81c5d63141bda90e7b606a8bf902a0f34b1f1c81c109848655`

Proven boundary: `early_numa_node_init()` genuinely returned and runtime
`numa_node` publication for CPU0..7 validated.

NH1 physically settled on CYAN `0xff00ffff` and the accepted stability gate
passed.

That proves:

- the proven P2 CPU0 runtime per-CPU base handoff remained intact;
- `early_numa_node_init()` genuinely returned;
- runtime `per_cpu(numa_node, cpu) == 0` for every possible CPU0..7;
- a fresh `note10_paging_bridge` load remained non-NULL and writable;
- `boot_cpu_hotplug_init()` did not execute.

The production `early_numa_node_init()` and `early_cpu_to_node()` records
remained function-relative exact versus promoted P2.

## Previous proven MAINLINE

P2:

`225485e165989cfd7b72f333531230db1409b53478b2023fa5d5ec6e684db719`

Kernel source:

`fe03932bd4c34e1d54344926fa3df8203e909a23`

P2 proves `smp_prepare_boot_cpu()` through genuine return with
`TPIDR_EL1 == __per_cpu_offset[0]`.

## Current next boundary

`boot_cpu_hotplug_init()`.

The accepted NH2 plan must stop before
`print_kernel_cmdline(saved_command_line)`.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
