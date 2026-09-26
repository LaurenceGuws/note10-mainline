# setup_arch pre-idmap teardown marker diagnostic

This tranche follows the physically proven pure-green ordinary `start_kernel`
checkpoint.

Accepted parent kernel diagnostic commit:

`4bba17ee5449b9d815f9ec99b5955d50d47f7dcb`

New kernel diagnostic commit:

`a5f1daf067e04c3a224078120b6a96c4df3ceee6`

Current proven MAINLINE checkpoint / routine rollback target:

`8dd7d4d2a160b1072f76c2d84ee30dce1bbaa8523fa53a4ecb72f9143f07d591`

Immutable Android RECOVERY checkpoint:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The accepted transient TTBR0 framebuffer identity mapping remains unchanged.

## Diagnostic change

The proven pure-green marker after `boot_cpu_init()` remains, but only its
deliberate hold is removed. The original path then executes banner printing and
enters arm64 `setup_arch()`.

Inside `setup_arch()`, all safe work before TTBR0 teardown runs unchanged:

```text
setup_initial_init_mm
*cmdline_p = boot_command_line
kaslr_init
early_fixmap_init
early_ioremap_init
setup_machine_fdt
jump_label_init
parse_early_param
dynamic_scs_init state represented by this build
local_daif_restore(DAIF_PROCCTX_NOIRQ)
```

Immediately after `local_daif_restore()` and before `cpu_uninstall_idmap()`, a
direct arm64 extended-inline-assembly marker overwrites rows 672..703 pure
blue:

`ARGB8888 0xff0000ff`

The marker then deliberately holds in `wfe`.

No instruction materially attributable to `cpu_uninstall_idmap()` is allowed
to execute before blue.

## Marker mechanism

The blue marker:

- uses no C operands;
- calls no helper;
- machine instructions physically use only `x9..x14`;
- declares `x0`, `x1`, and `x8` as compiler-only scheduling clobbers;
- declares `x9..x14`, `cc`, and `memory` clobbered;
- does not physically modify `x0`, `x1`, or `x8`;
- preserves `x18` / live SCS state;
- preserves `sp`, `x29`, `x30`;
- preserves live `x19` and `x20` / compiler-managed callee-saved state;
- preserves the DAIF state established immediately before the marker;
- reuses exact framebuffer range `0xca3b1000..0xca3de000`, length `0x2d000`;
- uses the established CTR-derived cache-line-size calculation, `dc cvac`,
  `dsb sy; isb` visibility sequence;
- holds immediately after blue becomes visible.

The compiler-only clobbers are deliberate. In the parent build Clang hoisted
`adrp x8, kimage_voffset` across `local_daif_restore()`. The strict scheduling
contract prevents that and all other materially teardown-attributable work from
crossing the blue statement.

## Strict linked ordering proof

Final linked `start_kernel` continuation shows:

```text
pure-green marker
banner argument preparation
bl _printk
prepare &command_line
bl setup_arch
```

Final linked `setup_arch` ordering is:

```text
compiler SCS/frame setup
setup_initial_init_mm
cmdline publication
kaslr_init
early_fixmap_init
early_ioremap_init
setup_machine_fdt
jump_label_init
parse_early_param
msr DAIF, #0xc0 state

PURE BLUE MARKER
blue visibility barriers
blue wfe hold

only after unreachable hold:
adrp kimage_voffset
reserved_pg_dir address preparation
load kimage_voffset
mrs SP_EL0
load current->active_mm
derive reserved TTBR0 physical address
msr TTBR0_EL1
TLB/TCR/cpu-switch continuation
```

Exact linked addresses in the frozen Image:

- `start_kernel = ffff800082210468`;
- banner `_printk` call = `ffff800082210594`;
- `setup_arch` call = `ffff80008221059c`;
- `setup_arch = ffff800082214950`;
- visible `msr DAIF` = `ffff8000822149bc`;
- blue marker begins = `ffff8000822149c0`;
- blue hold begins = `ffff800082214a2c`;
- first teardown-attributable instruction = `ffff800082214a34`;
- `msr TTBR0_EL1` = `ffff800082214a50`.

