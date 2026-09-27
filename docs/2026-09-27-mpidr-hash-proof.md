# 2026-09-27 MPIDR hash proof

This phase started from the physically proven YELLOW `smp_init_cpus()`
checkpoint and crossed only `smp_build_mpidr_hash()`. It stopped before the
`boot_args[1..3]` warning tail and before genuine `setup_arch()` return.

## Starting authority

Starting proven MAINLINE:

`5242447cfaa9fcda25358ac5aa08eabbda2d3fb59aef61195fcc8955348ede84`

Starting proven source:

`7118d50211dab09b179096bd1859be8bf4b040e6`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/mpidr-hash-phase-review.md`

## Proven input and exact derivation

Physically proven possible CPU maps:

`0,1,2,3,4,5,0x100,0x101`

Physically proven possible CPU count:

`8`

The exact deterministic production derivation is:

```text
mask          = 0x107
affinity      = [0x07, 0x01, 0x00, 0x00]
fs            = [0, 0, 0, 0]
bits_per_aff  = [3, 1, 0, 0]
shift_aff     = [0, 5, 12, 28]
bits          = 4
hash_size     = 16
```

Thus the production warning predicate is false:

`16 > 4 * 8` is false.

## Unchanged production hash

`smp_build_mpidr_hash()` remained instruction-equivalent to the proven parent
across 101 instructions.

`cpu_logical_map()` remained instruction-equivalent across 5 instructions.

The production function:
- iterates only possible CPUs;
- folds their MPIDR differences into `mask`;
- derives per-affinity bit widths/shifts;
- publishes `mpidr_hash`;
- evaluates the large-hash warning predicate;
- genuinely returns.

## H1 PURPLE checkpoint

H1 source:

`80ebe0f677ec52fc1a350e1e7383d62176e1c479`

Image:

`bda9dec330e4b94705151ba7068eb1e435b4d169bb645f1d0a7762a7520ac382`

Loader:

`6832dc7477e49a25590473a79971a66efc302e9ad87a990ecdff6138bdfeb341`

BOOT:

`470198620f2cbd2544e029df8965bbe9581928cd3732225f75352caf62ae543e`

H1 removed only the YELLOW hold and ran original `smp_build_mpidr_hash()`
unchanged. After genuine return it required:
- `mask == 0x107`;
- shifts `[0,5,12,28]`;
- `bits == 4`;
- source-level `mpidr_hash_size() == 16`;
- `num_possible_cpus() == 8`.

The compiler eliminated the separate hash-size comparison because the unchanged
inline definition is `1 << mpidr_hash.bits` and the linked containment already
requires `bits == 4`. The independent frozen-candidate review explicitly
accepted this optimization as preserving the full source-level postcondition.

Any failed independent field/count check self-held on YELLOW. Only complete
success painted PURPLE (`0xff8000ff`).

Final linked boundary:

```text
ffff800082214f50  bl smp_build_mpidr_hash

ffff800082214f5c  ldr x9, [mpidr_hash]
ffff800082214f60  cmp x9, #0x107
...
ffff800082214f68  ldr w9, [mpidr_hash, #0x8]
ffff800082214f6c  cbnz w9, FAIL_YELLOW
ffff800082214f70  ldr w9, [mpidr_hash, #0xc]
ffff800082214f74  cmp w9, #0x5
ffff800082214f7c  ldr w9, [mpidr_hash, #0x10]
ffff800082214f80  cmp w9, #0xc
ffff800082214f88  ldr w9, [mpidr_hash, #0x14]
ffff800082214f8c  cmp w9, #0x1c
ffff800082214f94  ldr w8, [mpidr_hash, #0x18]
ffff800082214f98  cmp w8, #0x4

ffff800082214fa4  ldr w8, [__num_possible_cpus]
ffff800082214fa8  cmp w8, #0x8

ffff800082214fb0  wfe
ffff800082214fb4  b ffff800082214fb0

ffff800082214fb8  mov x9, x19
ffff800082214fc0  mov x11, #0xff
ffff800082214fc4  movk x11, #0xff80, lsl #16
ffff800082214fc8  movk x11, #0xff, lsl #32
ffff800082214fcc  movk x11, #0xff80, lsl #48
ffff800082214fdc  str x11, [x10], #8
ffff800082214fe8  dsb sy
ffff800082214fec  wfe
ffff800082214ff0  b ffff800082214fec

-- unreachable --

ffff800082214ff4  adrp x8, boot_args
```

Captain reported PURPLE PASS under the accepted >=3-minute physical rule.

Stable PURPLE proves:
- `smp_build_mpidr_hash()` genuinely returned;
- exact published mask, shifts, bits and implied size;
- possible CPU count 8;
- false production large-hash warning predicate;
- no execution of the boot-argument warning tail;
- no genuine `setup_arch()` return yet.

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
checksum/id-only and accepted AVB stale-descriptor behavior was unchanged.

## Promotion and next boundary

Exact H1 BOOT:

`470198620f2cbd2544e029df8965bbe9581928cd3732225f75352caf62ae543e`

is the newest proven MAINLINE checkpoint and remains installed.

This closes the MPIDR-hash phase.

The next bounded decision is the final `setup_arch()` tail:
- evaluate the `boot_args[1..3]` warning condition;
- possibly print the warning;
- genuinely restore the `setup_arch()` frame/callee-saved/SCS state and return.

Do not cross that tail without a new bounded architectural phase plan/review.
