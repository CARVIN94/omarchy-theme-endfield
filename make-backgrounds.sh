#!/usr/bin/env bash
# Rebuild the wallpapers from Omarchy's Endfield palette.
#
# The palette mirrors the official site's measured values: paper #F6F5EF, ink
# #191919, signal yellow #FFFA00 and the magenta/yellow/mint signal band. The
# diagonal hatch is the site's own repeating-linear-gradient(-45deg, #1f1f22
# 3px, transparent 6px) idiom, redrawn as a tile.
#
# background/omarchy.png is the solid fallback Omarchy falls back to when a
# theme has no chosen background — stock themes each ship one, so this theme
# does too.
#
# Requires ImageMagick 7 (magick) and a monospace bold font. Output is written
# to backgrounds/; the checked-in PNGs are the output of this script.
set -euo pipefail

cd "$(dirname "$0")"

WIDTH=3840
HEIGHT=2160
OUT=backgrounds
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

PAPER='#F6F5EF'
INK='#191919'
SIGNAL='#FFFA00'
MAGENTA='#FF00F0'
MINT='#00FFA2'

font=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font:style=Bold' || true)
[[ -f $font ]] || font=$(fc-match -f '%{file}' 'Noto Sans Mono:style=Black')
[[ -f $font ]] || { echo "no monospace bold font found" >&2; exit 1; }

# --- tiles -------------------------------------------------------------------

# 128px drafting grid, ~10% ink on paper.
magick -size 128x128 xc:none -stroke "$INK" -strokewidth 2 -fill none \
  -draw 'line 0,0 127,0' -draw 'line 0,0 0,127' \
  -alpha set -channel A -evaluate multiply 0.10 +channel "$WORK/grid-light.png"

# 45 degree hatch, the site's warning-stripe idiom: 3px ink, 3px gap.
magick -size 16x16 xc:none -fill "$INK" -draw 'polygon 0,16 16,0 16,7 7,16' \
  "$WORK/hatch-light.png"

magick -size 128x128 xc:none -stroke '#ffffff' -strokewidth 2 -fill none \
  -draw 'line 0,0 127,0' -draw 'line 0,0 0,127' \
  -alpha set -channel A -evaluate multiply 0.05 +channel "$WORK/grid-dark.png"

magick -size 24x24 xc:none -fill '#26261f' -draw 'polygon 0,24 24,0 24,9 9,24' \
  "$WORK/hatch-dark.png"

# --- helpers -----------------------------------------------------------------

# signal_band <file> <x> <y> — magenta / yellow / mint rule, 16px tall
signal_band() {
  magick "$1" \
    -fill "$MAGENTA" -draw "rectangle $2,$3 $(( $2 + 240 )),$(( $3 + 16 ))" \
    -fill "$SIGNAL" -draw "rectangle $(( $2 + 240 )),$3 $(( $2 + 720 )),$(( $3 + 16 ))" \
    -fill "$MINT" -draw "rectangle $(( $2 + 720 )),$3 $(( $2 + 960 )),$(( $3 + 16 ))" \
    "$1.tmp"
  mv "$1.tmp" "$1"
}

# --- 0: Paper Grid (light) ---------------------------------------------------

magick -size ${WIDTH}x${HEIGHT} xc:"$PAPER" \
  \( -size ${WIDTH}x${HEIGHT} "tile:$WORK/grid-light.png" \) -composite \
  \( -size 1240x1040 "tile:$WORK/hatch-light.png" \) -geometry +2600+1120 -composite \
  -font "$font" -pointsize 192 -fill "$INK" -annotate +192+1992 'ENDFIELD' \
  -font "$font" -pointsize 44 -fill '#6A685F' \
  -annotate +200+2068 'INTEGRATED  INDUSTRIES  //  TALOS-II' \
  -stroke "$INK" -strokewidth 4 -fill none \
  -draw "line 192,240 192,360" -draw "line 176,240 208,240" -draw "line 176,360 208,360" \
  -draw "line 3648,1800 3768,1800" -draw "line 3648,1784 3648,1816" -draw "line 3768,1784 3768,1816" \
  "$OUT/0-paper-grid.png"

signal_band "$OUT/0-paper-grid.png" 192 1736

# --- 1: Signal Hatch (dark) --------------------------------------------------

magick -size ${WIDTH}x${HEIGHT} xc:"$INK" \
  \( -size ${WIDTH}x${HEIGHT} "tile:$WORK/grid-dark.png" \) -composite \
  \( -size ${WIDTH}x${HEIGHT} "tile:$WORK/hatch-dark.png" \) -composite \
  -font "$font" -pointsize 380 -fill "$SIGNAL" -annotate +240+1280 'ENDFIELD' \
  -font "$font" -pointsize 48 -fill '#8A8878' \
  -annotate +252+1400 'ARKNIGHTS: ENDFIELD  //  ENDFIELD INDUSTRIES' \
  -stroke "$SIGNAL" -strokewidth 4 -fill none \
  -draw "line 240,1520 3672,1520" \
  "$OUT/1-signal-hatch.png"

signal_band "$OUT/1-signal-hatch.png" 240 1600

# --- fallback ----------------------------------------------------------------

magick -size ${WIDTH}x${HEIGHT} xc:"$PAPER" "$OUT/omarchy.png"

echo "wrote $OUT/{0-paper-grid,1-signal-hatch,omarchy}.png"
