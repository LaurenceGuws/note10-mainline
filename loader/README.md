# uniLoader integration

The current Note10 BOOT uses uniLoader as a second-stage Linux loader inside Samsung's Android BOOT envelope.

The accepted loader source is reconstructed as:

1. upstream `ivoszbg/uniLoader` commit `f45d73b344ce9ae8dab191836933ebfbed287afb`;
2. apply `patches/0001-arm64-mark-final-kernel-jump-state.patch`.

That exact source tree must hash to Git tree:

`49a6246d833253d8e2fe28d8d93605d549083dc1`

This is source-equivalent to the historical local commit:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

The local-only commit is no longer an ownership dependency. The system repo owns the delta required to recreate it.

`tools/build-uniloader` performs and verifies this reconstruction before build.
