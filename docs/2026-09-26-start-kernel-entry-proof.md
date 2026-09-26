# 2026-09-26 start_kernel entry proof

The corrected reviewed rose-entry candidate was tested physically on d2s:

- maintained source checkpoint:
  `cb39799f900a962e74a28bac437e04fa93923a0a`
- kernel diagnostic commit:
  `fbf4fedfc4f45d5fbdfadafb3e38c3aa42ce4eb0`
- BOOT candidate:
  `3992fcbfd834db4e63da7a6350f4a7d99a4002528e636ccc053faf3a63051c0e`
- previous proven MAINLINE checkpoint:
  `bc4a78a9dfad41992777b42913394735e893a709e52e06309d482478a1307f94`
- immutable Android RECOVERY checkpoint:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The previous white pre-`start_kernel` hold was removed and the original
`bl start_kernel` was allowed to execute. Inside `start_kernel()`, the first
explicit source statement is a direct arm64 inline-assembly marker that paints
rows 672..703 rose (`ARGB8888 0xffff4080`) and immediately holds.

The corrected linked order is:

```text
start_kernel:
    compiler SCS push
    compiler stack/frame setup
    CONFIG_INIT_STACK_ALL_ZERO stack-slot zeroing
    rose marker
    rose visibility barriers
    rose wfe hold
    adrp/add &init_task
    bl set_task_stack_end_magic
```

The one compiler-only `x0` clobber used to enforce that order emits no x0
instruction in the marker. The marker machine code still physically uses only
`x9..x14` and does not touch `x18`, `sp`, `x29`, or `x30`.

Captain observed the expected rose / dark-pink-near-red band in rows 672..703.
It remained unchanged for at least three minutes.

That stable rose state physically proves:

1. the previously proven pre-`start_kernel` path completed;
2. the original `bl start_kernel` branch and target fetch succeeded;
3. `start_kernel`'s compiler-generated shadow-call-stack push completed;
4. compiler stack/frame setup completed;
5. required stack auto-initialization completed;
6. the first explicit source marker executed through the still-valid transient
   TTBR0 framebuffer identity mapping;
7. no ordinary `start_kernel` operation executed.

The first ordinary operation, `set_task_stack_end_magic(&init_task)`, remains
unreachable after the deliberate rose hold.

## Promotion

This proof is the first completed iteration under the proven-checkpoint
workflow.

The exact candidate:

`3992fcbfd834db4e63da7a6350f4a7d99a4002528e636ccc053faf3a63051c0e`

is promoted as the newest proven MAINLINE checkpoint and remains installed.

It is now the normal progression parent and routine rollback target.

The previous MAINLINE checkpoint `bc4a78a9...` remains preserved as historical
proof, while Android `1a78e511...` remains the immutable RECOVERY checkpoint
for Android/device-side archaeology or recovery-chain uncertainty.

Because the promoted rose checkpoint deliberately holds before ordinary kernel
initialization, there is no Android/ADB post-flash block-device re-read.
Installed identity is established by:

- exact reviewed candidate identity;
- successful BOOT-only samloader transaction;
- no automatic reboot during flash;
- attended reboot into the candidate;
- the candidate-specific rose marker;
- stable held-state observation for at least three minutes.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/start-kernel-entry-marker/`

The next earned boundary is ordinary early `start_kernel` initialization.
The current low framebuffer evidence sink expires later inside arm64
`setup_arch()` at `cpu_uninstall_idmap()`, so the next plan must respect that
hard boundary.
