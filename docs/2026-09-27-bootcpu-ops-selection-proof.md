# 2026-09-27 boot CPU operations selection proof

This phase started from the physically proven CYAN RSI checkpoint and crossed
only the original boot CPU operations-selection call. It stopped after a
successful non-NULL `get_cpu_ops(0)` observation and before `smp_init_cpus()`.

## Starting authority

Starting proven MAINLINE:

`aab7bbe7663f0659ce7fd025fb3d3f814f282f0174bda951a030baf267c488e3`

Starting proven source:

`99592f24ccc1fd80c7311ed0d076b589d78bc491`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/bootcpu-ops-phase-review.md`

The starting checkpoint physically proved `arm64_rsi_init()` genuine return
and left the actual linked `bl init_cpu_ops` unreachable.

## Exact frozen CPU0 input

Exact DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

The kernel-built dtc independently decompiled CPU0 as:

```text
cpu@0 {
    device_type = "cpu";
    compatible = "arm,cortex-a55";
    reg = <0x00 0x00>;
    enable-method = "psci";
    phandle = <0x02>;
};
```

The physically proven runtime lane remains DT-based with `acpi_disabled == 1`.

## Unchanged production selector

Production helpers remained untouched and matched the proven parent:

- `init_cpu_ops`: 28 normalized instructions;
- `cpu_read_enable_method`: 53;
- `cpu_get_ops`: 32;
- `get_cpu_ops`: 5.

The source-level wrapper remains:

```c
static inline void __init init_bootcpu_ops(void)
{
    init_cpu_ops(0);
}
```

Production DT-supported operations are:
- `smp_spin_table_ops` with name `"spin-table"`;
- `cpu_psci_ops` with name `"psci"`;
- NULL.

Thus exact CPU0 `"psci"` uniquely maps to `&cpu_psci_ops`.

## Initial/write invariant

`cpu_ops[]` is static zero-initialized storage.

Repository-wide source search finds one assignment:

```c
cpu_ops[cpu] = cpu_get_ops(enable_method);
```

Before `smp_init_cpus()`, the only CPU0 call is the boot wrapper being crossed
in this phase.

Production failure semantics:
- missing method returns `-ENODEV` before assignment and leaves NULL;
- unsupported method stores NULL then returns `-EOPNOTSUPP`;
- success stores non-NULL then returns 0.

Therefore a post-return `get_cpu_ops(0) != NULL` proves successful completion
of `init_cpu_ops(0)`. Combined with the exact CPU0 DT property and unchanged
lookup logic, it identifies `cpu_ops[0] == &cpu_psci_ops`.

## B1 RED physical checkpoint

B1 source:

`265b25d4a6819bbf78fbee4c97a2006e431c9b14`

B1 Image:

`dbaee74007a58dc2e4ed2cd92c8eb5900a0096ea47624b45f8dba265f2e12445`

B1 loader:

`cd8ed05455bcca7d5f26ddea13bb0d9cf4d6b711b4356bdd123d152b5b5ccbc8`

B1 BOOT:

`6abd2f0e776fa89f5023a5c5072261122263efa9339b098a91d25f0f5eacd1ef`

B1 removed only the CYAN hold and executed the original linked:

```text
mov w0, wzr
bl init_cpu_ops
```

After genuine return, it called the existing pure accessor
`get_cpu_ops(0)` only for diagnostic containment. NULL preserved CYAN and
self-held. Non-NULL alone reached RED.

Final linked seam:

```text
ffff800082214e0c  mov w0, wzr
ffff800082214e10  bl init_cpu_ops

ffff800082214e14  mov w0, wzr
ffff800082214e18  bl get_cpu_ops
ffff800082214e1c  cbnz x0, ffff800082214e28

ffff800082214e20  wfe
ffff800082214e24  b ffff800082214e20

ffff800082214e28  mov x9, x19
ffff800082214e2c  mov x10, x9
ffff800082214e30  mov x11, #0x0
ffff800082214e34  movk x11, #0xffff, lsl #16
ffff800082214e38  movk x11, #0xffff, lsl #48
ffff800082214e48  str x11, [x10], #8
ffff800082214e54  dsb sy
ffff800082214e58  wfe
ffff800082214e5c  b ffff800082214e58

-- unreachable --

ffff800082214e60  bl smp_init_cpus
```

Captain observed bright RED upright for at least three minutes. Looking at the
panel from the side briefly made it appear orange; the direct upright view was
bright RED and stable. This is recorded as a viewing-angle observation, not a
marker mismatch.

Stable RED physically proves:
- all CYAN/S1 facts remain true;
- original `init_cpu_ops(0)` executed and returned;
- post-return `get_cpu_ops(0)` returned non-NULL;
- exact DT `"psci"` plus unchanged selector logic establishes
  `cpu_ops[0] == &cpu_psci_ops`;
- boot CPU operations selection completed successfully;
- no `cpu_psci_ops` callback ran before RED;
- no kernel PSCI `CPU_ON` occurred before RED;
- `smp_init_cpus()` did not execute.

It does not prove:
- any secondary CPU was enumerated;
- any secondary CPU ops were selected;
- `cpu_psci_cpu_init` or `cpu_psci_cpu_prepare` ran;
- any CPU logical map was constructed by `smp_init_cpus()`.

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

Exact B1 BOOT:

`6abd2f0e776fa89f5023a5c5072261122263efa9339b098a91d25f0f5eacd1ef`

is the newest proven MAINLINE checkpoint and remains installed.

This closes boot CPU operations selection.

The next architectural boundary is `smp_init_cpus()`. Do not cross it without
a new bounded architectural phase plan/review.
