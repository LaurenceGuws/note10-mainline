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

`1a68d65504697c20e5dea7027e8afa38fa25f4bf772012b05f8789ca19782171`

It physically proves `setup_nr_cpu_ids()` through genuine return and exact
eight-CPU publication.

N1R1 repaired the failed N1 diagnostic control-flow edge without changing the
production `setup_nr_cpu_ids()` or `_find_last_bit()` records. After the one
reachable target call, the frozen ladder independently proved:

- fresh `nr_cpu_ids == 8`;
- fresh `__num_possible_cpus == 8`;
- exact eight-word possible mask `0xff,0,0,0,0,0,0,0`;
- fresh non-NULL writable framebuffer bridge.

Captain observed stable CORAL / ORANGE `0xffff7f50` for longer than the
accepted three-minute rule.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

The previous checkpoint is C1 TURQUOISE. It proves `setup_command_line()`
through genuine return with exact published command-line copies and stops
before `setup_nr_cpu_ids()`.

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
