# Current system state

## Proven MAINLINE

Kernel commit: `5cecb81f77d7121c3370206f898ac50daacb2668`

BOOT: `42cdd5db65209346b2649bd3e58559d434b6008afc44feecc5c9a3bde03dd806`

Promoted checkpoint: **MM3B8B1-P1 GREEN** (2026-11-26).

MM3B8B1-P1 physically passed GREEN `#00ff00`, under the independently accepted
fresh-boot full-slot decoder. The original B1 GOLD observation remains
inconclusive. P1 preserves the exact B1 allocator semantics and reserves GREEN
for the active success writer. Every processed chunk completes production PFN
and zone materialization before the frozen first-semantic-operation preparation
stop returns false. Complete range/chunk traversal, nonzero accumulation and
per-zone managed-page publication survive. No preparation initializer/body or
buddy insertion executes. Global totalram stays zero; slab unavailable, IRQs
disabled, CPU0 continuity and fresh final bridge intact. Computed PFN/zone
correctness or a new zone-pointer dereference are not claimed.

The next accepted checkpoint is MM3B8B2, covering the preparation initializers
and false FPI_PREPARED guard. It must retain P1's cumulative obligations and
permanent palette; no B3 operation may execute.

The release string is intentionally pinned to original B1 for byte-equivalence;
actual source identity is the commit above. See the exact decoder and active
workstream physical/review receipts. Detailed proof history is batched at phase end.

## Immediate rollback

Promoted MM3B8A BOOT: `33f39b5412d206990b264736da7ee9b8fa83c970708baab73c14e2e5e16f095e`

Kernel source: `2990c6f85ccf844a9712c05cd941425efdfab01e`

## Rejected diagnostic

MM3B8 source `4d9b5880ba9c55b71b8c19ee627035ef5eb5ecc9` / BOOT
`91a0a62b4dc66fca464a74a9d8d2f07decd62efd3b2ba97807af5ad1a1f54e8e`
settled on WHITE and is non-promotable. It is not in the current promoted
ancestry.

## Framebuffer evidence model

Rows 512..671 are the persistent early-head trail, now muted. Rows 672..703
are the reusable checkpoint slot. Only a uniform stable full-slot GREEN after
a positively identified fresh exact candidate boot is PASS. YELLOW pre-fail,
WHITE entered, RED returned/post-fail. Historical palettes are candidate-specific.

See `bring-up-lineage.html#mm3b8b1-p1`.
