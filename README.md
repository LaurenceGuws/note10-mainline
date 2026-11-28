# note10-mainline

System integration for mainline Linux on the Samsung Galaxy Note10+ `SM-N975F` (`d2s`, Exynos 9825).

This repository is the **whole-system composition authority**. It does not vendor Linux itself.

## Ownership

### `note10-mainline` owns

- exact component pins used to assemble the current system;
- the early initramfs and its `/init`;
- uniLoader integration/deltas until they justify their own fork;
- deterministic loader and Android BOOT packaging helpers;
- Debian/rootfs handoff work;
- bring-up evidence and system-level documentation.

### Linux kernel source

The Linux source authority is the sibling repository:

`~/personal/exynos-9825-mainline-linux`

GitHub:

`LaurenceGuws/exynos-9825-mainline-linux`

Its canonical proven branch is `note10-mainline`.

### Hardware truth

`~/personal/note10-platform` owns durable hardware, Samsung/Android, partition, recovery and vendor-platform facts that remain true independently of this Linux implementation.

### Operational laboratory

`~/.local/state/workstreams/note10-mainline` is disposable operational state: build trees, temporary worktrees, review packets, frozen test candidates, rollback images and physical receipts.

It is not a source-code home.

## Boot composition

Roughly:

```text
Samsung ROM / proprietary boot chain
        ↓
Android BOOT partition
        ↓
uniLoader
        ↓
Linux Image + d2s DTB + initramfs
        ↓
Linux kernel
        ↓
initramfs /init (PID 1)
        ↓
eventual real Debian rootfs
```

The exact currently accepted component identities live in `components.lock`.

## Repository layout

- `components.lock` exact accepted source/artifact identities
- `initramfs/` tiny early userspace
- `loader/` uniLoader delta/provenance
- `tools/` deterministic host-side composition helpers
- `docs/` system-level bring-up and proof history
- `diagnostics/` historical exported diagnostic patches/evidence
- `kernel/` historical kernel patch exports only; active kernel development belongs in the kernel fork

Generated binaries and compiler build trees do not belong in Git.

## Current proven kernel boundary

Current proven kernel source: `948d674a23f4571228c7b088c49967e83d3efd92`

Current proven BOOT: `76a1de3c0bf42009f482fb82d85ef78a16569167892f40266270e7d1b8c30c00`

MM3B8C4 physically passed the accepted complete stable GREEN/BLUE striped
decoder (operator report). Every selected chunk completes the cumulative
C3 prefix, original enabled head validator and genuine zero-bad gate.
Every selected positive-order tail completes actual enabled validation,
with at least one completed positive-order chunk. Identity/ownership
witness, per-zone managed-page publication, full nonzero traversal and
both outer/public gates are qualified under the independently reviewed
bounded normal/nonfaulting early-boot contract. Global totalram zero,
slab unavailable, IRQs masked, CPU0 continuity and fresh bridge intact.
The read-only firmware guard remains unchanged. No active early-false
or error reporting on the passing lane. No actual individual anon/type
outcome, stat value, release count or arbitrary hardware safety claim.

The C metadata/validation phase is complete, not complete preparation
or allocator readiness. The stop precedes page_cpupid_reset_last(page),
head flags/private normalization and all subsequent preparation.
No buddy insertion, mem_init, slab initialization or UFS I/O proven.
Next phase requires a separately reviewed bounded plan and explicit
cadence reacceptance before further implementation or flash.

Build-input provenance and exact rollback: `docs/CURRENT.md`.
Phase closure: `docs/2026-11-28-mm-core-init-mm3b8c-phase-proof.md`.
Decoder: `docs/bring-up-lineage.html#mm3b8c4`.
