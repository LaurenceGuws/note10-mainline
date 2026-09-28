# note10-mainline agent contract

## Mission

Compose a reproducible mainline-Linux system for the Samsung Galaxy Note10+ SM-N975F (`d2s`, Exynos 9825).

## Repository ownership

This repository owns whole-system composition around Linux:

- component pins;
- initramfs;
- loader integration/deltas;
- BOOT construction;
- rootfs handoff;
- system-level proof and release documentation.

It does **not** own Linux source. Active kernel development belongs in:

`~/personal/exynos-9825-mainline-linux`

The workstream under `~/.local/state/workstreams/note10-mainline` is operational scratch/build/evidence state, not durable source ownership.

`note10-platform` remains the authority for durable hardware, Samsung/Android, partition and recovery facts.

## Source-of-truth rule

No durable runtime source may exist only in a workstream checkout.

If a tested system depends on a local-only delta, either:

1. commit it to its owning durable repository; or
2. export the exact delta and upstream base into this repository with enough identity checks to reconstruct it.

Component hashes alone are not sufficient when the corresponding source cannot be fetched/reconstructed.

## Build/evidence rules

- Pin exact source commits/config/toolchain identities for tested candidates.
- Keep build trees and generated binaries out of Git.
- Keep physical receipts/reviews in the workstream while active; summarize durable results into `docs/`.
- Distinguish proven source state from experimental or diagnostic state.
- Diagnostic candidates must never silently become the canonical system.

## Physical safety

Physical BOOT experiments are attended transactions.

Before mutation:

1. freeze the exact candidate and hash;
2. verify BOOT target geometry;
3. preserve the current proven rollback;
4. use one reviewed BOOT-only write;
5. interpret only the predeclared physical gate;
6. restore/promote explicitly.

Never mutate EFS, modem/radio calibration, bootloader, PIT, userdata or unrelated partitions as part of mainline bring-up.
