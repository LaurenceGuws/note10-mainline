# note10-mainline agent contract

## Mission

Turn the Samsung SM-N975F / d2s into a maintainable mainline-Linux computer. Optimise for a real local Debian desktop with touch, battery-backed operation and reliable networking, not for Android compatibility or phone-feature completeness.

## Ownership

- `note10-platform` owns hardware truth, current accepted physical state, vendor-kernel archaeology and recovery knowledge.
- `note10-mainline` owns the mainline kernel/DTS/config/initramfs delta.
- The phone lab owns large/private installation and rollback artifacts.
- The workstream owns disposable reference clones and build products.

When a new finding is fundamentally about the hardware rather than mainline implementation, record it in `note10-platform` and reference it here.

## Priority

1. UFS/rootfs
2. display/panel
3. touch
4. battery/charging/thermal
5. USB
6. Wi-Fi
7. Panfrost/GPU
8. Bluetooth/audio/other useful peripherals
9. cellular data
10. calls/SMS/IMS

Do not let modem/telephony completeness distract from the compute-appliance product.

## Upstream posture

- Start from contemporary upstream-oriented work, but verify every borrowed change against this exact N975F.
- Keep provenance for every non-upstream patch.
- Prefer small reviewable commits that could plausibly be submitted upstream.
- Do not cargo-cult vendor CAL/PM/clock code into mainline. First identify the actual missing binding/clock/reset/power/firmware contract.
- Avoid a permanent private mega-fork. If the project requires a kernel fork during bring-up, keep the commit series rebaseable and source-shaped like upstream Linux.

## Build/evidence rules

- Record exact source commit, config inputs, compiler identity and output hashes for any candidate worth testing.
- Build trees and binary artifacts do not belong in Git.
- A candidate must have a deterministic debug/forensics path before physical testing.
- Distinguish “driver binds”, “device enumerates”, “I/O works”, and “survives soak/power transition”. Do not collapse them into one “working” label.

## Physical safety

`note10-platform` owns the maintained platform state, but a physical mainline
test must freeze rollback from a fresh read of the phone itself. If maintained
documentation and the live BOOT disagree, stop promotion and use the physical
read as the candidate/rollback boundary until the platform bookkeeping is
reconciled.

Before any physical mainline test, freeze a candidate receipt that records and
verifies the exact current live BOOT mapping, SHA-256 and size on the phone.
That frozen image is the immediate rollback target for the experiment.

For the tranche being prepared on 2026-09-26, the verified snapshot is:

- BOOT SHA-256: `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`
- size: `57,671,680` bytes
- workstream rollback copy: `~/.local/state/workstreams/note10-mainline/rollback/live-boot-20260926-1a78.img`

No unattended Download Mode transition, BOOT flash, raw partition write or reboot into an unreviewed candidate. Offline research/build work may proceed autonomously. Stop for Captain at the physical mutation boundary or for a genuine architecture choice with material long-term consequences.

Never mutate EFS, modem/radio calibration, bootloader, PIT, userdata, or unrelated partitions as part of mainline bring-up.
