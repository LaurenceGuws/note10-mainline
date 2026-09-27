# 2026-09-27 bootmem_init proof

This phase started from the physically proven ACPI/DT-selection checkpoint and
crossed only `bootmem_init()`. It stopped immediately after the genuine
`bootmem_init()` return to `setup_arch()` and before
`request_standard_resources()`.

## Starting authority

Starting proven MAINLINE:

`8fa7d749e6aefc84f28465056488914111ffef38f27c683ce0fc17a1ecf13cd4`

Starting proven source:

`4c9f675615ae589a4c47d9d9922e72f4eeaa0fd4`

Immutable Android recovery:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The starting checkpoint physically proved unchanged `unflatten_device_tree()`
returned on the expected DT-selected branch. `bootmem_init()` remained
unreachable.

## Exact frozen inputs

Accepted config:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Exact DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

Exact bootargs:

`earlycon=exynos4210,0x10440000 console=ttySAC0,115200 console=tty0 init=/init scsi_mod.max_luns=1 pmos_root=/dev/sda32 log_buf_len=4M`

Relevant exact absences:
- no `memtest=`;
- no `numa=`;
- no `kvm-arm.mode=`;
- no `cma=` or `cma_pernuma=`;
- no `crashkernel=`;
- no `memblock=debug`;
- compiled DTB has no `numa-node-id`;
- compiled DTB has no `dma-ranges`;
- compiled DTB has no `linux,cma-default` or `reusable`.

Exact DT memory span:
- minimum base `0x80000000`;
- maximum end `0xb00000000`.

## M1: PFN publication and NUMA return

M1 source:

`5dbf5091ed1a8b5bf7e35866e2d0a5668dd7f9e9`

M1 Image:

`66bd92033a1e699e0f56682b6fd22093acb1a5f42cb1bc3ea9be02988a574dc5`

M1 loader:

`ed847dcc6ed1527591b8767fea1476cf77cfdaa30fc218ae9378886a401d4a44`

M1 BOOT:

`83104b850e38706cd03e36d7c4b3c2d535111f63e019a79489c0deff7999fd88`

M1 removed only the preceding GREEN hold and executed unchanged
`bootmem_init()` through DRAM-bound calculation, unchanged `early_memtest()`,
PFN publication and unchanged `arch_numa_init()`.

Independent object comparisons:
- `early_memtest()`: 47 identical normalized instruction lines;
- `arch_numa_init()`: 30 identical normalized instruction lines.

With no `memtest=`, `memtest_pattern` stays zero and the unchanged call returns
immediately.

A2/A3 had already physically proved `acpi_disabled == 1`. With no `numa=` and
no `numa-node-id` in the exact DTB, OF NUMA finds no explicit topology and the
accepted fallback is dummy node 0. Successful `dummy_numa_init()` sets
`numa_off=true`.

M1 contained unexpected `numa_off == false` by preserving GREEN and self-holding
before KVM. Only runtime `numa_off == true` freshly reloaded
`note10_paging_bridge` and painted YELLOW (`0xffffff00`).

Captain observed YELLOW stable for at least three minutes.

This physically proves:
- `bootmem_init()` entered;
- DRAM-bound calls returned;
- unchanged `early_memtest()` returned;
- PFN globals were published;
- unchanged `arch_numa_init()` returned;
- runtime `numa_off == true`;
- KVM work remained unreachable.

## M2: KVM return and exact DMA limit

M2 source:

`d6bf26a7cc36f2786c5ec5c87c00a8e5d4564d34`

M2 Image:

`d89f6cfbe3485849be05e7a958ddec55d747b850fea45b70ace65a4f5867a90f`

M2 loader:

`d1649394585516a45b33e155a370865456cfbeef49b4c69536975a2470440b49`

M2 BOOT:

`653d937868e1abcac2c41b5b59133e569b42dc5ed5a3abb215da11441e22dead`

M2 removed only the YELLOW hold, retained M1 containment, and executed unchanged
`kvm_hyp_reserve()` and `dma_limits_init()`.

Independent object comparisons:
- `kvm_hyp_reserve()`: 90 identical normalized instruction lines;
- `dma_limits_init()`: 44 semantically identical normalized instruction lines,
  with only object-layout target-address drift stripped.

With no `kvm-arm.mode=`, default KVM mode does not select protected-KVM
reservation.

