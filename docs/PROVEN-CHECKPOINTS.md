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

`d9c62bb19c49932752fae10644f76f4166ed4ee8e9f2fc627e1690432ebe6194`

It physically proves the complete `request_standard_resources()` phase.
Physically proven R1 established entry through the two fixed kernel code/data
`insert_resource()` calls, capture of `memblock.memory.cnt`, exact
`cnt * 64` backing-size calculation, and successful non-NULL return from
unchanged `memblock_alloc_or_panic()`. Physically proven R2 then ran the
unchanged `for_each_mem_region` loop to completion, executed every reached
descriptor path and per-region `insert_resource()` call, and completed the
genuine `request_standard_resources()` frame/callee-saved/SCS restoration and
`ret` back to `setup_arch()`. The surviving ordinary setup bridge was freshly
rebound `x19 -> x9` and painted PINK (technical marker `0xffff40c0`) over the
exact `0x2d000` evidence bridge. Captain reported PASS under the accepted
PINK >=3-minute physical rule. The source-level `early_ioremap_reset()` call
remains unreachable from the physical checkpoint, but on this exact arm64 build
that helper links to a bare `ret`: both early and late fixmap hooks resolve to
the same `__set_fixmap()` implementation, so the `after_paging_init` assignment
is optimized away. The next meaningful linked runtime boundary is the already
proven `acpi_disabled == 1` selection into `psci_dt_init()`.
No successful resource-tree insertion result is claimed because production
ignores every `insert_resource()` return value.

This phase proceeded under a recorded Captain process exception after the
phase-plan review prompt was accidentally sent back to the worker. The worker's
`resources-phase-review.md` is self-review analysis only and is not independent
authority. Both R1 and R2 frozen candidates still received independent
candidate reviews before physical flashing.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`fdc01a90fc95d24969370b6aeed33fca7ce6b1808c11cf60ab2f7e89877707d3`

The previous checkpoint is R1. It physically proves both fixed kernel code/data
`insert_resource()` calls returned and unchanged `memblock_alloc_or_panic()`
returned a non-NULL backing pointer, ending at the ORANGE hold before the
memory-region loop. It does not prove either resource insertion succeeded.

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
