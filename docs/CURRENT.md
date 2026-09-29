# Current system state

## Proven MAINLINE

Kernel commit:

`6fe546b731b7b615c17862439812b195cedbf420`

BOOT:

`05322bfde93238932084fb16c96675b025648db7c7fa7d36bfeae62987e5861a`

Proven boundary: one-line `print_kernel_cmdline(saved_command_line)` returned,
then the second `parse_early_param()` returned through its already-established
`done == 1` fast path.

CL1 physically settled on GREEN `0xff00ff00` and Captain reported the decoded
PASS meaning.

That proves:

- promoted NH2 boot-CPU hotplug state remained intact;
- `print_kernel_cmdline()` genuinely returned;
- the exact 133-byte saved command line took the unchanged one-line logging path;
- the second `parse_early_param()` genuinely returned;
- its exact pre-state was `done == 1`, so it did not parse early options again;
- `saved_command_line` remained non-NULL;
- `saved_command_line_len == 133` and byte 133 remained NUL;
- `TPIDR_EL1 == __per_cpu_offset[0]` still held;
- a fresh `note10_paging_bridge` remained non-NULL and writable;
- the first real `parse_args("Booting kernel", ...)` did not execute.

The production `print_kernel_cmdline()` and `parse_early_param()` remained
function-relative exact versus promoted NH2.

## Previous proven MAINLINE

NH2:

`0e5e5c2c61857f8648bd24c6a4aa9a742ed241a50df6295c168039b261be4974`

Kernel source:

`e7f654eec7cf60845aa6a5ba1069f0978e9c9526`

NH2 proves `boot_cpu_hotplug_init()` through genuine return with public
`cpus_booted_once_mask == 0x1,0,0,0,0,0,0,0` and CPU0 per-CPU continuity.

## Current next boundary

`parse_args("Booting kernel", static_command_line, ...)`.

Do not cross it until the next bounded phase plan has been independently accepted.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
