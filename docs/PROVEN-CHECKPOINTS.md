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

`0ecf7d177732160dca0d8e74d20074678510b8259db2fedb62558e6e773a7766`

It physically proves the complete PSCI DT initialization phase on the exact
Exynos9825 DT lane. P1 crossed the already-proven `acpi_disabled == 1` branch,
the linked no-op `early_ioremap_reset()`, PSCI DT node discovery and
availability checks, then runtime-confirmed that the selected typed init
function was exactly `psci_0_2_init`. BLUE (technical marker `0xff0000ff`)
remained stable for at least three minutes while the indirect init call and
therefore all PSCI firmware HVCs remained unreachable.

P2 then removed only the BLUE hold. The production `psci_0_2_init`,
`get_set_conduit_method`, `psci_probe` and HVC helper bodies remained
instruction-equivalent to P1. Exact DT method `"hvc"` selected the HVC
conduit. The original indirect init call completed, `of_node_put()` executed,
and `psci_dt_init()` completed its genuine frame/callee-saved/SCS restoration
and `ret`. `setup_arch()` accepted only return value 0, freshly rebound its
surviving bridge `x19 -> x9`, and painted GREEN (technical marker
`0xff00ff00`) over the exact `0x2d000` evidence bridge. Captain reported PASS
under the accepted GREEN >=3-minute physical rule. `arm64_rsi_init()` remains
unreachable.

The proof intentionally does not claim an exact PSCI firmware version, blanket
optional-feature support, or success of ignored-return operations beyond what
the production overall return semantics guarantee.

A reviewer also recorded one non-blocking source-comment issue: the inherited
`setup_arch()` PINK comment still says it will hold before
`early_ioremap_reset()` although the executable hold was removed in P1. The
frozen executable behavior and linked proof are correct.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`d74989d89b72e6e29acd6130cb64d7d9557316f24a10e94da3e64d1cd74fbadc`

The previous checkpoint is PSCI P1. It physically proves a non-NULL,
available PSCI DT node whose runtime selected typed init function equals
`psci_0_2_init`, ending at the BLUE hold before the indirect init call and
before any PSCI firmware HVC.

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
