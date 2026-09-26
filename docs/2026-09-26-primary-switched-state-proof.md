# 2026-09-26 pre-start_kernel state-setup proof

The reviewed amber/blue/white `__primary_switched` candidate was tested
physically on d2s:

- maintained checkpoint:
  `d7ded7a055a4bc8f3f6d6235033e43d2ca310e5f`
- BOOT candidate:
  `bc4a78a9dfad41992777b42913394735e893a709e52e06309d482478a1307f94`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The previously proven lime marker at the first `__primary_switched` body
instructions was retained but allowed to continue. The same rows 672..703 were
then reused as:

- amber immediately after `init_cpu_task`;
- blue immediately after `msr vbar_el1; isb`;
- white immediately after `finalise_el2` and the original frame pop, before
  `bl start_kernel`.

Captain observed the final white marker and it remained unchanged for at least
three minutes while the kernel deliberately held before `start_kernel`.

Because each marker overwrites the same band only after its preceding boundary
completes, the stable white state physically proves:

1. `init_cpu_task` completed;
2. the real init-task stack is live;
3. the final task frame record was created;
4. shadow-call-stack state was loaded;
5. per-CPU / TPIDR_EL1 setup completed;
6. VBAR_EL1 installation and its `isb` completed;
7. the original frame push completed;
8. `__fdt_pointer` publication completed;
9. `kimage_voffset` derivation and publication completed;
10. `set_cpu_boot_mode_flag` returned;
11. the unchanged observed-EL1 `finalise_el2` path returned;
12. the original frame pop completed;
13. execution reached the deliberate hold immediately before
    `start_kernel`.

`start_kernel` remained unreachable by construction.

The diagnostic marker preserved the live SCS state in `x18` as well as the
remaining architectural state requested by the independent review.

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
post-flash verification.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/primary-switched-state-marker/`

The next earned boundary is `start_kernel` entry itself. No conclusion about
later generic-kernel initialization or UFS is implied by this deliberately
held candidate.
