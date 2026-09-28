# `setup_nr_cpu_ids()` physical proof

Date: 2026-09-29

## Promoted identities

Kernel source:

`854aa12e5f43720d2ee3e08b6922bc85e1e6f70e`

Image:

`2e2f195e3e0f12a775316d472e4f34ce35e99994368c20f57e0350f2ce75ce37`

uniLoader:

`6fbd1a97f68a27d0ee15c47f0c3e704e646ec4050d9f28f35b65081cb880e6e7`

BOOT:

`1a68d65504697c20e5dea7027e8afa38fa25f4bf772012b05f8789ca19782171`

Previous proven MAINLINE was C1:

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

## Why failed N1 did not test the target

Failed N1 source `8eafe86bb04cc99f3e5dcead15b7424ad452e77f`
painted the proven C1 TURQUOISE marker and then fell directly into the retained
C1 failure WFE/self-loop. Its linked `setup_nr_cpu_ids()` call was unreachable.

Therefore the missing CORAL result from failed N1 contained no evidence about
the production `setup_nr_cpu_ids()` function.

N1R1 repaired only that diagnostic control-flow edge and added a staged
post-return ladder.

## Frozen linked evidence

The accepted N1R1 linked path:

1. performs the exact C1 validation;
2. loads the already-proven framebuffer bridge into callee-saved `x19`;
3. paints TURQUOISE;
4. explicitly branches around the C1 failure hold;
5. executes exactly one direct `setup_nr_cpu_ids()` call;
6. paints VIOLET from preserved `x19`;
7. proves fresh `nr_cpu_ids == 8`, then paints BLUE;
8. proves fresh `__num_possible_cpus == 8`, then paints YELLOW;
9. reads exactly eight 64-bit words of the possible mask and proves
   `0xff,0,0,0,0,0,0,0`, then paints LIME;
10. freshly reloads `note10_paging_bridge`;
11. paints CORAL and holds forever.

Every failed postcondition branches directly to a WFE/self-loop. The linked
`setup_per_cpu_areas()` call remains after those terminal outcomes and is
unreachable.

Production-function records remained exact versus failed N1:

- `setup_nr_cpu_ids()`: 17 instruction records, 5 relocation records;
- `_find_last_bit()`: 27 instruction records, 0 relocation records.

## Physical observation

The phone was flashed BOOT-only with exact frozen N1R1 while CAL1 was
installed. A separate C1 restore was intentionally unnecessary because each
candidate replaces the complete logical BOOT partition and a new boot starts
from reset.

Captain observed the reusable rows 672..703 slot settle on what was initially
described as **dirty orange**.

The durable rendered color key identifies the frozen success value
`0xffff7f50` / `#ff7f50` as **CORAL / ORANGE**. The observation remained
stable for more than seven minutes before classification, exceeding the
accepted three-minute physical gate.

Result: **PASS**.

## Proven consequence

The promoted checkpoint proves:

- `setup_nr_cpu_ids()` genuinely returned;
- `nr_cpu_ids == 8`;
- `__num_possible_cpus == 8`;
- `cpu_possible_mask` is exactly CPUs 0..7 over the eight checked 64-bit words;
- the framebuffer bridge remained valid after the target;
- `setup_per_cpu_areas()` did not execute.

The next production boundary is `setup_per_cpu_areas()`.
