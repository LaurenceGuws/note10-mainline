# Memory-core MM3B7 managed-page publication physical proof

Date: 2026-10-01

## Promoted identities

Kernel source:

`020dd90be78531638adba1c3a03b06133c11cfc4`

Image:

`f1938f9cba67f62c91c07e4dbbcdde8c06c0d3ec7b0dd30b59613398451d6734`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`cdfa665509a50daa3eb59874534d7e9ec18b73050c375808995cf66499c0b17d`

BOOT:

`0dba62ce0f0ff5042e5ed0ad1523db51fdf15de7db50cafd69dad9e9ceed3ba9`

Previous proven MAINLINE / immediate rollback:

`a728519b22415edbdee5f2a61534d98044a5739f7ffa113b1ca8898cee79a52f`

## Reviewed boundary

The physical lane was:

proven MM3B6 path
→ complete page metadata normalization
→ execute production per-zone `managed_pages += nr_pages`
→ runtime-selected ARM64 atomic implementation completes
→ frozen internal stop
→ return before `__free_pages_ok()`
→ complete all chunks and free ranges
→ require accumulated pages > 0
→ wrapper return before global `_totalram_pages` add
→ outer stop before `mem_init()`.

## Exact managed-page seam

Final linked `__free_pages_core()` starts:

`0xffff80008033fc18`

MEMINIT_EARLY metadata loop:

- PageReserved clear/store `0xffff80008033fc4c/fc50`;
- refcount-zero store `0xffff80008033fc54`;
- loop backedge `0xffff80008033fc5c`.

Per-zone managed-pages publication:

- address resolution `0xffff80008033fc60..fc80`;
- LSE `stadd x1,[x9]` at `0xffff80008033fc88`;
- LL/SC fallback `0xffff80008033fd20..fd30`;
- LL/SC success branch `0xffff80008033fd34 -> 0xffff80008033fc8c`;
- LSE falls through to the same `0xffff80008033fc8c`.

Diagnostic rendezvous:

- stop address `0xffff80008033fc8c`;
- stop load `0xffff80008033fc90`;
- frozen true test `0xffff80008033fc94`;
- frozen true returns via `0xffff80008033fca4`.

The `__free_pages_ok()` setup/call exists only on stop-false:

- setup `0xffff80008033fc98/fc9c`;
- call `0xffff80008033fca0`.

Thus both possible atomic implementations complete before the stop, and frozen
true excludes buddy publication.

## Hotplug separation

`CONFIG_MEMORY_HOTPLUG=y`.

The hotplug path:

- branches at `0xffff80008033fc38`;
- executes its original `adjust_managed_page_count()` path;
- rejoins at `0xffff80008033fc98`, after the MM3B7 stop.

Therefore hotplug does not read the diagnostic byte.

No hotplug runtime claim is made.

## Counter separation

MM3B7 intentionally publishes **per-zone** managed-page counters.

It does **not** publish global `_totalram_pages`.

The frozen wrapper still returns before `totalram_pages_add(pages)`, and its
existing nonzero discriminator ensures a successful downstream marker implies
the accumulated release-page count was strictly nonzero.

Thus CYAN proves at least one per-zone managed-page accounting operation
completed, while global `totalram_pages()` remained zero.

No exact per-zone or aggregate managed-page count is claimed.

## Physical observation

Captain reported:

`CYAN · MM3B7 PASS (#00ffff)`

Decoded meaning:

Every processed chunk completed metadata normalization and its real per-zone
`managed_pages += nr_pages` atomic update; whichever ARM64 atomic path ran
completed before the frozen stop; all chunk/range processing completed with
nonzero pages; every core-free call returned before `__free_pages_ok()`; no
buddy insertion occurred; the wrapper returned before global
`_totalram_pages` add; the outer stop returned before `mem_init()`; global
totalram remained zero and slab remained unavailable.

This physically proves:

- the already-proven MM3B6 path completed again;
- complete free-range iteration exhausted again;
- real chunk decomposition executed again;
- every processed page completed metadata normalization;
- every processed chunk completed its production per-zone managed-pages add;
- the runtime-selected ARM64 atomic implementation completed for each chunk;
- accumulated pages remained strictly nonzero;
- at least one managed-page accounting operation therefore completed;
- every core-free call returned through the new stop before
  `__free_pages_ok()`;
- no `__free_pages_ok()` call executed;
- no buddy insertion executed;
- wrapper returned before global `_totalram_pages` add;
- outer stop returned before `mem_init()`;
- global `totalram_pages() == 0`;
- `slab_is_available() == false`;
- IRQ-disabled state, CPU0 continuity, and fresh final bridge survived.

It proves **nothing** about:

- exact per-zone or aggregate managed-page counts;
- `__free_pages_ok()`;
- `free_one_page()`;
- `__free_one_page()`;
- buddy insertion;
- exact range/chunk/order/page counts;
- global `_totalram_pages` add;
- `mem_init()` or later allocator setup.

Build-specific note: generic source contains unaccepted-memory handling later in
`__free_pages_core()`, but the exact linked candidate contains no such call
path between managed-page accounting and `__free_pages_ok()`. No claim is made
about a compiled-out helper.

Result: **PASS**.

## Proven consequence

MM3B7 is promoted to MAINLINE.

The next unexecuted production boundary is `__free_pages_ok()` and the first
buddy-publication work behind it.
