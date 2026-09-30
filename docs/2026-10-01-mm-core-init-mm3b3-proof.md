# Memory-core MM3B3 memmap first-phase physical proof

Date: 2026-10-01

## Promoted identities

Kernel source:

`a01d8c43a32dc1f8975a463836f354a1f564eae6`

Image:

`f6b6c0a51343c945805d5762ae800b17deec1469885d3189c2e967b54c9b488c`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`3d31d07a0548e06b0cd7b670aaa5c74db95a5d482d972ac8fe142c10db8a908f`

BOOT:

`422a9eb189b350b8bdb4be64279eda92beb99a9f7339fea07e4e75789eca4aad`

Previous proven MAINLINE / immediate rollback:

`5d8f2867d24e6c67c50e4c02c41f043dec5071e52e36636898ea32bc1d609c60`

## Reviewed boundary

The physical lane was:

proven MM3B2 path
→ enter `memmap_init_reserved_pages()`
→ execute the first memory-region / reserved-node phase
→ repeat whenever `memblock.reserved.max` changed
→ fall through only after saved/current `reserved.max` equality
→ internal true stop
→ return before the second reserved-region loop
→ free-low diagnostic count 0 before free-range iteration
→ wrapper stop before `_totalram_pages` add
→ outer stop before `mem_init()`.

Frozen private state:

- `note10_mm3b3_outer_stop = 1`
- `reset_managed_pages_done = 0`
- `note10_mm3b3_memblock_stop = 1`
- `note10_mm3b3_free_low_stop = 1`
- `note10_mm3b3_memmap_stop = 1`

## Stabilization proof

Final linked control flow:

- saved/current `reserved.max` compare at `0xffff80008223a274`;
- `b.ne` at `0xffff80008223a27c` jumps back to phase-one repeat;
- equality is the only fall-through to the memmap stop at
  `0xffff80008223a280/284/288`;
- frozen stop is true;
- physical true lane returns through the common epilogue before phase two;
- false stop branch begins phase-two setup at `0xffff80008223a28c`.

Thus the physical marker proves first-phase stabilization, not merely completion
of one iteration.

## Ignored helper return boundary

`memblock_set_node()` returns an integer, but this production caller ignores it.

Final linked code:

- calls `memblock_set_node()` at `0xffff80008223a22c`;
- immediately reloads loop state at `0xffff80008223a230`;
- never tests returned `w0`.

Therefore physical GOLD proves every executed `memblock_set_node()` call
genuinely returned. It does not prove an ignored return code of zero.

No exact runtime count is claimed for regions, repeats, NOMAP regions, or helper
calls.

## Physical observation

Captain reported:

`GOLD · MM3B3 PASS (#ffd700)`

Decoded meaning:

The proven path entered `memmap_init_reserved_pages()`; its first
memory-region phase completed and repeated until saved/current
`memblock.reserved.max` matched; the internal stop returned before the second
reserved-region loop; downstream diagnostic stops returned before free-range
release, the `_totalram_pages` add, and `mem_init()`; total RAM remained zero,
slab remained unavailable, interrupts remained disabled, CPU0 continuity
remained intact, and the fresh final framebuffer bridge was valid.

This physically proves:

- the already-proven MM3B2 path completed again;
- `memmap_init_reserved_pages()` was entered;
- its first phase completed for the runtime memory-region set;
- any encountered NOMAP region completed its executed
  `memmap_init_reserved_range()` call;
- each executed `memblock_set_node()` call genuinely returned;
- if `memblock.reserved.max` grew, phase one repeated;
- the stop was reached only after saved/current `reserved.max` equality;
- the second reserved-region phase was not entered;
- free-range iteration was not entered;
- the free-low diagnostic return count was zero;
- the memblock wrapper returned before `_totalram_pages` add;
- the outer stop returned before `mem_init()`;
- `totalram_pages() == 0`;
- `slab_is_available() == false`;
- IRQ-disabled state, CPU0 continuity, and fresh final bridge survived.

It proves **nothing** about:

- ignored `memblock_set_node()` return codes being zero;
- whether any NOMAP region necessarily existed;
- exact region/repeat/helper-call counts;
- the second reserved-region loop;
- phase-two `early_pfn_to_nid()`;
- phase-two reserved-range initialization;
- free-range release;
- `_totalram_pages` add;
- `mem_init()` or later allocator setup.

Result: **PASS**.

## Proven consequence

MM3B3 is promoted to MAINLINE.

The next unexecuted production boundary is the second reserved-region phase
inside `memmap_init_reserved_pages()`.
