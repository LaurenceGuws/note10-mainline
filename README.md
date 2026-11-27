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

Current proven kernel source: `82446e644a543b19c8c72ebd2e99864acb4e5a92`

Current proven BOOT: `5deb82eb52f64057372d768c226a2ae9163324c76d82c7893f62dbe8ec159833`

MM3B8B2 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot full-slot decoder. Every processed chunk completes P1 PFN/zone
materialization, the preparation initializers (KASAN constant, init-on-free
Boolean, compound test and folio value), the physical false FPI_PREPARED guard
and frozen false return. Complete nonzero traversal and per-zone publication
survive. The wrapper returns before global totalram publication and the outer
stop before mem_init. Totalram remains zero, slab unavailable, IRQs disabled,
CPU0 continuity and fresh bridge intact. No computed-pointer correctness or
dereference, specific static-key/compound outcome, B3 work or buddy insertion
is claimed.

Next: MM3B8B3, covering the PageTail assertion/trace/KMSAN and conditional
memcg-kmem prefix, stopping before the mlocked-specific load/test or effects.
Config-elided operations remain described as such; runtime branches are
path-scoped. Permanent GREEN decoder and cumulative obligations remain.

The original B1 GOLD remains inconclusive. Build-input provenance, exact
rollback and physical decoder: `docs/CURRENT.md` and
`docs/bring-up-lineage.html#mm3b8b2`.
