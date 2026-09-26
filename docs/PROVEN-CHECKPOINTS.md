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

`213b61315c94e37f942532c6fdbe5f6dcd158a851dbe9177258036265d2ec803`

It physically proves the complete accepted `paging_init()` phase:
`map_mem()`, `memblock_allow_resize()`, `create_idmap()` and
`declare_kernel_vmas()` all return, then `paging_init()` executes its genuine
frame/SCS epilogue and returns normally to `setup_arch()`. The surviving
ordinary `setup_arch` framebuffer bridge is then freshly rebound `x20 -> x9`
and paints spring green `0xff00ff80`. That marker remained unchanged for at
least three minutes. `earlyfb_console_init()` remains unreachable behind the
deliberate spring-green hold. The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`7b12062945c4f47b8eb85b90f72d9fd57fdda6c7bf6a458f861f793876cbc1b5`

The previous checkpoint physically proves `memblock_allow_resize()` and
`create_idmap()` return and ends at the electric-purple hold immediately
before `declare_kernel_vmas()`.

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
