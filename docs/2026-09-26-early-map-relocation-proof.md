# 2026-09-26 early-map / relocation / virtual-branch proof

The reviewed violet/cyan/lime candidate was tested physically on d2s:

- maintained checkpoint:
  `64659a3cf1d6d2a77542578aaeedf4726e16cbb0`
- BOOT candidate:
  `025783ccd1b4040f60e1035600f67e98fb81c6fda92627c46ac96d62cdfebf15`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The accepted transient TTBR0 framebuffer identity mapping remained unchanged.
Rows 672..703 were reused as the new evidence band:

- violet immediately before `bl __pi_early_map_kernel`;
- cyan immediately after that call returned;
- lime at the first body instructions of high-VA `__primary_switched`.

Captain observed the final lime marker and it remained unchanged for at least
three minutes while the kernel deliberately held before task, VBAR, FDT,
`kimage_voffset`, final-EL, or `start_kernel` work.

Because each marker overwrites the same band only after its preceding boundary
completes, the stable lime state physically proves:

1. early stack reset and the boot-status/FDT argument setup completed;
2. `__pi_early_map_kernel` returned, including its FDT/KASLR setup, kernel
   mapping, TTBR1 replacements and relocation work;
3. the untouched final branch sequence
   `ldr x8, =__primary_switched; adrp x0, KERNEL_START; br x8` executed;
4. the first body instructions of `__primary_switched` executed under the final
   kernel virtual mapping.

The candidate deliberately preserved live `x0` as physical `KERNEL_START`,
`x20` as boot status and `x21` as the FDT pointer at the lime hold.

After observation, the exact rollback BOOT was restored to `BOOT` only.
Post-rollback verification showed:

- `/dev/block/by-name/boot -> /dev/block/sda14`;
- size `57,671,680` bytes;
- SHA-256
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`;
- device `d2s`;
- expected 4.14 vendor kernel running;
- Android `sys.boot_completed=1`.

Home-side ADB was restarted with `adb kill-server` / `adb start-server` before
post-flash verification, and device detection returned cleanly.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/early-map-relocation-marker/`

The next earned boundary is the early `__primary_switched` state setup:
`init_cpu_task`, VBAR setup, FDT and `kimage_voffset` publication, and final EL
handoff, still before `start_kernel`.
