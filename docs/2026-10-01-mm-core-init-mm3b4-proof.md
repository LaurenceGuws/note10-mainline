# Memory-core MM3B4 complete-memmap physical proof

Date: 2026-10-01

## Promoted identities

Kernel source:

`39ac33796e2452a03afc06e032332f4f2d8902be`

Image:

`2569d776901e10eb69cd1e53f73b44f0f226e7c2e9b6243a55b8ba9069699f35`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`496877f8101c365ff4fd21b9bc5a2dc3aebde68a8f8dc2ef9940e3373bf2c62d`

BOOT:

`fc59b43ecc433399615e6f6e2681e1d67fec3a19897f5b3334a2fcc61901228c`

Previous proven MAINLINE / immediate rollback:

`422a9eb189b350b8bdb4be64279eda92beb99a9f7339fea07e4e75789eca4aad`

## Reviewed boundary

The physical lane was:

proven MM3B3 path
→ phase one of `memmap_init_reserved_pages()` stabilizes
→ execute the complete second reserved-region phase
→ natural return from complete `memmap_init_reserved_pages()`
→ caller-side free-low true stop
→ diagnostic count 0 before free-range iteration
→ memblock-wrapper stop before `_totalram_pages` add
→ outer stop before `mem_init()`.

There is no diagnostic stop inside `memmap_init_reserved_pages()`.

The frozen candidate restores the complete function to the exact 90-instruction /
8-relocation production body previously present in MM3B2.

## Complete second phase

Final linked production flow:

- second-phase setup begins at `0xffff80008223a280`;
- reserved-region empty/end test occurs at `0xffff80008223a28c`;
- loop body begins at `0xffff80008223a2a8`;
- `MEMBLOCK_RSRV_NOINIT` is tested at `0xffff80008223a2ac`;
- applicable-region nid/start/end are loaded at `0xffff80008223a2c4/2c8`;
- nid validity is checked at `0xffff80008223a2cc`;
- if required, `early_pfn_to_nid()` is called at
  `0xffff80008223a2d8`;
- its returned nid is consumed at `0xffff80008223a2dc`;
- `memmap_init_reserved_range()` is called at `0xffff80008223a2e8`;
- iteration continues through `0xffff80008223a2f4`;
- the natural epilogue begins at `0xffff80008223a2f8`;
- the natural function return is `0xffff80008223a32c`.

No claim is made that any invalid-nid path or any applicable non-NOINIT region
necessarily existed, nor any exact runtime iteration count.

## Caller-side boundary

After the natural memmap return, `free_low_memory_core_early()` resumes
directly at:

- stop address setup `0xffff800082239e1c`;
- stop load `0xffff800082239e20`;
- stop test `0xffff800082239e24`.

Frozen free-low stop is true.

The true lane reaches the diagnostic-zero epilogue at
`0xffff800082239ee0`, returning count zero.

The first free-range iterator setup exists only on the false branch beginning at
`0xffff800082239e28`.

The first `__next_mem_range()` call is therefore unreachable and remains at:

`0xffff800082239e54`.

## Physical observation

Captain reported:

`PINK · MM3B4 PASS (#ff69b4)`

Decoded meaning:

The proven MM3B3 path completed; complete two-phase
`memmap_init_reserved_pages()` naturally returned; the second reserved-region
phase completed as runtime data required; free-low returned diagnostic count
zero before any free-range iteration; the wrapper returned before
`_totalram_pages` add; the outer stop returned before `mem_init()`; total RAM
remained zero, slab remained unavailable, interrupts remained disabled, CPU0
continuity survived, and the fresh final framebuffer bridge was valid.

This physically proves:

- the already-proven MM3B3 path completed again;
- phase one stabilized again;
- the complete second reserved-region iteration completed for the runtime set;
- every applicable non-NOINIT reserved-region body completed its executed
  `memmap_init_reserved_range()` call;
- any executed invalid-nid path returned from `early_pfn_to_nid()` and used
  that returned nid;
- complete `memmap_init_reserved_pages()` genuinely returned naturally;
- free-range iteration was not entered;
- the free-low diagnostic count returned was zero;
- the memblock wrapper returned before `_totalram_pages` add;
- the outer stop returned before `mem_init()`;
- `totalram_pages() == 0`;
- `slab_is_available() == false`;
- IRQ-disabled state, CPU0 continuity, and fresh final bridge survived.

It proves **nothing** about:

- whether any invalid-nid path necessarily existed;
- whether an applicable non-NOINIT reserved-region body necessarily existed;
- exact runtime region/helper counts;
- free-range iteration;
- `__free_pages_memory()`;
- `_totalram_pages` add;
- `mem_init()` or later allocator setup.

Result: **PASS**.

## Proven consequence

MM3B4 is promoted to MAINLINE.

The next unexecuted production boundary is the free-memory range iteration inside
`free_low_memory_core_early()`.
