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

`5242447cfaa9fcda25358ac5aa08eabbda2d3fb59aef61195fcc8955348ede84`

It physically proves the complete `smp_init_cpus()` phase. All nine production
helpers remained instruction-equivalent to the proven RED parent. Exact frozen
DT contains eight `"psci"` CPU nodes with MPIDRs
`0,1,2,3,4,5,0x100,0x101`.

The accepted anti-counterfeit pre-state is important: `CONFIG_INIT_ALL_POSSIBLE`
is absent, the possible mask starts zeroed, `boot_cpu_init()` marks only CPU0
possible before `setup_arch()`, secondary logical maps begin
`INVALID_HWID`, and secondary `cpu_ops[]` entries begin NULL.

After original `smp_init_cpus()` genuinely returned, diagnostic checks required:
- CPU0 ops remained non-NULL;
- all eight logical maps matched the exact DT MPIDRs;
- every CPU 1-7 shared CPU0's already-proven PSCI ops pointer;
- every CPU 1-7 was marked possible.

Any failure preserved RED. Only complete success repainted the evidence bridge
YELLOW (technical marker `0xffffff00`). Captain reported YELLOW PASS under the
accepted >=3-minute rule.

Combined with exact all-`"psci"` DT input, unchanged selector logic and unchanged
`cpu_psci_cpu_init()` which is exactly `mov w0, wzr; ret`, this establishes
successful PSCI `cpu_init` for all seven secondaries. It does not establish
that any secondary is present or online. No `cpu_prepare`, `cpu_boot`, or
kernel PSCI `CPU_ON` occurred, and `smp_build_mpidr_hash()` remained
unreachable.

The checkpoint remains installed.

Previous proven MAINLINE checkpoint:

`6abd2f0e776fa89f5023a5c5072261122263efa9339b098a91d25f0f5eacd1ef`

The previous checkpoint is boot CPU ops B1. It proves CPU0 selected
`&cpu_psci_ops` and ends at RED before `smp_init_cpus()`.

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
