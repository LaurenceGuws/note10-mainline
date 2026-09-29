# Current system state

## Proven MAINLINE

Kernel commit:

`fe03932bd4c34e1d54344926fa3df8203e909a23`

BOOT:

`225485e165989cfd7b72f333531230db1409b53478b2023fa5d5ec6e684db719`

Proven boundary: `smp_prepare_boot_cpu()` genuinely returned and the boot CPU
runtime per-CPU base handoff validated.

P2 physically settled on WHITE `0xffffffff` for the accepted three-minute
window.

That proves:

- the proven P1 runtime per-CPU publication remained intact;
- `smp_prepare_boot_cpu()` genuinely returned;
- the post-return `TPIDR_EL1` value exactly matched `__per_cpu_offset[0]`;
- a fresh `note10_paging_bridge` load remained non-NULL and writable;
- `early_numa_node_init()` did not execute.

The production `smp_prepare_boot_cpu()`, `cpuinfo_store_boot_cpu()`, and
`setup_boot_cpu_features()` records remained exact versus promoted P1.

## Previous proven MAINLINE

P1:

`906cc6e762260a4adef6eaecfaee05db6b3dbecaf752c525401630639fdb67b9`

Kernel source:

`a08d512a731a802f9ebc52c515a8254193b82790`

P1 proves `setup_per_cpu_areas()` through genuine return and exact CPU0..7
runtime per-CPU publication.

## Current next boundary

`early_numa_node_init()`.

Do not cross it until the next bounded phase plan has been independently accepted.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
