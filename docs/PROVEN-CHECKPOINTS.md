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

`c7cc9b7d46b64943b6155a185b2b237f610d1ddb65a07de59e268669be6e3e86`

It physically proves `early_security_init()` through its genuine zero-iteration
return to `start_kernel()`.

Exact final L1 links an empty early-LSM interval:

```text
__start_early_lsm_info = 0xffff8000824b4880
__end_early_lsm_info   = 0xffff8000824b4880
```

`CONFIG_SECURITY_LOCKDOWN_LSM_EARLY` is unset, so lockdown remains a normal
later LSM and contributes no early descriptor. Unchanged 55-instruction
`early_security_init()` therefore takes its first equal-bounds branch directly
to the normal epilogue with zero loop iterations.

Only after genuine return does the caller freshly load the Note10 framebuffer
bridge and paint MAGENTA (`0xffff00ff`). Captain reported MAGENTA PASS under
the accepted >=3-minute rule.

Stable MAGENTA proves:
- all J1 GREEN facts remain true;
- unchanged `early_security_init()` executed;
- exact equal early-LSM bounds forced zero iterations;
- no early-LSM enable/order/prepare/init work ran in this invocation;
- `lsm_count_early` was not incremented by its loop;
- the normal epilogue set return value zero;
- frame/callee-saved/x18-SCS restoration and genuine `ret` completed;
- control returned to `start_kernel()`;
- the bridge was freshly loaded after return and remained writable;
- `get_boot_config_from_initrd()` did not execute.

It makes no claim that normal later LSMs initialized, that `security_init()`
ran, or that bootconfig or command-line processing occurred.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`6f2fa130f3ae71a3631e93272188e3b4c057e0e8ff2cbbc9c1b156f2b6f70bcf`

The previous checkpoint is J1 GREEN. It physically proves the second linked
`start_kernel()` `jump_label_init()` through its initialized fast-return path
and stops before `early_security_init()`.

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
