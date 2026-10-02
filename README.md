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

Current proven kernel source:

`2990c6f85ccf844a9712c05cd941425efdfab01e`

Current proven BOOT:

`33f39b5412d206990b264736da7ee9b8fa83c970708baab73c14e2e5e16f095e`

MM3B8A physically passed BLUE `#0000ff`. It proves the complete promoted
MM3B7 memory-release traversal genuinely calls and enters `__free_pages_ok()`
for every processed chunk and returns through a frozen first-operation entry
stop before any page-derived preparation work. No `__free_pages_prepare()`,
`free_one_page()`, `__free_one_page()`, or buddy insertion executes on the
proven lane.

The next unexecuted production boundary is the first page-derived work inside
`__free_pages_prepare()`.

See `docs/CURRENT.md` and `docs/2026-10-02-mm-core-init-mm3b8a-proof.md`.
