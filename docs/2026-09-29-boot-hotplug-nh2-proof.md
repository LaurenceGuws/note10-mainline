# `boot_cpu_hotplug_init()` physical proof

Date: 2026-09-29

## Promoted identities

Kernel source:

`e7f654eec7cf60845aa6a5ba1069f0978e9c9526`

Image:

`a2cf353c90093dd77f1e9c14cc1391a12c197ab32edd8c7b70bb719be10d6d96`

uniLoader:

`b8cf0b7e814c7665b3bc8f256fb5237fb86aabe9a8de293da7ed5d955f7d74af`

BOOT:

`0e5e5c2c61857f8648bd24c6a4aa9a742ed241a50df6295c168039b261be4974`

Previous proven MAINLINE:

`4734a2bd0d20ef81c5d63141bda90e7b606a8bf902a0f34b1f1c81c109848655`

## Exact pre-state

- boot CPU identity is proven logical CPU0;
- no secondary CPU had started before NH2;
- `cpus_booted_once_mask` was therefore all-zero before the call;
- P2/NH1 continuity proved `TPIDR_EL1 == __per_cpu_offset[0]`.

## Frozen linked proof

The accepted NH2 linked path:

1. preserves the proven NH1 framebuffer bridge in callee-saved `x19`;
2. paints the complete CYAN NH1 success marker;
3. explicitly branches to exactly one direct `boot_cpu_hotplug_init()` call;
4. paints complete YELLOW immediately after genuine return using preserved `x19`;
5. directly reads all eight 64-bit words of `cpus_booted_once_mask`;
6. requires word0 == `0x1` and words1..7 == 0;
7. directly reads `TPIDR_EL1` and directly compares it with `__per_cpu_offset[0]`;
8. freshly reloads `note10_paging_bridge` only after those public-state checks;
9. paints MAGENTA / PINK only after all checks pass and terminal-holds;
10. keeps the saved-command-line load and `print_kernel_cmdline()` unreachable.

The production `boot_cpu_hotplug_init()` remained exact versus NH1:

- 66 instructions;
- 8 relocations.

The unchanged linked production body still:

- atomically sets the current CPU bit in `cpus_booted_once_mask`;
- stores `SYNC_STATE_ONLINE == 5` into the boot CPU AP sync state;
- stores `CPUHP_ONLINE == 0xec` into boot CPU state;
- stores `CPUHP_ONLINE == 0xec` into boot CPU target;
- genuinely returns only after those stores.

The internal `cpuhp_state` object is file-static and was not exposed through a
new diagnostic API. Those internal stores are consequences of genuine return
through unchanged production code, while the public booted-once mask was
independently observed.

## Physical observation

Captain reported the decoded MAGENTA / PINK meaning:

`NH2 PASS. Boot CPU0 hotplug initialization returned and the public booted-once mask is CPU0-only.`

Under the current bring-up policy, the clearly stable decoded terminal marker
is the semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves:

- `boot_cpu_hotplug_init()` genuinely returned;
- the public booted-once mask is CPU0-only;
- CPU0 remained on its runtime per-CPU base;
- the framebuffer bridge remained valid after the target;
- `print_kernel_cmdline(saved_command_line)` did not execute.

The accepted NH1/NH2 phase is complete.

The next production boundary is `print_kernel_cmdline(saved_command_line)`.
