# 2026-09-27 PSCI DT initialization proof

This phase started from the physically proven
`request_standard_resources()` return checkpoint and crossed only PSCI DT
initialization. It stopped after a successful genuine `psci_dt_init()` return
to `setup_arch()` and before `arm64_rsi_init()`.

## Starting authority

Starting proven MAINLINE:

`d9c62bb19c49932752fae10644f76f4166ed4ee8e9f2fc627e1690432ebe6194`

Starting proven source:

`7009c472f176329a802945b5cf2ef2c29dc8045f`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/psci-dt-phase-review.md`

Exact DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

The exact DT source uses:

```text
psci {
    compatible = "arm,psci-0.2";
    method = "hvc";
};
```

The PSCI node is available.

## Corrected pre-boundary semantics

The source-level call immediately before PSCI selection is
`early_ioremap_reset()`:

```c
void __init early_ioremap_reset(void)
{
    after_paging_init = 1;
}
```

On this exact arm64 build, however, both early and late fixmap setting use the
same `__set_fixmap()` implementation, and the late clear form is the
corresponding `__set_fixmap(..., FIXMAP_PAGE_CLEAR)` operation. Exact object
and final linked code therefore reduce the helper to:

```text
early_ioremap_reset:
    ret
```

No physical checkpoint or runtime-state claim is assigned to that source-level
call.

## P1: exact PSCI DT selection before firmware HVC

P1 source:

`1120f3dfa2e40d0c3a704289ff63ae8187484b6c`

P1 Image:

`f6bab1af1a328d98fcad39dfe99d8c99da6ebf23de5a52541d15809c26584fe0`

P1 loader:

`2db30bae4302d9682aae289ea2f1ff41b4f3cf51c4b8589b9ee9740a9df58b31`

P1 BOOT:

`d74989d89b72e6e29acd6130cb64d7d9557316f24a10e94da3e64d1cd74fbadc`

P1 removed only the proven PINK hold, crossed the linked no-op
`early_ioremap_reset()`, and followed the already physically proven
`acpi_disabled == 1` branch into `psci_dt_init()`.

It executed unchanged:
- `of_find_matching_node_and_match()`;
- non-NULL node check;
- `of_device_is_available()`.

The selected match data was cast to typed `psci_initcall_t init_fn`. Any runtime
`init_fn != psci_0_2_init` preserved PINK and self-held. Exact
`init_fn == psci_0_2_init` freshly loaded canonical
`note10_paging_bridge` into fixed/read-only `x9` and painted BLUE
(`0xff0000ff`) before the original indirect call.

The production helpers later used by P2 remained unchanged:
- `psci_0_2_init`: 10 identical normalized instructions;
- `get_set_conduit_method`: 71;
- `psci_probe`: 85;
- `__invoke_psci_fn_hvc`: 33.

Captain observed BLUE stable for at least three minutes.

This physically proves:
- all starting R2 facts remain true;
- the DT lane reached `psci_dt_init()`;
- PSCI node discovery returned non-NULL;
- the node was available;
- runtime selected typed init function was exactly `psci_0_2_init`;
- the bridge remained writable;
- the indirect init function call did not execute;
- no PSCI firmware HVC executed.

## P2: exact HVC/probe path and genuine successful return

P2 source:

`2a78ad48b66e052966be8823f2bb36d4b4387443`

P2 Image:

`6721d3ee729996df62de8d65f6c00eb992aaa5016cf91728cd28be0fee31ef50`

P2 loader:

`4b39bdf878d902f47a4b0d781006ed4d3fc77be9ec03ba75dd29ccac3b5fa47b`

P2 BOOT:

`0ecf7d177732160dca0d8e74d20074678510b8259db2fedb62558e6e773a7766`

P2 removed only the BLUE hold. The selected production helper bodies remained
instruction-equivalent to P1.

Exact DT method `"hvc"` makes unchanged `get_set_conduit_method()` select
`SMCCC_CONDUIT_HVC` and set `invoke_psci_fn = __invoke_psci_fn_hvc`.
Unchanged `psci_probe()` then performs the production PSCI version probe and
any version-selected initialization.

The original `psci_dt_init()` tail from the indirect init call through genuine
return remained equivalent to P1 across 25 normalized lines.

Final linked tail:

```text
ffff8000822a2198  mov x0, x19
ffff8000822a219c  blr x15
ffff8000822a21a0  mov w20, w0
ffff8000822a21ac  mov x0, x19
ffff8000822a21b0  bl of_node_put
ffff8000822a21c8  mov w0, w20
ffff8000822a21cc  ldp x20, x19, [sp, #0x20]
ffff8000822a21d0  ldp x29, x30, [sp, #0x10]
ffff8000822a21d8  ldr x30, [x18, #-0x8]!
ffff8000822a21f0  ret
```

In `setup_arch()`, nonzero return preserves BLUE and self-holds. Only return 0
can reach GREEN:

```text
ffff800082214d90  bl psci_dt_init
ffff800082214d94  cbz w0, ffff800082214da0
ffff800082214d98  wfe
ffff800082214d9c  b ffff800082214d98

ffff800082214da0  mov x9, x19
ffff800082214da8  mov x11, #0xff00
ffff800082214dac  movk x11, #0xff00, lsl #16
ffff800082214db0  movk x11, #0xff00, lsl #32
ffff800082214db4  movk x11, #0xff00, lsl #48
ffff800082214dc4  str x11, [x10], #8
ffff800082214dd0  dsb sy
ffff800082214dd4  wfe
ffff800082214dd8  b ffff800082214dd4

-- unreachable --

ffff800082214ddc  bl arm64_rsi_init
```

Captain reported PASS under the accepted GREEN >=3-minute physical rule.

Stable GREEN physically proves:
- all P1 facts remain true;
- the exact selected `psci_0_2_init` production path was entered;
- unchanged conduit parsing returned success;
- exact DT `"hvc"` caused HVC conduit selection;
- unchanged `psci_probe()` returned success;
- the firmware reported a PSCI version acceptable to the production >=0.2
  path;
- all production work actually selected by that firmware version completed
  sufficiently for `psci_probe()` to return 0;
- the selected init function returned 0;
- `of_node_put()` executed;
- `psci_dt_init()` completed genuine frame/callee-saved/SCS restoration and
  returned;
- `setup_arch()` observed return value 0;
- the bridge remained writable;
- `arm64_rsi_init()` did not execute.

It does not prove:
- an exact PSCI firmware version;
- support for every optional PSCI feature;
- success of optional or ignored-return operations beyond the production
  overall return semantics.

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

## Non-blocking source-comment note

The P1/P2 reviewers both accepted one inherited non-executable issue: the old
`setup_arch()` PINK comment still says the marker will hold before
`early_ioremap_reset()` even though P1 removed that hold. The executable source,
frozen candidate and final linked behavior are correct.

## Promotion and next boundary

Exact P2 BOOT:

`0ecf7d177732160dca0d8e74d20074678510b8259db2fedb62558e6e773a7766`

is the newest proven MAINLINE checkpoint and remains installed.

This closes PSCI DT initialization.

Do not cross `arm64_rsi_init()` without a new bounded architectural phase
plan/review.
