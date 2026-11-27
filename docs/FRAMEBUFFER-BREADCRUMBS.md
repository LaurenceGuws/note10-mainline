# Note10 framebuffer breadcrumb layout

Authoritative model after CAL1 physical calibration.

simplefb:
- base: 0xca000000
- width: 1440
- height: 3040
- bytes/pixel: 4
- scanline bytes: 0x1680 / 5760

## Historical CAL1 early boot trail (pre-palette amendment)

These bands were retained by the original `head.S` diagnostic sequence. Later markers overwrite only selected subranges, leaving a compact
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

## Permanent active decoder (MM3B8B1-P1 and later)

All 83 inherited paint sites are opaque black or muted blue-dominant,
including the trail in rows512..671. Historical colors above apply only to
earlier exact BOOTs. The four active roles are YELLOW #ffff00 (pre-fail),
WHITE #ffffff (entered/incomplete), RED #ff0000 (returned, postconditions not
established), GREEN #00ff00 (success). Only a stable, uniform full-width
GREEN in the whole calibrated rows672..703 slot on a positively identified
fresh exact candidate boot from a known non-pass/Download Mode/reset state
is promotable. No transient witness required. All other colors, partial
band, green NOTICE glyphs, stale/reset/uncertain provenance are non-promotable.
All existing writer and loader/reset-provenance gates remain. Historical
decoder requirements, including original B1 GOLD, are not retroactively
changed. See bring-up-lineage.html and the phase proof.
