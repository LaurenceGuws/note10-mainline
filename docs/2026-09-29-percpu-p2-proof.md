# `smp_prepare_boot_cpu()` physical proof

Date: 2026-09-29

## Promoted identities

Kernel source:

`fe03932bd4c34e1d54344926fa3df8203e909a23`

Image:

`c447b565ec0b151a82965d447a3a1e3d79b4f0020e09e79d3957763e3505fd6f`

uniLoader:

`06390aa94355e048d0c73c947eb0bf7625ff932d4195fe619564b5f507850157`

BOOT:

`225485e165989cfd7b72f333531230db1409b53478b2023fa5d5ec6e684db719`

Previous proven MAINLINE:

`906cc6e762260a4adef6eaecfaee05db6b3dbecaf752c525401630639fdb67b9`

## Frozen linked proof

The accepted P2 linked path:

1. freshly reloads the proven P1 framebuffer bridge into callee-saved `x19`;
2. paints the complete GREEN P1 success marker;
3. explicitly branches around an unreachable compiler `mov x19,xzr` artifact;
4. executes exactly one direct `smp_prepare_boot_cpu()` call;
5. paints complete BLUE immediately after genuine return using preserved `x19`;
6. directly reads `TPIDR_EL1` with `mrs`;
7. directly loads `__per_cpu_offset[0]` and compares it to `TPIDR_EL1`;
8. freshly reloads `note10_paging_bridge` only after the equality check;
9. paints WHITE only after the CPU0 per-CPU base handoff and bridge checks pass;
10. terminal-holds before `early_numa_node_init()`.

Production records remained exact versus promoted P1 for:

- `smp_prepare_boot_cpu()`: 16 instructions, 4 relocations;
- `cpuinfo_store_boot_cpu()`: 28 instructions, 9 relocations;
- `setup_boot_cpu_features()`: 14 instructions, 4 relocations.

## Physical observation

Captain observed stable **WHITE** `0xffffffff` for three minutes.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves:

- `smp_prepare_boot_cpu()` genuinely returned;
- boot CPU0 moved to the published runtime per-CPU base;
- the framebuffer bridge remained valid after the target;
- `early_numa_node_init()` did not execute.

The accepted P1/P2 phase is complete.

The next production boundary is `early_numa_node_init()`.
