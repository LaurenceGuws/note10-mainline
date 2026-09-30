# Booting-kernel parameter parse KP1 physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`3b04b5a9a9e53431a2bcfaf5e0254cc0d36b097d`

Image:

`ccd87285aa49551ddefe91eec54328caef8d9e3edb9cac30d97af5e8dff36b25`

uniLoader:

`133be0590ef2f7925de6df67949adece4597159c478a8c9cd6c1353dbe7390dd`

BOOT:

`072408ec313851f9d66f69c21efc235ff3f037febf33fc88aa105f2ac5d90b84`

Previous proven MAINLINE:

`05322bfde93238932084fb16c96675b025648db7c7fa7d36bfeae62987e5861a`

## Exact parser input

The main parser received the separately allocated mutable copy of the exact
133-byte command line:

`earlycon=exynos4210,0x10440000 console=ttySAC0,115200 console=tty0 init=/init scsi_mod.max_luns=1 pmos_root=/dev/sda32 log_buf_len=4M`

There was no `--` token.

## Exact production effects

The accepted frozen evidence establishes:

- `earlycon=...` and `log_buf_len=4M` were recognized as already-consumed
  early parameters and not re-executed;
- both `console=` tokens traversed unchanged `console_setup()` and established
  public `console_set_on_cmdline == 1`;
- `init=/init` traversed unchanged `init_setup()`, establishing
  `execute_command == "/init"` and clearing later argv entries;
- `scsi_mod.max_luns=1` matched the real built-in parameter object backed by
  file-static `max_scsi_luns`, using unchanged `param_ops_ullong` semantics;
- `pmos_root=/dev/sda32` had no kernel registration and became the sole extra
  init environment entry at `envp_init[2]`.

Because every exact token returned success and no `--` was present,
`parse_args()` returned exactly NULL.

## Frozen linked proof

The accepted KP1 linked path:

1. preserves the proven CL1 framebuffer bridge in callee-saved `x19`;
2. executes the first real direct `parse_args("Booting kernel", ...)` call;
3. paints complete BLUE immediately after genuine return;
4. directly validates after-dashes NULL, panic state, exact `/init`, argv,
   exact `pmos_root=/dev/sda32`, env terminator, public console state, and
   `extra_init_args == NULL`;
5. any parse-state mismatch terminal-holds preserving BLUE;
6. only after all exact parse-state checks pass executes
   `print_unknown_bootoptions()`;
7. paints complete ORANGE/CORAL immediately after genuine reporting return;
8. the Setting-init-args parser is unreachable on exact NULL after-dashes;
9. the remaining extra-init-args guard reloads NULL and skips its nested parser;
10. directly revalidates `TPIDR_EL1 == __per_cpu_offset[0]`;
11. freshly reloads `note10_paging_bridge` only after the skip/continuity path;
12. paints WHITE only after all checks pass and terminal-holds;
13. retains `random_init_early(command_line)` linked immediately after the
    terminal proof boundary but structurally unreachable from all KP1 outcomes.

BLUE and ORANGE failure targets are WFE-first.

## Production equivalence

Frozen CL1/KP1 semantic function-relative records were exact for:

- `parse_args()`: 190 instructions / 30 relocations;
- `unknown_bootoption()`: 101 / 24;
- `obsolete_checksetup()`: 53 / 9;
- `init_setup()`: 17 / 5;
- `print_unknown_bootoptions()`: 97 / 34;
- `console_setup()`: 121 / 17.

No production accessor was added for file-static SCSI or console internals.

## Physical observation

Captain reported the decoded WHITE meaning:

`KP1 PASS. Main command-line parsing, exact seven-token effects, unknown-option reporting, and both init-argument skip guards completed; CPU0 continuity remained valid.`

Under the current bring-up policy, the clearly stable decoded terminal marker
is the semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves the complete main command-line handoff through
reporting and deterministic init-argument skips, while preserving CPU0
continuity and the framebuffer oracle.

The next unexecuted production boundary is:

`random_init_early(command_line)`.
