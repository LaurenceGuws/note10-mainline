# Kernel integration

Active Linux development does not live in this directory.

Canonical kernel source:

`~/personal/exynos-9825-mainline-linux`

GitHub:

`LaurenceGuws/exynos-9825-mainline-linux`

The `kernel/patches/` directory is historical provenance from the earliest bring-up tranche. Do not add new active kernel changes here. Real kernel changes belong in the Linux fork as normal Git commits.

The exact kernel commit consumed by the whole-system build is pinned in `../components.lock`.
