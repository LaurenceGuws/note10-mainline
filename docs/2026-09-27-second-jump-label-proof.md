# 2026-09-27 second start_kernel jump_label_init proof

This phase started from the physically proven WHITE `mm_core_init_early()`-return
checkpoint and crossed only the second linked `start_kernel()` invocation of
`jump_label_init()`. It stopped before `early_security_init()`.

## Starting authority

Starting proven MAINLINE:

`c3e565842d2af6eab7e55de6b79f93d6e247196a2119553b0def3d644d8abef2`

Starting proven source:

`070e38ff1c1b3d32ad031ffd1172dca57e498d3a`

Accepted phase review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/start-kernel-jump-label-phase-review.md`

Independent frozen-candidate review:

`/home/home/.local/state/workstreams/note10-mainline/reviews/start-kernel-jump-label-j1-review.md`

## Why this call is different

This is not the first `jump_label_init()` execution in the boot.

Exact linked J1 contains two direct calls:

```text
ffff800082214ac0  bl jump_label_init   # setup_arch
ffff800082210650  bl jump_label_init   # start_kernel
```

The exact image byte for `static_key_initialized` starts at zero. The selected
`CONFIG_JUMP_LABEL=y` production path has one true writer and no selected clear
writer.

The first linked call is inside the already physically proven `setup_arch()`
path. Its unchanged false-entry path has no normal return before publishing
true. Since T1 proved complete `setup_arch()` through genuine return, the first
`jump_label_init()` necessarily completed that store and returned.

No later clear writer exists before J1. The deterministic runtime pre-state at
the second call is therefore `static_key_initialized == true`.

## J1 GREEN checkpoint

J1 source:

`10aa4aeeec327c6e26c93f8ebe9c3dd6677a10b9`

Image:

`fd618e522bc4ae1f6c185671beb9e47fec7a60846ac0c4e060ae4d86dcc21103`

Loader:

`c567f4359f4d76dad5ea28d387a0fcd326e637a14ae052bd6b6c5d7b70cad7fb`

BOOT:

`6f2fa130f3ae71a3631e93272188e3b4c057e0e8ff2cbbc9c1b156f2b6f70bcf`

J1 changes only the caller-side evidence seam in `init/main.c`. Production
`jump_label_init()`, static-call code and LSM code remain unchanged.

Independent comparison against MM2 reproduced:
- `jump_label_init()`: 86/86 instructions equivalent;
- `early_security_init()`: 55/55 instructions equivalent.

The exact second-call production branch is:

```text
ffff8000822311d0  ldrb w8, [x20, #0xb84]
ffff8000822311d4  tbnz w8, #0, ffff8000822312c0
```

Given the independently established true pre-state, the second invocation is
forced to the initialized branch and common epilogue.

It therefore skips the false-only path:
- `cpus_read_lock()`;
- jump-label mutex acquisition;
- jump-table sorting;
- jump-table iteration and rewrite;
- the initialization store;
- mutex unlock;
- `cpus_read_unlock()`.

The taken path still performs the real common epilogue, including frame,
callee-saved and x18/SCS restoration, and executes the genuine
`jump_label_init()` `ret`.

## Post-return corroboration and bridge

The caller does not preload the static-key byte across the call. Only after the
genuine return does it reload and test the actual byte:

```text
ffff800082210650  bl jump_label_init
ffff800082210654  adrp ...
ffff800082210658  ldrb ...
ffff80008221065c  tbnz ...
```

This post-return true check is corroboration only. By itself it would not prove
that the fast path was taken, because a hypothetical false entry could execute
full initialization and leave the byte true. The fast-path conclusion comes
from the independently established true entry pre-state plus unchanged
production semantics.

After that corroboration, the bridge pointer itself is freshly loaded from
`note10_paging_bridge`; only the symbol-page base survives in callee-saved
state. A NULL bridge self-holds before any success marker.

The exact DT continues to reserve `0xca000000..0xcc000000` as framebuffer
`reserved-memory` with `no-map`. The evidence band
`0xca3b1000..0xca3de000` remains entirely inside it.

## Final GREEN boundary

Only successful second-call return, static-key corroboration and fresh non-NULL
bridge load reach GREEN.

The success pattern is exact ARGB8888 `0xff00ff00`, written over exact length
`0x2d000` with aligned 64-bit stores, followed by `dsb sy` and an infinite
hold.

The linked `early_security_init()` call is after that hold and is therefore
structurally unreachable in J1. No linked `static_call_init()` call exists
between the second `jump_label_init()` and `early_security_init()` on this
exact build.

Captain reported GREEN PASS under the accepted >=3-minute physical rule.

Stable GREEN proves:
- all MM2 WHITE facts remain true;
- the second linked `start_kernel()` `jump_label_init()` invocation executed;
- its runtime entry pre-state was already initialized/true;
- unchanged production semantics forced the initialized `tbnz` fast-return path;
- the false-only locking, sorting, jump-table rewrite, initialization store and unlock path were skipped;
- the real common epilogue completed;
- genuine `jump_label_init()` return completed;
- control returned to `start_kernel()`;
- `static_key_initialized` remained true after return;
- the bridge pointer was freshly loaded after return and remained writable;
- `early_security_init()` did not execute.

Stable GREEN does not prove:
- the post-return true check independently proves the fast path;
- the first `setup_arch()` call skipped initialization;
- `early_security_init()` ran;
- any LSM was initialized.

## Reproducibility

Accepted config:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

Pinned loader `BUILD_DATE`:

`2026-09-26 01:21:56 UTC`

Two loader builds were byte-identical at the loader hash above. Two BOOT
packaging runs were byte-identical at the J1 BOOT hash.

Payload offsets remained:
- Image `0xc000`;
- DTB `0x2a3f000`;
- initramfs `0x2a44000`.

BOOT size remained `57,671,680` bytes. Ramdisk and post-ramdisk tail stayed
byte-identical to MM2. Header drift was checksum/id-only. Accepted AVB metadata
and stale-descriptor behavior were unchanged.

## Promotion and next boundary

Exact J1 BOOT:

`6f2fa130f3ae71a3631e93272188e3b4c057e0e8ff2cbbc9c1b156f2b6f70bcf`

is the newest proven MAINLINE checkpoint and remains installed.

This closes the second `start_kernel()` `jump_label_init()` boundary.

The next linked production boundary is `early_security_init()`. That is a new
architectural phase because it enters LSM/security initialization. Do not cross
it without a new bounded phase plan and independent phase review.
