# Memory-core MM3B1 reset-managed-pages physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`0cbacec8b7b179503e7af9a23114ff91927082c4`

Image:

`b8b7330e4346bd8672affeba7ea0b33b1dacbe2fc7a969478a8c6362fb150486`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`42c47ffda9936d03d9d0a4ab0d8d8304fc17f3b8bbe27d1ba5ee06deae74a67d`

BOOT:

`241a2a701a7655ce575c2bfca1acb12f259da84836a6b04769fa8b8f0908acd4`

Previous proven MAINLINE / immediate rollback:

`ec918c8baf4f6fcc5d0496cf63a02ae8d6574bb050c773625f54a641eedd9596`

Rejected MM3B BOOT:

`c3fb912a89088c5c8dec54123cd6acfc26a9bc6a4b82ba02f7a5c0d132c7a672`

Rejected whole-MM3 BOOT:

`6daec9ff790a348fbb26eec9103c6596ba8d6cd3fea2da15457a28771fd88aa6`

Both rejected lanes remain non-promotable.

## Frozen private state

Final frozen image:

- `note10_mm3b1_outer_stop = 1`
- `reset_managed_pages_done = 0`
- `note10_mm3b1_memblock_stop = 1`

Therefore the physical MM3B1 lane could not take
`reset_all_zones_managed_pages()`'s already-done fast return.

## Reviewed execution boundary

The physical lane was:

proven MM3A prefix
→ enter `memblock_free_all()`
→ unchanged `reset_all_zones_managed_pages()`
→ internal true stop
→ return before `free_low_memory_core_early()`
→ outer true stop
→ return before `mem_init()`.

Untouched helper records:

- `reset_all_zones_managed_pages()`: 29 instructions / 5 relocations
- `free_low_memory_core_early()`: 86 instructions / 8 relocations

## Physical observation

Captain reported:

`CYAN · MM3B1 PASS (#00ffff)`

Decoded meaning:

The proven prefix entered `memblock_free_all()`; unchanged
`reset_all_zones_managed_pages()` ran from frozen `done=0`, completed its
online-pgdat / zone reset path and final `done=1` store; the internal stop
returned before `free_low_memory_core_early()`; the outer stop returned before
`mem_init()`; `totalram_pages()` remained zero, slab remained unavailable,
IRQs remained disabled, CPU0 continuity remained intact, and the fresh final
framebuffer bridge was valid.

This physically proves:

- the already-proven MM3A prefix completed again;
- `memblock_free_all()` was entered;
- unchanged `reset_all_zones_managed_pages()` genuinely returned;
- because frozen `reset_managed_pages_done == 0`, its slow online-pgdat / zone
  reset path executed rather than the already-done fast return;
- its final `reset_managed_pages_done = 1` store completed;
- the internal true stop returned before `free_low_memory_core_early()`;
- the outer true stop returned before `mem_init()`;
- `totalram_pages() == 0` still held;
- `slab_is_available() == false` still held;
- IRQ-disabled state survived;
- CPU0 continuity survived;
- the fresh final framebuffer bridge was valid.

It proves **nothing** about:

- `free_low_memory_core_early()`;
- the later atomic add into `_totalram_pages`;
- `mem_init()`;
- `kmem_cache_init()`;
- later allocator initialization.

Result: **PASS**.

## Proven consequence

MM3B1 is promoted to MAINLINE.

The next unexecuted production boundary is inside:

`free_low_memory_core_early()`
