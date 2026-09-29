# Current system state

## Proven MAINLINE

Kernel commit:

`a08d512a731a802f9ebc52c515a8254193b82790`

BOOT:

`906cc6e762260a4adef6eaecfaee05db6b3dbecaf752c525401630639fdb67b9`

Proven boundary: `setup_per_cpu_areas()` genuinely returned and the runtime
per-CPU publication for CPU0..7 validated.

P1 physically settled on GREEN `0xff00ff00` for the accepted three-minute
window.

That proves:

- the exact proven N1R1 state remained intact through the target entry;
- `setup_per_cpu_areas()` genuinely returned;
- fresh `pcpu_base_addr` was non-NULL;
- fresh `pcpu_unit_offsets` was non-NULL;
- for CPU0..7, `__per_cpu_offset[cpu]` exactly matched
  `((unsigned long)pcpu_base_addr - (unsigned long)__per_cpu_start) +
  pcpu_unit_offsets[cpu]`;
- a fresh `note10_paging_bridge` load remained non-NULL and writable;
- `smp_prepare_boot_cpu()` did not execute.

The production percpu implementation remained unchanged from proven N1R1.
P1 does not claim whether the embed allocator succeeded directly or the
supported page allocator fallback was used.

## Previous proven MAINLINE

N1R1:

`1a68d65504697c20e5dea7027e8afa38fa25f4bf772012b05f8789ca19782171`

Kernel source:

`854aa12e5f43720d2ee3e08b6922bc85e1e6f70e`

N1R1 proves `setup_nr_cpu_ids()` through genuine return with the accepted exact
eight-CPU state.

## Current next boundary

`smp_prepare_boot_cpu()`.

The accepted P2 plan must stop before `early_numa_node_init()`.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
