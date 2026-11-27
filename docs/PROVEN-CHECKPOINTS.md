# Proven checkpoint workflow

Note10 mainline bring-up advances as a ladder of physically proven BOOT
artifacts rather than returning to Android after every successful tranche.

## Authorities

### Proven MAINLINE checkpoint

The newest exact BOOT that has passed:

1. frozen artifact identity;
2. independent final review;
3. attended physical terminal-marker proof;
4. bounded stability observation;
5. durable proof recording.

This is the normal progression parent and routine rollback target for the next
mainline tranche.

Current promoted MAINLINE checkpoint (MM3B8B4 GREEN):

`7e1b7a52766837885e316cd583e7b21ac38220b402f8c8994616f778b7323455`

Kernel source: `1a7581e134a5774fc009a8c9ee99905e700b5702`

R1 preparation-prefix phase complete. Every processed chunk completes the
cumulative PFN/zone, initializer, physical prepared-false, disabled memcg
condition and mlocked decision boundary, then returns false before
HWPoison-specific work. Conditional mlocked accounting operations are
qualified if taken; no claim the branch was taken. The complete nonzero
traversal, per-zone managed-page publication, withheld global totalram,
slab-unavailable, IRQ-disabled CPU0 continuity and fresh bridge remain
proven. No later preparation, buddy insertion or mem_init.

Immediate previous proven checkpoint (MM3B8B3 GREEN):

`1561eb4b691e6cbb7c4c4b727de020c10538aefa936e0cc0cfb3c2fbd9d2203b`

Kernel source: `fe8cbddba495439664c2ca58a64b2bfff76efc8b`

All deeper promoted checkpoints preserved; original B1 GOLD inconclusive
and failed MM3B8 are not promotable or rollback lineage. See
`2026-11-27-mm-core-init-mm3b8b-phase-proof.md`.

### Android RECOVERY checkpoint

Immutable Android-inclusive recovery floor:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Use recovery only when Android/device-side archaeology is required or when the
mainline recovery chain itself is uncertain. It is not the routine rollback
target after a failed mainline experiment.

## Iteration

```text
latest proven MAINLINE checkpoint
    -> plan one bounded phase (2-4 checkpoints)
    -> independent phase-plan review
    -> build/freeze exact candidate
    -> independent frozen-candidate review
    -> install candidate
    -> attended physical proof

PASS:
    promote exact candidate to proven MAINLINE checkpoint
    keep it installed
    continue from it

FAIL:
    restore previous proven MAINLINE checkpoint
    investigate only the newly crossed tranche

RECOVERY NEED:
    restore immutable Android RECOVERY checkpoint
```

## Packaging from a promoted MAINLINE BOOT

The BOOT construction helper uses `magiskboot unpack/repack`.

On this image, `magiskboot` exposes the Android BOOT kernel field as two files:
`kernel` and `kernel_dtb`. Their sizes sum to the exact header `kernel_size`.

`tools/build-boot-candidate` now treats those two extracted files as one
logical kernel field. It writes `uniLoader + zero padding` across that full
field, then lets `magiskboot` repack it.

The helper is regression-proven by self-repacking C1 with C1's own uniLoader
and reproducing exact C1 bytes.

Therefore the current proven MAINLINE BOOT can serve directly as both the
progression parent and deterministic BOOT envelope for the next candidate.
The immutable Android recovery BOOT remains only the emergency recovery floor.
