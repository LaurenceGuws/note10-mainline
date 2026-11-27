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

Current proven kernel source: `af9c624f814aa0763ee9b36eca54a460a949fe6b`

Current proven BOOT: `73edf29e3a160baa227439b45eabb272e4a49ec0ac10a70781f9ec630f818b20`

MM3B8C3 physically passed the accepted complete stable GREEN/BLUE striped
decoder (operator report). Every selected chunk completes the cumulative
C2 order/tail block, original anonymous-folio and page-type decisions,
and any taken bounded per-CPU stat decrement, mapping clear and type
reset. At least one positive-order chunk completes actual enabled tail
validation. Identity/ownership witness, per-zone publication, full nonzero
traversal and both outer/public gates are qualified under the independently
reviewed bounded normal boot contract. Global totalram zero, slab
unavailable, IRQs disabled, CPU0 continuity and fresh bridge intact.
The firmware guard remains unchanged. No claim either new predicate
was true, actual stat value, page count, head validation, later
preparation, buddy insertion or arbitrary corruption safety.

Next: C4 moves the same stop and COMPLETE past the complete original
head-validation/bad-return block, before page_cpupid_reset_last.
Actual enabled validator, fail-closed active error handling and inactive
production error/false-return semantics retained. Two genuine clean
kernel builds required. C4 closes metadata/validation only, not all
preparation. No new mechanism.

Build-input provenance, exact rollback, accepted C-phase cadence and physical
decoder: `docs/CURRENT.md` and `docs/bring-up-lineage.html#mm3b8c3`.
