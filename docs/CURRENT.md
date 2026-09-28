# Current system state

## Proven MAINLINE

Kernel commit:

`854aa12e5f43720d2ee3e08b6922bc85e1e6f70e`

BOOT:

`1a68d65504697c20e5dea7027e8afa38fa25f4bf772012b05f8789ca19782171`

Proven boundary: `setup_nr_cpu_ids()` genuinely returned and published the
accepted eight-CPU state.

N1R1 physically settled on the frozen CORAL / ORANGE marker `0xffff7f50`
for longer than the accepted three-minute window.

That proves, in order:

- the repaired C1 success path reached the one ordinary `setup_nr_cpu_ids()` call;
- `setup_nr_cpu_ids()` returned;
- `nr_cpu_ids == 8`;
- `__num_possible_cpus == 8`;
- the exact eight-word possible mask is `0xff,0,0,0,0,0,0,0`;
- a fresh `note10_paging_bridge` load remained non-NULL and writable.

The production `setup_nr_cpu_ids()` and `_find_last_bit()` instruction /
relocation records remained exact versus failed N1. The failure in failed N1
was the diagnostic success edge falling into the old C1 terminal hold, not the
production CPU-ID setup itself.

## Previous proven MAINLINE

C1:

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

Kernel source:

`16f5becb8d1e0116f7a070e3ac9743d9f08ce0ea`

C1 proves `setup_command_line()` through genuine return with the exact
published command-line copies.

## Current next boundary

`setup_per_cpu_areas()`.

Do not cross it until its bounded phase plan has been independently accepted.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
