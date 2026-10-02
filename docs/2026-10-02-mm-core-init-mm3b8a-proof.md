# Memory-core MM3B8A `__free_pages_ok()` entry-plumbing physical proof

Date: 2026-10-02

## Promoted identities

Kernel source:

`2990c6f85ccf844a9712c05cd941425efdfab01e`

Image:

`4b3b701c6897fbe8dbd006200ce935060b45c57323bb5f7147e845a82b9717a4`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`2fd90520c1c67e4c2b59a27ae77110b7cf8a2bfeba01d0713f703d64f9386909`

BOOT:

`33f39b5412d206990b264736da7ee9b8fa83c970708baab73c14e2e5e16f095e`

Previous promoted MAINLINE / immediate rollback:

`0dba62ce0f0ff5042e5ed0ad1523db51fdf15de7db50cafd69dad9e9ceed3ba9`

Failed MM3B8 is not in the promoted ancestry and remains non-promotable.

## Reviewed boundary

The physical lane was:

promoted MM3B7
→ complete early page metadata normalization
→ complete production per-zone `managed_pages += nr_pages`
→ call `__free_pages_ok(page, order, FPI_TO_TAIL)`
→ ordinary function entry/prologue
→ frozen persistent entry stop as the first semantic/data-dependent operation
→ immediate return
→ no page-derived preparation work
→ complete all chunks/ranges
→ require accumulated release pages > 0
→ wrapper return before global `_totalram_pages` add
→ outer return before `mem_init()`.

## Final linked entry seam

Final linked `__free_pages_ok()` starts:

`0xffff80008033fdd4`

Allowed ordinary ABI/prologue/register-save work ends at:

`0xffff80008033fdf4`

The first semantic/data-dependent operations are:

- `0xffff80008033fdf8`: address the persistent entry-stop byte;
- `0xffff80008033fdfc`: load the stop byte;
- `0xffff80008033fe00`: test frozen true and branch directly to the epilogue.

Frozen true lands at:

`0xffff80008033ffb0`

and returns at:

`0xffff80008033fffc`.

The first page-derived load is only on stop-false:

`0xffff80008033fe04`.

Therefore the physical BLUE lane cannot have executed `page_to_pfn()`,
`page_zone()`, page-flag inspection, memcg inspection, or any inlined
`__free_pages_prepare()` work.

The stop-false `free_one_page()` call is later at
`0xffff80008033ffac` and is unreachable from frozen true.

## Production continuation proof

MM3B8A removes the MM3B7 managed-pages stop and restores production
`__free_pages_core()` continuation into `__free_pages_ok()`.

Final candidate `__free_pages_core()` is:

- 69 instructions;
- 3 relocations;
- 276 bytes.

It was independently compared to a rebuilt pre-diagnostic production source at
`a4d814e1b`; object disassembly is byte-for-byte exact.

The MEMINIT_EARLY path therefore still performs:

- metadata normalization;
- per-zone managed-pages publication;
- production FPI_TO_TAIL call into `__free_pages_ok()`.

## Frozen state

- `note10_mm3b8a_entry_stop = 1` in persistent `.data`;
- `note10_mm3b8a_memblock_stop = 1`;
- `note10_mm3b8a_outer_stop = 1`;
- `reset_managed_pages_done = 0` before target execution.

The wrapper still discriminates zero vs nonzero accumulated release pages and
returns before `totalram_pages_add(pages)`.

Thus per-zone managed-page counters are intentionally published while global
`totalram_pages()` remains zero.

## Physical observation

Captain reported:

`BLUE · MM3B8A PASS (#0000ff)`

Decoded meaning:

The proven MM3B7 path completed again; every processed chunk completed metadata
normalization and per-zone managed-page publication, genuinely called and
entered `__free_pages_ok()`, then returned through the frozen first-operation
entry stop before any page-derived preparation work. The complete range/chunk
traversal exhausted with a nonzero page count; no inlined
`__free_pages_prepare()`, `free_one_page()`, `__free_one_page()`, or buddy
insertion executed. The wrapper returned before global `_totalram_pages`
publication and the outer stop returned before `mem_init()`; global totalram
stayed zero, slab unavailable, interrupts disabled, CPU0 continuity intact, and
the fresh final bridge valid.

This physically proves:

- the complete promoted MM3B7 lane replayed successfully;
- every processed chunk genuinely crossed the `__free_pages_ok()` call boundary;
- ordinary call/entry/prologue/stop/return plumbing is safe for the complete traversal;
- frozen true returns before the first page-derived operation;
- no `__free_pages_prepare()` work executed;
- no `free_one_page()` or `__free_one_page()` executed from this path;
- no buddy insertion occurred;
- accumulated release pages were strictly nonzero;
- global `_totalram_pages` remained withheld;
- `mem_init()` remained unexecuted;
- public IRQ/CPU0/framebuffer continuity survived.

It proves nothing about:

- any internal operation of `__free_pages_prepare()`;
- the specific cause of failed MM3B8 WHITE;
- `free_one_page()` behavior;
- buddy insertion;
- exact range/chunk/order/page counts;
- global totalram publication;
- `mem_init()` or later allocator setup.

Result: **PASS**.

## Proven consequence

MM3B8A is promoted to MAINLINE and remains installed.

The next unexecuted production work is the stop-false `__free_pages_ok()` front porch: production `page_to_pfn(page)` / `page_zone(page)` materialization followed by the inlined `__free_pages_prepare()` prefix.
