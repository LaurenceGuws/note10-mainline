# 2026-09-26 init-idmap / MMU-off invalidation proof

The reviewed breadcrumb candidate was tested physically on d2s:

- maintained checkpoint:
  `1603800ff8c84f9f312b9fc903c8a8bbaaf059b6`
- BOOT candidate:
  `8da260e154b65be965fb44b929ec5eff5f8c4f4eb4e01e8c41a31faf1d0ce728`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The loader receipt remained unchanged and visible:

```text
COPY_DONE / JUMP_READY
target=0x0000000090000000
x0=0x000000008ba476e0
CurrentEL=EL1
DAIF=0x00000000000002c0
SCTLR=0x0000000030c5083a
```

The final framebuffer state was:

- rows 512..575 magenta;
- rows 576..607 cyan;
- rows 608..639 green.

The green lower quarter remained unchanged for at least three minutes while
the kernel deliberately held before `init_kernel_el`.

Because Stage A paints rows 608..639 yellow only after
`__pi_create_init_idmap` returns, and Stage B overwrites that same range green
only after the observed `x19=0` page-table `dcache_inval_poc` returns, the final
green state proves all of the following physically:

1. early stack setup completed;
2. `__pi_create_init_idmap` returned;
3. execution followed the expected `x19=0` MMU-off path;
4. the page-table `dcache_inval_poc` call returned;
5. execution reached the deliberate hold before `init_kernel_el` and remained
   stable there.

The physical photo uploaded by Captain has SHA-256:

`602d26890448bc27a565448ff62009a4585b2cafb52fa1edfbf976eef6917598`

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/idmap-breadcrumb-marker/`

After observation, Captain re-entered Samsung Download Mode and the exact
rollback BOOT was restored to `BOOT` only. Post-rollback verification showed:

- `/dev/block/by-name/boot -> /dev/block/sda14`;
- size `57,671,680` bytes;
- SHA-256
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`;
- device `d2s`;
- expected 4.14 vendor kernel running;
- Android `sys.boot_completed=1`.

The next earned boundary is now `init_kernel_el` / `__cpu_setup`, still before
`__primary_switch` and MMU enable. No UFS conclusion is drawn from this
deliberately held candidate.
