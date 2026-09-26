# 2026-09-26 init_kernel_el / __cpu_setup proof

The reviewed red/white breadcrumb candidate was tested physically on d2s:

- maintained checkpoint:
  `e795b760e59c6f3b6be065538536316acc6c6427`
- BOOT candidate:
  `aca13ad11e80e0c791f4200400b30bf1dc4583b0a1f4f52e5cbaa4717341b530`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The prior framebuffer history remained intact through the physically proven
green idmap/invalidation boundary. The new stage overwrote rows 640..671 red
only after `init_kernel_el` returned and its boot-mode result was saved in
`x20`, then overwrote the same rows white only after `__cpu_setup` returned.

Captain observed the white bottom marker remain unchanged for at least three
minutes while the kernel deliberately held before `__primary_switch`.

That final white state physically proves:

1. the observed EL1 `init_kernel_el` path completed and returned;
2. the returned boot mode was preserved in `x20`;
3. `__cpu_setup` completed and returned;
4. execution reached the deliberate hold before `__primary_switch`;
5. `__enable_mmu` remained unreachable by design.

The final stage intentionally preserved live `x0`, which contains the future
`INIT_SCTLR_EL1_MMU_ON` value that the original path would pass into
`__enable_mmu`.

The host-side samloader transaction showed two noisy intermediate failures
(`Claiming interface failed`, then `Unexpected handshake response`) during this
test. Physical evidence is authoritative: the unique reviewed white marker
appeared, proving the exact diagnostic candidate became active. No conclusion
about a partial flash is drawn from those transport logs.

After observation, Captain re-entered Samsung Download Mode and the exact
rollback BOOT was restored to `BOOT` only. Post-rollback verification showed:

- `/dev/block/by-name/boot -> /dev/block/sda14`;
- size `57,671,680` bytes;
- SHA-256
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`;
- device `d2s`;
- expected 4.14 vendor kernel running;
- Android `sys.boot_completed=1`.

Post-flash ADB returned cleanly after restarting the Home-side ADB server with
`adb kill-server` followed by `adb start-server`. For this bring-up lane, stale
Home ADB state should therefore be treated as the first suspect after a
flash/reboot before diagnosing the phone itself.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/init-kernel-el-cpu-setup-marker/`

The next earned boundary is now `__primary_switch` / `__enable_mmu` itself.
Any next diagnostic must account for the fact that the raw physical framebuffer
marker primitive may not remain valid after MMU enable and must keep later
kernel mapping/relocation work out of scope until that transition is localized.
