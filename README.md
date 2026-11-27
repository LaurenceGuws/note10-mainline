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

Current proven kernel source: `1a7581e134a5774fc009a8c9ee99905e700b5702`

Current proven BOOT: `7e1b7a52766837885e316cd583e7b21ac38220b402f8c8994616f778b7323455`

MM3B8B4 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot full-slot decoder. This completes the R1 preparation-prefix phase.
Every processed chunk completes cumulative B3 obligations and the actual
mlocked decision, including existing clear/stat/event operations if taken,
then returns false at the common frozen stop before HWPoison-specific work.
Independent review establishes accounting-callee containment, initialized
boot-time per-CPU storage and IRQ preservation; actual scheduling excluded.
The memcg key remains disabled on the admitted boot lane. PageTail assertion,
tracepoint and KMSAN are configuration-elided, not dynamically exercised.
Complete nonzero traversal and per-zone publication survive. The wrapper
returns before global totalram publication and the outer stop before mem_init.
Totalram remains zero, slab unavailable, IRQs disabled, CPU0 continuity and
fresh bridge intact. No claim of mlocked=true, uncharge, stat values,
computed-pointer correctness, HWPoison, later preparation or buddy insertion.

Next phase: isolate HWPoison and the compound/tail and subsequent metadata
preparation region. New independent phase-plan acceptance required before
implementation. The permanent GREEN decoder remains.

The original B1 GOLD remains inconclusive. Build-input provenance, exact
rollback and physical decoder: `docs/CURRENT.md`,
`docs/2026-11-27-mm-core-init-mm3b8b-phase-proof.md` and
`docs/bring-up-lineage.html#mm3b8b4`.
