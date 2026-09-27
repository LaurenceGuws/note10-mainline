# 2026-09-27 ACPI / DT-selection proof

This phase started from the physically proven corrected pre-slab earlyfb
checkpoint and crossed only:

1. `acpi_table_upgrade()`;
2. `acpi_boot_table_init()`;
3. the expected DT-selected `unflatten_device_tree()` branch.

It stopped immediately before `bootmem_init()`.

## Starting authority

Starting proven MAINLINE:

`10eb19209719a38b677e01f5dc5afa89b14839312b2d8eae7d295f344f0068cc`

Starting proven source:

`a12563a55083651b11db5963d6f3064c07d7991a`

Immutable Android recovery:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The starting checkpoint physically proved the pre-slab earlyfb invocation
deferred before full framebuffer ioremap, returned normally to `setup_arch()`,
and held before `acpi_table_upgrade()`.

## Runtime facts fixed by phase review

The phase-plan review corrected one important premise: `parse_early_param()`
had already executed inside arm64 `setup_arch()` before this ACPI boundary.

The exact frozen bootargs contain no `acpi=` option and use explicit non-empty
`earlycon=exynos4210,0x10440000`. Therefore:
- `param_acpi_off=false`;
- `param_acpi_on=false`;
- `param_acpi_force=false`;
- `param_acpi_nospcr=false`;
- `earlycon_acpi_spcr_enable=false`.

The exact DTB SHA-256 is:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

It has 26 root children, with `aliases` first. Since `dt_is_stub()` skips only
`chosen` and a Xen hypervisor node, this exact DT deterministically yields
`dt_is_stub()==false`.

The exact loader-passed Linux initrd SHA-256 is:

`86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`

It is a 7,696-byte gzip blob. There is no preceding uncompressed newc archive,
and the decompressed archive contains no `kernel/firmware/acpi/*` or `.aml`
payload. `find_cpio_data()` only parses uncompressed newc content before
compressed content. Therefore this exact initrd cannot provide an early ACPI
table override.

## A1: ACPI override-scan return

A1 source:

`b4a7bb316b6f615d2ef81c8dce316bbf96f29676`

A1 Image:

`02f83a9c9f609bc26ddfeda1c500d657b8490f81a3a84bee754e880d005cd712`

A1 loader:

`3dfe861ac02b1ed82a90883c46a7fdea527ffe626f7cf2bb26ddf89310a57f12`

A1 BOOT:

`e26a0fb30a652b51967bc978b32d0e3cb72f4911e4514852ed01ab78e2e55296`

A1 removed only the starting teal hold. `acpi_table_upgrade()` remained
unchanged and independently compared instruction-equivalent to the proven
parent across 210 normalized instruction lines.

After it returned, A1 freshly rebound the bridge and painted RED, technical
ARGB8888 `0xffff4040`, then held before `acpi_boot_table_init()`.

Captain observed a red/orange-looking screen and confirmed it remained stable
for at least three minutes.

This physically proves unchanged `acpi_table_upgrade()` returned and the
ordinary bridge survived and remained writable. Absence of override
installation is a frozen-input/source conclusion from the exact initrd.

## A2: ACPI boot-table decision returns DT-selected

A2 source:

`128495632184b4c9ebe619d85339781b8e1983e3`

A2 Image:

`4b8ed3bb595061a95aab9a7530243d80d057aebb89dce0ec2e91172e9e77151c`

A2 loader:

`8e33d99be8d3cf6df6508844b6149b49d63f2224d334b8504423828126830da0`

A2 BOOT:

`cd180839ae4f0db71d3a250058a5e7347413385e26a21d3c78080fb9fe34d6a0`

A2 removed only the RED hold. `acpi_boot_table_init()` remained unchanged and
independently compared instruction-equivalent to A1 across 86 normalized
instruction lines.

