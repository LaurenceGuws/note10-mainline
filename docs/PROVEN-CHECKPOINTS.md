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

`33f39b5412d206990b264736da7ee9b8fa83c970708baab73c14e2e5e16f095e`

Kernel source:

`2990c6f85ccf844a9712c05cd941425efdfab01e`

MM3B8A BLUE physically proves the complete promoted MM3B7 release traversal can
genuinely call and enter `__free_pages_ok()` for every processed chunk and
return through a frozen first-operation entry stop before the first page-derived
load. No `__free_pages_prepare()`, `free_one_page()`, `__free_one_page()`, or
buddy insertion executes on the frozen lane. Per-zone managed pages remain
published while global `_totalram_pages` stays zero, and the outer stop remains
before `mem_init()`.

Captain reported the decoded BLUE `#0000ff` PASS meaning. The checkpoint remains
installed.

Previous proven MAINLINE checkpoint:

`0dba62ce0f0ff5042e5ed0ad1523db51fdf15de7db50cafd69dad9e9ceed3ba9`

The previous checkpoint is MM3B7 CYAN. It proves complete metadata normalization
and per-zone managed-page publication while stopping before `__free_pages_ok()`.

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
