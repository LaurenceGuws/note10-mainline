# 2026-09-26 paging_init phase proof

The accepted three-checkpoint `paging_init()` phase started from the physically
proven post-`arm64_memblock_init()` cyan checkpoint and reused the already
proven high-TTBR1 `PROT_NORMAL_NC` framebuffer bridge.

## Starting authority

Starting proven MAINLINE:

`3a66d98bcfa76de7f9f598eba839f5ccc4a096c4ca50f6cacd5e44fe87eb6d27`

That checkpoint proved `arm64_memblock_init()` returned and the established
bridge remained visibly writable while `paging_init()` was still unreachable.

Android recovery remained the immutable recovery floor:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

It was not used as the routine rollback target.

## Q1: post-`map_mem()`

- kernel commit:
  `052cae4854efd54e0dd55cbe77c0529a8a998a8a`
- Image:
  `79680b3a277f74b64c5258ad14782486e87a6030338facf494ee47b46aa7ecb2`
- loader:
  `2855d7ac8691cbc25cf63a543252ac0775e9e7f22b34281a365ca1e3d1a2200f`
- BOOT:
  `7c4cf029d91b2841e4705e06218d7780ed24a87ed69f39848568e46e0637e749`
- marker:
  gold `ARGB8888 0xffffb000`

Q1 removed only the proven cyan hold. `setup_arch()` copied the already-proven
bridge pointer once into the accepted diagnostic `__initdata` handoff
`note10_paging_bridge` immediately before calling `paging_init()`.

Inside `paging_init()`, `map_mem()` executed completely. Its normalized object
instruction sequence remained equivalent to the proven parent. Only after
`map_mem()` returned did `READ_ONCE(note10_paging_bridge)` supply a fresh
fixed/read-only `x9` marker input.

Captain observed stable gold for at least three minutes. This proves
`paging_init()` was genuinely entered, `map_mem()` returned, and the existing
high-TTBR1 bridge survived `map_mem()`. `memblock_allow_resize()` remained
unreachable.

The accepted alias invariant remained intact: the framebuffer reservation was
already `MEMBLOCK_NOMAP` before this phase, so `map_mem()` did not create a
conflicting WB linear alias.

## Q2: post-`memblock_allow_resize()` / `create_idmap()`

- kernel commit:
  `34f506791f0b3aadb247cf098b04f9b71303deef`
- Image:
  `10539c2c30721e9dba2fd794d74f47bf258ec195ea9a637d628c4d6df5315544`
- loader:
  `64d3bd563258e1b2eddc680151c0fe4f26cf16bc20a32055dd878782a4045316`
- BOOT:
  `7b12062945c4f47b8eb85b90f72d9fd57fdda6c7bf6a458f861f793876cbc1b5`
- marker:
  electric purple `ARGB8888 0xffc000ff`

Q2 removed only the gold hold. The original `memblock_allow_resize()` and
`create_idmap()` then executed unchanged. `create_idmap()` remained
instruction-equivalent to Q1.

Only after `create_idmap()` returned did Q2 freshly reload the diagnostic
handoff into fixed/read-only `x9` and paint electric purple.

Captain observed stable electric purple for at least three minutes. This proves
`memblock_allow_resize()` returned, `create_idmap()` returned, and the existing
bridge survived both operations. `declare_kernel_vmas()` remained unreachable.

The accepted hierarchy invariant also remained intact: `create_idmap()` builds
the separate idmap hierarchy rather than modifying the live TTBR1 fixmap
hierarchy used by the diagnostic bridge.

A bounded review found one metadata-only blocker before physical Q2 testing:
the canonical root `current-mainline.txt` had not advanced with Q1 even though
the checkpoint metadata and mirror had. The root pointer and mirror were
reconciled to exact Q1, the standing receipt was regenerated against the live
canonical pointer, and frozen Q2 source/Image/loader/BOOT identities remained
unchanged. The R1 follow-up then received FINAL ACCEPT.

## Q3: genuine `paging_init()` return

- kernel commit:
  `bc18a2891ffd0dea85eb7bab759efbe13b8098d6`
- patch SHA-256:
  `5b9b2bee42fbd5b14adecd262c0725eac50ecac09fe19a4601196a3cf79dc5a9`
