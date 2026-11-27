# Current system state

## Proven MAINLINE

Kernel commit: `1a7581e134a5774fc009a8c9ee99905e700b5702`

BOOT: `7e1b7a52766837885e316cd583e7b21ac38220b402f8c8994616f778b7323455`

Promoted checkpoint: **MM3B8B4 GREEN** (2026-11-27).

MM3B8B4 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot full-slot decoder. This completes the R1 preparation-prefix phase.
Every processed chunk completes cumulative B3 obligations and the actual
mlocked decision, including existing clear/stat/event operations if taken,
then returns false at the common frozen stop before HWPoison-specific work.
Independent review establishes accounting-callee containment, initialized
boot-time per-CPU storage and IRQ preservation; actual scheduling excluded.
The memcg key remains disabled on the admitted boot lane. PageTail assertion,
tracepoint and KMSAN are configuration-elided, not dynamically exercised.
Complete nonzero traversal and per-zone publication survive. The wrapper
returns before global totalram publication and the outer stop before mem_init.
Totalram remains zero, slab unavailable, IRQs disabled, CPU0 continuity and
fresh bridge intact. No claim of mlocked=true, uncharge, stat values,
computed-pointer correctness, HWPoison, later preparation or buddy insertion.

Next phase: isolate HWPoison and the compound/tail and subsequent metadata
preparation region. New independent phase-plan acceptance required before
implementation. The permanent GREEN decoder remains.

The release string remains deliberately pinned to original B1 as build
metadata, not source identity. The original B1 GOLD remains inconclusive,
not promoted. See `2026-11-27-mm-core-init-mm3b8b-phase-proof.md`.

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
B4 independent review revalidated the bounded exception (verdict SHA256
`8214884743cfec366de81c4da2f63278be4b663d05f3e0b327c98eb663f5519b`).

## Immediate rollback

Promoted MM3B8B3 BOOT: `1561eb4b691e6cbb7c4c4b727de020c10538aefa936e0cc0cfb3c2fbd9d2203b`

Kernel source: `fe8cbddba495439664c2ca58a64b2bfff76efc8b`

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

See `bring-up-lineage.html#mm3b8b4`.
