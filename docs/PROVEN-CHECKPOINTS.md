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

`2e98f070ac0f68525aff65cdc63080501714cc56651e9f0d7d47c3e98021687e`

It physically proves the exact `CONFIG_BOOT_CONFIG=n`
`get_boot_config_from_initrd(NULL)` path through genuine NULL return to
`start_kernel()`.

Exact frozen initramfs is 7,696 bytes (`0x1e10`). Final uniLoader copies that
exact payload to physical `0x84000000` and introduces DT initrd bounds through
`0x84001e10`. The unchanged 68-instruction production function probes exactly
four possible `#BOOTCONFIG\n` tail alignments.

All four exact frozen probes mismatch. The found path is therefore unreachable
on this exact input, so no bootconfig size/checksum/error/removal work can run.

Only after genuine return does BC1 load runtime `initrd_start/end`, require a
nonzero exact `0x1e10` span, freshly load the Note10 framebuffer bridge and
paint GOLD (`0xffffd700`). Captain reported GOLD PASS under the accepted
>=3-minute rule.

The runtime span check is corroboration only. The no-found path is
distinguished by the exact frozen four probes plus unchanged production
semantics.

Stable GOLD proves:
- all L1 MAGENTA facts remain true;
- the runtime initrd window remained nonzero and exactly `0x1e10` after return;
- all four exact bootconfig magic probes failed;
- the found path and its size/checksum/error/removal work did not execute;
- the ordinary frame/x18-SCS epilogue and genuine NULL return completed;
- control returned to `start_kernel()`;
- the bridge was freshly loaded after the runtime checks and remained writable;
- `setup_command_line()` did not execute.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`c7cc9b7d46b64943b6155a185b2b237f610d1ddb65a07de59e268669be6e3e86`

The previous checkpoint is L1 MAGENTA. It closes `early_security_init()` and
stops before the linked bootconfig scan.

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
