# 2026-09-28 get_boot_config_from_initrd proof

This phase started from the physically proven L1 MAGENTA checkpoint and crossed
only the exact `CONFIG_BOOT_CONFIG=n` `setup_boot_config()` path through its
linked `get_boot_config_from_initrd(NULL)` call. It stopped before
`setup_command_line()`.

## Starting authority

Starting proven MAINLINE:

`c7cc9b7d46b64943b6155a185b2b237f610d1ddb65a07de59e268669be6e3e86`

Starting proven source:

`d779ade7bf7b92fbfae0d0e41bb292edee1a9789`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/get-boot-config-phase-review.md`

Independent frozen-candidate review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/get-boot-config-bc1-review.md`

## Exact production function and input

Frozen BC1 source:

`df1c280a0df668362fea508f8ae288d986057435`

Production `get_boot_config_from_initrd()` remained unchanged at:
- 68 linked instructions;
- 79 normalized instruction+relocation records.

Exact initramfs:

`86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`

Exact size:

`7696 == 0x1e10`

Exact `BOOTCONFIG_MAGIC` is 12 bytes:

`#BOOTCONFIG\n`

The four exact tail probes in the frozen payload are:

```text
i=0 offset 0x1e04: df bb fe 03 aa f9 21 7c 00 48 00 00
i=1 offset 0x1e03: fe df bb fe 03 aa f9 21 7c 00 48 00
i=2 offset 0x1e02: a9 fe df bb fe 03 aa f9 21 7c 00 48
i=3 offset 0x1e01: 5a a9 fe df bb fe 03 aa f9 21 7c 00
```

All four mismatch the magic.

The unchanged function therefore cannot enter its `found` path on this exact
frozen input. It cannot execute:
- bootconfig size/header processing;
- bootconfig checksum processing;
- either found-path error `_printk`;
- a valid bootconfig return;
- the valid-found `initrd_end` shortening store.

Four failed probes converge on the ordinary frame/x18-SCS epilogue and NULL
return.

## Exact loader / initrd handoff

Final uniLoader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Its exact linked state resolves:
- `ramdisk_size = 0x1e10`;
- destination `0x84000000`;
- copy count `0x1e10`;
- patched `linux,initrd-start = 0x84000000`;
- patched `linux,initrd-end = 0x84001e10`.

The original DT contains `/chosen` but no initrd properties. They are
loader-introduced.

The physically proven arm64 setup path had already consumed those properties
and published the runtime virtual `initrd_start/end` window.

## BC1 GOLD checkpoint

Frozen Image:

`985b841fe2e53c57d546dada795891adb25cbe020b36bbe7eaa32eea9b288e19`

Frozen loader:

`69c84d4981190dc73d51bd3cb2029d6153935d7213ae1644c5487f841b9299b7`

Frozen BOOT:

`2e98f070ac0f68525aff65cdc63080501714cc56651e9f0d7d47c3e98021687e`

BC1 removed only MAGENTA's terminal hold. The MAGENTA paint remained the
pre-call breadcrumb.

Final caller seam:

```text
ffff8000822106e8  dsb sy
ffff8000822106ec  bl get_boot_config_from_initrd

# only after genuine return
ffff8000822106f8  ldr x8, [x21, #0x40]   # initrd_start
ffff8000822106fc  ldr x9, [x9,  #0x48]   # initrd_end
ffff800082210700  cbz x8, FAIL
ffff800082210704  cbz x9, FAIL
ffff800082210708  cmp x9, x8
ffff80008221070c  b.lo FAIL
ffff800082210710  sub x8, x9, x8
ffff800082210714  mov w9, #0x1e10
ffff800082210718  cmp x8, x9
ffff80008221071c  b.eq GOLD_GATE

# failed runtime corroboration preserves MAGENTA
ffff800082210720  wfe
ffff800082210724  b ffff800082210720

# complete runtime corroboration only
ffff800082210728  ldr x9, [x19, #0x808]
ffff80008221072c  cbnz x9, GOLD
ffff800082210730  wfe
ffff800082210734  b ffff800082210730

# GOLD
ffff800082210738  mov x10, x9
ffff80008221073c  mov x11, #0xd700
ffff800082210740  movk x11, #0xffff, lsl #16
ffff800082210744  movk x11, #0xd700, lsl #32
ffff800082210748  movk x11, #0xffff, lsl #48
...
ffff800082210758  str x11, [x10], #8
...
ffff800082210764  dsb sy
ffff800082210768  wfe
ffff80008221076c  b ffff800082210768

-- unreachable --

ffff800082210770  ldr x0, [x29, #0x18]
ffff800082210774  bl setup_command_line
```

GOLD is exact ARGB8888 `0xffffd700`, duplicated as
`0xffffd700ffffd700`, over exact `0x2d000` bytes.

Captain reported GOLD PASS under the accepted >=3-minute physical rule.

Stable GOLD proves:
- all L1 MAGENTA facts remain true;
- runtime `initrd_start` and `initrd_end` were nonzero after target return;
- their post-return span was exactly 7,696 bytes / `0x1e10`;
- unchanged `get_boot_config_from_initrd(NULL)` executed on the nonzero-initrd
  scan path;
- the exact four frozen tail comparisons all failed;
- the found path was not entered;
- no bootconfig size/checksum work executed;
- neither found-path error `_printk` executed;
- `initrd_end` was not shortened by valid bootconfig removal;
- the ordinary frame/x18-SCS epilogue completed;
- the function genuinely returned NULL;
- control returned to `start_kernel()`;
- the bridge was freshly loaded after the runtime span checks and remained
  non-NULL/writable;
- `setup_command_line()` did not execute.

The exact `0x1e10` post-return span is corroboration only. It is not the sole
path discriminator because hypothetical found-path size/checksum errors would
also return without shortening `initrd_end`. The no-found conclusion comes
from the exact four frozen probes plus unchanged production semantics.

## Reproducibility and packaging

The accepted config remained SHA-256:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Compiler remained Android clang 21.0.0 based on r563880c.

BC1 reused the accepted frozen L1 module-signing PEM/X.509 as explicit build
inputs. A clean canonical-path rebuild followed by pinned-input
certificate/final-link relink reproduced the frozen BC1 Image byte-for-byte.

Two independent loader worktrees produced byte-identical loaders. Two
independent BOOT packaging runs produced byte-identical BOOT images.

BOOT geometry, ramdisk region, post-ramdisk tail and AVB metadata remained
accepted relative to exact L1.

## Promotion and next boundary

Exact BC1 BOOT:

`2e98f070ac0f68525aff65cdc63080501714cc56651e9f0d7d47c3e98021687e`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `get_boot_config_from_initrd(NULL)`.

The next linked production boundary is `setup_command_line()`.

Do not cross it without a new bounded phase plan/review.
