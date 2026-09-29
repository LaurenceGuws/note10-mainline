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

`4734a2bd0d20ef81c5d63141bda90e7b606a8bf902a0f34b1f1c81c109848655`

It physically proves `early_numa_node_init()` through genuine return and exact
runtime NUMA-node publication for every possible CPU0..7.

NH1 preserved the proven P2 framebuffer bridge, painted RED immediately after
the unchanged target returned, directly checked runtime `numa_node` for all
eight CPUs, freshly reloaded the framebuffer bridge, and painted CYAN only
after all eight values were exactly zero.

Captain reported the decoded CYAN meaning and the accepted stability gate
passed.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`225485e165989cfd7b72f333531230db1409b53478b2023fa5d5ec6e684db719`

The previous checkpoint is P2 WHITE. It proves `smp_prepare_boot_cpu()` through
genuine return with `TPIDR_EL1 == __per_cpu_offset[0]` and stops before
`early_numa_node_init()`.

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
