# early __primary_switched state-setup breadcrumb diagnostic

This tranche follows the physical lime proof that `__pi_early_map_kernel`
returned, the final virtual branch succeeded, and the first body instructions
of `__primary_switched` executed under the final kernel mapping.

Accepted parent diagnostic commit:

`ac7bd9e7e56c0785e42bbfddc8f2410ffc4f34c0`

New kernel diagnostic commit:

`6eb4fa9a81ab027fc373ad1f3c874ddb7a6507cd`

The accepted diagnostic TTBR0 framebuffer identity mapping remains unchanged,
as do the d2s DT `no-map` reservation and all normal mappings.

## Marker sequence

The already-proven lime marker at the first `__primary_switched` body
instructions remains as the baseline, but its deliberate hold is removed.

The same rows 672..703 are reused:

`0xca3b1000..0xca3de000`, length `0x2d000`.

Every new marker uses only `x9..x14` and the established
`raw_dcache_line_size` + `dc cvac` + `dsb sy; isb` visibility sequence.

### Stage A: init_cpu_task completed

The original:

```text
adr_l x4, init_task
init_cpu_task x4, x5, x6
```

runs unchanged. Immediately afterward, before vector setup, rows 672..703 are
overwritten amber (`ARGB8888 0xffffa000`). There is no hold.

At this point the real init-task stack is live, the final task frame record has
been created, SCS state is loaded into `x18`, and TPIDR_EL1/per-CPU setup has
completed. The marker touches only `x9..x14`, preserving live `x0`, `x18`,
`x20`, `x21`, `sp`, `x29`, and `x30`.

### Stage B: VBAR setup completed

The original:

```text
adr_l x8, vectors
msr   vbar_el1, x8
isb
```

runs unchanged. Immediately after the `isb`, before the original frame push,
rows 672..703 are overwritten blue (`ARGB8888 0xff0080ff`). There is no hold.

Again only `x9..x14` are used, leaving the task-stack/SCS/per-CPU state and
`x0`, `x18`, `x20`, `x21`, `sp`, `x29`, and `x30` untouched.

### Stage C: all pre-start_kernel state completed

The remainder of the original pre-start path then runs unchanged:

```text
stp x29, x30, [sp, #-16]!
mov x29, sp
str_l x21, __fdt_pointer, x5
adrp x4, _text
sub x4, x4, x0
str_l x4, kimage_voffset, x5
mov x0, x20
bl set_cpu_boot_mode_flag
mov x0, x20
bl finalise_el2
ldp x29, x30, [sp], #16
```

Immediately after the original frame pop and before `bl start_kernel`, rows
672..703 are overwritten white (`ARGB8888 0xffffffff`) and the CPU
deliberately holds in `wfe`.

`start_kernel` remains unreachable. The white marker uses only `x9..x14` and
preserves `x0`, `x18`, `x20`, `x21`, `sp`, `x29`, and `x30`.

The frozen config has no KASAN early-init call in this path. The physical boot
was proven EL1, so the unchanged `finalise_el2` call should follow its normal
EL1 immediate-return path; the call is not bypassed or special-cased.

## Frozen source/build gates

- patch: `kernel-primary-switched-state-marker.patch`;
- patch SHA-256:
  `00a09d25528f1c97c4bdfbab68729612a5439659658480d3fbd86e744347c883`;
- stable patch-id: `6f1cbafd21ab3e3f432d9f199ce977a23d4639b2`;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `75dedb9e58f26dbb99fe4bef9a970ae8bb3d2f8677e85fd269a130a29adf9dc0`;
- Image size: `44,247,552` bytes;
- arm64 Image header remains `text_offset=0`, `image_size=0x2b10000`, flags
  `0xa`, ARM64 magic;
- linked `__primary_switched`: `ffff80008221b2fc`;
- linked `start_kernel`: `ffff800082210468`;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

Linked disassembly confirms exactly:

1. proven lime marker completes and no longer holds;
2. `init_cpu_task` switches to the real task stack and loads `x18` SCS state;
3. amber marker executes without touching `x18`;
4. VBAR write + ISB execute unchanged;
5. blue marker executes without touching `x18`;
6. original frame/FDT/kimage/boot-mode/finalise sequence executes;
7. original frame pop executes;
8. white marker executes;
9. deliberate white hold;
10. only after the unreachable hold, the original `bl start_kernel` remains
    linked.

The framebuffer mapping source is byte-identical to the accepted lime parent.

## Frozen loader and BOOT

Two independent builds of the unchanged reviewed JUMP_READY loader source are
byte-identical:

`fd0298aaa2c3920ab8b759f296a339c9c186dfd154a5d7277c8623ee18564058`

The loader remains 44,838,912 bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Rollback/base BOOT:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Frozen diagnostic BOOT:

`bc4a78a9dfad41992777b42913394735e893a709e52e06309d482478a1307f94`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/primary-switched-state-a/candidate.img`

The complete BOOT package reproduced byte-for-byte in a second run. The
kernel slot, zero padding, Android ramdisk, all post-ramdisk bytes,
checksum/id-only header drift and base/candidate AVB behavior remain unchanged.

## Intended physical interpretation

- proven lime remains, no amber: `init_cpu_task` did not complete;
- amber, no blue: task/SCS/per-CPU setup completed; failure is confined to
  vector-address setup, `msr VBAR_EL1`, or the following `isb`;
- blue, no white: task and VBAR setup completed; failure is confined to the
  frame push, FDT publication, `kimage_voffset`, boot-mode publication,
  unchanged EL1 `finalise_el2` return path, or final frame pop;
- white stable: every pre-`start_kernel` operation completed and
  `start_kernel` remains unreachable; the next earned boundary is
  `start_kernel` entry itself;
- reset after any new color remains scoped to the interval after that marker
  and before the next boundary.

No UFS, DTB-content, initramfs, clock, power, watchdog, normal framebuffer
policy, console, `start_kernel` internals, driver init, or later-subsystem
change belongs in this candidate.
