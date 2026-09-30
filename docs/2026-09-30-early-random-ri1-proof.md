# Early random initialization RI1 physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`9dd31169095d181a678ddad8a3a613d656c6a08e`

Image:

`f57dd877441d3838654f39db4a72548aabc9c4474797812f60cc360340a12be5`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`6282899552df76ee2fdb639e88c339ab73f60ddb28aca3229957ba37c0f1c3b5`

BOOT:

`21c38ab15fe7d3a5f4b7a79d5850281b1372f3474fedd32bc5d55f5f3eb44acf`

Previous proven MAINLINE / immediate rollback:

`072408ec313851f9d66f69c21efc235ff3f037febf33fc88aa105f2ac5d90b84`

## Frozen reviewed boundary

RI1 crossed exactly:

`rng_is_initialized()` pre-query
→ `random_init_early(command_line)`
→ immediate RED return marker
→ `rng_is_initialized()` post-query
→ bounded continuity checks
→ terminal readiness classification

and stopped before:

`setup_log_buf(0)`

The frozen candidate received independent `FINAL ACCEPT` before the physical BOOT-only write.

## Production target

The reviewed `random_init_early()` body remained production-equivalent at
155 instructions / 23 relocations. The public `rng_is_initialized()` query
remained production-equivalent at 11 instructions / 2 relocations and was
read-only.

The target attempted to fill eight 64-bit architecture-randomness slots using
the unchanged arm64 batched semantics, then unconditionally mixed the 390-byte
`utsname` state and the exact previously proven 133-byte boot command line.

Static evidence deliberately did not claim which SMCCC TRNG or RNDR paths
succeeded at runtime.

## Physical observation

Captain reported the decoded terminal marker:

`CYAN · RI1 PASS (#00ffff)`

Decoded meaning:

`Early random input was mixed. RNG was not initialized before RI1 and still reports not initialized after RI1.`

Therefore the public readiness observation for this physical boot was exactly:

`false -> false`

This proves `random_init_early(command_line)` genuinely returned and its
reviewed bounded postconditions passed. It does **not** prove that every
individual architecture-randomness source failed or succeeded; the candidate
intentionally observes only the public CRNG readiness state.

Under the current bring-up policy, the clearly stable decoded terminal marker
is the semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

RI1 is promoted to MAINLINE.

The next unexecuted production boundary is:

`setup_log_buf(0)`
