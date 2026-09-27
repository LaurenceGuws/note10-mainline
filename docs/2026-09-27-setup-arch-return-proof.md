# 2026-09-27 setup_arch genuine-return proof

This phase started from the physically proven PURPLE MPIDR-hash checkpoint and
crossed only the final `setup_arch()` boot-argument tail and genuine return.
It stopped in `start_kernel()` before `mm_core_init_early()`.

## Starting authority

Starting proven MAINLINE:

`470198620f2cbd2544e029df8965bbe9581928cd3732225f75352caf62ae543e`

Starting proven source:

`80ebe0f677ec52fc1a350e1e7383d62176e1c479`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/setup-arch-return-phase-review.md`

## Exact loader and saved-boot-argument authority

Frozen loader source remains:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Exact AArch64 handoff:

```c
load_kernel_and_jump(dt, 0, 0, 0, (void *)CONFIG_PAYLOAD_ENTRY);
```

Final branch:

```text
br x4
```

Thus kernel entry receives x1=x2=x3=0.

Unchanged `preserve_boot_args` stores incoming x0..x3 exactly, and its
successful completion was physically proven earlier.

## Unchanged production setup_arch tail

`CONFIG_ARM64_SW_TTBR0_PAN` is absent.

The only remaining production tail was:

```c
if (boot_args[1] || boot_args[2] || boot_args[3])
    pr_err(...);
```

followed by the compiler-generated `setup_arch()` epilogue and `ret`.

Fast object comparison of the complete tail against exact proven H1 passed
across 40 normalized instruction/relocation lines.

`arch/arm64/kernel/setup.c` changed only by deleting the preceding PURPLE
`wfe/b` hold.

## T1 BLUE checkpoint

T1 source:

`322c48936e57ae4ebeada786a9b22684fdd15207`

Image:

`011b09b51fb5cff949d0ea0a33192f3bd9b8c85110692dc1fe55e6e6115499ca`

Loader:

`3247915be99fa8f39757a5475fd37d14e1b2451ae4f2cc97d70594a900c3ee43`

BOOT:

`80587eb6d08902cc1047652a49f33094cb9a757db0f578dc34c885d4384ee220`

The final linked no-warning production tail is:

```text
ffff800082215060  adrp x8, boot_args
ffff800082215064  add x8, x8, #0x8
ffff800082215068  ldp x1, x2, [x8]
ffff80008221506c  ldr x3, [x8, #0x10]
ffff800082215070  cbnz x1, warning
ffff800082215074  cbnz x2, warning
ffff800082215078  cbnz x3, warning

ffff80008221507c  ldp x20, x19, [sp, #0x30]
ffff800082215080  ldr x23, [sp, #0x10]
ffff800082215084  ldp x22, x21, [sp, #0x20]
ffff800082215088  ldp x29, x30, [sp], #0x40
ffff80008221508c  ldr x30, [x18, #-0x8]!
...
ffff8000822150b4  ret
```

Only after that real `ret` does `start_kernel()` perform T1 containment:

```text
ffff80008221059c  bl setup_arch

ffff8000822105a0  adrp x8, boot_args
ffff8000822105a8  ldr x9, [x8]
ffff8000822105ac  cbnz x9, FAIL_PURPLE
ffff8000822105b0  ldr x9, [x8, #0x8]
ffff8000822105b4  cbnz x9, FAIL_PURPLE
ffff8000822105b8  ldr x8, [x8, #0x10]
ffff8000822105bc  cbz x8, BOOTARGS_OK

ffff8000822105c0  wfe
ffff8000822105c4  b ffff8000822105c0

ffff8000822105c8  adrp x8, note10_paging_bridge page
ffff8000822105cc  ldr x9, [x8, #0x808]
ffff8000822105d0  cbnz x9, BRIDGE_OK

ffff8000822105d4  wfe
ffff8000822105d8  b ffff8000822105d4

ffff8000822105dc  mov x10, x9
ffff8000822105e0  mov x11, #0xff
ffff8000822105e4  movk x11, #0xff00, lsl #16
ffff8000822105e8  movk x11, #0xff, lsl #32
ffff8000822105ec  movk x11, #0xff00, lsl #48
ffff8000822105fc  str x11, [x10], #8
ffff800082210608  dsb sy
ffff80008221060c  wfe
ffff800082210610  b ffff80008221060c

-- unreachable --

ffff800082210614  bl mm_core_init_early
```

Captain reported BLUE PASS under the accepted >=3-minute physical rule.

Stable BLUE physically proves:
- production boot-argument tail executed;
- saved x1=x2=x3 were all zero;
- production warning `_printk` path was not taken;
- genuine `setup_arch()` frame/callee-saved/SCS restoration completed;
- genuine `setup_arch()` `ret` completed;
- control returned to `start_kernel()`;
- the published Note10 evidence bridge remained non-NULL and writable;
- `mm_core_init_early()` did not execute.

## Reproducibility

`preserve_boot_args` remained object-equivalent across 12 instructions.

`mm_core_init_early` remained object-equivalent across 9 instructions.

Loader source remained exact and paired loader builds were byte-identical.
Paired BOOT packaging runs were byte-identical.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail stayed
byte-identical to the previous proven MAINLINE. Header drift remained
checksum/id-only and accepted AVB stale-descriptor behavior was unchanged.

## Promotion and next boundary

Exact T1 BOOT:

`80587eb6d08902cc1047652a49f33094cb9a757db0f578dc34c885d4384ee220`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `setup_arch()` completely.

The next architectural boundary is `mm_core_init_early()`, which currently
contains:
- `hugetlb_cma_reserve()`;
- `hugetlb_bootmem_alloc()`;
- `free_area_init()`.

Do not cross `mm_core_init_early()` without a new bounded architectural
phase plan/review.
