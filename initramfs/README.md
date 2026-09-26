# Early userspace

The initramfs is a bring-up and recovery instrument, not a second permanent
distribution.

Its first job is intentionally narrow: mount the pseudo filesystems, open UFS
read-only, perform repeatable bounded GPT/block reads, emit machine-readable
diagnostics, and remain alive. It contains no storage write path.

## Reproducible build

Use the already-built candidate kernel tree so its own `gen_init_cpio` creates
the archive:

```sh
KERNEL_BUILD=~/.local/state/workstreams/note10-mainline/build/ufs-prdt-length
OUTPUT=~/.local/state/workstreams/note10-mainline/initramfs
tools/build-initramfs "$KERNEL_BUILD" "$OUTPUT"
```

The helper:

- requires the fleet Zig baseline `0.17.0-dev.1980+e78ea8f2c`;
- runs the inline Zig tests;
- emits a stripped static AArch64 Linux `/init`;
- uses `gen_init_cpio -t 0` so archive metadata is deterministic;
- uses `gzip -n -9` so the compressed artifact carries no host timestamp;
- prints sizes and SHA-256 hashes for the resulting artifacts.

Build products stay in the active workstream, not Git.

The 2026-09-26 frozen diagnostic artifacts are reproducible as:

- `init`: `dd44596d39d6683b16bbb568a3d5831b004c4beb9c9612b932b4c3e7c34f8828`
- `initramfs.cpio`: `b54ec315fe80526de7dfc8d4d7f3762d249870d37ffdf852b50dc5d8e6c355a1`
- `initramfs.cpio.gz`: `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`

The eventual job expands only when earned: establish deterministic diagnostics,
prepare the minimum storage/hardware state required for boot, then hand off
into the existing Debian operating environment when that is safe.
