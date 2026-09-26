# 2026-09-26 post-preserve_boot_args proof

The third attended mainline BOOT-only experiment tested the independently
reviewed split-stripe candidate:

- maintained repository at test time:
  `9bcd2f36899f57b5be539c3d1240ba2c7fdf70f2`
- BOOT candidate:
  `ac54bba79cf5e796a30b7cb2635e997f27bb0fe48a2120471c601859e3c7f4a6`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The loader again displayed `COPY_DONE / JUMP_READY` with the same handoff
receipt:

```text
target=0x0000000090000000
x0=0x000000008ba476e0
CurrentEL=EL1
DAIF=0x00000000000002c0
SCTLR=0x0000000030c5083a
```

The kernel first painted rows 512..639 magenta, continued through the original
`record_mmu_state` and `preserve_boot_args`, then overwrote rows 576..639 cyan
and deliberately held before `early_init_stack` / idmap setup.

Captain's photo clearly showed the expected final split:

- rows 512..575 magenta;
- rows 576..639 cyan.

The phone had already remained in that unchanged split state for about five
minutes when the photo was taken. The uploaded photo SHA-256 is:

`5c6b5e8a330913c8fbbab55d0565e6e84b2472299b403d9fcafab67f06444aeb`

This physically proves:

1. `record_mmu_state` completed and returned;
2. with the observed `M=0/C=0/EE=0` entry state, it reduced the MMU-at-entry
   state without requiring an SCTLR transition;
3. `preserve_boot_args` stored the boot arguments and preserved the FDT in
   `x21`;
4. its MMU-off `dmb sy` + `dcache_inval_poc` path completed and returned;
5. the system remains stable in the deliberate hold immediately afterward.

The experiment does not yet prove early stack setup, init-idmap construction,
page-table cache invalidation, `init_kernel_el`, `__cpu_setup`, or MMU enable.

After observation, the exact rollback BOOT was restored to `BOOT` only with
`--no-reboot`. Post-rollback verification showed:

- `/dev/block/by-name/boot -> /dev/block/sda14`;
- size `57,671,680` bytes;
- SHA-256
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`;
- device `d2s`;
- expected 4.14 vendor kernel running;
- Android `sys.boot_completed=1`.

Raw flash/rollback/observation receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/post-preserve-marker/`

The earned next diagnostic boundary is immediately after
`__pi_create_init_idmap` and the subsequent MMU-off page-table
`dcache_inval_poc`, still before `init_kernel_el`.
