# Current system state

## Proven MAINLINE

Kernel commit:

`2990c6f85ccf844a9712c05cd941425efdfab01e`

BOOT:

`33f39b5412d206990b264736da7ee9b8fa83c970708baab73c14e2e5e16f095e`

Promoted checkpoint: **MM3B8A BLUE**.

The complete promoted MM3B7 release traversal now genuinely calls and enters
`__free_pages_ok()` for every processed chunk. Final machine code loads/tests a
persistent frozen entry-stop byte before the first page-derived operation, and
frozen true returns directly through the ordinary epilogue.

Captain reported the decoded BLUE `#0000ff` PASS meaning.

This proves:

- complete free-range/chunk traversal still exhausts with nonzero pages;
- every processed page completes early metadata normalization;
- every processed chunk completes production per-zone managed-page publication;
- every processed chunk genuinely calls and enters `__free_pages_ok()`;
- ordinary call/entry/prologue/return plumbing completes for every invocation;
- no page-derived preparation work executes on the frozen true path;
- no inlined `__free_pages_prepare()` work executes;
- no `free_one_page()`, `__free_one_page()`, or buddy insertion executes from this path;
- the wrapper returns before global `_totalram_pages` publication;
- the outer stop returns before `mem_init()`;
- global `totalram_pages() == 0` and slab remains unavailable;
- IRQ-disabled state, CPU0 continuity, and the fresh framebuffer bridge survive.

See `2026-10-02-mm-core-init-mm3b8a-proof.md`.

## Immediate rollback

Previous promoted MM3B7 BOOT:

`0dba62ce0f0ff5042e5ed0ad1523db51fdf15de7db50cafd69dad9e9ceed3ba9`

Kernel source:

`020dd90be78531638adba1c3a03b06133c11cfc4`

## Rejected diagnostic

MM3B8 source `4d9b5880ba9c55b71b8c19ee627035ef5eb5ecc9` / BOOT
`91a0a62b4dc66fca464a74a9d8d2f07decd62efd3b2ba97807af5ad1a1f54e8e`
settled on WHITE and is non-promotable. It is not in the current promoted
ancestry.

## Current next boundary

The first page-derived work inside `__free_pages_prepare()`.

A fresh bounded phase plan is required before crossing that boundary.

## Framebuffer evidence model

Rows 512..671 are the intentional persistent early-head boot trail.

Rows 672..703 are the single reusable final-state checkpoint slot.

See `FRAMEBUFFER-BREADCRUMBS.md` and `bring-up-lineage.html`.
