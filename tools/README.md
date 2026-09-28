# Host tools

Small deterministic build, packaging and verification helpers belong here.

No helper may flash or reboot the phone implicitly. Physical mutation tooling must fail closed, pin exact hashes/targets and remain an attended operation.

Current helpers:

- `build-initramfs`: reproducible static read-only UFS diagnostic initramfs;
- `build-uniloader`: reconstructs the accepted uniLoader source from the pinned upstream commit plus the owned patch, verifies the exact source tree, then builds with pinned version metadata;
- `build-boot-candidate`: BOOT-only offline packaging with exact kernel-slot padding and byte-range verification. It never contacts the phone.

## Toolchain pin

`build-uniloader` requires `LLVM_BIN` to name the pinned Android LLVM bin directory. The currently accepted loader was built with Android clang/LLD 21.0.0 r563880c. The helper records the compiler identity and fails before build if the directory does not provide both `clang` and `ld.lld`.
