# 2026-09-26 first mainline physical BOOT

This is the first attended physical test of the reviewed mainline d2s
candidate. It is a hardware checkpoint, not acceptance of UFS or of the
mainline kernel.

## Frozen candidate

- repository checkpoint: `a48fc8baf2bff9d33e0874d8bb06a54507904c85`
- independent review verdict: `FINAL ACCEPT`
- BOOT candidate SHA-256:
  `044459f40f1dac78f7ab57980d1caed8202c9f0c9186edebb08df81865cf095c`
- physical pre-test BOOT / rollback SHA-256:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`
- BOOT size: `57,671,680` bytes

The candidate was flashed with the established samloader BOOT-only path and
`--no-reboot`. The upload completed successfully. No other partition was in the
flash command.

Receipt directory:

`~/.local/state/workstreams/note10-mainline/physical/first-mainline-ufs-boot`

## Physical observation

After Captain exited Samsung Download Mode, uniLoader became visible and
reached:

`Booting kernel...`

The phone then reset and repeated that sequence. The diagnostic initramfs did
not become visible. ADB and Samsung Download Mode USB both disappeared during
the mainline attempt, consistent with the intentionally absent USB gadget stack
in this first candidate.

This moves the failure boundary past Android BOOT parsing and past uniLoader's
own initialization. The failure occurs after uniLoader's final handoff into the
mainline Image and before any visible proof of `/init`.

It does **not** yet prove whether the reset occurs before the first kernel
instruction, during earliest arm64 entry, during DT/console initialization, or
later before initramfs execution.

## Rollback

Captain re-entered Samsung Download Mode using the physical button path. The
exact frozen rollback BOOT was flashed to `BOOT` only with `--no-reboot`; the
upload completed successfully. Captain then exited Download Mode.

Post-rollback verification:

- `/dev/block/by-name/boot -> /dev/block/sda14`
- BOOT size: `57,671,680` bytes
- BOOT SHA-256:
  `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`
- Android `sys.boot_completed=1`
- device: `d2s`
- running kernel:
  `4.14.356-openela-rc1-g693d1da93597`

The phone therefore returned to the exact pre-test BOOT and remains bootable.

## Crash evidence after rollback

`/sys/fs/pstore` contained only the Android `pmsg-ramoops-0` record after
rollback. `/proc/last_kmsg` was readable, but searches found no mainline
`Linux version 7.2`, `d2s-kinit`, or `note10_mainline_init` marker and no useful
mainline panic/oops record. Its visible early-boot material corresponds to the
Samsung/vendor boot path.

So the first attempt yielded no durable mainline crash log. The next candidate
must improve evidence at the kernel-entry boundary rather than changing UFS
blindly.

## Earned next question

Before another physical BOOT, isolate the smallest source/config/loader change
that can distinguish these cases:

1. control never reaches the arm64 mainline entry point;
2. arm64 entry begins but fails before normal printk/console initialization;
3. the supplied DTB or early memory placement causes the reset;
4. the kernel advances farther but the existing visible-console path is not a
   trustworthy indicator.

Do not spend the next tranche on UFS data-path changes until kernel-entry
survival is demonstrated.
