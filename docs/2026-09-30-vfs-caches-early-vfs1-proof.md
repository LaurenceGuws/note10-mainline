# VFS early-caches VFS1R1 physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`a4bbc995521cb9c93d622e275949a3b03e9812a3`

Image:

`f4654a9dddc431b6867217abcf1b3543a5bf11fa19c5bd7c96bc92d3d65c2d3a`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`ec3101cec5bb421f8676640a293d08548a67100f3a9544f1a8146a35b6b67fa4`

BOOT:

`326d993a382cc0c2bf75e65276b1fb9af18624778d4fd0de78b65f70f2e75efc`

Previous proven MAINLINE / immediate rollback:

`0ba42adc09058b7e4c374820f27ba89c334d2d89c1a8b066d83256f1fa26b276`

## Review history

The first frozen VFS1 candidate was rejected before flash because its YELLOW
failure marker always used the prior LB1 framebuffer bridge instead of using the
freshly read VFS bridge for ordinary hashdist/IRQ/CPU0 failures.

The bounded VFS1R1 follow-up corrected that exact linked dataflow:

`cmp x19, #0`

`csel x9, x19, x9, ne`

where x19 is the freshly read VFS pre-target bridge and the retained x9 is the
previously validated LB1 bridge. Thus ordinary precondition failures use x19;
only fresh-bridge NULL falls back to the older bridge.

The VFS1R1 frozen candidate received independent `FINAL ACCEPT` before flash.

## Frozen reviewed boundary

VFS1R1 crossed exactly:

direct `hashdist == false` / IRQ-disabled / CPU0 / fresh-bridge preconditions
→ WHITE pre-target marker
→ unchanged `vfs_caches_init_early()`
→ immediate RED return marker
→ direct hashdist / IRQ / CPU0 postconditions
→ fresh final bridge
→ terminal BLUE

and stopped before:

`sort_main_extable()`

## Unchanged production semantics

The frozen review preserved exact production equivalence for:

- `vfs_caches_init_early()`: 16 instructions / 4 relocations;
- `dcache_init_early()`: 126 / 32;
- `inode_init_early()`: 36 / 13;
- `alloc_large_system_hash()`: 175 / 25.

Parent/candidate executable `.text` and `.init.text` sections for
`fs/dcache.o`, `fs/inode.o`, and `mm/mm_init.o` were byte-identical.

With runtime `hashdist == false`, unchanged production:

- zeroes the exact 8192-byte / 1024-entry `in_lookup_hashtable`;
- executes the Dentry-cache early `alloc_large_system_hash(... HASH_EARLY |
  HASH_ZERO ...)` path;
- executes the Inode-cache early `alloc_large_system_hash(... HASH_EARLY |
  HASH_ZERO ...)` path;
- publishes the resulting private hash state.

The allocator may legitimately shrink the requested table size after allocation
pressure. If no allocation succeeds, unchanged production panics and cannot
normally return. VFS1R1 therefore does not claim exact Dentry/Inode bucket
counts or allocation byte sizes.

## Physical observation

Captain reported the decoded terminal marker:

`BLUE · VFS1 PASS (#0000ff)`

Decoded meaning:

`vfs_caches_init_early() returned with runtime hashdist still false, interrupts still disabled, CPU0 continuity intact, and a valid fresh final bridge. With unchanged production semantics, the 8 KiB in-lookup initialization and successful early Dentry/Inode hash allocation paths completed.`

This physically proves:

- `vfs_caches_init_early()` genuinely returned;
- runtime `hashdist` was false before target entry and remained false after return;
- the exact 8192-byte / 1024-entry in-lookup initialization completed;
- both early Dentry and Inode hash-allocation paths ultimately returned non-NULL;
- their unchanged production publication work completed;
- IRQ-disabled state survived the target;
- CPU0 continuity survived;
- the final freshly read framebuffer bridge remained valid.

It does not prove exact final Dentry/Inode hash-table bucket counts or byte
sizes.

Under the current bring-up policy, the clearly stable decoded terminal marker
is semantic proof. Longer soak is separate optional stability evidence.

Result: **PASS**.

## Proven consequence

VFS1R1 is promoted to MAINLINE.

The next unexecuted production boundary is:

`sort_main_extable()`
