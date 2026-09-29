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

Current promoted MAINLINE checkpoint:

`225485e165989cfd7b72f333531230db1409b53478b2023fa5d5ec6e684db719`

It physically proves `smp_prepare_boot_cpu()` through genuine return and the
CPU0 runtime per-CPU base handoff.

P2 preserved the proven P1 framebuffer bridge, painted BLUE immediately after
the unchanged target returned, directly read `TPIDR_EL1`, directly compared it
with `__per_cpu_offset[0]`, freshly reloaded the framebuffer bridge, and
painted WHITE only after the handoff check passed.

Captain observed stable WHITE `0xffffffff` for the accepted three-minute rule.

The accepted P1/P2 phase is complete and this checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`906cc6e762260a4adef6eaecfaee05db6b3dbecaf752c525401630639fdb67b9`

The previous checkpoint is P1 GREEN. It proves `setup_per_cpu_areas()`
through genuine return with exact CPU0..7 runtime offset publication and stops
before `smp_prepare_boot_cpu()`.

### Android RECOVERY checkpoint

Immutable Android-inclusive recovery floor:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Use recovery only when Android/device-side archaeology is required or when the
mainline recovery chain itself is uncertain. It is not the routine rollback
target after a failed mainline experiment.

## Iteration

```text
latest proven MAINLINE checkpoint
    -> plan one bounded tranche
    -> independent plan review
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
