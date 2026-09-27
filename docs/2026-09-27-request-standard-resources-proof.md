# 2026-09-27 request_standard_resources proof

This phase started from the physically proven `bootmem_init()` return checkpoint
and crossed only `request_standard_resources()`. It stopped immediately after
the genuine function return to `setup_arch()` and before the source-level
`early_ioremap_reset()` call.

## Process authority

A Captain handover error occurred at the phase-plan gate: the independent
phase-review prompt was accidentally sent back to the worker.

Therefore:

`/home/home/.local/state/workstreams/note10-mainline/reviews/resources-phase-review.md`

is self-review analysis only and is not independent authority.

Captain explicitly authorized continuing this phase under:

`/home/home/.local/state/workstreams/note10-mainline/reviews/resources-phase-captain-exception.txt`

The original bounded phase scope remained:

`/home/home/.local/state/workstreams/note10-mainline/reviews/resources-phase-review-brief.md`

Both R1 and R2 subsequently received normal independent frozen-candidate
reviews before physical flashing.

## Starting authority

Starting proven MAINLINE:

`b2799d78e4d90e670dd291922d458ea9827ccad86cd93df5d6416a7c591d18b4`

Starting proven source:

`9d8fb286f5e0e6cb60730c9f9378ebebc7f542df`

Immutable Android recovery:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The starting checkpoint physically proved genuine `bootmem_init()` return.
`request_standard_resources()` remained unreachable.

## Production function and claim boundary

The production function:
- publishes kernel code/data physical bounds;
- calls `insert_resource()` for kernel code and data;
- captures `memblock.memory.cnt`;
- allocates `num_standard_resources * sizeof(struct resource)` bytes using
  `memblock_alloc_or_panic()`;
- iterates all `memblock.memory` regions;
- constructs either a NOMAP reserved descriptor or ordinary System RAM
  descriptor for each reached region;
- calls `insert_resource()` for each descriptor.

The exact build uses 64-byte `struct resource`, so the backing size is
`cnt * 64`.

`insert_resource()` returns 0 on success or `-EBUSY` on conflict, but
`request_standard_resources()` discards every return value. The phase therefore
does not claim successful resource-tree insertion. Physical markers prove only
that the reached calls returned and execution continued.

## R1: fixed resources and backing allocation

R1 source:

`a6cd2c0df3c0fc6f2605d2164c0d647676432b51`

R1 Image:

`f8067c49878b71e4b103b977e46f9631654d6e6a5958adea6a67224347e67745`

R1 loader:

`f41640091d4db24a2276c14c71ad8825f1f82e975dd4a73df64486c9a7bd392d`

R1 BOOT:

`fdc01a90fc95d24969370b6aeed33fca7ce6b1808c11cf60ab2f7e89877707d3`

Independent helper comparisons:
- `insert_resource()`: 27 identical normalized instruction lines versus M3;
- `__memblock_alloc_or_panic()`: 37 identical normalized instruction lines.

R1 removed only the WHITE hold, entered unchanged
`request_standard_resources()`, let both fixed kernel resource calls return,
captured `memblock.memory.cnt`, calculated `cnt * 64`, and executed unchanged
`memblock_alloc_or_panic()`.

The allocator panics on NULL and otherwise returns the allocated pointer.
Reaching the marker after that call therefore proves a non-NULL backing pointer
returned without panic. The returned pointer was stored to `standard_resources`
before the marker.

The allocation reserves its physical range through `memblock.reserved` and does
not mutate the `memblock.memory` set/count used by the later iterator.

Only after the allocation return/store did R1 freshly reload canonical
`note10_paging_bridge` into fixed/read-only `x9` and paint ORANGE
(`0xffff8000`). The memory-region loop remained unreachable.

Captain observed ORANGE stable for at least three minutes.

This physically proves:
- all starting M3 facts remain true;
- `request_standard_resources()` entered;
- kernel code/data physical bounds were computed/stored;
- both fixed `insert_resource()` calls returned;
- `memblock.memory.cnt` was captured;
- backing-size calculation completed;
- unchanged `memblock_alloc_or_panic()` returned non-NULL without panic;
- `standard_resources` was stored;
- the bridge remained writable;
- the memory-region loop did not execute.

It does not prove either fixed insertion succeeded.

## R2: memory-region loop and genuine function return

R2 source:

`7009c472f176329a802945b5cf2ef2c29dc8045f`

R2 Image:

`75a0d73eeb7bde741ba15fdedcfbc2b9af21e9ff82276b8c108e3f2268fec0a0`

