# Staged kernel patches

These patches are durable exports of the currently understood d2s mainline
delta. They are not a substitute for an upstream-quality Linux history.

## UFS PRDT length

Base commit:

    796981b622418debafa20e264ff8eb38122845f0

Candidate commit:

    0f909c956f4f5d3ebfd5217dd22b73d9b4f4fa82

Stable patch-id:

    cff09f6580b2cc00862c718bcd8038a3b77768df

Patch SHA-256:

    f04cb2e21aa75d43c20a9813e868078737a43cf75a0d37800e114b736256581d

Apply it to the recorded base with `git am`. The patch is still
hardware-unproven; its physical promotion gates are recorded in `docs/UFS.md`.
