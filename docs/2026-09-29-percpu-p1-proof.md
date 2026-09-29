# `setup_per_cpu_areas()` physical proof

Date: 2026-09-29

## Promoted identities

Kernel source:

`a08d512a731a802f9ebc52c515a8254193b82790`

Image:

`dbcc5c3372d3bb4b9cda931b2d57ebe949821c3b0b74d7ba9bd5b2b96e86d839`

uniLoader:

`f0f5cd7d4e8ba0124e4d2bf76ba79e4596fb529ccb7c9b44aff815a68d1247c2`

BOOT:

`906cc6e762260a4adef6eaecfaee05db6b3dbecaf752c525401630639fdb67b9`

Previous proven MAINLINE:

`1a68d65504697c20e5dea7027e8afa38fa25f4bf772012b05f8789ca19782171`

## Production target

The selected build uses the NUMA-aware `drivers/base/arch_numa.c::setup_per_cpu_areas()` implementation.

Exact P1 pre-state was `pcpu_chosen_fc == PCPU_FC_AUTO`. The physically proven
`setup_arch()` lineage had already executed `parse_early_param()`, but the
exact bootargs contain no `percpu_alloc=` option, so the relevant early-param
writer did not alter the selector.

The production function supports the NUMA-aware embedded allocator and its
page-first-chunk fallback. P1 intentionally does not distinguish which
successful allocator path was taken.

## Frozen linked proof

The accepted P1 linked path:

1. freshly reloads the proven N1 framebuffer bridge into callee-saved `x19`;
2. paints the complete CORAL / ORANGE N1 success marker;
3. executes exactly one direct `setup_per_cpu_areas()` call;
4. paints complete RED immediately after genuine return using the preserved pre-call bridge;
5. freshly reads `pcpu_base_addr` and `pcpu_unit_offsets`;
6. computes the production delta from `__per_cpu_start`;
7. directly validates all eight `__per_cpu_offset[0..7]` values against `delta + pcpu_unit_offsets[0..7]`;
8. freshly reloads `note10_paging_bridge`;
9. paints GREEN only after all publication checks pass and terminal-holds.

Every P1 failure after RED terminal-holds without another repaint.
`smp_prepare_boot_cpu()` remains structurally unreachable behind the GREEN and failure holds.

Production records remained exact versus N1R1 for:

- `setup_per_cpu_areas()`: 77 instructions, 33 relocations;
- `pcpu_embed_first_chunk()`: 208 instructions, 16 relocations;
- `pcpu_page_first_chunk()`: 224 instructions, 41 relocations;
- `pcpu_setup_first_chunk()`: 570 instructions, 287 relocations.

## Physical observation

Captain observed stable **GREEN** `0xff00ff00` for three minutes.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves:

- `setup_per_cpu_areas()` genuinely returned;
- runtime per-CPU base publication exists;
- CPU0..7 runtime offsets exactly satisfy the production relation;
- the framebuffer bridge remained valid after the target;
- `smp_prepare_boot_cpu()` did not execute.

The next production boundary is `smp_prepare_boot_cpu()`.
