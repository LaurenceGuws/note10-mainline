# d2s mainline bring-up matrix

Status vocabulary:

- `platform-proven`: hardware behaviour is established under the current vendor/Android substrate.
- `reference-proven`: another mainline-oriented d2s/exynos982x tree reports the capability.
- `enumerates`: mainline sees the device but useful I/O is not yet proven.
- `works`: bounded functional proof on our N975F.
- `accepted`: survives the relevant restart/power/soak boundary and is suitable for the product path.

| # | Subsystem | Platform evidence | Current mainline/reference floor | Our next proof |
|---|-----------|-------------------|----------------------------------|----------------|
| 1 | UFS + rootfs | Samsung UFS at `13d60000.ufs`; vendor source describes HCI, PHY/protector/FMP/clocks/calibration | Exynos9825 reference detects link/device but reports block reads broken; first PRDT-length mismatch is vendor-correlated and patched offline. Physical markers now prove loader copies/branch, earliest `primary_entry`, `record_mmu_state`, `preserve_boot_args`, early stack setup, `__pi_create_init_idmap`, expected MMU-off page-table cache maintenance, `init_kernel_el`, `__cpu_setup`, `__primary_switch`, MMU enable/return, `__pi_early_map_kernel`, final virtual branch, `init_cpu_task`, VBAR/FDT/kimage/boot-mode publication, `finalise_el2` return, genuine `start_kernel` entry, early ordinary `start_kernel` work, safe pre-teardown `setup_arch()` work, high-TTBR1 framebuffer evidence bridge, complete idmap teardown/Xen/EFI/memblock/paging phases, corrected pre-slab earlyfb deferral, complete ACPI/DT selection, complete `bootmem_init()`, complete `request_standard_resources()`, complete PSCI DT initialization, and now complete `arm64_rsi_init()` bypass: the physically proven PSCI/SMCCC state excludes SMC, unchanged RSI logic takes the initial non-SMC return, no RSI SMC/version/config/memory work runs, and a stable CYAN post-return hold proves the actual `bl init_cpu_ops(0)` remains uncrossed. `rsi_present` is claimed only as not enabled by `arm64_rsi_init()` on this path | next architectural boundary is the actual `bl init_cpu_ops` with argument 0 (`init_bootcpu_ops()`); do not cross it without a new bounded phase plan/review. Full framebuffer/console work remains a separate future phase only after complete `mm_core_init()` returns |
| 2 | panel/display | direct OLED ownership proven through DPU20/DECON0 -> DSIM0 -> MIPI D-PHY -> `SDC_810412`; KWin/Plasma pixels physically proven | Exynos9825 reference reports partial framebuffer output, no proper desktop stack | establish deterministic local framebuffer/DRM output and reach a local compositor without Android |
| 3 | touch | `sec_touchscreen` on event2; physical Plasma interaction proven under vendor kernel | reference reports no touchscreen yet | identify controller/bus/regulators/IRQ/reset from platform facts and bring up native evdev multitouch |
| 4 | battery/charging/thermal | S2MPS19/S2MPS20/MAX77705 power stack and thermal policy mapped on vendor kernel | experimental/unknown in current d2s mainline reference | truthful battery state, wired charging, thermal zones/cooling, unplug/reattach survival |
| 5 | USB | USB recovery/ADB path is a proven independent foothold | USB networking/shell works in current Exynos9825 reference | preserve a deterministic USB debug/recovery channel across early mainline boots |
| 6 | Wi-Fi | BCM4375-class Samsung PCIe Wi-Fi path is known and stable under current substrate | unproven in d2s reference | enumerate PCIe/Wi-Fi, load firmware legally from existing system, associate and pass sustained traffic |
| 7 | GPU / Panfrost | Mali-G76 r0p0, product `0x7211`, 12-core mask `0x770077`, vendor power/clock dependencies mapped | not yet a usable mainline graphics path on d2s | make power/IOMMU/clock/reset description sufficient for Panfrost probe, then render under Wayland |
| 8 | Bluetooth/audio/etc. | existing vendor stack works; not product-critical for first DE | largely untested | recover useful local peripherals after core desktop/power/network path is stable |
| 9 | cellular data | modem/SIM works under Android; useful primarily as outage uplink | untested | expose a data-capable modem path suitable for Linux networking; telephony not required |
| 10 | calls/SMS/IMS | vendor Android functionality only | out of scope for core bring-up | investigate only if earned by later product use |

## First candidate philosophy

The first physical mainline candidate does not need every row above. It does need:

- a deterministic early debug channel;
- a bounded initramfs that can report storage/display/input state;
- a clean path toward the existing Debian userspace rather than a parallel permanent distro;
- an exact rollback recipe to the accepted September BOOT.

A shell-only boot is useful evidence but is not the product milestone.
