# d2s mainline bring-up matrix

Status vocabulary:

- `platform-proven`: hardware behaviour is established under the current vendor/Android substrate.
- `reference-proven`: another mainline-oriented d2s/exynos982x tree reports the capability.
- `enumerates`: mainline sees the device but useful I/O is not yet proven.
- `works`: bounded functional proof on our N975F.
- `accepted`: survives the relevant restart/power/soak boundary and is suitable for the product path.

| # | Subsystem | Platform evidence | Current mainline/reference floor | Our next proof |
|---|-----------|-------------------|----------------------------------|----------------|
| 1 | UFS + rootfs | Samsung UFS at `13d60000.ufs`; vendor source describes HCI, PHY/protector/FMP/clocks/calibration | Exynos9825 reference detects link/device but reports block reads broken; first PRDT-length mismatch is vendor-correlated and patched offline. Physical markers now prove complete `setup_arch()`, complete `mm_core_init_early()`, second linked `jump_label_init()`, `early_security_init()`, exact no-magic bootconfig return, `setup_command_line()` through genuine return, and `setup_nr_cpu_ids()` through genuine return. N1R1 CORAL/ORANGE proves `nr_cpu_ids == 8`, `__num_possible_cpus == 8`, and the exact eight-word possible mask `0xff,0,0,0,0,0,0,0`. P1 GREEN proves `setup_per_cpu_areas()` genuinely returned and CPU0..7 runtime `__per_cpu_offset[]` publication exactly matches the production relation. P2 WHITE proves `smp_prepare_boot_cpu()` genuinely returned and `TPIDR_EL1 == __per_cpu_offset[0]` after the CPU0 runtime per-CPU handoff. NH1 CYAN proves `early_numa_node_init()` genuinely returned and runtime `numa_node == 0` for every possible CPU0..7. NH2 MAGENTA/PINK proves `boot_cpu_hotplug_init()` genuinely returned with public `cpus_booted_once_mask == 0x1,0,0,0,0,0,0,0` while CPU0 remained on its runtime per-CPU base. CL1 GREEN proves one-line `print_kernel_cmdline(saved_command_line)` returned and the second `parse_early_param()` fast-returned through exact `done == 1` pre-state. KP1 WHITE now also proves the first real `parse_args("Booting kernel", static_command_line, ...)` returned with the exact seven-token effects, `print_unknown_bootoptions()` returned, both following init-argument parser branches skipped, and CPU0 continuity remained valid | next linked production boundary is `random_init_early(command_line)`. Map its exact entropy/state effects and stop before the next unreviewed production call. Full framebuffer/console work remains separate future work |
| 2 | panel/display | direct OLED ownership proven through DPU20/DECON0 -> DSIM0 -> MIPI D-PHY -> `SDC_810412`; KWin/Plasma pixels physically proven | Exynos9825 reference reports partial framebuffer output, no proper desktop stack | establish deterministic local framebuffer/DRM output and reach a local compositor without Android |
| 3 | touch | `sec_touchscreen` on event2; physical Plasma interaction proven under vendor kernel | reference reports no touchscreen yet | identify controller/bus/regulators/IRQ/reset from platform facts and bring up native evdev multitouch |
| 4 | battery/charging/thermal | S2MPS19/S2MPS20/MAX77705 power stack and thermal policy mapped on vendor kernel | experimental/unknown in current d2s mainline reference | truthful battery state, wired charging, thermal zones/cooling, unplug/reattach survival |
| 5 | USB | USB recovery/ADB path is a proven independent foothold | USB networking/shell works in current Exynos9825 reference | preserve a deterministic USB debug/recovery channel across early mainline boots |
| 6 | Wi-Fi | BCM4375-class Samsung PCIe Wi-Fi path is known and stable under current substrate | unproven in d2s reference | enumerate PCIe/Wi-Fi, load firmware legally from existing system, associate and pass sustained traffic |
| 7 | GPU / Panfrost | Mali-G76 r0p0, product `0x7211`, 12-core mask `0x770077`, vendor power/clock dependencies mapped | not yet a usable mainline graphics path on d2s | make power/IOMMU/clock/reset description sufficient for Panfrost probe, then render under Wayland |
| 8 | Bluetooth/audio/etc. | existing vendor stack works; not product-critical for first DE | largely untested | recover useful local peripherals after core desktop/power/network path is stable |
| 9 | cellular data | modem/SIM works under Android; useful primarily as outage uplink | untested | expose a data-capable modem path suitable for Linux networking; telephony not required |
| 10 | calls/SMS/IMS | vendor Android functionality only | out of scope for core bring-up | investigate only if earned by later product use |

## Physical marker proof versus soak

A terminal framebuffer marker is the semantic proof once it is clearly stable
and unambiguously decoded. A longer soak is separate evidence for delayed
instability; it is not automatically part of every proof.

Do not cargo-cult a universal three-minute hold. A phase plan may require a
bounded stability interval when that boundary benefits from one, but otherwise
use only enough stable observation to rule out a transient repaint. Historical
three-minute observations remain valid evidence; they are not a permanent
global rule.

For attended runs, Captain should report either the decoded meaning copied from
`bring-up-lineage.html` or the explicit operator signal
`shit I can't exit the boot loop` when no trustworthy terminal marker can be
decoded. Treat the latter as a non-promotable ambiguous/failure state until
investigated.

## First candidate philosophy

The first physical mainline candidate does not need every row above. It does need:

- a deterministic early debug channel;
- a bounded initramfs that can report storage/display/input state;
- a clean path toward the existing Debian userspace rather than a parallel permanent distro;
- an exact rollback recipe to the accepted September BOOT.

A shell-only boot is useful evidence but is not the product milestone.
