# Memory-core MM3A pre-buddy prefix physical proof

Date: 2026-09-30

## Promoted identities

Kernel source:

`245a31aef5e1b3d3edf23a90a24f4b8c2e64e347`

Image:

`c89b18f75a938972bdd60d660309ac1f618ce530d0d93a4b9ddcb92c693e7d5c`

DTB:

`6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`

uniLoader:

`d090f795c9ef3648ba42ff2df2a303853a2abf15504fa73a3836dc3ed1330292`

BOOT:

`ec918c8baf4f6fcc5d0496cf63a02ae8d6574bb050c773625f54a641eedd9596`

Previous proven MAINLINE / immediate rollback:

`7007ab6b4d10d62b1db782db35922821ac4c416bbffecb95b85d98b7e9a201ce`

Rejected whole-MM3 BOOT:

`6daec9ff790a348fbb26eec9103c6596ba8d6cd3fea2da15457a28771fd88aa6`

The whole-MM3 candidate boot-looped with no decoded terminal marker and remains
non-promotable.

## Reviewed internal boundary

MM3A preserved the ET1 machine prefix of `mm_core_init()` through:

1. `arch_mm_preinit()`
2. `arch_setup_zero_pages()`
3. linked zero-PFN setup
4. `build_all_zonelists(NULL)`
5. `page_alloc_init_cpuhp()`
6. `mem_debugging_and_hardening_init()`
7. `report_meminit()`
8. `stack_depot_early_init()`

Immediately after genuine `stack_depot_early_init()` return, frozen MM3A
loads a one-byte local `__initdata` diagnostic stop flag.

Frozen stop state:

- symbol: `note10_mm3a_stop`
- address: `0xffff800082362e80`
- size: 1 byte
- value: `1`

The true lane returns from `mm_core_init()` before `memblock_free_all()`.
The false lane retains the complete original allocator suffix.

## Physical observation

Captain reported:

`BLUE · MM3A PASS (#0000ff)`

Decoded meaning:

The unchanged pre-buddy `mm_core_init()` prefix through
`stack_depot_early_init()` completed and returned through the reviewed stop
before `memblock_free_all()`; `totalram_pages()` remained zero, slab remained
unavailable, interrupts remained disabled, CPU0 continuity remained intact, and
the fresh final framebuffer bridge was valid.

This physically proves:

- every reviewed prefix call above returned;
- the linked zero-PFN setup between the arm64 setup call and zonelist build completed;
- the runtime stop branch returned before `memblock_free_all()`;
- `totalram_pages() == 0` still held after the prefix;
- `slab_is_available() == false` still held;
- IRQ-disabled state survived;
- CPU0 continuity survived;
- the final freshly read framebuffer bridge was valid.

It proves **nothing** about:

- `memblock_free_all()`;
- `mem_init()`;
- `kmem_cache_init()`;
- `pgtable_cache_init()`;
- `vmalloc_init()`;
- `mm_cache_init()`.

Result: **PASS**.

## Proven consequence

MM3A is promoted to MAINLINE.

The next unexecuted production boundary is:

`memblock_free_all()`

The next diagnostic step should advance the internal stop exactly one call,
placing it immediately after `memblock_free_all()` and before `mem_init()`.
