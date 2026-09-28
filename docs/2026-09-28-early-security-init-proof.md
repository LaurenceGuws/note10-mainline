# 2026-09-28 early_security_init proof

This phase started from the physically proven GREEN second-`jump_label_init()`
checkpoint and crossed only `early_security_init()`. It stopped before the
linked `get_boot_config_from_initrd()` call.

## Starting authority

Starting proven MAINLINE:

`6f2fa130f3ae71a3631e93272188e3b4c057e0e8ff2cbbc9c1b156f2b6f70bcf`

Starting proven source:

`10aa4aeeec327c6e26c93f8ebe9c3dd6677a10b9`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/early-security-init-phase-review.md`

Independent frozen-candidate review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/early-security-l1-review.md`

## Exact production path

Frozen L1 source:

`d779ade7bf7b92fbfae0d0e41bb292edee1a9789`

Production `early_security_init()` remained unchanged at 55 linked
instructions.

Exact final symbols:

```text
ffff80008224ae60 T early_security_init
ffff8000824b4880 D __start_early_lsm_info
ffff8000824b4880 D __end_early_lsm_info
```

The early-LSM interval is therefore exactly empty.

The function computes both bounds as `0xffff8000824b4880`, compares start
against end, and its initial `b.hs` is forced directly to the normal epilogue.
No loop-body instruction can execute.

The exact config contains:

```text
CONFIG_SECURITY=y
CONFIG_SECURITY_LOCKDOWN_LSM=y
# CONFIG_SECURITY_LOCKDOWN_LSM_EARLY is not set
```

Lockdown is therefore a normal later `DEFINE_LSM`, not an early descriptor.

The zero-iteration path:
- performs the ordinary prologue/SCS push;
- computes and compares the equal early-LSM bounds;
- skips every loop iteration;
- sets `w0 = 0`;
- restores frame and callee-saved state;
- restores x30 through x18/SCS;
- executes the sole normal `ret`.

It cannot execute this invocation's:
- `lsm_enabled_set()`;
- `lsm_order_append()`;
- `lsm_prepare()`;
- `lsm_init_single()`;
- early-LSM init callback;
- `lsm_count_early++`.

## L1 MAGENTA checkpoint

Frozen Image:

`9e716b43c2d8d81947b91f34ea77680d1a9a23af96f43d3c3a66615585062cc2`

Frozen loader:

`b416f775e395e9e2ff49f06400e3520efb53367137778684de8057ed7508dcdc`

Frozen BOOT:

`c7cc9b7d46b64943b6155a185b2b237f610d1ddb65a07de59e268669be6e3e86`

L1 removed only GREEN's terminal hold. The GREEN paint itself remained the
pre-call breadcrumb.

Final caller seam:

```text
ffff8000822106a4  dsb sy
ffff8000822106a8  bl early_security_init

# only after genuine return
ffff8000822106ac  ldr x9, [x19, #0x808]
ffff8000822106b0  cbnz x9, MAGENTA_OK

# NULL bridge preserves GREEN
ffff8000822106b4  wfe
ffff8000822106b8  b ffff8000822106b4

# complete success only
ffff8000822106bc  mov x10, x9
ffff8000822106c0  mov x11, #0x00ff
ffff8000822106c4  movk x11, #0xffff, lsl #16
ffff8000822106c8  movk x11, #0x00ff, lsl #32
ffff8000822106cc  movk x11, #0xffff, lsl #48
...
ffff8000822106dc  str x11, [x10], #8
...
ffff8000822106e8  dsb sy
ffff8000822106ec  wfe
ffff8000822106f0  b ffff8000822106ec

-- unreachable --

ffff8000822106f4  bl get_boot_config_from_initrd
```

MAGENTA is exact ARGB8888 `0xffff00ff`, duplicated as
`0xffff00ffffff00ff`, over exact `0x2d000` bytes.

Captain reported MAGENTA PASS under the accepted >=3-minute physical rule.

Stable MAGENTA proves:
- all J1 GREEN facts remain true;
- unchanged `early_security_init()` was invoked;
- exact equal early-LSM bounds forced zero loop iterations;
- no early-LSM enable/order/prepare/init work was executed by this invocation;
- `lsm_count_early` was not incremented by its loop;
- the normal epilogue set return value zero;
- frame/callee-saved/x18-SCS restoration completed;
- genuine `ret` completed;
- control returned to `start_kernel()`;
- `note10_paging_bridge` was freshly value-loaded after return and remained
  non-NULL/writable;
- `get_boot_config_from_initrd()` did not execute.

It does not prove anything about normal later LSM initialization,
`security_init()`, bootconfig inspection/removal, command-line processing, or
later `start_kernel()` work.

## Reproducibility and packaging

The accepted config remained SHA-256:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Compiler remained Android clang 21.0.0 based on r563880c.

The build exposed Kbuild's generated module-signing key as a real entropy input.
The first build's key/X.509 pair was frozen as an explicit build input. With
source, config, compiler, KBUILD timestamp and that input pinned, a clean
canonical-path rebuild plus certificate/final-link relink reproduced the frozen
Image byte-for-byte.

Cross-output-directory comparison with the same frozen signing input differed
only in three 20-byte linker build-ID fields. This is recorded as path-sensitive
metadata, not claimed as universal arbitrary-output-directory reproducibility.

Two uniLoader builds from exact loader source
`36ecc6a56967af0887af2a72fca81d091ae876a7` and pinned
`BUILD_DATE=2026-09-26 01:21:56 UTC` were byte-identical.

Two BOOT packaging runs were byte-identical. BOOT geometry, ramdisk region,
post-ramdisk tail and AVB metadata remained accepted relative to exact J1.

## Promotion and next boundary

Exact L1 BOOT:

`c7cc9b7d46b64943b6155a185b2b237f610d1ddb65a07de59e268669be6e3e86`

is the newest proven MAINLINE checkpoint and remains installed.

This closes `early_security_init()`.

On this exact `CONFIG_BOOT_CONFIG=n` build, source-level
`setup_boot_config()` reduces to a real linked
`get_boot_config_from_initrd(NULL)` call. That function is the next
architectural boundary.

Do not cross it without a new bounded phase plan/review.
