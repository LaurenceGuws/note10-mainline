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

Current proven kernel source: `194e8337497bc3f60339e939a91dafeb57fc663e`

Current proven BOOT: `58d5de4272216f4baa58c78507c07d777aafe2ba008e75acfe0d7d3d27a04d17`

MM3B8C1 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot decoder. Every processed chunk completes cumulative B4 obligations
and the original-page HWPoison/order-zero decision, preserving the genuine
poisoned/order-zero production false return if applicable; other predicate
outcomes reach the common frozen false stop. Complete nonzero traversal and
per-zone publication survive. The wrapper returns before global totalram and
the outer stop before mem_init. Totalram zero, slab unavailable, IRQs disabled,
CPU0 continuity and fresh bridge intact. No claim every chunk read the
diagnostic byte, actual poison/mlocked/order outcome, positive-order tail
execution or validated metadata. No order-driven tail, anon/type/head
validation, later preparation or buddy insertion.

Next: C2 compound/order and complete tail loop. Independently establish
initialized released-range membership, intervening writers/aliases,
nonvacuous normal-lane continuation and bad-page-effect exclusion for every
processed chunk. HOLD if proof fails. Enabled check-pages must be preserved.
No new witness/forcing/error swallowing approved.

Build-input provenance, exact rollback, accepted C-phase cadence and physical
decoder: `docs/CURRENT.md` and `docs/bring-up-lineage.html#mm3b8c1`.
