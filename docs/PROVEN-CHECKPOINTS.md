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

`10eb19209719a38b677e01f5dc5afa89b14839312b2d8eae7d295f344f0068cc`

It physically proves the corrected pre-slab earlyfb phase. The previously
proven E1 path enters `earlyfb_console_init()` and returns from the unchanged
watchdog helper path while the established high-TTBR1 framebuffer bridge
remains visibly writable. E2D then preserves the original `earlyfb_map` check,
observes that normal slab/vmap-backed ioremap infrastructure is not available
at this `setup_arch()` call, defers before the full framebuffer
`ioremap_wc()` path, executes the genuine `earlyfb_console_init()`
frame/SCS epilogue and returns normally to `setup_arch()`. The surviving
ordinary bridge is freshly rebound `x20 -> x9` and paints teal
`0xff00c0c0`. That marker remained unchanged for at least three minutes.
`acpi_table_upgrade()` remains unreachable behind the deliberate teal hold.
The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`fcf1a6b751f49c5ef675cb883859feebacdb73ed03e059076815b47d129ba050`

The previous checkpoint is E1. It physically proves the selected early
watchdog-helper call returns and the existing bridge remains writable, ending
at the amber `0xffffa000` hold before the `earlyfb_map` decision.

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
