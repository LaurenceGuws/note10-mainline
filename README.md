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

Current proven kernel source: `a4e7c0e1fd3aa1028a22e53475cfd43967b5f183`

Current proven BOOT: `839e0ca76b59bc76a95039e48e5f131268f0b2a34a0ae07e6b1820edd84ff3a8`

MM3B8C2 physically passed the accepted complete stable GREEN/BLUE striped
decoder (operator report). Every selected chunk consumes actual completion
after the original order/tail block; at least one positive-order chunk
completes genuine enabled tail validation. The per-chunk identity/ownership
witness, original core normalization/per-zone publication and full nonzero
traversal are qualified under the independently reviewed bounded normal
boot contract. The wrapper returns before global totalram and the outer stop
before mem_init; totalram zero, slab unavailable, IRQs disabled, CPU0 continuity
and fresh bridge intact. The read-only firmware selector guard excludes the
optional unchecked KVM implementation discovery path on the admitted lane.
No measured bitmap, actual count of pages/chunks, head anon/type or head
validation, later preparation, buddy insertion or arbitrary corruption
safety claim.

Next: C3 moves the same stop and completion together past the original
anonymous-folio and page-type blocks, before head validation. Bound any
taken stat decrement, mapping clear and type reset; preserve all C2 gates.
No new mechanism or forced predicate outcomes.

Build-input provenance, exact rollback, accepted C-phase cadence and physical
decoder: `docs/CURRENT.md` and `docs/bring-up-lineage.html#mm3b8c2`.
