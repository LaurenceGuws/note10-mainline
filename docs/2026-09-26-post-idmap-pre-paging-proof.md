# 2026-09-26 post-idmap / pre-paging phase proof

The accepted three-checkpoint phase used the already proven
`PROT_NORMAL_NC` high-TTBR1 framebuffer bridge to cross the remaining
pre-`paging_init()` `setup_arch()` work without creating a new evidence sink.

## Starting authority

The phase started from proven yellow MAINLINE:

`ac321737aeeaa886bf6ca2e3fd4263a08a9880fcd3b9be7e216fdb1ad359977e`

That checkpoint proved the high-TTBR1 bridge returned by
`early_memremap_prot(0xca3b1000, 0x2d000, PROT_NORMAL_NC)` visibly wrote the
framebuffer while `cpu_uninstall_idmap()` remained unreachable.

Android recovery remained the immutable recovery floor:

`1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

It was not used as the routine rollback target during the phase.

## P1: post-`cpu_uninstall_idmap()`

- kernel commit:
  `1a7810e8fc3293ab1e1af1985bc9cf6fea2d9a93`
- Image:
  `83f6607953ce63890deac3a638ee1d9c383b933813c46f95df2ffc69bc37fd4f`
- BOOT:
  `f4383f57b057543b9f5eb10d7d8fe568f12e28fb37eafca0b2826c1ae70fdd8a`
- marker:
  pure red `ARGB8888 0xffff0000`

P1 removed only the yellow deliberate hold. The original
`cpu_uninstall_idmap()` then executed completely, including TTBR0 replacement,
TLB/TCR maintenance and any runtime-active `cpu_do_switch_mm` path. After the
join, the ordinary C bridge value was freshly rebound to fixed/read-only `x9`
and the existing high-TTBR1 band was repainted red.

Captain observed stable red for at least three minutes. This proves
`cpu_uninstall_idmap()` returned and the high-TTBR1 evidence bridge survived
the teardown. `xen_early_init()` remained unreachable.

## P2: post-Xen / EFI continuation

- kernel commit:
  `2339be5ade8592a5b52dd837345678de2fc76f17`
- Image:
  `f5cb0a779babac15aabedbb584384d1900ef504e3421ae23a17b1e45a53f8462`
- BOOT:
  `21f25494c348ea886717128762a6e371e9428aff43c448f630fca359297e82de`
- marker:
  violet `ARGB8888 0xff8000ff`

P2 removed only the red hold. The original `xen_early_init()` and `efi_init()`
executed in order. The original `!efi_enabled(EFI_BOOT)` path, optional image
alignment warning and `WARN_TAINT(mmu_enabled_at_boot, ...)` runtime control
flow remained unchanged.

Final linked inspection proved both normal and warning-active paths converge at
the same violet join before the marker. The surviving ordinary C bridge state
remained in callee-saved `x20` and was freshly rebound `x20 -> x9` before the
violet writes.

The attended physical test recorded P2 PASS. The exact BOOT above was promoted
and kept installed. `arm64_memblock_init()` remained unreachable.

## P3: post-`arm64_memblock_init()`

- kernel commit:
  `14f74f058d6307278db43613395599608673cc21`
- patch SHA-256:
  `28c02b3694af0dae2713f60ac0d3235e3d44cc8ed9ce3cd835c5bfe05b4c300e`
- Image:
  `b72f4305141aeeef6878b1829498906f75177f4199045038a96f4adf816a4325`
- loader:
  `e074ec98909989ea654bb67dd8f3ee193886fe2a2c2837337db3064d76a93d38`
- BOOT:
  `3a66d98bcfa76de7f9f598eba839f5ccc4a096c4ca50f6cacd5e44fe87eb6d27`
- marker:
  pure cyan `ARGB8888 0xff00ffff`

P3 removed only the violet hold. `arm64_memblock_init()` itself was unchanged
from P2; independent review additionally confirmed its function-level object
disassembly was identical between the P2 and P3 builds.

Final linked ordering is:

```text
ffff800082214bd8  bl arm64_memblock_init
ffff800082214bdc  mov x9, x20
ffff800082214be0  mov x10, x9
...
ffff800082214c0c  dsb sy
ffff800082214c10  wfe
ffff800082214c14  b ffff800082214c10

-- unreachable --

ffff800082214c18  bl paging_init
```

The cyan marker physically uses only `x9..x12`, writes the exact existing
`0x2d000` high-TTBR1 band with aligned 64-bit stores, performs no `dc cvac` or
marker `isb`, and completes with `dsb sy`.

Captain observed pure cyan and confirmed it remained unchanged for at least
three minutes.

That stable cyan state proves:

1. every physically proven P2 fact remains true;
2. `arm64_memblock_init()` returned;
3. the established high-TTBR1 bridge survived `arm64_memblock_init()` and
   remained visibly writable;
4. `paging_init()` did not execute.

## Reproducibility and standing invariants

P3 retained accepted config:

`314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`

The loader source remained the already reviewed commit:

`36ecc6a56967af0887af2a72fca81d091ae876a7`

uniLoader embeds a wall-clock build second in `VER_TAG`. The supported
`BUILD_DATE` input was therefore explicitly pinned to the same accepted P2
value, `2026-09-26 01:21:56 UTC`. No loader source changed. Two clean P3 loader
builds were byte-identical at the loader hash above.

Two P3 BOOT packaging runs were byte-identical. The final BOOT retained:

- size `57,671,680` bytes;
- Image offset `0xc000`;
- DTB offset `0x2a3f000`;
- initramfs offset `0x2a44000`;
- byte-identical ramdisk relative to proven P2;
- byte-identical post-ramdisk tail;
- checksum/id-only BOOT-header drift;
- unchanged accepted AVB metadata and stale-descriptor behavior.

## Promotion and next boundary

The exact P3 BOOT:

`3a66d98bcfa76de7f9f598eba839f5ccc4a096c4ca50f6cacd5e44fe87eb6d27`

is the newest proven MAINLINE checkpoint, remains installed, and is the normal
progression parent / routine rollback target.

The previous P2 checkpoint:

`21f25494c348ea886717128762a6e371e9428aff43c448f630fca359297e82de`

remains preserved as the immediate historical proof checkpoint.

This completes the accepted post-idmap / pre-paging phase. Do not move the
current cyan hold or execute `paging_init()` under this phase's authority.
`paging_init()` is the next architectural boundary and requires a new bounded
phase plan/review before physical progression.

Raw physical receipts remain under:

`~/.local/state/workstreams/note10-mainline/physical/post-idmap-p1/`

`~/.local/state/workstreams/note10-mainline/physical/post-idmap-p2/`

`~/.local/state/workstreams/note10-mainline/physical/post-idmap-p3/`
