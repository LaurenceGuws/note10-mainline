# note10-mainline

Mainline-Linux bring-up for the Samsung Galaxy Note10+ `SM-N975F` (`d2s`, Exynos 9825).

The product target is not a conventional phone ROM. It is a durable Linux computer with an integrated OLED, touchscreen, battery/charging, local desktop environment and resilient networking. Cellular data is useful later as an outage uplink; telephony is not a bring-up gate.

## Repository boundary

`~/personal/note10-platform` remains the authority for device facts, accepted physical state, vendor/Android archaeology, partition/recovery knowledge and hardware lessons that are true regardless of operating system.

This repository owns only the alternative mainline-Linux substrate:

- upstream/mainline kernel delta and configuration;
- `d2s` device-tree work;
- initramfs and rootfs handoff;
- mainline-specific bring-up tools and evidence summaries;
- patches prepared for upstream submission.

Do not duplicate durable hardware facts here when they belong in `note10-platform`. Link or cite their source instead.

## Product milestone

The first useful milestone is deliberately higher than “kernel boots”:

> Boot Debian into a local graphical session with usable display and touch, trustworthy battery/charging/thermal behaviour, USB and Wi-Fi, with deterministic recovery/debug underneath.

Software rendering is acceptable during early display bring-up. Panfrost becomes a priority once the local desktop path is structurally sound.

## Bring-up order

1. UFS + root filesystem
2. panel/display
3. touch
4. battery gauge + charging + thermal
5. USB
6. Wi-Fi
7. GPU / Panfrost
8. Bluetooth / audio / adjacent peripherals
9. cellular data
10. calls / SMS / IMS only if they become worthwhile

See `docs/BRINGUP.md`.

## Current physical rollback authority

`note10-platform` owns the maintained platform definition. A mainline physical
test additionally requires a fresh read of `/dev/block/by-name/boot` from the
phone itself so rollback follows physical reality rather than a stale copied
hash.

Snapshot checked for the 2026-09-26 UFS bring-up tranche:

- current live BOOT SHA-256: `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`
- BOOT partition/image size: `57,671,680` bytes
- physically verified mapping: `/dev/block/by-name/boot` -> `/dev/block/sda14`
- frozen workstream rollback copy:
  `~/.local/state/workstreams/note10-mainline/rollback/live-boot-20260926-1a78.img`

The live read on 2026-09-26 disagreed with the then-current
`note10-platform/docs/CURRENT_STATE.md` value `b5b6f5cc...`; no mainline phone
mutation had occurred. Re-check the physical BOOT immediately before every
attended mainline test.

## Safety boundary

Mainline research and builds are autonomous offline work. Physical BOOT experiments are attended transactions:

1. freeze the exact candidate and hash;
2. prove the exact BOOT target/mapping and image size offline;
3. preserve the accepted current BOOT as immediate rollback;
4. enter Samsung Download Mode only with Captain present;
5. perform one reviewed BOOT-only write with no unrelated partition mutation;
6. recover the deepest foothold first after boot (USB/pstore/serial as available), then higher services;
7. if the candidate fails, restore the accepted September BOOT rather than improvising on-device repair.

Never treat a successful experimental boot as promotion by itself.

## Layout

- `docs/` current mainline plan, provenance and bring-up results
- `dts/` maintained d2s DTS/DTSI delta when it becomes smaller/clearer than a kernel commit series
- `kernel/config/` reproducible config fragments
- `kernel/patches/` temporary patch queue only; prefer real kernel commits once a delta matures
- `initramfs/` deterministic early userspace and Debian handoff
- `tools/` host-side build/pack/check helpers

Reference kernel clones, build outputs, initramfs staging trees and BOOT candidates belong under the `note10-mainline` workstream, not Git.
