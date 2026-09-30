# Exception-table + trap ET1 physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`439bbe62eacfd7cc47b760a1e80ee780dbef58ce`

Image:

`a5aa2228a4e85804128ba36c49d7c3488a885cc13982e87182f0b47bc84ce906`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`9a4c4d6ab4c2d34fa75e8d9aa91e0ff960862152f78e441fc3787055181a2b5c`

BOOT:

`7007ab6b4d10d62b1db782db35922821ac4c416bbffecb95b85d98b7e9a201ce`

Previous proven MAINLINE / immediate rollback:

`326d993a382cc0c2bf75e65276b1fb9af18624778d4fd0de78b65f70f2e75efc`

## Frozen reviewed boundary

ET1 crossed exactly:

VFS1R1 BLUE
→ ET1 IRQ / CPU0 / fresh-bridge preconditions
→ WHITE
→ unchanged `sort_main_extable()`
→ immediate RED
→ unchanged `trap_init()`
→ IRQ / CPU0 / fresh-final-bridge checks
→ terminal GREEN

and stopped before:

`mm_core_init()`

## Exact exception-table state

The frozen final image has:

- `CONFIG_BUILDTIME_TABLE_SORT=y`;
- `main_extable_sort_needed` at `0xffff8000823619c0`;
- exact final flag value `0x00000000`;
- `__start___ex_table = 0xffff8000821f4cb0`;
- `__stop___ex_table = 0xffff8000821f80e8`;
- exact table size 13,368 bytes;
- exact entry size 12 bytes;
- exact entry count 1,114.

The frozen raw table was independently parsed and all 1,114 instruction keys
were sorted non-decreasing.

The runtime sort path remains linked, but unchanged `sort_main_extable()`
sees the exact zero flag and does not call `_printk` or `sort_extable()`.

ET1 therefore does **not** prove runtime sorting. The table had already been
sorted by the build-time `scripts/sorttable` tool.

## Exact trap behavior

The final linked arm64 `trap_init()` is exactly one instruction:

`ret`

It resolves to the generic weak definition in `init/main.c`.

## Physical observation

Captain reported the decoded terminal marker:

`GREEN · ET1 PASS (#00ff00)`

Decoded meaning:

`sort_main_extable() returned on the already build-time-sorted / flag-zero lane, the exact one-instruction trap_init() returned, interrupts remained disabled, CPU0 continuity remained intact, and the fresh final bridge was valid.`

Therefore the physical boot proves:

- `sort_main_extable()` genuinely returned;
- the runtime sort lane was not taken on this exact image;
- exact one-instruction `trap_init()` returned;
- IRQ-disabled state survived both calls;
- CPU0 continuity survived;
- the final freshly read framebuffer bridge remained valid.

Under the current bring-up policy, the clearly stable decoded terminal marker
is semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

ET1 is promoted to MAINLINE.

The next unexecuted production boundary is:

`mm_core_init()`
