# Memory-core MM3B2 clear-hotplug physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`f77a59fc855171a8bdd5981c9ffd43f2c6083dda`

Image:

`d5df7f4fe019bfde873e5be2978c00e9d1c67633fe001395242081f509ac12d5`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`5a83e45b67b1a4651435e52ac4dad95798ac4cffb3ba7c6ad20d5338a43e0f2f`

BOOT:

`5d8f2867d24e6c67c50e4c02c41f043dec5071e52e36636898ea32bc1d609c60`

Previous proven MAINLINE / immediate rollback:

`241a2a701a7655ce575c2bfca1acb12f259da84836a6b04769fa8b8f0908acd4`

Rejected MM3B:

`c3fb912a89088c5c8dec54123cd6acfc26a9bc6a4b82ba02f7a5c0d132c7a672`

Rejected whole-MM3:

`6daec9ff790a348fbb26eec9103c6596ba8d6cd3fea2da15457a28771fd88aa6`

Both rejected lanes remain non-promotable.

## Reviewed boundary

The physical lane was:

proven MM3B1 path
→ enter `free_low_memory_core_early()`
→ unchanged production `memblock_clear_hotplug(0, -1)`
→ helper true stop
→ return diagnostic count 0 before `memmap_init_reserved_pages()`
→ memblock-wrapper true stop before `_totalram_pages` add
→ outer true stop before `mem_init()`.

Frozen private state:

- `note10_mm3b2_outer_stop = 1`
- `reset_managed_pages_done = 0`
- `note10_mm3b2_memblock_stop = 1`
- `note10_mm3b2_free_low_stop = 1`

Untouched production records:

- `reset_all_zones_managed_pages()`: 29 instructions / 5 relocations
- `memblock_clear_hotplug()`: 53 / 7
- `memmap_init_reserved_pages()`: 90 / 8
- `__free_pages_memory()`: 35 / 1

## Ignored production return code

The production source invokes:

`memblock_clear_hotplug(0, -1);`

as a bare statement. Its integer return value is deliberately ignored.

The frozen machine code matches that semantics:

- production call at `0xffff800082239e14`;
- next instructions only form/load/test the helper-stop byte;
- there is no compare, test, or use of returned `w0` before the diagnostic branch;
- the diagnostic true lane independently sets count register `x20 = 0`;
- that zero is later moved to return register `x0`.

Therefore the physical MM3B2 result proves the production call **genuinely
returned**, but does not prove that its production return code was zero or that
the clear-hotplug operation independently succeeded.

## Physical observation

Captain reported:

`ORANGE · MM3B2 PASS (#ff7f00)`

Decoded meaning:

The proven MM3B1 path completed; `free_low_memory_core_early()` was entered;
unchanged production `memblock_clear_hotplug(0, -1)` genuinely returned; the
diagnostic helper returned count 0 before `memmap_init_reserved_pages()`; the
wrapper returned before the `_totalram_pages` add; the outer stop returned
before `mem_init()`; total RAM remained zero, slab remained unavailable,
interrupts remained disabled, CPU0 continuity remained intact, and the fresh
final framebuffer bridge was valid.

This physically proves:

- the already-proven MM3B1 path completed again;
- `free_low_memory_core_early()` was entered;
- unchanged production `memblock_clear_hotplug(0, -1)` genuinely returned;
- the helper diagnostic true branch returned count exactly zero before
  `memmap_init_reserved_pages()`;
- `memmap_init_reserved_pages()` was not reached;
- the memblock-wrapper true stop returned before either linked
  `_totalram_pages` add implementation;
- the outer true stop returned before `mem_init()`;
- `totalram_pages() == 0` still held;
- `slab_is_available() == false` still held;
- IRQ-disabled state survived;
- CPU0 continuity survived;
- the fresh final framebuffer bridge was valid.

It proves **nothing** about:

- the production `memblock_clear_hotplug()` return code being zero;
- `memmap_init_reserved_pages()`;
- free-range iteration;
- `__free_pages_memory()`;
- the later `_totalram_pages` add;
- `mem_init()`;
- later allocator initialization.

Result: **PASS**.

## Proven consequence

MM3B2 is promoted to MAINLINE.

The next unexecuted production boundary is:

`memmap_init_reserved_pages()`
