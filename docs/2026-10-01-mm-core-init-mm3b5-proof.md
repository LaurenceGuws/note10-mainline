# Memory-core MM3B5 free-range dry-run physical proof

Date: 2026-10-01

## Promoted identities

Kernel source:

`a4d814e1b7bb44068dee8ced09a26811e60149dd`

Image:

`e13bc90040afcce84e629b3f490a7c2fdab7140dcd312b0fd9e8310d49b19bf8`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`750a3d5e24c1debdd756cd9119e9529b110cff4ab7e63b1a4bfc3322f8802e02`

BOOT:

`32ac4df1f433bb592a2f8b788e64c6542fe2c5f685d68859027473b8c7adb985`

Previous proven MAINLINE / immediate rollback:

`fc59b43ecc433399615e6f6e2681e1d67fec3a19897f5b3334a2fcc61901228c`

## Reviewed boundary

The physical lane was:

proven MM3B4 path
→ complete two-phase memmap return
→ execute complete free-range iterator to exhaustion
→ production PFN rounding / lowmem clipping / empty-span checks
→ for each nonempty post-clamp span, frozen bypass before
  `__free_pages_memory()`
→ return exact would-be page count
→ accumulate dry-run page total
→ require accumulated pages > 0
→ wrapper return before `_totalram_pages` add
→ outer stop before `mem_init()`.

No page-release helper executes on the frozen true-bypass lane.

## Exact dry-run helper

Final linked `__free_memory_core()`:

- starts `0xffff80008223a2e8`;
- `PFN_DOWN(end)` at `0xffff80008223a2fc`;
- `max_low_pfn` load at `0xffff80008223a300`;
- `PFN_UP(start)` construction at `0xffff80008223a304/a31c`;
- exact `CONFIG_HIGHMEM=n` clamp at `0xffff80008223a308/a30c`;
- empty/clipped span check at `0xffff80008223a310/a314`;
- empty span returns zero via `0xffff80008223a334`;
- frozen bypass page/load/compare at `0xffff80008223a318/a320/a324`;
- false branch to release lane at `0xffff80008223a328`;
- frozen true lane computes `end_pfn - start_pfn` at
  `0xffff80008223a32c`;
- frozen true lane returns at `0xffff80008223a354`;
- false production lane reaches `__free_pages_memory()` at
  `0xffff80008223a360`.

Frozen `note10_mm3b5_free_core_bypass == 1`, so the release call is
unreachable on the physical lane.

## Iterator / accumulation

Final linked `free_low_memory_core_early()`:

- first `__next_mem_range()` call `0xffff800082239e50`;
- first sentinel check `0xffff800082239e54/e58/e5c`;
- valid path initializes accumulated count at `0xffff800082239e60`;
- current range load at `0xffff800082239e64`;
- dry-run helper call at `0xffff800082239e68`;
- returned would-be pages accumulate at `0xffff800082239e6c`;
- subsequent iterator call `0xffff800082239e90`;
- subsequent sentinel check `0xffff800082239e94/e98/e9c`;
- iterator exhaustion returns accumulated count via x0 at
  `0xffff800082239ebc`.

Thus the helper return is the complete accumulated dry-run page total.

## Strictly nonzero discriminator

Frozen wrapper:

- free-low returns at `0xffff800082239d84`;
- stop load/compare at `0xffff800082239d88/d8c/d90`;
- page-count check `cbnz x0` at `0xffff800082239d98`;
- zero count enters mutation-free `yield`/self-loop at
  `0xffff800082239d9c/da0`;
- nonzero count returns through the wrapper epilogue;
- stop-false paths alone retain `_totalram_pages` add.

Therefore any later RED/LIME marker proves the accumulated dry-run page count
was strictly nonzero.

## Actual release excluded

Unchanged production helpers remain linked:

- `__free_pages_memory()`: 35 instructions / 1 relocation;
- `memblock_free_pages()`: 20 / 3.

Final linked:

- `__free_pages_memory()` starts at `0xffff80008223a430`;
- its `memblock_free_pages()` mutation call is at
  `0xffff80008223a488`.

Both are unreachable while the frozen bypass is true.

## Physical observation

Captain reported:

`LIME · MM3B5 PASS (#7fff00)`

Decoded meaning:

The complete free-range enumeration exhausted; production PFN
rounding/clipping ran; accumulated dry-run page count was strictly nonzero; at
least one nonempty releasable span existed; every such span returned its
would-be page count before release; no `__free_pages_memory()` or
`memblock_free_pages()` call executed; the wrapper returned before
`_totalram_pages` add; the outer stop returned before `mem_init()`; total RAM
remained zero and slab remained unavailable.

This physically proves:

- the already-proven MM3B4 path completed again;
- complete two-phase memmap returned again;
- the full free-range iterator sequence exhausted;
- unchanged `__next_mem_range()` calls returned through that sequence;
- production PFN rounding/clipping and empty-span checks executed;
- accumulated dry-run pages was strictly nonzero;
- at least one nonempty post-clamp releasable PFN span therefore existed;
- each nonempty span contributed exact would-be page count;
- no `__free_pages_memory()` call executed;
- no `memblock_free_pages()` call executed;
- the wrapper returned before `_totalram_pages` add;
- the outer stop returned before `mem_init()`;
- `totalram_pages() == 0`;
- `slab_is_available() == false`;
- IRQ-disabled state, CPU0 continuity, and fresh final bridge survived.

It proves **nothing** about:

- actual page release;
- runtime behavior of `__free_pages_memory()`;
- runtime behavior of `memblock_free_pages()`;
- exact free-range count;
- exact would-be page count;
- `_totalram_pages` add;
- `mem_init()` or later allocator setup.

Result: **PASS**.

## Proven consequence

MM3B5 is promoted to MAINLINE.

The next unexecuted production boundary is the first actual page release inside
`__free_pages_memory()` / `memblock_free_pages()`.
