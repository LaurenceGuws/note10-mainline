# command-line logging / early-param guard CL1 physical proof

Date: 2026-09-29

## Promoted identities

Kernel source:

`6fe546b731b7b615c17862439812b195cedbf420`

Image:

`79619234f2febdc7c086628f2e7f97af0aec8fbbeebb1ce59e989e17e7b0410a`

uniLoader:

`cb176a7ee66609e9b15a39c030a8477d2b9b7a0e26f4bd7ec2936b2e8f806ae9`

BOOT:

`05322bfde93238932084fb16c96675b025648db7c7fa7d36bfeae62987e5861a`

Previous proven MAINLINE:

`0e5e5c2c61857f8648bd24c6a4aa9a742ed241a50df6295c168039b261be4974`

## Exact pre-state

- `saved_command_line` was already physically proven non-NULL;
- exact payload length was 133 bytes and byte 133 was NUL;
- `CONFIG_CMDLINE_LOG_WRAP_IDEAL_LEN=1021`, giving exact one-line threshold 1000;
- the earlier physically proven `setup_arch()` call already executed and returned from
  `parse_early_param()`, establishing exact second-call pre-state `done == 1`.

## Frozen linked proof

The accepted CL1 linked path:

1. preserves the proven NH2 framebuffer bridge in callee-saved `x19`;
2. paints the complete MAGENTA/PINK NH2 success marker;
3. executes one direct `print_kernel_cmdline(saved_command_line)` call;
4. paints ORANGE/CORAL immediately after genuine return;
5. executes the second direct `parse_early_param()` call;
6. paints RED immediately after genuine return;
7. directly validates saved pointer, length 133, byte 133 NUL, and CPU0 TPIDR continuity;
8. freshly reloads `note10_paging_bridge` only after those checks;
9. paints GREEN only after all checks pass and terminal-holds;
10. keeps the first real `parse_args("Booting kernel", ...)` call unreachable.

`print_kernel_cmdline()` remained function-relative exact at 90 instructions /
14 relocations. The proven 133-byte length takes the short path and reaches
exactly one final `_printk()` before ordinary return.

`parse_early_param()` remained function-relative exact at 55 instructions /
17 relocations. The second call's exact `done == 1` pre-state takes its initial
`tbnz` directly to the epilogue; no early-option parsing executes again.

RED failure branches to an out-of-line WFE/self-loop whose first instruction is
`wfe`. On the successful path LLVM schedules only side-effect-free register/address
arithmetic for the future parser before GREEN; GREEN's actual terminal loop still
makes every later parser load and call unreachable.

## Physical observation

Captain reported the decoded GREEN meaning:

`CL1 PASS. One-line command-line logging returned, the second early-param call fast-returned, and the bounded continuity checks passed.`

Under the current bring-up policy, the clearly stable decoded terminal marker
is the semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves:

- command-line logging returned through the exact one-line path;
- the second early-param call fast-returned through `done == 1`;
- the bounded saved-command-line invariants remained intact;
- CPU0 remained on its runtime per-CPU base;
- the framebuffer bridge remained valid;
- the first real `parse_args("Booting kernel", ...)` did not execute.

The next production boundary is the first real
`parse_args("Booting kernel", static_command_line, ...)`.
