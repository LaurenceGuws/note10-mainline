# TTBR1 framebuffer evidence-bridge diagnostic

This tranche follows the physically proven pure-blue
`setup_arch()` pre-`cpu_uninstall_idmap()` checkpoint.

Accepted parent kernel diagnostic commit:

`a5f1daf067e04c3a224078120b6a96c4df3ceee6`

New kernel diagnostic commit:

`f7ee20f7687ff8b1851ad06e8c5ee449fb824ec4`

Current proven MAINLINE checkpoint / routine rollback target:

`6f7c807ef733582d1f200a38aac11285d82b0c055447b20071352a058e713204`

Immutable Android RECOVERY checkpoint:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

## Diagnostic purpose

The existing visible framebuffer breadcrumb lives at a low TTBR0 identity
mapping and cannot survive `cpu_uninstall_idmap()`.

This candidate does **not** cross that boundary yet.

Instead it physically proves a replacement TTBR1 evidence sink first.

The accepted low framebuffer alias maps the physical band using
`PROT_NORMAL_NC`. The replacement therefore uses the same ARM memory type:

```c
bridge = early_memremap_prot(0xca3b1000, 0x2d000, PROT_NORMAL_NC);
```

Plain `early_ioremap()` is deliberately not used because arm64 would map the
same physical memory as Device-nGnRE while the old Normal-NC alias still exists.

## Exact source flow

Inside `setup_arch()`:

1. all already-proven safe pre-teardown work runs;
2. the existing pure-blue marker remains;
3. only the blue marker's deliberate hold is removed;
4. `early_memremap_prot()` creates the matching-attribute TTBR1 fixmap;
5. a NULL return enters an immediate infinite `wfe` hold with blue unchanged;
6. a non-NULL return is passed as a read-only register input to the yellow
   marker;
7. yellow is written through the returned high VA;
8. `dsb sy` completes the writes;
9. an infinite yellow `wfe` hold begins;
10. `cpu_uninstall_idmap()` remains linked but unreachable.

`early_memunmap()` is intentionally never reached in this diagnostic so the
new mapping stays alive for the following teardown-crossing tranche.

## Mapping proof

This exact config has:

```text
CONFIG_ARCH_USE_MEMREMAP_PROT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARM64_VA_BITS=48
CONFIG_PGTABLE_LEVELS=4
```

The requested range is:

```text
physical start = 0xca3b1000
size           = 0x2d000
pages          = 45
```

arm64 reserves 65 pages per temporary early-fixmap slot, so the whole band
fits in one slot.

`early_memremap_prot()` passes the protection value directly through
`__pgprot()` into the generic early map path. arm64's temporary fixmap PTEs
belong to the kernel page tables created through `pgd_offset_k()` /
`init_mm`, in the TTBR1 half of this 48-bit VA configuration.

The linked first-slot address in this build is
`0xffffffffff22c000`, but the diagnostic never hardcodes it. The yellow marker
uses only the pointer actually returned by `early_memremap_prot()`.

## Yellow marker

Visible band:

- rows 672..703;
- physical range `0xca3b1000..0xca3de000`;
- length `0x2d000`.

Color:

`ARGB8888 0xffffff00` pure yellow.

Store contract:

- returned high VA is the sole address input;
- direct extended inline asm, no helper;
- 64-bit `str` stores;
- `x11 = 0xffffff00ffffff00`, two yellow pixels per store;
- exact 8-byte stepping until exactly `0x2d000` bytes are written;
- no `dc cvac` on the new `PROT_NORMAL_NC` mapping;
- `dsb sy` after the final store;
- immediate infinite `wfe` hold;
- no `isb` is needed for yellow framebuffer data visibility.

Inline-asm clobbers:

```text
x0, x1, x8,
x10, x11, x12, x13, x14,
cc, memory
```

`x0/x1/x8` are compiler-only anti-hoist clobbers. The yellow marker does not
modify them.

The returned bridge pointer is explicitly bound to **x9** as the fixed
read-only input register. x9 is therefore deliberately omitted from the
clobber list:

```asm
bl   early_memremap_prot
cbnz x0, success

null_hold:
    wfe
    b null_hold

success:
    mov  x9, x0
    mov  x10, x9
    ...
```

x9 is read-only across the yellow asm. Destructive marker scratch is x10..x12
in the frozen binary. The yellow marker therefore physically uses only
x9..x12, satisfying the literal x9..x14 register-confinement contract.

`x18` / SCS, `sp`, `x29`, `x30`, and live compiler-managed
callee-saved state remain untouched by the yellow asm. The
`early_memremap_prot()` call uses the normal balanced SCS call/return path.

## Strict final linked ordering

Frozen linked `setup_arch()` has:

