# Memory-core MM3B6 page-metadata normalization physical proof

Date: 2026-10-01

## Promoted identities

Kernel source:

`2d43ec3d73c9ee6203a4b0012d9c100281c8a411`

Image:

`a6ce2d0f8e913e509851dfb800d52d11bbd808a249f4a2fa17d25811399a8334`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`8754d7726900592daad6d43141d2349153ce69756cc04ddf41a9106c6e6193c0`

BOOT:

`a728519b22415edbdee5f2a61534d98044a5739f7ffa113b1ca8898cee79a52f`

Previous proven MAINLINE / immediate rollback:

`32ac4df1f433bb592a2f8b788e64c6542fe2c5f685d68859027473b8c7adb985`

## Reviewed boundary

The physical lane was:

proven MM3B5 path
→ restore actual `__free_pages_memory()` chunk decomposition
→ unchanged `memblock_free_pages()`
→ enter `__free_pages_core(page, order, MEMINIT_EARLY)`
→ complete the per-page metadata loop
→ clear `PageReserved`
→ set each page refcount to zero
→ frozen internal stop
→ return before zone managed-page publication
→ return before `__free_pages_ok()` / buddy insertion
→ complete all chunks and free ranges
→ require accumulated pages > 0
→ wrapper return before `_totalram_pages` add
→ outer stop before `mem_init()`.

## Exact MEMINIT_EARLY seam

Final linked `__free_pages_core()` starts:

`0xffff80008033fc18`

Context split:

- context compare at `0xffff80008033fc30`;
- hotplug branch at `0xffff80008033fc38` jumps to
  `0xffff80008033fcd4`;
- memblock caller supplies `MEMINIT_EARLY == 0`, so physical lane falls
  through into the non-hotplug branch.

MEMINIT_EARLY metadata loop:

- flags load `0xffff80008033fc44`;
- PageReserved clear mask `0xffff80008033fc4c`;
- flags store `0xffff80008033fc50`;
- refcount-zero store `0xffff80008033fc54`;
- page advance `0xffff80008033fc58`;
- loop backedge `0xffff80008033fc5c`.

Frozen diagnostic seam:

- stop page address `0xffff80008033fc60`;
- stop load `0xffff80008033fc64`;
- true test/branch `0xffff80008033fc68`;
- frozen true returns through the common epilogue at
  `0xffff80008033fca4`.

The first stop-false zone/managed-page work begins only at
`0xffff80008033fc6c`.

The first linked managed-pages atomic add is
`0xffff80008033fc94`.

The `__free_pages_ok()` call is
`0xffff80008033fca0`.

Thus frozen true proves metadata normalization while excluding allocator
publication and buddy insertion.

## Restored release chain

Final linked release path:

- valid free span reaches `__free_pages_memory()` at
  `0xffff800082239ed8`;
- `__free_pages_memory()` starts `0xffff80008223a3fc`;
- each chosen chunk calls `memblock_free_pages()` at
  `0xffff80008223a454`;
- `memblock_free_pages()` starts `0xffff800082234480`;
- it sets `w2 = 0` at `0xffff800082234494`;
- it calls `__free_pages_core()` at `0xffff8000822344b0`.

Thus every chunk reached the real MEMINIT_EARLY page-metadata path.

## Hotplug lifetime

`CONFIG_MEMORY_HOTPLUG=y`.

Therefore `__meminitdata` is persistent rather than discardable on this exact
build.

The frozen `note10_mm3b6_page_metadata_stop` is a one-byte persistent data
object and the hotplug branch jumps around its read entirely.

No hotplug-runtime claim is made.

## Physical observation

Captain reported:

`MAGENTA · MM3B6 PASS (#ff00ff)`

Decoded meaning:

Real `__free_pages_memory()` chunking executed; unchanged
`memblock_free_pages()` entered
`__free_pages_core(..., MEMINIT_EARLY)`; every processed page completed
`PageReserved` clear and refcount-to-zero; each core-free call returned at the
frozen stop before managed-page publication and before `__free_pages_ok()` /
buddy insertion; all ranges/chunks completed with nonzero pages; wrapper
returned before `_totalram_pages` add; outer stop returned before
`mem_init()`; total RAM stayed zero and slab remained unavailable.

This physically proves:

- the already-proven MM3B5 path completed again;
- complete free-range iteration exhausted again;
- actual `__free_pages_memory()` chunk decomposition executed;
- unchanged `memblock_free_pages()` calls executed;
- each entered `__free_pages_core(..., MEMINIT_EARLY)`;
- every page in every processed chunk completed PageReserved clear;
- every page in every processed chunk had its refcount set to zero;
- every core-free call returned through the frozen stop before managed-page
  publication;
- no linked zone managed-pages atomic add executed from this path;
- no `__free_pages_ok()` call executed;
- no buddy insertion executed;
- accumulated pages remained strictly nonzero;
- wrapper returned before `_totalram_pages` add;
- outer stop returned before `mem_init()`;
- `totalram_pages() == 0`;
- `slab_is_available() == false`;
- IRQ-disabled state, CPU0 continuity, and fresh final bridge survived.

It proves **nothing** about:

- managed-page publication;
- `__free_pages_ok()`;
- `free_one_page()`;
- `__free_one_page()`;
- buddy insertion;
- exact range/chunk/order/page counts;
- `_totalram_pages` add;
- `mem_init()` or later allocator setup.

Build-specific note: generic source contains unaccepted-memory handling later in
`__free_pages_core()`, but that path is compiled out of this exact linked
candidate. No execution/exclusion claim is made for a nonexistent linked path.

Result: **PASS**.

## Proven consequence

MM3B6 is promoted to MAINLINE.

The next unexecuted production boundary is the zone managed-page accounting in
`__free_pages_core()`, immediately before `__free_pages_ok()`.
