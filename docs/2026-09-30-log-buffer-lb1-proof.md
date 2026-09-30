# Log-buffer setup LB1 physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`2b3dc98e0aa5de7d587eb1c47cab08d1b043c5d0`

Image:

`2a08407e3c75999d67de90a907a0b0fae13b2e5af0eb7a7b0fd7baefa632d4d3`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`0139156a74b21dab3417a882ef87a39d16659961ff4c842f86338b89e1a1bb5c`

BOOT:

`0ba42adc09058b7e4c374820f27ba89c334d2d89c1a8b066d83256f1fa26b276`

Previous proven MAINLINE / immediate rollback:

`21c38ab15fe7d3a5f4b7a79d5850281b1372f3474fedd32bc5d55f5f3eb44acf`

## Frozen reviewed boundary

LB1 crossed exactly:

`log_buf_addr_get()` / `log_buf_len_get()` pre-state
→ exact `setup_log_buf(0)`
→ immediate RED return marker
→ public log-buffer address/length post-state
→ IRQ-disabled / CPU0 / fresh-bridge continuity checks
→ terminal GREEN classification

and stopped before:

`vfs_caches_init_early()`

The frozen candidate received independent `FINAL ACCEPT` before the physical BOOT-only write.

## Deterministic pre-state

The accepted config has `CONFIG_LOG_BUF_SHIFT=17`, so the public static
printk text ring begins at exactly 131,072 bytes.

The previously proven boot command line contains exact `log_buf_len=4M`.
Unchanged early-param handling therefore leaves the production pending
log-buffer request at exactly 4 MiB before `setup_log_buf(0)`.

No arm64 `setup_log_buf()` invocation occurs before the start_kernel target.

## Unchanged production target

The frozen review independently preserved exact production equivalence for:

- `setup_log_buf()`: 226 instructions / 75 relocations;
- `log_buf_addr_get()`: 4 / 2;
- `log_buf_len_get()`: 4 / 2.

Parent/candidate printk `.text` and `.init.text` sections were byte-identical.

With the exact 4 MiB pending request, unchanged production requests:

- 4 MiB text storage;
- 3 MiB descriptor storage;
- 11 MiB printk-info storage;

for an exact 18 MiB total bootmem footprint.

Allocation failure is nonfatal in production, so LB1 deliberately required the
public ring transition rather than treating target return alone as success.

## Physical observation

Captain reported the decoded terminal marker:

`GREEN · LB1 PASS (#00ff00)`

Decoded meaning:

`setup_log_buf(0) returned; the public printk buffer address changed and its public length became exactly 4 MiB, with interrupts still disabled, CPU0 continuity intact, and a valid fresh final bridge.`

Therefore the physical boot proves:

- the target genuinely returned;
- the public printk buffer address changed from its exact pre-target value;
- public log-buffer length changed from 131,072 bytes to exactly 4,194,304 bytes;
- the production dynamic-ring path progressed far enough to install the new
  public ring rather than taking an allocation-failure return;
- IRQ-disabled state survived the target;
- CPU0 continuity survived;
- the final framebuffer evidence bridge remained valid.

LB1 does not claim exact preservation of every individual printk record and
does not inspect or expose private printk ring state.

Under the current bring-up policy, the clearly stable decoded terminal marker
is the semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

LB1 is promoted to MAINLINE.

The next unexecuted production boundary is:

`vfs_caches_init_early()`