Immediately after return, A2 inspected runtime `acpi_disabled`:
- unexpected `0` preserves RED and self-holds before DT unflatten and bootmem;
- expected `1` freshly rebinds the bridge and paints BLUE, technical ARGB8888
  `0xff40c0ff`.

Captain observed BLUE and confirmed it remained stable for at least three
minutes.

This physically proves unchanged `acpi_boot_table_init()` returned with runtime
`acpi_disabled == 1` on the expected DT-selected lane. Both
`unflatten_device_tree()` and `bootmem_init()` remained unreachable.

## A3: live DT-unflatten return

A3 source:

`4c9f675615ae589a4c47d9d9922e72f4eeaa0fd4`

A3 Image:

`367cff8e79c38398e76c41f819a4ff2a8dc38ca424e32d8ae601126f18624a07`

A3 loader:

`a13a676c3254b50eb1a7d342ff87356a85e3253a9229f10cb3c2a841de936f6e`

A3 BOOT:

`8fa7d749e6aefc84f28465056488914111ffef38f27c683ce0fc17a1ecf13cd4`

A3 removed only the BLUE hold, kept the A2 unexpected-ACPI containment, braced
the existing expected DT branch, and executed unchanged
`unflatten_device_tree()` inside that branch.

`unflatten_device_tree()` independently compared instruction-equivalent to A2
across 54 normalized instruction lines.

The final linked seam is:

```text
ffff800082214cd8  ldr w8, [x20, #0xeec]
ffff800082214cdc  cbz w8, ffff800082214d20
ffff800082214ce0  bl unflatten_device_tree
ffff800082214ce4  mov x9, x19
ffff800082214cec  mov x11, #0xff40
ffff800082214cf0  movk x11, #0xff80, lsl #16
ffff800082214cf4  movk x11, #0xff40, lsl #32
ffff800082214cf8  movk x11, #0xff80, lsl #48
ffff800082214d08  str x11, [x10], #8
ffff800082214d14  dsb sy
ffff800082214d18  wfe
ffff800082214d1c  b ffff800082214d18

-- unreachable --

ffff800082214d20  bl bootmem_init
```

Captain observed GREEN and confirmed it remained stable for at least three
minutes.

This physically proves:
- all A2 facts remain true;
- the expected `acpi_disabled` DT branch executed;
- unchanged `unflatten_device_tree()` returned;
- the ordinary setup_arch bridge survived and remained writable;
- `bootmem_init()` did not execute.

For the exact already-validated DTB and unchanged OF implementation, the
stronger interpretation is that the live OF-tree allocation/population tranche
completed sufficiently to return.

## Reproducibility and standing invariants

Accepted config remained:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE` remained:

`2026-09-26 01:21:56 UTC`

Each checkpoint had two byte-identical loader builds and two byte-identical BOOT
packaging runs.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Relative to each immediately previous
proven MAINLINE, the Android ramdisk and post-ramdisk tail remained
byte-identical, header drift remained checksum/id-only, and the accepted
AVB/stale-descriptor behavior remained unchanged.

Both canonical current-MAINLINE pointer surfaces were checked before every
frozen candidate and updated together after every physical PASS.

## Promotion and next boundary

Exact A3 BOOT:

`8fa7d749e6aefc84f28465056488914111ffef38f27c683ce0fc17a1ecf13cd4`

is the newest proven MAINLINE checkpoint and remains installed.

This closes the ACPI / DT-selection phase.

The immediate next architectural boundary is `bootmem_init()`. It contains a
materially larger memory-init tranche:
- DRAM PFN limit derivation;
- `early_memtest()`;
- max/min PFN publication;
- `arch_numa_init()`;
- `kvm_hyp_reserve()`;
- `dma_limits_init()`;
- CMA reservation;
- crashkernel reservation;
- memblock dump.

Do not cross `bootmem_init()` without a new bounded phase plan/review.

Full framebuffer mapping/clear/console registration remains a separate future
lane only after complete `mm_core_init()` returns.
