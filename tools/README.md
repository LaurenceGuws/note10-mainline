# Host tools

Small deterministic build, packaging and verification helpers belong here.

No helper may flash or reboot the phone implicitly. Physical mutation tooling must fail closed, pin exact hashes/targets and remain an attended operation.

Current helpers:

- `build-initramfs`: reproducible static read-only UFS diagnostic initramfs;
- `build-uniloader`: deterministic detached-worktree uniLoader build with
  pinned upstream commit/version metadata;
- `build-boot-candidate`: BOOT-only offline packaging with exact kernel-slot
  padding and byte-range verification. It never contacts the phone.
