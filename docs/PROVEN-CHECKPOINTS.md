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

`05322bfde93238932084fb16c96675b025648db7c7fa7d36bfeae62987e5861a`

It physically proves the one-line `print_kernel_cmdline(saved_command_line)`
path through genuine return and the immediately following second
`parse_early_param()` through its exact `done == 1` fast return.

CL1 preserved the proven NH2 framebuffer bridge, painted ORANGE immediately
after the unchanged logging function returned, painted RED immediately after
the unchanged early-param guard returned, directly rechecked the bounded saved
command-line invariants and CPU0 per-CPU continuity, freshly reloaded the
framebuffer bridge, and painted GREEN only after all checks passed.

Captain reported the decoded GREEN CL1 PASS meaning.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`0e5e5c2c61857f8648bd24c6a4aa9a742ed241a50df6295c168039b261be4974`

The previous checkpoint is NH2 MAGENTA/PINK. It proves
`boot_cpu_hotplug_init()` through genuine return with exact CPU0-only public
booted-once state and stops before `print_kernel_cmdline(saved_command_line)`.

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
