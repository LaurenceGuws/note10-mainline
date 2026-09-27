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

`470198620f2cbd2544e029df8965bbe9581928cd3732225f75352caf62ae543e`

It physically proves the complete `smp_build_mpidr_hash()` phase on the
already-proven eight-CPU possible set. Production `smp_build_mpidr_hash()`
remained instruction-equivalent to the proven YELLOW parent.

The physically proven input maps are
`0,1,2,3,4,5,0x100,0x101` with `num_possible_cpus() == 8`. Those inputs
deterministically yield:
- `mask = 0x107`;
- `shift_aff = [0,5,12,28]`;
- `bits = 4`;
- `mpidr_hash_size() = 16`.

After genuine hash-builder return, linked containment required every independent
published field and possible-count value to match exactly. The source-level
`mpidr_hash_size() == 16` check was optimized away as redundant once
`mpidr_hash.bits == 4` is required, because the unchanged inline definition is
exactly `1 << mpidr_hash.bits`.

Only complete success repainted the evidence bridge PURPLE (technical marker
`0xff8000ff`). Captain reported PURPLE PASS under the accepted >=3-minute rule.

The production large-hash warning predicate is therefore false for the proven
state: `16 > 4 * 8` is false. The subsequent `boot_args[1..3]` warning tail did
not execute and `setup_arch()` did not return.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`5242447cfaa9fcda25358ac5aa08eabbda2d3fb59aef61195fcc8955348ede84`

The previous checkpoint is SMP-init S2. It physically proves the exact
eight-CPU logical maps, PSCI ops identity for CPUs 1-7, and their possible
state, ending at YELLOW before `smp_build_mpidr_hash()`.

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
