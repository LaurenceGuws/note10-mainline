# Current system state

## Proven MAINLINE

Kernel commit:

`16f5becb8d1e0116f7a070e3ac9743d9f08ce0ea`

BOOT:

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

Proven boundary: `setup_command_line()` genuinely returned and the accepted command-line copies/postconditions passed.

## Current next boundary

`setup_nr_cpu_ids()`.

N1 source `8eafe86bb04cc99f3e5dcead15b7424ad452e77f` was independently accepted offline but failed its physical CORAL gate. It is not MAINLINE.

Framebuffer CAL1 subsequently proved that the reusable rows 672..703 breadcrumb slot faithfully presents its final writes. Therefore N1's missing CORAL remains a genuine physical failure rather than stale framebuffer presentation.

CAL1 was diagnostic-only and is never promotable.

## Framebuffer evidence model

Rows 512..671 are an intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md`.
