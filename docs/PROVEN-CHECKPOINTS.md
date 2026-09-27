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

`6abd2f0e776fa89f5023a5c5072261122263efa9339b098a91d25f0f5eacd1ef`

It physically proves the complete boot CPU operations-selection phase.
Production `init_cpu_ops()`, `cpu_read_enable_method()`, `cpu_get_ops()` and
`get_cpu_ops()` remained instruction-equivalent to the proven CYAN parent.
The exact frozen DTB CPU0 node has `enable-method = "psci"` and the DT-supported
ops table uniquely maps `"psci"` to `&cpu_psci_ops`.

`cpu_ops[]` is static zero-initialized storage and the only writer is the
assignment inside `init_cpu_ops()`. The `-ENODEV` failure leaves
`cpu_ops[0] == NULL` and the unsupported-method `-EOPNOTSUPP` path stores NULL.
After the original `init_bootcpu_ops() / init_cpu_ops(0)` call genuinely
returned, the existing pure `get_cpu_ops(0)` accessor returned non-NULL.
Combined with the exact frozen DT input and unchanged selector logic, this
establishes `cpu_ops[0] == &cpu_psci_ops`.

Only after that non-NULL result did `setup_arch()` freshly rebind its surviving
bridge `x19 -> x9` and paint RED (technical marker `0xffff0000`) over the exact
`0x2d000` evidence bridge. Captain observed bright RED upright for at least
three minutes. A side-angle view briefly appeared orange; this was recorded as
a panel/viewing-angle effect because the direct upright view was bright RED and
stable.

No `cpu_psci_ops` callback executed before RED, no kernel PSCI `CPU_ON` call
occurred before RED, and `smp_init_cpus()` remained unreachable.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`aab7bbe7663f0659ce7fd025fb3d3f814f282f0174bda951a030baf267c488e3`

The previous checkpoint is RSI S1. It physically proves the genuine non-SMC
`arm64_rsi_init()` return and ends at CYAN before the actual
`init_cpu_ops(0)` call.

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
