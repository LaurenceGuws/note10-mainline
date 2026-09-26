# Post-preserve_boot_args split-stripe diagnostic

Parent kernel diagnostic commit:
`f11b2430102d78735ff9761fb09c2bc9aaf34466`

New kernel diagnostic commit:
`efb241e6c40183263002f9e4839864a5864b7c31`

The proven loader marker remains unchanged at:
`36ecc6a56967af0887af2a72fca81d091ae876a7`.

The first-body magenta marker still paints rows 512..639, but no longer holds.
The original `record_mmu_state` and `preserve_boot_args` execute unchanged.
Immediately after `preserve_boot_args` returns and before early stack/idmap
setup, rows 576..639 are overwritten cyan and cleaned to PoC, then the CPU
holds in `wfe`.

Marker ranges:
- magenta: `0xca2d0000..0xca384000`
- cyan lower half: `0xca32a000..0xca384000`

Only x9..x14 are used by both marker paths. x19 and x21 remain untouched.

Offline identities:
- config SHA-256: `314c3cea10b92a6078cf2eb2ede2fa11189d940d4d62bd810a280c446a287e37`
- Image SHA-256: `8df98b50dbdcc315bde92e4b86c529b5d9af3b8988345a6c9aa8cae96e6da459`
- Image size: `44,247,552` bytes
- unchanged d2s DTB SHA-256: `6ec8f1894e4498fbfe6c6ffc9e2b6f1839bda0c6d0fd661123a1e768c4399bc6`
- unchanged initramfs SHA-256: `86875f16f3a59fc5c34a1cdfd6f2de411e16a01ee6095947f8fd862770791989`
- deterministic loader SHA-256: `1f7a19b71f3b77d536a5010e286ef2c77292a4364499d8ec6848e1e082e6e959`
- frozen BOOT SHA-256: `ac54bba79cf5e796a30b7cb2635e997f27bb0fe48a2120471c601859e3c7f4a6`
- rollback/base BOOT: `1a78e5117cf23b3cab5547da2369018066c9ddac27307e97fce46026647ae2f9`

Two independent loader builds and two BOOT packaging runs were byte-identical.
BOOT layout, ramdisk, post-ramdisk tail and AVB behavior remain unchanged.

Expected physical interpretation:
- no magenta: regression before/at first entry;
- full magenta only: failure inside `record_mmu_state` + `preserve_boot_args`;
- magenta upper half + cyan lower half stable: both routines, including the
  MMU-off boot-argument cache invalidation path, are proven;
- split marker then reset: investigate only the just-crossed record/preserve
  boundary before moving deeper.
