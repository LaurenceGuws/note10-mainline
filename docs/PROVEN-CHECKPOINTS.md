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

`8fa7d749e6aefc84f28465056488914111ffef38f27c683ce0fc17a1ecf13cd4`

It physically proves the complete accepted ACPI / DT-selection phase.
`acpi_table_upgrade()` returns on the exact frozen loader/initrd inputs,
`acpi_boot_table_init()` returns with runtime `acpi_disabled == 1` on the
already-parsed bootargs plus exact non-stub d2s DTB, and the expected DT branch
executes unchanged `unflatten_device_tree()` through its live OF-tree
allocation/population tranche and returns. The surviving ordinary
`setup_arch()` bridge remains visibly writable throughout. The final GREEN
marker `0xff80ff40` remained unchanged for at least three minutes immediately
before `bootmem_init()`. The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`cd180839ae4f0db71d3a250058a5e7347413385e26a21d3c78080fb9fe34d6a0`

The previous checkpoint is A2. It physically proves unchanged
`acpi_boot_table_init()` returns with runtime `acpi_disabled == 1` on the
expected DT-selected lane, ending at the BLUE hold before
`unflatten_device_tree()`.

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
