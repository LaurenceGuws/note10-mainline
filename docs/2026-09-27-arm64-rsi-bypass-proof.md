# 2026-09-27 arm64 RSI bypass proof

This phase started from the physically proven successful PSCI DT initialization
checkpoint and crossed only `arm64_rsi_init()`. It stopped after genuine RSI
return to `setup_arch()` and before the actual linked `bl init_cpu_ops` for CPU
0.

## Starting authority

Starting proven MAINLINE:

`0ecf7d177732160dca0d8e74d20074678510b8259db2fedb62558e6e773a7766`

Starting proven source:

`2a78ad48b66e052966be8823f2bb36d4b4387443`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/arm64-rsi-phase-review.md`

PSCI P2 had already physically proved:
- exact runtime `psci_0_2_init` selection;
- exact DT `"hvc"` conduit path;
- successful unchanged `psci_probe()`;
- genuine `psci_dt_init()` return value 0.

## Conduit-state proof

Exact enum values are:

```text
SMCCC_CONDUIT_NONE = 0
SMCCC_CONDUIT_SMC  = 1
SMCCC_CONDUIT_HVC  = 2
```

SMCCC global state starts at version 1.0 with conduit NONE.

`arm_smccc_1_1_get_conduit()` returns NONE while the stored SMCCC version is
below 1.1; otherwise it returns the stored conduit.

Repository-wide source inspection established that the only caller of
`arm_smccc_version_init(version, conduit)` is PSCI's `psci_init_smccc()`.
When PSCI establishes SMCCC >=1.1, it passes `psci_conduit`. The physically
proven PSCI path selected HVC.

Therefore, after proven PSCI P2, the legitimate runtime getter domain is:
- NONE; or
- HVC.

SMC is excluded. The proof intentionally does not distinguish which of NONE
versus HVC is returned at runtime.

## Unchanged RSI function

Production `arm64_rsi_init()` was not edited.

Fast object comparison against proven PSCI P2:

`ARM64_RSI_INIT_OBJECT_EQUIVALENCE=PASS`

across 121 instructions.

The SMCCC getter was also unchanged:

`ARM_SMCCC_1_1_GET_CONDUIT_OBJECT_EQUIVALENCE=PASS`

across 9 instructions.

Production begins:

```c
if (arm_smccc_1_1_get_conduit() != SMCCC_CONDUIT_SMC)
    return;
```

Final linked code:

```text
ffff80008221a5a0  bl arm_smccc_1_1_get_conduit
ffff80008221a5a4  cmp w0, #0x1
ffff80008221a5a8  b.ne ffff80008221a5f8

-- SMC-only body --

ffff80008221a5e8  bl __arm_smccc_smc

-- accepted non-SMC return path --

ffff80008221a5f8  mrs x8, SP_EL0
ffff80008221a5fc  ldr x8, [x8, #0x580]
ffff80008221a600  ldur x9, [x29, #-0x8]
ffff80008221a604  cmp x8, x9
ffff80008221a608  b.ne stack_chk_fail
ffff80008221a60c  ldp x29, x30, [sp, #0x40]
ffff80008221a610  ldr x19, [sp, #0x50]
ffff80008221a614  add sp, sp, #0x60
ffff80008221a618  ldr x30, [x18, #-0x8]!
ffff80008221a650  ret
```

Because SMC is excluded by the accepted state proof, the legitimate path takes
the first non-SMC return before:
- the first RSI SMC;
- `rsi_version_matches()`;
- `rsi_get_realm_config()`;
- realm-memory setup;
- `static_branch_enable(&rsi_present)`.

The precise static-key claim is only:

`rsi_present was not enabled by arm64_rsi_init() on this path.`

No broader hardware/global RSI or RME support claim is made.

## S1 CYAN physical checkpoint

S1 source:

`99592f24ccc1fd80c7311ed0d076b589d78bc491`

S1 Image:

`d9e92483596cab3746ff3060a4e550f27acd7c2dd45ef8b0e1cc5ce354141bd4`

S1 loader:

`45ea9d8bd2cea84998079a3dd9351d91ed3425d3d8915fbce0ee0c0f0cafc343`

S1 BOOT:

`aab7bbe7663f0659ce7fd025fb3d3f814f282f0174bda951a030baf267c488e3`

S1 removed only the GREEN hold, left RSI/getter production code untouched, and
allowed genuine `arm64_rsi_init()` return. Only after that return did
`setup_arch()` freshly rebind its surviving bridge `x19 -> x9` and paint CYAN
(`0xff00ffff`).

Final linked boundary:

```text
ffff800082214dd4  bl arm64_rsi_init
ffff800082214dd8  mov x9, x19
ffff800082214ddc  mov x10, x9
ffff800082214de0  mov x11, #0xffff
ffff800082214de4  movk x11, #0xff00, lsl #16
ffff800082214de8  movk x11, #0xffff, lsl #32
ffff800082214dec  movk x11, #0xff00, lsl #48
ffff800082214dfc  str x11, [x10], #8
ffff800082214e08  dsb sy
ffff800082214e0c  wfe
ffff800082214e10  b ffff800082214e0c

-- unreachable --

ffff800082214e14  mov w0, wzr
ffff800082214e18  bl init_cpu_ops
```

The accepted phase review explicitly distinguishes the compiler's
`mov w0, wzr` argument preparation from crossing the next boundary. The actual
`bl init_cpu_ops` remained unreachable.

Captain reported CYAN PASS under the requested >=3-minute physical rule, then
returned the device to Download Mode.

Stable CYAN proves:
- all PSCI P2 facts remain true;
- `arm64_rsi_init()` entered and genuinely returned;
- combined with the accepted conduit-state proof and unchanged RSI code, the
  legitimate path took the first non-SMC bypass;
- no RSI SMC/version/config/memory path executed;
- `rsi_present` was not enabled by `arm64_rsi_init()` on this path;
- the surviving bridge remained writable;
- actual `init_cpu_ops(0)` did not execute.

## Comment-only hygiene

Both PSCI candidate reviewers had flagged an inherited stale PINK source comment
which still claimed PINK would hold before `early_ioremap_reset()`.

The RSI phase review explicitly allowed correcting this comment.

An otherwise identical S1 control source retaining the old comment was compiled.
Normalized complete disassembly including relocations was identical to S1.
Raw object bytes differed only in debug metadata because the temporary control
worktree had a different source path.

Thus the cleanup has no executable semantic effect.

## Reproducibility

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE`:

`2026-09-26 01:21:56 UTC`

Paired loader builds and paired BOOT packaging runs were byte-identical.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail remained
byte-identical to the immediately previous proven MAINLINE. Header drift stayed
inside the accepted checksum/id-only envelope. Accepted AVB stale-descriptor
behavior remained unchanged.

## Promotion and next boundary

Exact S1 BOOT:

`aab7bbe7663f0659ce7fd025fb3d3f814f282f0174bda951a030baf267c488e3`

is the newest proven MAINLINE checkpoint and remains the proven installed image,
with the device subsequently returned to Download Mode by Captain.

This closes the arm64 RSI bypass phase.

The next meaningful linked boundary is the actual `bl init_cpu_ops` with
argument 0, i.e. `init_bootcpu_ops()`. Do not cross that call without a new
bounded architectural phase plan/review.
