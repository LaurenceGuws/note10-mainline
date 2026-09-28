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

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

It physically proves `setup_command_line()` through genuine return to
`start_kernel()` with exact published command-line copies.

Exact DT bootargs are 133 bytes plus terminating NUL. The selected build has
`CONFIG_CMDLINE=""` and `CONFIG_BOOT_CONFIG=n`, so the nonempty DT line is
preserved and optional bootconfig extra-command-line state is compiled away.

Unchanged 67-instruction `setup_command_line()` therefore requests two
134-byte memblock objects at 64-byte alignment, publishes
`saved_command_line` and `static_command_line`, copies the exact line into
both, publishes `saved_command_line_len = 133`, restores frame/SCS state and
returns.

Only after genuine return does C1 verify both pointers non-NULL, distinct and
64-byte aligned, verify length 133 and NUL at index 133, then compare exact
indices 0..133 of both buffers against `boot_command_line` using an explicit
helper-free byte loop. Captain reported TURQUOISE PASS under the accepted
>=3-minute rule.

Stable TURQUOISE proves:
- all BC1 GOLD facts remain true;
- both exact 134-byte / 64-byte allocation calls returned;
- both published command-line buffers are exact byte copies including NUL;
- `saved_command_line_len == 133`;
- ordinary frame/callee-saved/x18-SCS restoration and genuine return completed;
- the bridge was freshly loaded after all command-line checks and remained writable;
- `setup_nr_cpu_ids()` did not execute.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`2e98f070ac0f68525aff65cdc63080501714cc56651e9f0d7d47c3e98021687e`

The previous checkpoint is BC1 GOLD. It closes
`get_boot_config_from_initrd(NULL)` and stops before `setup_command_line()`.

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