Therefore a stable blue state proves all safe pre-teardown `setup_arch` work
completed and **zero** `cpu_uninstall_idmap()`-attributable linked instruction
executed.

## Frozen source/build gates

- source delta:
  - `init/main.c`;
  - `arch/arm64/kernel/setup.c`;
- patch: `kernel-setup-arch-pre-idmap-marker.patch`;
- patch SHA-256:
  `b8551548fe2f9de3c5eb0a137561c79db8cc3d8fbe55f964da6e7ecb9f8c070a`;
- stable patch-id:
  `adfd92206c82aa8d6709e4d436454ae40355dcfd`;
- patch applies cleanly to accepted parent;
- source `git diff --check`: pass;
- strict checkpatch: 0 errors, 0 warnings, 0 checks;
- Android clang: 21.0.0 `r563880c`;
- config SHA-256:
  `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`;
- Image SHA-256:
  `d7a31fd2a08255f9ad803648ce502c9b1438944d32dd26150aff274e662ee55b`;
- Image size: `44,247,552` bytes;
- arm64 Image header remains `text_offset=0`, `image_size=0x2b10000`, flags
  `0xa`, ARM64 magic;
- accepted TTBR0 mapping source is byte-identical to the promoted green parent;
- unchanged d2s DTB SHA-256:
  `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`;
- unchanged initramfs SHA-256:
  `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`.

## Frozen loader and BOOT

Two independent builds of the unchanged reviewed JUMP_READY loader source are
byte-identical:

`771a03c30769fb795763b94ae641f3903a77f09f8184cba43ffdc45741f94e3e`

Loader size remains `44,838,912` bytes with exact embedded offsets:

- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

Frozen diagnostic BOOT:

`6f7c807ef733582d1f200a38aac11285d82b0c055447b20071352a058e713204`

Workstream path:

`~/.local/state/workstreams/note10-mainline/boot-candidate/setup-arch-pre-idmap-a/candidate.img`

Two complete packaging runs reproduce the candidate byte-for-byte.

Packaging uses immutable Android recovery only as the deterministic BOOT
envelope template. Progression/rollback authority remains current proven
MAINLINE `8dd7d4d2...`.

Against that current proven MAINLINE parent:

- total image size is identical;
- kernel size remains `48,424,984`;
- ramdisk size remains `1,458,687`;
- ramdisk region is byte-identical;
- post-ramdisk tail is byte-identical;
- header drift is checksum/id-only;
- AVB metadata is identical;
- template, parent and candidate all reproduce the accepted stale
  hash-descriptor rc=1 after footer and `NONE` vbmeta verification.

## Intended physical interpretation

- proven green remains but blue does not appear:
  the ordinary `start_kernel` cluster remains proven. Failure is confined to
  banner printing, `setup_arch` entry/prologue, safe pre-teardown helpers,
  cmdline publication, DAIF restoration, or the blue marker itself. Do not
  investigate `cpu_uninstall_idmap()` or anything later;
- pure blue `0xff0000ff` visible and stable:
  banner printing returned; `setup_arch` was genuinely entered; every safe
  pre-teardown operation through `local_daif_restore` completed; zero
  `cpu_uninstall_idmap()`-attributable linked instruction executed; TTBR0
  replacement remains untouched;
- blue appears but does not remain stable:
  the pre-teardown boundary is reached, but do not promote until held-state
  stability is resolved.

On physical PASS, promote exact `6f7c807e...` as the new proven MAINLINE
checkpoint and leave it installed. On FAIL, restore current proven MAINLINE
`8dd7d4d2...`, not Android recovery.

Do not execute or cross `cpu_uninstall_idmap()`, add a replacement framebuffer
mapping, or expand into xen/EFI continuation, `arm64_memblock_init`,
`paging_init`, UFS, DTB/initramfs changes, clocks/power/watchdog, normal
framebuffer policy, console design, drivers, or later generic kernel
initialization in this tranche.
