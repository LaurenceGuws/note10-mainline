# Proven checkpoint workflow

Note10 mainline bring-up advances as a ladder of physically proven BOOT
artifacts rather than returning to Android after every successful tranche.

## Authorities

### Proven MAINLINE checkpoint

The newest exact BOOT that has passed:

1. frozen artifact identity;
2. independent final review;
3. attended physical terminal-marker proof;
4. bounded stability observation;
5. durable proof recording.

This is the normal progression parent and routine rollback target for the next
mainline tranche.

Current promoted MAINLINE checkpoint:

`b2799d78e4d90e670dd291922d458ea9827ccad86cd93df5d6416a7c591d18b4`

It physically proves the complete accepted `bootmem_init()` phase. The
previously proven M1/M2 containment remains active, unchanged
`dma_contiguous_reserve()`, `arch_reserve_crashkernel()` and
`memblock_dump_all()` all return, and `bootmem_init()` executes its genuine
frame/callee-saved/SCS restoration and `ret` back to `setup_arch()`. The
surviving ordinary setup bridge is then freshly rebound `x19 -> x9` and paints
WHITE (technical marker `0xffffffff`) over the established exact `0x2d000`
evidence bridge. Captain reported PASS under the accepted WHITE >=3-minute
physical rule. `CONFIG_KASAN` is off, so the next meaningful linked operation,
`request_standard_resources()`, remains unreachable behind the WHITE hold.
The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`653d937868e1abcac2c41b5b59133e569b42dc5ed5a3abb215da11441e22dead`

The previous checkpoint is M2. It physically proves unchanged
`kvm_hyp_reserve()` and `dma_limits_init()` returned and runtime
`arm64_dma_phys_limit == 0x100000000`, ending at the PURPLE hold before
`dma_contiguous_reserve()`.

### Android RECOVERY checkpoint

Immutable Android-inclusive recovery floor:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Use recovery only when Android/device-side archaeology is required or when the
mainline recovery chain itself is uncertain. It is not the routine rollback
target after a failed mainline experiment.

## Iteration

```text
latest proven MAINLINE checkpoint
    -> plan one bounded tranche
    -> independent plan review
    -> build/freeze exact candidate
    -> independent frozen-candidate review
    -> install candidate
    -> attended physical proof

PASS:
    promote exact candidate to proven MAINLINE checkpoint
    keep it installed
    continue from it

FAIL:
    restore previous proven MAINLINE checkpoint
    investigate only the newly crossed tranche

RECOVERY NEED:
    restore immutable Android RECOVERY checkpoint
```

## Packaging template versus progression parent

The current BOOT construction helper uses `magiskboot unpack/repack`. When a
promoted mainline BOOT already contains uniLoader plus zero padding,
`magiskboot unpack` trims that representation and does not expose the full
Android BOOT header `kernel_size` as the extracted `kernel` file size.

Therefore:

- the proven MAINLINE checkpoint remains the progression/rollback authority;
- the immutable Android RECOVERY BOOT remains the canonical deterministic
  envelope template for constructing the next BOOT;
- every candidate is separately verified against the proven MAINLINE parent so
  ramdisk, post-ramdisk tail, geometry and AVB lineage cannot drift.

This distinction is packaging mechanics only. It does not demote the mainline
checkpoint or make Android the routine rollback target.
