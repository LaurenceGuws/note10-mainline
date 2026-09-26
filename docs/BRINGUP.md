# d2s mainline bring-up matrix

Status vocabulary:

- `platform-proven`: hardware behaviour is established under the current vendor/Android substrate.
- `reference-proven`: another mainline-oriented d2s/exynos982x tree reports the capability.
- `enumerates`: mainline sees the device but useful I/O is not yet proven.
- `works`: bounded functional proof on our N975F.
- `accepted`: survives the relevant restart/power/soak boundary and is suitable for the product path.

| # | Subsystem | Platform evidence | Current mainline/reference floor | Our next proof |
|---|-----------|-------------------|----------------------------------|----------------|
| 1 | UFS + rootfs | Samsung UFS at `13d60000.ufs`; vendor source describes HCI, PHY/protector/FMP/clocks/calibration | Exynos9825 reference detects link/device but reports block reads broken; first PRDT-length mismatch is vendor-correlated and patched offline. Physical markers now prove loader copies/branch, earliest `primary_entry`, `record_mmu_state`, `preserve_boot_args`, early stack setup, `__pi_create_init_idmap`, the expected MMU-off page-table `dcache_inval_poc`, `init_kernel_el`, `__cpu_setup`, `__primary_switch`, MMU enable/return, `__pi_early_map_kernel`, the final virtual branch, `init_cpu_task`, VBAR installation, FDT/kimage publication, boot-mode publication, `finalise_el2` return, frame restoration, genuine `start_kernel` entry, the first ordinary `start_kernel` cluster through `boot_cpu_init()`, kernel-banner return, safe pre-teardown `setup_arch()` work, a matching-`PROT_NORMAL_NC` high-TTBR1 framebuffer bridge, complete `cpu_uninstall_idmap()`, `xen_early_init()`, `efi_init()`, the original runtime-selected EFI warning/taint continuation, `arm64_memblock_init()`, then the complete `paging_init()` path through `map_mem()`, `memblock_allow_resize()`, `create_idmap()` and `declare_kernel_vmas()` plus a genuine return to `setup_arch()`. The final spring-green post-`paging_init()` hold remained stable for at least three minutes and is the current promoted MAINLINE checkpoint | plan the next architectural phase beginning at `earlyfb_console_init()`; do not cross it without a new bounded phase plan/review |
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
