# Current system state

## Proven MAINLINE

Kernel commit: `82446e644a543b19c8c72ebd2e99864acb4e5a92`

BOOT: `5deb82eb52f64057372d768c226a2ae9163324c76d82c7893f62dbe8ec159833`

Promoted checkpoint: **MM3B8B2 GREEN** (2026-11-27).

MM3B8B2 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot full-slot decoder. Every processed chunk completes P1 PFN/zone
materialization, the preparation initializers (KASAN constant, init-on-free
Boolean, compound test and folio value), the physical false FPI_PREPARED guard
and frozen false return. Complete nonzero traversal and per-zone publication
survive. The wrapper returns before global totalram publication and the outer
stop before mem_init. Totalram remains zero, slab unavailable, IRQs disabled,
CPU0 continuity and fresh bridge intact. No computed-pointer correctness or
dereference, specific static-key/compound outcome, B3 work or buddy insertion
is claimed.

Next: MM3B8B3, covering the PageTail assertion/trace/KMSAN and conditional
memcg-kmem prefix, stopping before the mlocked-specific load/test or effects.
Config-elided operations remain described as such; runtime branches are
path-scoped. Permanent GREEN decoder and cumulative obligations remain.

The release string remains deliberately pinned to original B1 as build
metadata, not source identity. Detailed proof history is batched at phase end.
The original B1 GOLD remains inconclusive, not promoted.

## Build-input provenance

Colt built Image/dtbs using the exact public DER certificate in a certificate-only
PEM, explicitly accepted by independent review (2026-11-27, verdict SHA256
`de8164838eb1762a5b5911ccd48862a3ee075fd730c138c6ce89681839d9e113`).
Actual build PEM SHA256
`5e8321cd430f71e46808735c7005628c0d503a225bbff9d08aa2c57ca1209f4b`;
original private-key-bearing PEM SHA256
`34a430f87b6ad0be7cc63d65ff3f17e60ecac3e8d697eded70c6425e0345a1ef`
remains preserved on Home. Identical DER SHA256
`44d337651ba5ec477b204a80582669c1e3c5a2b1af602c101f0ff8f05cd20d9e`.
This is not PEM byte equality, no key generation/transport or module-signing
authority. Recheck at every freeze; drift/signing reopens review.

## Immediate rollback

Promoted MM3B8B1-P1 BOOT: `42cdd5db65209346b2649bd3e58559d434b6008afc44feecc5c9a3bde03dd806`

Kernel source: `5cecb81f77d7121c3370206f898ac50daacb2668`

Separate immutable Android recovery remains
`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`.

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

See `bring-up-lineage.html#mm3b8b2`.
