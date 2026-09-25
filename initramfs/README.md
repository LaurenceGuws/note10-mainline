# Early userspace

The initramfs is a bring-up and recovery instrument, not a second permanent distribution.

Its eventual job is to provide deterministic diagnostics, prepare the minimum hardware/storage state required for boot, and hand off into the existing Debian operating environment when that is safe.
