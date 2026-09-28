# Note10 framebuffer breadcrumb layout

Authoritative model after CAL1 physical calibration.

simplefb:
- base: 0xca000000
- width: 1440
- height: 3040
- bytes/pixel: 4
- scanline bytes: 0x1680 / 5760

## Persistent early boot trail

These bands are intentionally retained by the current `head.S` diagnostic
sequence. Later markers overwrite only selected subranges, leaving a compact
historical trail:

- rows 512..575: MAGENTA
- rows 576..607: CYAN
- rows 608..639: GREEN
- rows 640..671: WHITE

Derivation:
- rows 512..639 first become MAGENTA;
- rows 576..639 are later overwritten CYAN;
- rows 608..639 are later overwritten YELLOW, then GREEN;
- rows 640..671 are first RED, then overwritten WHITE.

The visible steady-state trail is therefore MAGENTA / CYAN / GREEN / WHITE.

## Reusable final-state slot

Rows 672..703, physical 0xca3b1000..0xca3de000, exact length 0x2d000.

All later early-head, setup_arch and start_kernel checkpoint colors repaint
this same 32-row slot in place.

CAL1 physically calibrated this slot by writing:
1. RED / GREEN / BLUE / WHITE, 8 rows each;
2. then overwriting the middle 16 rows with YELLOW;
3. then holding forever.

Observed final slot was exactly RED 8 / YELLOW 16 / WHITE 8, with no GREEN or
BLUE surviving.

Therefore direct row addressing and overwrite visibility for the reusable slot
are physically trustworthy at terminal hold.

## Interpretation rule

For future bring-up:
- rows 512..671 are historical early-boot trail and should be ignored when
  interpreting the current checkpoint;
- only rows 672..703 are the current reusable checkpoint slot;
- a stable final color in rows 672..703 is a valid final-state physical oracle;
- transient colors while the slot is repainting are not phase evidence;
- CAL1 itself is diagnostic-only and never promotable.
