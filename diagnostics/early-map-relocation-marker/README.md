# __pi_early_map_kernel / relocation / virtual-branch diagnostic

This tranche follows the physical orange proof that `__enable_mmu` returned
successfully with the MMU enabled.

Accepted parent diagnostic commit:

`a0d33b3e53965104a18f487d5707b0e69ea00f1d`

New kernel diagnostic commit:

`ac7bd9e7e56c0785e42bbfddc8f2410ffc4f34c0`

The reviewed JUMP_READY loader source remains unchanged at:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

The existing diagnostic-only TTBR0 framebuffer identity mapping remains
unchanged:

- VA == PA `0xca200000..0xca400000`;
- writable NX Normal-NC;
- d2s DT framebuffer `no-map` unchanged;
- normal kernel mappings unchanged.

`CONFIG_ARM64_LPA2` is not enabled, so the active early-map path does not
replace TTBR0. `map_kernel()` replaces TTBR1 only, relocation touches memory
only, and TLB flushes leave the TTBR0 page tables available for refill. The
same low framebuffer breadcrumb remains valid through this tranche.

## Marker sequence

The previously proven rows 672..703 remain the only fresh evidence band:

`0xca3b1000..0xca3de000`, length `0x2d000`.

The prior orange marker is retained but its deliberate hold is removed.

### Stage 0: immediately before __pi_early_map_kernel

The original early stack reset and call argument setup run unchanged:

```text
adrp x1, early_init_stack
mov  sp, x1
mov  x29, xzr
mov  x0, x20
mov  x1, x21
```

Immediately before `bl __pi_early_map_kernel`, rows 672..703 are overwritten
violet (`ARGB8888 0xff8000ff`). There is no hold.

The marker uses only `x9..x14`, preserving `x0`, `x1`, `x20`, `x21`, `sp`,
`x29`, and `x30`.

### Stage 1: __pi_early_map_kernel returned

Immediately after `bl __pi_early_map_kernel` returns and before the original
`ldr x8, =__primary_switched`, rows 672..703 are overwritten cyan
(`ARGB8888 0xff00ffff`). There is no hold.

The original final branch sequence remains unchanged:

```text
ldr  x8, =__primary_switched
adrp x0, KERNEL_START
br   x8
```

### Stage 2: first __primary_switched instructions

At the first body instructions of high-VA `__primary_switched`, before
`adr_l x4, init_task`, rows 672..703 are overwritten lime
(`ARGB8888 0xff80ff00`) and the CPU deliberately holds in `wfe`.

This marker again uses only `x9..x14` and preserves:

- live `x0` = physical `KERNEL_START`;
- `x20` = boot status;
- `x21` = FDT;
- `sp`, `x29`, and `x30`.

Task setup, VBAR setup, FDT/kimage_voffset stores, final EL work and
`start_kernel` remain unreachable.

## Frozen source/build gates

- patch: `kernel-early-map-relocation-marker.patch`;
- patch SHA-256:
  `a3f34dae4af2c240a4c024609b8563ef707238edcc45f93dd13126092ace87a0`;
- stable patch-id: `523ee4838f72c2d9e7b2c2eaa45a6a5592cd9245`;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `68d6df565fd215d9b35e3145bb108b380b530c3326a5cbed9458627a9a2f9012`;
- Image size: `44,247,552` bytes;
- arm64 Image header unchanged: `text_offset=0`, `image_size=0x2b10000`,
  flags `0xa`, ARM64 magic;
- linked `primary_entry`: `ffff8000822040a0`;
- linked `__primary_switch`: `ffff800082204918`;
- linked `__pi_early_map_kernel`: `ffff800082217780`;
- linked `__primary_switched`: `ffff80008221b2fc`;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

Compiled and linked disassembly confirms exactly:

1. original orange marker completes;
2. early stack/arguments are set;
3. violet marker;
4. `bl __pi_early_map_kernel`;
5. cyan marker after return;
6. untouched `ldr x8 / adrp x0 / br x8`;
7. lime marker as first `__primary_switched` body work;
8. deliberate hold;
9. only later/unreachable task/VBAR/FDT/kimage/start-kernel work.

The compiled `create_init_idmap()` still contains the diagnostic framebuffer
`map_range()` call exactly as in the accepted MMU-enable parent.

## Frozen loader and BOOT

Two independent builds of the unchanged JUMP_READY loader source are
byte-identical:

`01b553acf70b26d6a1901f418285806bdc824fc5396eebfb9f96f49ade2a4159`

The loader remains 44,838,912 bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Rollback/base BOOT:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Frozen diagnostic BOOT:

`025783ccd1b4040f60e1035600f67e98fb81c6fda92627c46ac96d62cdfebf15`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/early-map-relocation-a/candidate.img`

The complete BOOT package reproduced byte-for-byte in a second run. The
kernel slot, zero padding, Android ramdisk, all post-ramdisk bytes,
checksum/id-only header drift and base/candidate AVB behavior remain unchanged.

## Intended physical interpretation

- earlier breadcrumb history missing: regression before this tranche;
- orange remains, no violet: failure during early stack / call-argument setup;
- violet, no cyan: `__pi_early_map_kernel` did not return; the next split stays
  inside FDT/KASLR/map/TTBR1/relocation work;
- cyan, no lime: `__pi_early_map_kernel` returned; failure is confined to the
  final `ldr/adrp/br` sequence or first translated fetch at
  `__primary_switched`;
- lime stable: the final virtual branch succeeded and the first
  `__primary_switched` instructions executed under the final kernel mapping;
- reset after any new color remains scoped to the interval after that color and
  before the next one.

No internal early-map C instrumentation, UFS, DTB-content, initramfs, clock,
power, watchdog, normal framebuffer policy, `start_kernel`, driver init or
later-subsystem change belongs in this candidate.
