# 2026-09-26 __primary_switch / __enable_mmu proof

The reviewed transient-idmap MMU-boundary candidate was tested physically on
d2s:

- maintained checkpoint:
  `b4234f9859d52bf35881e60f895c6d31b7929a59`
- BOOT candidate:
  `fbb1b88599eb8466afcbab4a42dfbdbae6d9299acebf2240f19558c1d8fdf33f`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The candidate retained all previously proven breadcrumb history and used one
diagnostic-only TTBR0 identity mapping for physical framebuffer block
`0xca200000..0xca400000` as writable NX Normal-NC. The d2s DT `no-map`
reservation and all normal mappings remained unchanged.

The fresh rows 672..703 were staged as:

- blue at first `__primary_switch` instructions;
- yellow after TTBR0/TTBR1 setup immediately before `set_sctlr_el1`;
- red after the complete `set_sctlr_el1` macro, with the MMU enabled;
- orange immediately after `__enable_mmu` returned to `__primary_switch`.

Captain observed the final orange band underneath the previously proven white
band, and it remained unchanged for at least three minutes while the kernel
deliberately held before early stack reset and `__pi_early_map_kernel`.

Because each stage overwrites the same fresh band only after its preceding
boundary completes, the stable orange state physically proves:

1. execution entered `__primary_switch`;
2. the granule checks and original TTBR0/TTBR1 setup completed;
3. the complete original `set_sctlr_el1` macro executed;
4. execution continued with the MMU enabled through the explicit framebuffer
   identity mapping;
5. `__enable_mmu` returned successfully to `__primary_switch`;
6. execution reached the deliberate post-return hold before
   `__pi_early_map_kernel`.

The initial-idmap reservation remained unchanged at 8 pages. Final linked
allocation accounting was 7 pages including the diagnostic framebuffer PMD
table, leaving one 4 KiB page spare.

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

`~/.local/state/workstreams/note10-mainline/physical/primary-switch-enable-mmu-marker/`

The next earned boundary is `__pi_early_map_kernel` and the relocation / final
kernel-map transition. No UFS result is implied by this deliberately held
candidate.