Because ACPI is physically proven disabled, the exact DT contains no
`dma-ranges`, DRAM begins below 4 GiB and extends above 4 GiB, unchanged
`dma_limits_init()` deterministically sets:

`arm64_dma_phys_limit = 0x100000000`

Any mismatch preserved YELLOW and self-held. Only the exact 4 GiB value freshly
reloaded the bridge and painted PURPLE (`0xffff00ff`).

Captain observed PURPLE stable for at least three minutes.

This physically proves:
- all M1 facts remain true;
- unchanged `kvm_hyp_reserve()` returned;
- unchanged `dma_limits_init()` returned;
- runtime DMA physical limit is exactly 4 GiB;
- CMA remained unreachable.

## M3: bootmem tail and genuine return

M3 source:

`9d8fb286f5e0e6cb60730c9f9378ebebc7f542df`

M3 Image:

`b00b7da711c40e4d56612e247de487a1a6fde4c090e9794ad5a7ddad59b09142`

M3 loader:

`55d2a475b239b2b5bc22080a5b3e229653bd78c1f7c2686aa7e72068579d7151`

M3 BOOT:

`b2799d78e4d90e670dd291922d458ea9827ccad86cd93df5d6416a7c591d18b4`

M3 removed only the PURPLE hold and retained M1/M2 containment.

Independent object comparisons:
- `dma_contiguous_reserve()`: 60 identical normalized instruction lines;
- `arch_reserve_crashkernel()`: 45 identical normalized instruction lines;
- `memblock_dump_all()`: 14 identical normalized instruction lines.

Exact config/inputs select a generic 32 MiB CMA attempt, but M3 deliberately
does not claim allocation success. The physical claim is only that unchanged
`dma_contiguous_reserve()` returned.

With no `crashkernel=`, no crashkernel reservation is requested. With no
`memblock=debug`, no memblock dump is enabled.

Final linked tail:

```text
ffff80008221bcf0  bl dma_contiguous_reserve
ffff80008221bcf4  bl arch_reserve_crashkernel
ffff80008221bcf8  bl memblock_dump_all
ffff80008221bcfc  ldp x20, x19, [sp, #0x20]
ffff80008221bd00  ldr x21, [sp, #0x10]
ffff80008221bd04  ldp x29, x30, [sp], #0x30
ffff80008221bd08  ldr x30, [x18, #-0x8]!
ffff80008221bd20  ret
```

After the genuine return, `setup_arch()` freshly rebinds the surviving ordinary
bridge:

```text
ffff800082214d18  bl bootmem_init
ffff800082214d1c  mov x9, x19
ffff800082214d24  mov x11, #-1
ffff800082214d34  str x11, [x10], #8
ffff800082214d40  dsb sy
ffff800082214d44  wfe
ffff800082214d48  b ffff800082214d44

-- unreachable --

ffff800082214d4c  bl request_standard_resources
```

Captain reported PASS under the accepted WHITE >=3-minute physical rule.

This physically proves:
- all M2 facts remain true;
- unchanged CMA/crashkernel/memblock-tail calls returned;
- `bootmem_init()` executed genuine frame/callee-saved/SCS restoration and
  returned to `setup_arch()`;
- the ordinary setup bridge survived and remained writable;
- `request_standard_resources()` did not execute.

## KASAN correction

`CONFIG_KASAN` is not set in the accepted config. `kasan_init()` is therefore an
empty inline and produces no meaningful linked runtime tranche here.

The next architectural boundary is directly:

`request_standard_resources()`

not KASAN.

## Reproducibility

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE` remained:

`2026-09-26 01:21:56 UTC`

All three checkpoints had byte-identical paired loader builds and byte-identical
paired BOOT packaging runs.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail remained
byte-identical to the immediately previous proven MAINLINE. Header drift stayed
inside the accepted checksum/id-only envelope, and accepted AVB stale-descriptor
behavior remained unchanged.

## Promotion and next boundary

Exact M3 BOOT:

`b2799d78e4d90e670dd291922d458ea9827ccad86cd93df5d6416a7c591d18b4`

is the newest proven MAINLINE checkpoint and remains installed.

This closes the `bootmem_init()` phase.

Do not cross `request_standard_resources()` without a new bounded architectural
phase plan/review.

Full framebuffer mapping/clear/console registration remains a separate future
lane only after complete `mm_core_init()` returns.
