# Exynos9825 / d2s UFS bring-up

## Current floor

The public `EithanAsulin/exynos-9825-mainline-linux` snapshot at
`796981b622418debafa20e264ff8eb38122845f0` reports that the d2s UFS link and
device enumerate but block reads do not work reliably. Its tree contains a
substantial Exynos9820 UFS host/PHY port plus several d2s bring-up quirks.

Our first task is to convert that experimental snapshot into behaviour that is
both correct for the N975F and explainable against Samsung's working Exynos9820
4.14 implementation.

## Frozen reference build

Unmodified public snapshot:

- source: `796981b622418debafa20e264ff8eb38122845f0`
- compiler: Android clang 21.0.0 `r563880c`, LLVM revision `5e96669f0607...`
- d2s config SHA-256: `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`
- Image SHA-256: `1c73d1aca878d0ca8f10b16dbab56dba1eb615994faacb012610efda3ede00ca`
- `exynos9825-d2s.dtb` SHA-256: `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

Build products live in the workstream, not this repository.

## Vendor-correlated requirements already established

### Byte-granular PRDT length

Samsung's working Exynos9820 4.14 UFS core special-cases
`CONFIG_SOC_EXYNOS9820` and writes:

```text
PRDTL = scatterlist_entries * sizeof(struct ufshcd_sg_entry) + 16
```

The standard PRD structure is 16 bytes. Therefore the encoded controller field
is:

```text
PRDTL = 16 * N + 16
```

This is not merely inferred from the public mainline port. It is present in the
working Samsung source used by our accepted current kernel.

### 32-bit DMA

Samsung's Exynos UFS platform driver assigns a `DMA_BIT_MASK(32)` to the UFS
device before UFS core allocates its DMA-backed command structures. The public
d2s tree reproduces that policy through the Exynos variant `set_dma_mask`
callback before generic UFS DMA allocation.

This makes the public tree's observation that data commands fail when UFS DMA
lands above 4 GiB consistent with the working vendor implementation.

### 128-byte FMP PRDT stride

With Samsung FMP enabled, the working vendor driver changes
`hba->sg_entry_size` to `sizeof(struct fmp_table_setting)`. The UFS variant is a
32-dword / 128-byte record. The command-descriptor allocation and iteration
therefore use a 128-byte physical stride.

Critically, Samsung **does not** use that 128-byte stride to calculate PRDTL on
Exynos9820. It still encodes `16 * N + 16` in the controller field.

This means two independent sizes coexist by design:

```text
memory allocation / PRD stride = 128 bytes with FMP
controller PRDT length field   = 16 * N + 16 bytes on Exynos9820
```

## First candidate bug

The public d2s snapshot combines the generic mainline FMP stride support with a
new `UFSHCD_QUIRK_PRDT_LEN_INCLUDES_HEADER` quirk. Its current calculation is:

```text
PRDTL = N * ufshcd_sg_entry_size(hba) + 16
```

When FMP secure initialization succeeds, `ufshcd_sg_entry_size()` is 128. A
single-segment data request is therefore advertised to the controller as:

```text
public d2s: 128 * 1 + 16 = 144 bytes
vendor:      16 * 1 + 16 =  32 bytes
```

Control/query traffic that carries no PRDT can still work, which is consistent
with the observed state where the UFS device enumerates while data reads fail.

`UFSHCD_QUIRK_BROKEN_CRYPTO_ENABLE` does not invalidate this hypothesis. That
quirk suppresses the standard `CRYPTO_GENERAL_ENABLE` bit; it does not prevent
the Exynos secure-monitor FMP setup from selecting 128-byte descriptors.

## Candidate correction

Branch/worktree: `captain/ufs-prdt-length` in the mainline workstream.

The candidate keeps the 128-byte variant stride for allocation and PRD
iteration, but when `UFSHCD_QUIRK_PRDT_LEN_INCLUDES_HEADER` is active it encodes
and decodes PRDTL using the standard 16-byte PRD size plus one additional
16-byte entry. No other `UFSHCD_QUIRK_PRDT_BYTE_GRAN` host changes behaviour.

Offline gates:

- reference source builds cleanly before the change;
- `git diff --check`: pass;
- `scripts/checkpatch.pl --strict`: 0 errors, 0 warnings, 0 checks;
- full d2s Image + DTB build: **pass**;
- candidate commit: `0f909c956f4f5d3ebfd5217dd22b73d9b4f4fa82`;
- candidate config SHA-256: `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37` (identical to reference);
- candidate Image SHA-256: `e85f0ab067162d25b6af2df6f79ac2648f81285e1939bbf03bc2f711a47cf35e`;
- candidate Image size: `44,247,552` bytes (unchanged);
- candidate d2s DTB SHA-256: `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6` (byte-identical to reference);
- physical UFS read test: **not yet performed**.

## Other known UFS boundaries

The public snapshot also records a real hibern8 failure mode. After idle, the
PHY can fail to leave hibern8 and trigger abort/reset storms. The tree therefore
keeps runtime/system power mode ACTIVE and disables broken auto-hibern8 during
bring-up. That problem is distinct from the PRDT data-command issue and should
not be conflated with it.

The Exynos9820 PHY driver in the snapshot carries an explicit port of Samsung's
9820 UFS calibration tables, including pre/post-link, power-mode and hibern8
calibration/poll sequences. We should still audit them exactly, but the current
storage failure is not simply an absence of PHY calibration.

## Promotion rule

A successful compile does not establish that UFS reads are fixed. The next
physical candidate must prove, in order:

1. link/device enumeration remains stable;
2. bounded read-only SCSI/block reads complete repeatedly;
3. partition-table reads succeed;
4. a disposable filesystem can be mounted read-only;
5. repeated I/O survives idle periods without hibern8/reset regressions.

No writable-root experiment is earned before those gates pass.
