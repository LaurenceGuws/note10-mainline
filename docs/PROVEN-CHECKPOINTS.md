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

`aab7bbe7663f0659ce7fd025fb3d3f814f282f0174bda951a030baf267c488e3`

It physically proves the complete arm64 RSI bypass phase on the exact proven
PSCI/SMCCC state. Production `arm64_rsi_init()` and
`arm_smccc_1_1_get_conduit()` remained instruction-equivalent to the proven
PSCI parent. The accepted state proof established that after the physically
proven HVC PSCI path, `arm_smccc_1_1_get_conduit()` can legitimately return
only NONE or HVC, never SMC. The unchanged RSI entry compares the getter result
against `SMCCC_CONDUIT_SMC == 1` and therefore takes the first non-SMC return
before any RSI SMC, version/config query, realm-memory setup, or
`static_branch_enable(&rsi_present)`.

After genuine `arm64_rsi_init()` frame/callee-saved/SCS restoration and
`ret`, `setup_arch()` freshly rebound its surviving bridge `x19 -> x9` and
painted CYAN (technical marker `0xff00ffff`) over the exact `0x2d000`
evidence bridge. Captain reported CYAN PASS under the accepted >=3-minute
physical rule. The actual linked `bl init_cpu_ops` remains unreachable behind
the CYAN hold.

The precise `rsi_present` claim is only that it was not enabled by
`arm64_rsi_init()` on this path. No broader claim about hardware/global RSI or
RME support is made, and the physical proof does not distinguish whether the
runtime SMCCC getter returned NONE or HVC.

The previously stale PINK comment was corrected as reviewer-approved
comment-only hygiene. A control build retaining the old comment produced
identical normalized complete disassembly including relocations; only debug
metadata differed because of the temporary worktree path.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`0ecf7d177732160dca0d8e74d20074678510b8259db2fedb62558e6e773a7766`

The previous checkpoint is PSCI P2. It physically proves successful exact
`psci_0_2_init` / HVC PSCI DT initialization through genuine return value 0,
ending at the GREEN hold before `arm64_rsi_init()`.

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
