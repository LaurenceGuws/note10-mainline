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

Current promoted MAINLINE checkpoint (MM3B8C4 GREEN/BLUE):

`76a1de3c0bf42009f482fb82d85ef78a16569167892f40266270e7d1b8c30c00`

Kernel source: `948d674a23f4571228c7b088c49967e83d3efd92`

C metadata/validation phase complete. Every selected chunk completed
the original enabled head validator and genuine zero-bad decision
after cumulative C3 effects; at least one completed positive-order
chunk and all its selected tails validated. Full nonzero traversal,
per-zone managed publication, withheld global totalram, slab unavailable,
IRQ-masked CPU0 continuity and fresh bridge remain qualified.
No later preparation, buddy insertion or mem_init.

Immediate previous proven checkpoint (MM3B8C3 GREEN/BLUE):

`73edf29e3a160baa227439b45eabb272e4a49ec0ac10a70781f9ec630f818b20`

Kernel source: `af9c624f814aa0763ee9b36eca54a460a949fe6b`

All deeper promoted checkpoints preserved; original B1 GOLD inconclusive,
failed MM3B8 and unflashed preguard C2 are not promoted rollback parents.
See `2026-11-28-mm-core-init-mm3b8c-phase-proof.md`.
New phase plan/review and cadence acceptance required before advancing.

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
