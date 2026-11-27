# Current system state

## Proven MAINLINE

Kernel commit: `fe8cbddba495439664c2ca58a64b2bfff76efc8b`

BOOT: `1561eb4b691e6cbb7c4c4b727de020c10538aefa936e0cc0cfb3c2fbd9d2203b`

Promoted checkpoint: **MM3B8B3 GREEN** (2026-11-27).

MM3B8B3 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot full-slot decoder. Every processed chunk completes cumulative B2
obligations and the configured preparation prefix through the memcg condition,
then returns false at the frozen stop. Independent source/linked review
establishes the disabled memcg key and excludes its early enable path; the
optional uncharge and its transitive effects do not execute. PageTail assertion,
tracepoint and KMSAN are configuration-elided, not dynamically exercised.
Complete nonzero traversal and per-zone publication survive. The wrapper
returns before global totalram publication and the outer stop before mem_init.
Totalram remains zero, slab unavailable, IRQs disabled, CPU0 continuity and
fresh bridge intact. No computed-pointer correctness, specific initializer
alternative, mlocked operation, later preparation or buddy insertion claimed.

Next: MM3B8B4, through the complete production mlocked block, stopping before
any HWPoison-specific load/test. Both optimized mlocked outcomes must reach
the frozen false-return boundary; no claim the taken branch actually ran
without independent evidence. Permanent GREEN decoder remains.

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
B3 independent review revalidated the bounded exception (verdict SHA256
`fba60e0c200defbf4488b97def175d8a4f5186fcd7fda5306eddbce71620af57`).

## Immediate rollback

Promoted MM3B8B2 BOOT: `5deb82eb52f64057372d768c226a2ae9163324c76d82c7893f62dbe8ec159833`

Kernel source: `82446e644a543b19c8c72ebd2e99864acb4e5a92`

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

See `bring-up-lineage.html#mm3b8b3`.
