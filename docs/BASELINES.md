# Mainline reference baselines

This file records external implementation baselines worth studying. They are references, not authority for the N975F.

## Exynos9825 d2s mainline tree

Reference: `EithanAsulin/exynos-9825-mainline-linux`.

Observed public state on 2026-09-26:

- Linux 7.2.0-rc7 based tree;
- d2s/d2x/d1-family intent;
- reaches a postmarketOS shell over USB networking;
- partial framebuffer output;
- UFS link/device detection, but block reads reported broken;
- touchscreen not yet working;
- power management explicitly experimental.

This is the most immediately relevant d2s implementation reference. Study its delta commit-by-commit before adopting anything.

## postmarketOS Exynos9820 kernel package

postmarketOS binary repositories currently publish `linux-postmarketos-exynos9820-7.2.0-r0` for aarch64. Treat this as evidence of an active Exynos9820 mainline-oriented packaging lane and inspect its exact pmaports/kernel provenance before borrowing config or patches.

## Existing d2s postmarketOS port

Reference: `EithanAsulin/PostmarketOS-Samsung-d2s`.

Its older public status reports BOOT/kernel/USB/display progress while GUI/SSH were not working and touch/Wi-Fi/Bluetooth/modem/power/Wayland remained untested. The newer Exynos9825 kernel tree above supersedes it as the stronger kernel reference, but its packaging and device files may still contain useful boot-image/device integration clues.

## Vendor/Lineage references

`note10-platform` and the external phone lab remain the authoritative local sources for:

- exact Samsung/Lineage kernel revision and device tree;
- partition and BOOT format;
- panel/touch/power/UFS/GPU topology;
- accepted recovery mechanics;
- current physical hardware behaviour.

Do not substitute an Internet device tree for those local facts.
