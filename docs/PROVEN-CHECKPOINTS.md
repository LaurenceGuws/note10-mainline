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

`6f2fa130f3ae71a3631e93272188e3b4c057e0e8ff2cbbc9c1b156f2b6f70bcf`

It physically proves the second linked `start_kernel()` `jump_label_init()`
invocation through its genuine return.

The exact image state begins with `static_key_initialized == 0`. The first
linked `jump_label_init()` call is inside the already physically proven
`setup_arch()` path. Under selected `CONFIG_JUMP_LABEL=y`, unchanged production
code has one true writer and no selected clear writer. Complete `setup_arch()`
return therefore establishes `static_key_initialized == true` before the second
call.

J1 leaves the 86-instruction production `jump_label_init()` unchanged. The
second call must therefore take its initialized `tbnz` fast-return path, skipping
the false-only locking, sorting, jump-table rewrite, initialization store and
unlock sequence while still executing the real common epilogue and `ret`.

After genuine return the caller reloads the static-key byte as corroboration,
then freshly loads the Note10 framebuffer bridge and paints GREEN
(`0xff00ff00`). Captain reported GREEN PASS under the accepted >=3-minute rule.

Stable GREEN proves:
- all physically proven MM2 WHITE facts remain true;
- the second linked `jump_label_init()` executed;
- its entry pre-state was initialized/true;
- unchanged production semantics forced the initialized fast-return branch;
- the false-only initialization path was skipped;
- the common frame/callee-saved/x18-SCS restoration and genuine `ret` completed;
- control returned to `start_kernel()`;
- `static_key_initialized` remained true after return;
- the bridge was freshly loaded after return and remained writable;
- `early_security_init()` did not execute.

The post-return true check is corroboration only, not the fast-path
discriminator. J1 makes no claim that `early_security_init()` or any LSM ran.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`c3e565842d2af6eab7e55de6b79f93d6e247196a2119553b0def3d644d8abef2`

The previous checkpoint is MM2 WHITE. It physically proves complete
`mm_core_init_early()` through genuine return to `start_kernel()` and stops
before the second linked `jump_label_init()` call.

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
