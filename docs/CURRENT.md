# Current system state

## Proven MAINLINE

Kernel commit:

`3b04b5a9a9e53431a2bcfaf5e0254cc0d36b097d`

BOOT:

`072408ec313851f9d66f69c21efc235ff3f037febf33fc88aa105f2ac5d90b84`

Proven boundary: the first real `parse_args("Booting kernel",
static_command_line, ...)` returned with the exact seven-token effects,
`print_unknown_bootoptions()` returned, both following init-argument parser
guards skipped their nested parser calls, and CPU0 per-CPU continuity remained
valid.

KP1 physically settled on WHITE `0xffffffff` and Captain reported the decoded
PASS meaning.

That proves:

- promoted CL1 command-line logging and early-param guard state remained intact;
- the main Booting-kernel parser genuinely returned;
- `after_dashes == NULL` and `panic_later == NULL`;
- `execute_command == "/init"` and `argv_init[1] == NULL`;
- `envp_init[2] == "pmos_root=/dev/sda32"` and `envp_init[3] == NULL`;
- `console_set_on_cmdline == 1`;
- exact built-in `scsi_mod.max_luns=1` was accepted through unchanged parameter code;
- `print_unknown_bootoptions()` genuinely returned;
- the Setting-init-args and Setting-extra-init-args parser calls did not execute;
- `TPIDR_EL1 == __per_cpu_offset[0]` still held;
- a fresh `note10_paging_bridge` remained non-NULL and writable;
- `random_init_early(command_line)` did not execute.

All six production functions reviewed for KP1 remained semantically
function-relative exact versus promoted CL1.

## Previous proven MAINLINE

CL1:

`05322bfde93238932084fb16c96675b025648db7c7fa7d36bfeae62987e5861a`

Kernel source:

`6fe546b731b7b615c17862439812b195cedbf420`

CL1 proves one-line command-line logging through genuine return and the
second `parse_early_param()` through exact `done == 1` fast return.

## Current next boundary

`random_init_early(command_line)`.

Do not cross it until the next bounded phase plan has been independently accepted.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
