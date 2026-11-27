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

Current proven kernel source: `fe8cbddba495439664c2ca58a64b2bfff76efc8b`

Current proven BOOT: `1561eb4b691e6cbb7c4c4b727de020c10538aefa936e0cc0cfb3c2fbd9d2203b`

MM3B8B3 physically passed GREEN `#00ff00` under the independently accepted
fresh-boot full-slot decoder. Every processed chunk completes cumulative B2
obligations and the configured preparation prefix through the memcg condition,
then returns false at the frozen stop. Independent source/linked review
establishes the disabled memcg key and excludes its early enable path; the
optional uncharge and its transitive effects do not execute. PageTail assertion,
tracepoint and KMSAN are configuration-elided, not dynamically exercised.
Complete nonzero traversal and per-zone publication survive. The wrapper
returns before global totalram publication and the outer stop before mem_init.
Totalram remains zero, slab unavailable, IRQs disabled, CPU0 continuity and
fresh bridge intact. No computed-pointer correctness, specific initializer
alternative, mlocked operation, later preparation or buddy insertion claimed.

Next: MM3B8B4, through the complete production mlocked block, stopping before
any HWPoison-specific load/test. Both optimized mlocked outcomes must reach
the frozen false-return boundary; no claim the taken branch actually ran
without independent evidence. Permanent GREEN decoder remains.

The original B1 GOLD remains inconclusive. Build-input provenance, exact
rollback and physical decoder: `docs/CURRENT.md` and
`docs/bring-up-lineage.html#mm3b8b3`.