```text
... safe setup_arch work ...
msr DAIF
blue marker + visibility

argument preparation for exact PROT_NORMAL_NC bridge
bl early_memremap_prot
cbnz x0, yellow

NULL:
    wfe
    b NULL

YELLOW:
    mov x9, x0
    mov x10, x9
    build 0xffffff00ffffff00
    end = returned_va + 0x2d000
loop:
    str x11, [x10], #8
    cmp x10, x12
    b.lo loop
    dsb sy
yellow_hold:
    wfe
    b yellow_hold

-- unreachable --

first cpu_uninstall_idmap preparation
kimage_voffset / reserved_pg_dir / current-active_mm preparation
msr TTBR0_EL1
TLB/TCR/cpu-switch continuation
```

Final linked addresses:

- `setup_arch = ffff800082214950`;
- `early_memremap_prot = ffff80008223f53c`;
- map call = `ffff800082214a58`;
- NULL hold = `ffff800082214a60`;
- x9 bridge binding = `ffff800082214a68`;
- yellow begins = `ffff800082214a6c`;
- yellow `dsb sy = ffff800082214a98`;
- yellow hold = `ffff800082214a9c`;
- first teardown-attributable instruction =
  `ffff800082214aa4`;
- `msr TTBR0_EL1 = ffff800082214ac0`.

Therefore both NULL and success paths keep every
`cpu_uninstall_idmap()`-attributable instruction unreachable.

## Frozen source/build gates

- source delta: `arch/arm64/kernel/setup.c` only;
- explicit `<asm/early_ioremap.h>` include;
- patch:
  `kernel-post-idmap-evidence-bridge.patch`;
- patch SHA-256:
  `b05ae02287359767fd315c2b90b486e8a9deae16b0b2f73899d8eb4e6b1aa875`;
- stable patch-id:
  `e764e54a35c632a92ab049ce936bd61d76912c13`;
- patch applies cleanly to accepted parent;
- `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `06698c3c0d7dd42be079698347653e9c414b36e17657675dcfaf75cf19264c64`;
- Image size: `44,247,552` bytes;
- arm64 Image header remains `text_offset=0`, `image_size=0x2b10000`,
  flags `0xa`, ARM64 magic;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

## Frozen loader and BOOT

Two independent builds of the unchanged reviewed JUMP_READY loader source are
byte-identical:

`211a87b053d52690207f2edcd8964570cedb14b918bbc34f889c7dacb0700173`

Loader size remains `44,838,912` bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Frozen diagnostic BOOT:

`ac321737aeeaa886bf6ca2e3fd4263a08a9880fcd3b9be7e216fdb1ad359977e`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/post-idmap-evidence-bridge-r1-a/candidate.img`

Two complete packaging runs reproduce the candidate byte-for-byte.

Packaging uses immutable Android recovery only as the deterministic BOOT
envelope template. Progression/rollback authority remains current proven
MAINLINE `6f7c807e...`.

Against that current proven MAINLINE parent:

- total image size is identical;
- kernel size remains `48,424,984`;
- ramdisk size remains `1,458,687`;
- ramdisk region is byte-identical;
- post-ramdisk tail is byte-identical;
- header drift is checksum/id-only;
- AVB metadata is identical;
- template, parent and candidate reproduce the accepted stale hash-descriptor
  rc=1 after footer and `NONE` vbmeta verification.

## Intended physical interpretation

- previously proven blue fails to appear:
  regression before this bridge tranche;
- blue remains stable and yellow never appears:
  safe pre-teardown setup_arch still completed, but the TTBR1 bridge is not
  proven. Scope investigation to the map call/return, NULL path, returned
  pointer, or yellow marker. `cpu_uninstall_idmap()` remains untouched;
- pure yellow `0xffffff00` visible and stable:
  `early_memremap_prot()` returned a usable high TTBR1 mapping of the exact
  framebuffer band with matching `PROT_NORMAL_NC` attributes, and writes
  through that returned high VA visibly reached the framebuffer while the old
  matching TTBR0 alias was still present. The replacement evidence sink is
  physically proven and `cpu_uninstall_idmap()` remains entirely unreachable;
- yellow appears but later resets:
  bridge creation and visible high-VA access are proven, but do not promote
  until held-state stability is resolved.

On physical PASS, promote exact `ac321737...` as the new proven MAINLINE
checkpoint and leave it installed. On FAIL, restore current proven MAINLINE
`6f7c807e...`, not Android recovery.

Do not cross `cpu_uninstall_idmap()`, call `early_memunmap()`, substitute
Device-nGnRE mapping attributes, add a permanent framebuffer mapping, or expand
into xen/EFI continuation, `arm64_memblock_init`, `paging_init`, UFS,
DTB/initramfs changes, clocks/power/watchdog, normal framebuffer policy,
console design, drivers, or later generic kernel initialization.