- Image:
  `7449bdb6cc4639e1a951b74f901a88afb9ef15343789f6e8a04638ddf028daf2`
- loader:
  `6e1aaed946e79b297c878e96d02f65b2542a9d93f370c99f3d5f2f57c5e675bf`
- BOOT:
  `213b61315c94e37f942532c6fdbe5f6dcd158a851dbe9177258036265d2ec803`
- marker:
  spring green `ARGB8888 0xff00ff80`

Q3 removed only the electric-purple hold. `declare_kernel_vmas()` remained
source-unchanged and instruction-equivalent to Q2.

The final linked `paging_init()` tail is:

```text
ffff80008221c9b4  bl declare_kernel_vmas
ffff80008221c9b8  ldr x19, [sp, #0x10]
ffff80008221c9bc  ldp x29, x30, [sp], #0x20
ffff80008221c9c0  ldr x30, [x18, #-0x8]!
ffff80008221c9c4  mov x9, #0x0
ffff80008221c9c8  ret
```

Thus `paging_init()` genuinely restores its compiler-managed state and SCS
return state before returning to `setup_arch()`.

The caller resumes with:

```text
ffff800082214c18  bl paging_init
ffff800082214c1c  mov x9, x20
ffff800082214c20  mov x10, x9
...
ffff800082214c4c  dsb sy
ffff800082214c50  wfe
ffff800082214c54  b ffff800082214c50

-- unreachable --

ffff800082214c58  bl earlyfb_console_init
```

The ordinary `setup_arch` bridge survives in callee-saved `x20` across
`paging_init()`. Q3 freshly rebinds `x20 -> x9` only after the call returns.
The spring-green marker then writes exactly the existing `0x2d000` bridge band
with aligned 64-bit stores using only `x9..x12`, performs no `dc cvac` or
marker `isb`, and completes with `dsb sy`.

Captain observed spring green and confirmed it remained unchanged for at least
three minutes.

That stable state proves:

1. every physically proven Q2 fact remains true;
2. `declare_kernel_vmas()` returned;
3. `paging_init()` completed its genuine epilogue and returned to
   `setup_arch()`;
4. the ordinary `setup_arch` bridge survived the complete `paging_init()` call
   and remained visibly writable;
5. `earlyfb_console_init()` did not execute.

## Reproducibility and standing invariants

All three checkpoints retained accepted config:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

Loader source remained:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

The loader `BUILD_DATE` stayed explicitly pinned to:

`2026-09-26 01:21:56 UTC`

Two clean loader builds and two BOOT packaging runs were byte-identical at each
checkpoint. Q3 retained:

- BOOT size `57,671,680` bytes;
- Image offset `0xc000`;
- DTB offset `0x2a3f000`;
- initramfs offset `0x2a44000`;
- byte-identical ramdisk relative to proven Q2;
- byte-identical post-ramdisk tail;
- checksum/id-only BOOT-header drift;
- unchanged accepted AVB metadata and stale-descriptor behavior.

Before Q3 freeze, both canonical MAINLINE pointers and the rollback BOOT hash
were verified as exact proven Q2.

## Promotion and next boundary

The exact Q3 BOOT:

`213b61315c94e37f942532c6fdbe5f6dcd158a851dbe9177258036265d2ec803`

is the newest proven MAINLINE checkpoint, remains installed, and is the normal
progression parent / routine rollback target.

The previous Q2 checkpoint:

`7b12062945c4f47b8eb85b90f72d9fd57fdda6c7bf6a458f861f793876cbc1b5`

remains preserved as the immediate historical proof checkpoint.

This completes the accepted `paging_init()` phase. Do not remove the
spring-green hold or execute `earlyfb_console_init()` under this phase's
authority. `earlyfb_console_init()` is the next architectural boundary and
requires a new bounded phase plan/review before physical progression.

Raw physical receipts remain under:

`~/.local/state/workstreams/note10-mainline/physical/paging-init-q1/`

`~/.local/state/workstreams/note10-mainline/physical/paging-init-q2/`

`~/.local/state/workstreams/note10-mainline/physical/paging-init-q3/`
