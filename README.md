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

Current proven kernel source: `5cecb81f77d7121c3370206f898ac50daacb2668`

Current proven BOOT: `42cdd5db65209346b2649bd3e58559d434b6008afc44feecc5c9a3bde03dd806`

MM3B8B1-P1 physically passed GREEN `#00ff00`, under the independently accepted
fresh-boot full-slot decoder. The original B1 GOLD observation remains
inconclusive. P1 preserves the exact B1 allocator semantics and reserves GREEN
for the active success writer. Every processed chunk completes production PFN
and zone materialization before the frozen first-semantic-operation preparation
stop returns false. Complete range/chunk traversal, nonzero accumulation and
per-zone managed-page publication survive. No preparation initializer/body or
buddy insertion executes. Global totalram stays zero; slab unavailable, IRQs
disabled, CPU0 continuity and fresh final bridge intact. Computed PFN/zone
correctness or a new zone-pointer dereference are not claimed.

The next accepted checkpoint is MM3B8B2, covering the preparation initializers
and false FPI_PREPARED guard. It must retain P1's cumulative obligations and
permanent palette; no B3 operation may execute.

See `docs/CURRENT.md` and `docs/bring-up-lineage.html#mm3b8b1-p1`.
