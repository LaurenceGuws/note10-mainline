# `early_numa_node_init()` physical proof

Date: 2026-09-29

## Promoted identities

Kernel source:

`8498fcece358e77f29873dc6f27ba0828a5259ab`

Image:

`95dee9c0920f557de1c312cb6a8e5f5d47fed9f1f9c017ab5fa9675ebe16ae40`

uniLoader:

`b5a17bbac6de449c75413badcdd5bfca4b387c4ae54731da2c1cefcb2c262291`

BOOT:

`4734a2bd0d20ef81c5d63141bda90e7b606a8bf902a0f34b1f1c81c109848655`

Previous proven MAINLINE:

`225485e165989cfd7b72f333531230db1409b53478b2023fa5d5ec6e684db719`

## Exact pre-state

- earlier M1 physical proof established `numa_off == true`;
- `CONFIG_NUMA_EMU` is unset;
- possible CPU set is exactly CPU0..7;
- `early_map_cpu_to_node()` therefore recorded node 0 for every possible CPU;
- no later selected writer changed `cpu_to_node_map[]` before NH1.

Therefore `early_cpu_to_node(0..7) == 0` before NH1.

## Frozen linked proof

The accepted NH1 linked path:

1. preserves the proven P2 framebuffer bridge in callee-saved `x19`;
2. paints the complete WHITE P2 success marker;
3. executes exactly one direct `early_numa_node_init()` call;
4. paints complete RED immediately after genuine return using preserved `x19`;
5. directly reads runtime per-CPU `numa_node` for CPU0..7;
6. requires all eight values to be exactly zero;
7. freshly reloads `note10_paging_bridge` only after all eight checks pass;
8. paints CYAN only after the NUMA publication checks and terminal-holds.

`boot_cpu_hotplug_init()` remains structurally unreachable behind NH1 terminal outcomes.

Production records remained function-relative exact versus P2 for:

- `early_numa_node_init()`: 38 instructions, 11 relocations;
- `early_cpu_to_node()`: 5 instructions, 2 relocations.

`early_numa_node_init()` moved by `0x104` inside `init/main.o` because the
`start_kernel()` diagnostic grew; the function-relative records remained exact.

## Physical observation

Captain reported the decoded **CYAN** meaning:

`NH1 PASS. Runtime numa_node is 0 for CPU0..7.`

The accepted stability gate passed.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves:

- `early_numa_node_init()` genuinely returned;
- runtime `numa_node == 0` for possible CPUs 0..7;
- the framebuffer bridge remained valid after the target;
- `boot_cpu_hotplug_init()` did not execute.

The next production boundary is `boot_cpu_hotplug_init()`.