R2 loader:

`604389c11c235123a075f7c90c7a2cad7b21d9ba4b25cabdb85f61f62b883340`

R2 BOOT:

`d9c62bb19c49932752fae10644f76f4166ed4ee8e9f2fc627e1690432ebe6194`

R2 removed only the ORANGE hold and executed the existing
`for_each_mem_region` loop unchanged.

Fast object normalization established:

`RESOURCE_LOOP_TAIL_EQUIVALENCE=PASS`

across 73 normalized lines from loop setup through the genuine
`request_standard_resources()` epilogue and `ret`.

Final linked loop/return tail:

```text
ffff800082215100  str x9, [x8, #0x8]
ffff800082215104  bl insert_resource
ffff800082215108  ldr x8, [x20]
ffff80008221510c  ldr x9, [x20, #0x18]
ffff800082215110  add x22, x22, #0x18
ffff800082215114  add x23, x23, #0x40
ffff800082215118  madd x8, x8, x26, x9
ffff80008221511c  cmp x22, x8
ffff800082215120  b.lo ffff8000822150a4

ffff800082215124  ldp x20, x19, [sp, #0x50]
ffff800082215128  ldp x22, x21, [sp, #0x40]
ffff80008221512c  ldp x24, x23, [sp, #0x30]
ffff800082215130  ldp x26, x25, [sp, #0x20]
ffff800082215134  ldp x28, x27, [sp, #0x10]
ffff800082215138  ldp x29, x30, [sp], #0x60
ffff80008221513c  ldr x30, [x18, #-0x8]!
ffff800082215160  ret
```

Only after genuine return did `setup_arch()` rebind the surviving ordinary
bridge `x19 -> x9` and paint PINK:

```text
ffff800082214d44  bl request_standard_resources
ffff800082214d48  mov x9, x19
ffff800082214d50  mov x11, #0x40c0
ffff800082214d54  movk x11, #0xffff, lsl #16
ffff800082214d58  movk x11, #0x40c0, lsl #32
ffff800082214d5c  movk x11, #0xffff, lsl #48
ffff800082214d6c  str x11, [x10], #8
ffff800082214d78  dsb sy
ffff800082214d7c  wfe
ffff800082214d80  b ffff800082214d7c

-- unreachable --

ffff800082214d84  bl early_ioremap_reset
```

Captain reported PASS under the accepted PINK >=3-minute physical rule.

This physically proves:
- all R1 facts remain true;
- the unchanged `memblock.memory` iterator ran to completion;
- every reached reserved/System-RAM descriptor path completed;
- every reached per-region `insert_resource()` call returned;
- `request_standard_resources()` restored frame/callee-saved/SCS state and
  genuinely returned to `setup_arch()`;
- the ordinary setup bridge survived and remained writable;
- `early_ioremap_reset()` did not execute.

It still does not prove successful resource insertion.

## Reproducibility

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE` remained:

`2026-09-26 01:21:56 UTC`

R1/R2 paired loader builds and paired BOOT packaging runs were byte-identical.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail remained
byte-identical to the immediately previous proven MAINLINE. Header drift stayed
within the accepted checksum/id-only envelope. R2 changed 19 bytes inside that
envelope. Accepted AVB stale-descriptor behavior remained unchanged.

## Promotion and next boundary

Exact R2 BOOT:

`d9c62bb19c49932752fae10644f76f4166ed4ee8e9f2fc627e1690432ebe6194`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `request_standard_resources()`.

The source-level next call is `early_ioremap_reset()`, but exact final linked
disassembly shows that helper is only:

```text
ffff80008223f358  ret
```

On arm64, `__early_set_fixmap` and `__late_set_fixmap` are both
`__set_fixmap`, while `__late_clear_fixmap` is the matching
`__set_fixmap(..., FIXMAP_PAGE_CLEAR)` form. As a result,
`after_paging_init` has no observable branch effect on this build and the
compiler removes its assignment entirely. There is no meaningful runtime phase
to prove at `early_ioremap_reset()` itself.

The next meaningful linked runtime boundary is the already-proven
`acpi_disabled == 1` branch into `psci_dt_init()`. The exact Exynos9825 DT uses
`compatible = "arm,psci-0.2"` and `method = "hvc"`, so the next phase is PSCI
DT discovery/conduit selection/probe. Do not cross that boundary without a new
bounded architectural phase plan/review.

Full framebuffer mapping/clear/console registration remains a separate future
lane only after complete `mm_core_init()` returns.
