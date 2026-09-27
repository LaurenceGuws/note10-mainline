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

`80587eb6d08902cc1047652a49f33094cb9a757db0f578dc34c885d4384ee220`

It physically proves the complete final `setup_arch()` tail and genuine return
to `start_kernel()`.

The exact frozen AArch64 loader still hands the kernel
`x0=DT, x1=0, x2=0, x3=0`, and unchanged `preserve_boot_args` stores those
values into `boot_args[]`. The final production `setup_arch()` boot-argument
tail and epilogue remained semantically equivalent to the proven PURPLE parent.

After the actual `setup_arch()` `ret` landed back in `start_kernel()`, the
T1 containment re-read `boot_args[1..3]` and required all three to remain zero.
Only then did it reload the published `note10_paging_bridge`, require non-NULL,
and paint BLUE (technical marker `0xff0000ff`).

Captain reported BLUE PASS under the accepted >=3-minute rule.

Stable BLUE therefore proves:
- the production boot-argument tail executed;
- saved x1=x2=x3 were zero;
- the warning `_printk` path was not taken;
- genuine `setup_arch()` frame/callee-saved/SCS restoration completed;
- genuine `setup_arch()` `ret` completed;
- control returned to `start_kernel()`;
- the evidence bridge remained valid/writable after return;
- `mm_core_init_early()` did not execute.

This closes `setup_arch()` completely.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`470198620f2cbd2544e029df8965bbe9581928cd3732225f75352caf62ae543e`

The previous checkpoint is MPIDR-hash H1. It proves the exact published hash and
ends at PURPLE before the final boot-argument tail and genuine return.

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
