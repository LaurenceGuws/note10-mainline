# 2026-09-27 mm_core_init_early proof

This phase started from the physically proven BLUE `setup_arch()`-return
checkpoint and crossed `mm_core_init_early()` in two independently reviewed
physical checkpoints.

## Starting authority

Starting proven MAINLINE:

`80587eb6d08902cc1047652a49f33094cb9a757db0f578dc34c885d4384ee220`

Starting proven source:

`322c48936e57ae4ebeada786a9b22684fdd15207`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/mm-core-init-early-phase-review.md`

## Production shape

Exact production wrapper:

```c
void __init mm_core_init_early(void)
{
    hugetlb_cma_reserve();
    hugetlb_bootmem_alloc();
    free_area_init();
}
```

The phase split the bounded HugeTLB prelude from the much larger
`free_area_init()` tranche.

## MM1 ORANGE: bounded HugeTLB prelude

MM1 source:

`b05cd7e85b4e7a9e3d7a6d1f0134336e6e274856`

Image:

`22f45bbe41a1604e66c0b551513b1e770bfee1ae9f7ed11e95dd9db2447104c6`

Loader:

`46b8bc1ddfc48c233c15c8ed1de97f869f050a20e415eeee6b38728487e3b11a`

BOOT:

`5544ef05cac188ce6f8a96db5d06534b37618275bd6d07c7b416adf60e5497f1`

Exact promoted-T1 binary bytes established:

```text
hugetlb_cma_size = 0
hugetlb_param_index = 0
hugetlb_max_hstate = 0
```

Exact fixed bootargs contain no `hugetlb_cma=`, `hugetlb_cma_only=`,
`hugepages=`, `hugepagesz=`, `default_hugepagesz=` or
`hugepage_alloc_threads=`.

The five reviewed HugeTLB helpers remained instruction-equivalent to T1:

```text
hugetlb_cma_reserve        175
hugetlb_bootmem_alloc       57
hugetlb_bootmem_set_nodes   71
hugetlb_parse_params        27
hugetlb_cma_validate_params  7
```

The linked MM1 seam placed ORANGE only after both real HugeTLB calls returned
and before `free_area_init()`.

Captain reported ORANGE PASS under the accepted >=3-minute physical rule.

Stable ORANGE proves:
- `mm_core_init_early()` entered;
- `hugetlb_cma_reserve()` genuinely returned through the exact zero-size path;
- no CMA declaration/reservation path executed;
- `hugetlb_bootmem_alloc()` genuinely returned;
- its node-mask/list bookkeeping completed;
- zero queued HugeTLB parameter callbacks ran;
- zero hstate allocation-loop iterations ran;
- no hugepage boot allocation occurred;
- `free_area_init()` did not execute.

## MM2 WHITE: free_area_init and genuine wrapper return

MM2 source:

`070e38ff1c1b3d32ad031ffd1172dca57e498d3a`

Image:

`cb6cdeb981bcd41c4cf65ed3d2688406ee3b3c2cb6d0af4b9f7c2c50c9ed334f`

Loader:

`687d7cc35b72e2f8c6756634d3cbd4dc531df79865f51023357cddd9a99d54c5`

BOOT:

`c3e565842d2af6eab7e55de6b79f93d6e247196a2119553b0def3d644d8abef2`

MM2 removed only the ORANGE hold and executed original `free_area_init()`
unchanged.

Production equivalence against physically proven MM1:

```text
free_area_init                 259 instructions
free_area_init_node             81
calc_nr_kernel_pages            76
memmap_init                     83
sparse_init                    111
sparse_init_subsection_map      59
arch_zone_limits_init           34
```

`free_area_init()` has no source-level early return and exactly one normal
linked `ret`.

Its major production work includes:
- architecture zone limits;
- sparse memory initialization;
- DRAM PFN and zone-range publication;
- movable-zone calculation;
- early memory-node range walking and subsection maps;
- pageflags-layout verification;
- node-id and pageblock setup;
- per-node `free_area_init_node()`;
- memory-node state publication/checking;
- sparse-vmemmap late node initialization;
- kernel-page counting;
- `memmap_init()`;
- hash-distribution fixup;
- high-memory publication.

The authoritative tail is:

```text
ffff800082233844  bl calc_nr_kernel_pages
ffff800082233848  bl memmap_init
...
ffff800082233864  bl memblock_end_of_DRAM
...
ffff8000822338bc  ldr x30, [x18, #-0x8]!
...
ffff8000822338e4  ret
```

After the genuine `free_area_init()` return, the wrapper performs:

```text
ffff8000822334cc  ldp x29, x30, [sp], #0x10
ffff8000822334d0  ldr x30, [x18, #-0x8]!
...
ffff8000822334dc  ret
```

Only after this real wrapper return does `start_kernel()` load the bridge
pointer and gate WHITE:

```text
ffff80008221060c  bl mm_core_init_early

ffff800082210610  ldr x9, [x19, #0x808]
ffff800082210614  cbnz x9, WHITE_OK

ffff800082210618  wfe
ffff80008221061c  b ffff800082210618

ffff800082210620  mov x10, x9
ffff800082210624  mov x11, #0xffff
ffff800082210628  movk x11, #0xffff, lsl #16
ffff80008221062c  movk x11, #0xffff, lsl #32
ffff800082210630  movk x11, #0xffff, lsl #48
ffff800082210640  str x11, [x10], #8
ffff80008221064c  dsb sy
ffff800082210650  wfe
ffff800082210654  b ffff800082210650

-- unreachable --

ffff800082210658  bl jump_label_init
```

The compiler hoists only the bridge symbol's page base into callee-saved x19.
The actual bridge-pointer value is freshly loaded after wrapper return.

Captain reported WHITE PASS under the accepted >=3-minute physical rule.

Stable WHITE proves:
- all MM1 facts remain true;
- original unchanged `free_area_init()` reached its sole normal function end;
- the sparsemem/NUMA/zone/node/memmap tranche completed sufficiently for
  production to return;
- genuine `mm_core_init_early()` frame restoration completed;
- genuine x18/SCS return-address restoration completed;
- genuine `mm_core_init_early()` `ret` completed;
- control returned to `start_kernel()`;
- the bridge pointer was freshly loaded after return and remained writable;
- the next linked `start_kernel()` `jump_label_init()` call did not execute.

## Bridge backing

Exact DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

contains:

```text
framebuffer@ca000000 {
    compatible = "shared-dma-pool";
    reg = <0x00 0xca000000 0x2000000>;
    no-map;
};
```

The evidence band `0xca3b1000..0xca3de000` lies entirely within
`0xca000000..0xcc000000`.

## Reproducibility

Both MM1 and MM2 used exact loader source:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

with pinned `BUILD_DATE`:

`2026-09-26 01:21:56 UTC`

Paired loader builds and paired BOOT packaging runs were byte-identical at each
checkpoint.

MM2 payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail stayed
byte-identical to the exact MM1 parent. Header drift remained checksum/id-only
and accepted AVB stale-descriptor behavior was unchanged.

## Promotion and next boundary

Exact MM2 BOOT:

`c3e565842d2af6eab7e55de6b79f93d6e247196a2119553b0def3d644d8abef2`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `mm_core_init_early()` completely.

The next linked `start_kernel()` call is `jump_label_init()`. This is a second
call in boot: an earlier `jump_label_init()` invocation is already part of the
physically proven `setup_arch()` path. A new phase must therefore reason about
the exact state and semantics of this later invocation rather than describing
it as first-time global initialization.

Do not cross that linked boundary without a new bounded phase plan/review.
