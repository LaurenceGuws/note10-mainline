# 2026-09-26 primary_entry proof

The second attended mainline BOOT-only experiment used the reviewed
copy-to-`primary_entry` marker candidate:

- note10-mainline checkpoint:
  `1712ec38d61e751b4d0a51985c7ebb28b9b3d53e`
- BOOT candidate:
  `9b8f39426860c64b28cc676ea52489ea5bed552cf6f5c7d6d418b936d9e91477`
- rollback BOOT:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

The loader printed `COPY_DONE / JUMP_READY` after both payload copies. Captain
then observed the first-body Linux marker as a large magenta framebuffer stripe
and left the phone untouched for at least three minutes. The stripe remained
stable and the phone did not reset.

The visible loader handoff receipt was transcribed as:

```text
target=0x0000000090000000
x0=0x000000008ba476e0
CurrentEL=EL1
DAIF=0x00000000000002c0
SCTLR=0x0000000030c5083a
```

Decoded entry state relevant to the arm64 boot contract:

- MMU off (`SCTLR_EL1.M=0`);
- D-cache off (`SCTLR_EL1.C=0`);
- I-cache off (`SCTLR_EL1.I=0`);
- little-endian (`SCTLR_EL1.EE=0`);
- debug/IRQ/FIQ masked while SError remains unmasked
  (`DAIF=0x2c0`).

This physically proves:

1. the Linux Image copy to `0x90000000` completed;
2. the initramfs copy to `0x84000000` completed;
3. the loader reached and executed its final branch path;
4. Linux `primary_entry` executed its first instrumented instructions;
5. the inherited entry state can remain alive in a deliberate `wfe` hold for
   minutes without an immediate reset.

This does not yet prove any later arm64 initialization stage, console, UFS or
initramfs behavior. It does rule out treating the original reset as an
inevitable pre-entry or immediate-entry watchdog event.

After the observation, Captain re-entered Samsung Download Mode and the exact
rollback BOOT was restored to `BOOT` only. Post-rollback verification showed:

- `/dev/block/by-name/boot -> /dev/block/sda14`;
- size `57,671,680` bytes;
- SHA-256
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`;
- device `d2s`;
- expected 4.14 vendor kernel running;
- Android `sys.boot_completed=1`.

Raw receipts are under:

`~/.local/state/workstreams/note10-mainline/physical/copy-primary-marker/`

The next experiment should move the deliberate marker/hold one bounded stage
deeper through the unmodified arm64 entry path, preserving this established
loader and physical rollback boundary.
