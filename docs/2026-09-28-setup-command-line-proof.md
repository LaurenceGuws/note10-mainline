# 2026-09-28 setup_command_line proof

This phase started from the physically proven BC1 GOLD checkpoint and crossed
only `setup_command_line(command_line)`. It stopped before
`setup_nr_cpu_ids()`.

## Starting authority

Starting proven MAINLINE:

`2e98f070ac0f68525aff65cdc63080501714cc56651e9f0d7d47c3e98021687e`

Starting proven source:

`df1c280a0df668362fea508f8ae288d986057435`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/setup-command-line-phase-review.md`

Independent frozen-candidate review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/setup-command-line-c1-review.md`

## Exact production function and pre-state

Frozen C1 source:

`16f5becb8d1e0116f7a070e3ac9743d9f08ce0ea`

Production `setup_command_line()` remained unchanged at:
- 67 linked instructions;
- 93 normalized instruction+relocation records.

Exact DT `/chosen/bootargs` payload is 133 bytes, 134 bytes including NUL:

`earlycon=exynos4210,0x10440000 console=ttySAC0,115200 console=tty0 init=/init scsi_mod.max_luns=1 pmos_root=/dev/sda32 log_buf_len=4M`

The final payload byte is `0x4d` and index 133 is NUL.

Exact selected config keeps `CONFIG_CMDLINE=""` and
`CONFIG_BOOT_CONFIG=n`. The nonempty DT command line therefore remains
authoritative, and optional bootconfig extra-command-line state is compiled
away.

arm64 `setup_arch()` stores the exact `boot_command_line` pointer through
the caller's `command_line` slot. The earlier `parse_early_param()` parses
its own private copy and does not mutate `boot_command_line`.

The exact pre-state therefore forces:
- first allocation request: 134 bytes, alignment 64;
- second allocation request: 134 bytes, alignment 64;
- both linked fortify branches false;
- exact copies into `saved_command_line` and `static_command_line`;
- `saved_command_line_len = 133`.

## C1 TURQUOISE checkpoint

Frozen Image:

`9ce44644a78ac5d5e3bb9c021df6ebfccaf46b4d5caa2c8a3df99caa1bd673ea`

Frozen loader:

`72ca7fb1598d8501c6911bbcb2d53efc73ac42a55e30655965119670bec32b8e`

Frozen BOOT:

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

C1 removed only GOLD's terminal hold. GOLD itself remained the pre-call
breadcrumb.

After genuine `setup_command_line()` return, final C1 freshly loads:
- `saved_command_line`;
- `static_command_line`;
- `saved_command_line_len`.

It requires:
- both pointers non-NULL;
- pointers distinct;
- both 64-byte aligned;
- saved length exactly 133;
- `boot_command_line[133] == '\0'`.

It then executes an explicit inline byte loop:
- counter starts at 0;
- exact loaded indices are 0 through 133 inclusive;
- each iteration compares one byte from `boot_command_line` against the same
  byte in both published buffers;
- counter exits at 134 / `0x86`;
- no index-134 byte is loaded;
- no diagnostic comparison helper call is linked.

Only after all 134 positions pass does C1 freshly load
`note10_paging_bridge`.

Complete success paints TURQUOISE, exact ARGB8888 `0xff40e0d0`, duplicated as
`0xff40e0d0ff40e0d0`, over exact `0x2d000`, executes `dsb sy`, and
self-holds.

Captain reported TURQUOISE PASS under the accepted >=3-minute physical rule.

Stable TURQUOISE proves:
- all BC1 GOLD facts remain true;
- `setup_command_line()` received command_line exactly equal to
  `boot_command_line`;
- exact input was 133 bytes plus terminating NUL;
- optional bootconfig extra-command-line state was absent on this build;
- both exact 134-byte / 64-byte allocation calls returned successfully;
- `saved_command_line` and `static_command_line` were published non-NULL,
  distinct and 64-byte aligned;
- `saved_command_line_len == 133`;
- all 134 bytes of both published buffers matched current
  `boot_command_line`, including NUL;
- both fortify panic branches were skipped;
- ordinary frame/callee-saved/x18-SCS restoration completed;
- `setup_command_line()` genuinely returned to `start_kernel()`;
- the bridge was freshly loaded after every command-line check and remained
  non-NULL/writable;
- `setup_nr_cpu_ids()` did not execute.

It does not prove ordinary parameter parsing, semantic application of command
line options, CPU-count setup, per-CPU setup, or later `start_kernel()` work.

## Reproducibility and packaging

The accepted config remained SHA-256:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Compiler remained Android clang 21.0.0 based on r563880c.

C1 reused the accepted frozen signing PEM/X.509 as explicit build inputs. A
clean canonical-path rebuild followed by pinned-input certificate/final-link
relink reproduced the frozen C1 Image byte-for-byte.

Two independent loader worktrees produced byte-identical loaders. Two
independent BOOT packaging runs produced byte-identical BOOT images.

BOOT geometry, ramdisk region, post-ramdisk tail and AVB metadata remained
accepted relative to exact BC1.

## Promotion and next boundary

Exact C1 BOOT:

`89373f9ba86dfffa0d998a6bfbc87270de941594c493826f42f061fcbcefafbf`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `setup_command_line()`.

The next linked production boundary is `setup_nr_cpu_ids()`.

Do not cross it without a new bounded phase plan/review.
