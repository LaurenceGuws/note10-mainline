# 2026-09-26 setup_arch pre-idmap proof

The reviewed pure-blue pre-`cpu_uninstall_idmap` candidate was tested
physically on d2s:

- maintained source checkpoint:
  `60f247474cc643aa2d827e0f596ec28fd3a7f6d9`
- kernel diagnostic commit:
  `a5f1daf067e04c3a224078120b6a96c4df3ceee6`
- BOOT candidate:
  `6f7c807ef733582d1f200a38aac11285d82b0c055447b20071352a058e713204`
- previous proven MAINLINE checkpoint:
  `8dd7d4d2a160b1072f76c2d84ee30dce1bbaa8523fa53a4ecb72f9143f07d591`
- immutable Android RECOVERY checkpoint:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The proven green marker remained after `boot_cpu_init()`, but its deliberate
hold was removed. The original path then printed the kernel banner and entered
arm64 `setup_arch()`.

The safe pre-teardown `setup_arch()` path ran through:

```text
setup_initial_init_mm
*cmdline_p = boot_command_line
kaslr_init
early_fixmap_init
early_ioremap_init
setup_machine_fdt
jump_label_init
parse_early_param
dynamic-SCS state represented by this build
local_daif_restore(DAIF_PROCCTX_NOIRQ)
```

Immediately after `local_daif_restore()`, the candidate painted rows
672..703 pure blue:

`ARGB8888 0xff0000ff`

and deliberately held before any linked instruction materially attributable to
`cpu_uninstall_idmap()`.

The strict final linked boundary was:

```text
msr DAIF                    ffff8000822149bc
BLUE marker begins          ffff8000822149c0
BLUE hold                   ffff800082214a2c

-- unreachable --

first teardown instruction  ffff800082214a34
msr TTBR0_EL1               ffff800082214a50
```

The first unreachable teardown instruction begins `kimage_voffset`
preparation. All reserved-page-table preparation, current/active-mm lookup,
TTBR0 derivation, the TTBR0 write itself, TLB/TCR maintenance, and any later
cpu-switch continuation remain behind the deliberate blue hold.

Captain observed the expected pure-blue band and it remained unchanged for at
least three minutes.

That stable blue state physically proves:

1. all previously proven `start_kernel` work completed;
2. the kernel banner `_printk` returned;
3. `setup_arch()` was genuinely entered;
4. `setup_initial_init_mm()` returned;
5. command-line pointer publication completed;
6. `kaslr_init()` returned;
7. `early_fixmap_init()` returned;
8. `early_ioremap_init()` returned;
9. `setup_machine_fdt()` returned;
10. `jump_label_init()` returned;
11. `parse_early_param()` returned;
12. the dynamic-SCS state represented in this build completed;
13. `local_daif_restore(DAIF_PROCCTX_NOIRQ)` completed;
14. the blue marker executed while the accepted low TTBR0 framebuffer identity
    mapping was still valid;
15. **zero** `cpu_uninstall_idmap()`-attributable linked instruction
    executed;
16. TTBR0 replacement remained untouched.

## Promotion

The exact candidate:

`6f7c807ef733582d1f200a38aac11285d82b0c055447b20071352a058e713204`

is promoted as the newest proven MAINLINE checkpoint and remains installed.

It is now the normal progression parent and routine rollback target.

The previous green MAINLINE checkpoint `8dd7d4d2...` remains preserved as a
historical proof checkpoint. Android `1a78e511...` remains the immutable
RECOVERY checkpoint only.

Because the promoted blue checkpoint deliberately holds before
`cpu_uninstall_idmap()`, no Android/ADB post-flash block-device re-read is
expected. Installed identity is established by the exact reviewed BOOT-only
flash transaction plus the candidate-specific stable blue marker.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/setup-arch-pre-idmap-marker/`

## Evidence-sink frontier

This checkpoint reaches the final safe point for the original low TTBR0
framebuffer identity mapping.

The next original path begins `cpu_uninstall_idmap()`. Once its TTBR0
replacement executes, low virtual address `0xca000000` is no longer a valid
diagnostic framebuffer mapping.

Therefore the next tranche must first establish or prove a replacement
evidence mechanism if it intends to observe execution after TTBR0 teardown.
It must not simply move the existing low-address marker past
`cpu_uninstall_idmap()`.
