# 2026-09-27 smp_init_cpus proof

This phase started from the physically proven RED boot-CPU-ops checkpoint and
crossed only `smp_init_cpus()`. It stopped before `smp_build_mpidr_hash()`.

## Starting authority

Starting proven MAINLINE:

`6abd2f0e776fa89f5023a5c5072261122263efa9339b098a91d25f0f5eacd1ef`

Starting proven source:

`265b25d4a6819bbf78fbee4c97a2006e431c9b14`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/smp-init-cpus-phase-review.md`

## Exact topology and anti-counterfeit pre-state

Exact DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

Exact eight CPU MPIDRs:

`0, 1, 2, 3, 4, 5, 0x100, 0x101`

All eight use `enable-method = "psci"`.

Exact bootargs contain no `nosmp`, `maxcpus=` or `nr_cpus=`.

The independent phase review required and accepted these starting invariants:
- `CONFIG_INIT_ALL_POSSIBLE` absent;
- possible mask begins zeroed;
- `boot_cpu_init()` marks only CPU0 possible before `setup_arch()`;
- CPUs 1-7 are not already possible at RED;
- secondary logical maps initially equal `INVALID_HWID`;
- secondary `cpu_ops[]` entries initially equal NULL.

These prevent an early-return/failure path from counterfeit-passing the final
postconditions.

## Unchanged production path

All production helpers remained instruction-equivalent to B1:

- `smp_init_cpus`: 60 instructions;
- `of_parse_and_init_cpus`: 91;
- `smp_cpu_setup`: 25;
- `init_cpu_ops`: 28;
- `cpu_read_enable_method`: 53;
- `cpu_get_ops`: 32;
- `get_cpu_ops`: 5;
- `cpu_psci_cpu_init`: 2;
- `cpu_logical_map`: 5.

`cpu_psci_cpu_init()` remains exactly:

```text
mov w0, wzr
ret
```

No `cpu_prepare` or `cpu_boot` callback is part of `smp_init_cpus()`.

## S2 YELLOW checkpoint

S2 source:

`7118d50211dab09b179096bd1859be8bf4b040e6`

Image:

`231917c717ec06c5204d13edd5f3a7fc552047af579a735b14972dbb31c8832e`

Loader:

`1dc4f93b9e0073151c6196624a99e9965820e61310dfb157f5969a921026af7b`

BOOT:

`5242447cfaa9fcda25358ac5aa08eabbda2d3fb59aef61195fcc8955348ede84`

S2 removed only the RED hold and ran original `smp_init_cpus()` unchanged.
After genuine return, it required:
- CPU0 ops non-NULL;
- exact logical maps `0,1,2,3,4,5,0x100,0x101`;
- each CPU 1-7 ops pointer equal to CPU0's already-proven PSCI ops pointer;
- each CPU 1-7 possible bit set.

Any failed check self-held on RED. Only complete success painted YELLOW
(`0xffffff00`).

Final linked stop:

```text
ffff800082214e60  bl smp_init_cpus
...
ffff800082214f14  wfe          # failed postcondition keeps RED
ffff800082214f18  b ffff800082214f14

ffff800082214f1c  mov x9, x19  # complete success only
...
ffff800082214f4c  dsb sy
ffff800082214f50  wfe
ffff800082214f54  b ffff800082214f50

-- unreachable --

ffff800082214f58  bl smp_build_mpidr_hash
```

Captain reported YELLOW PASS under the accepted >=3-minute physical rule.

Stable YELLOW proves:
- original `smp_init_cpus()` genuinely returned;
- exact CPU logical-map topology matches the frozen DT;
- CPUs 1-7 selected the same PSCI ops pointer as CPU0;
- CPUs 1-7 became possible;
- unchanged `cpu_psci_cpu_init()` succeeded for all seven secondaries;
- no `cpu_prepare` callback ran;
- no `cpu_boot` callback ran;
- no kernel PSCI `CPU_ON` occurred;
- `smp_build_mpidr_hash()` did not execute.

It does not prove that any secondary CPU is present or online.

## Reproducibility

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE`:

`2026-09-26 01:21:56 UTC`

Paired loader builds and BOOT packaging runs were byte-identical.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail stayed
byte-identical to the previous proven MAINLINE. Header drift remained
checksum/id-only, and accepted AVB stale-descriptor behavior was unchanged.

## Promotion and next boundary

Exact S2 BOOT:

`5242447cfaa9fcda25358ac5aa08eabbda2d3fb59aef61195fcc8955348ede84`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `smp_init_cpus()`.

The next architectural boundary is `smp_build_mpidr_hash()`. Do not cross it
without a new bounded architectural phase plan/review.
