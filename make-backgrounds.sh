#!/usr/bin/env bash
# Rebuild the two generated wallpapers from Omarchy's Endfield palette.
#
# The palette mirrors the official site's measured values: paper #F6F5EF, ink
# #191919, signal yellow #FFFA00 and the magenta/yellow/mint signal band. The
# diagonal hatch is the site's own repeating-linear-gradient(-45deg, #1f1f22
# 3px, transparent 6px) idiom, redrawn as a tile.
#
# Requires ImageMagick 7 (magick) and a monospace bold font. Output is written
# to backgrounds/ — the checked-in PNGs are the output of this script.
set -euo pipefail

cd "$(dirname "$0")"

WIDTH=1920
HEIGHT=1080
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

# 64px drafting grid, ~10% ink on paper.
magick -size 64x64 xc:none -stroke "$INK" -strokewidth 1 -fill none \
  -draw 'line 0,0 63,0' -draw 'line 0,0 0,63' \
  -alpha set -channel A -evaluate multiply 0.10 +channel "$WORK/grid-light.png"

# 45 degree hatch, the site's warning-stripe idiom: 3px ink, 3px gap.
magick -size 8x8 xc:none -fill "$INK" -draw 'polygon 0,8 8,0 8,3.5 3.5,8' \
  "$WORK/hatch-light.png"

magick -size 64x64 xc:none -stroke '#ffffff' -strokewidth 1 -fill none \
  -draw 'line 0,0 63,0' -draw 'line 0,0 0,63' \
  -alpha set -channel A -evaluate multiply 0.05 +channel "$WORK/grid-dark.png"

magick -size 12x12 xc:none -fill '#26261f' -draw 'polygon 0,12 12,0 12,4.5 4.5,12' \
  "$WORK/hatch-dark.png"

# --- helpers -----------------------------------------------------------------

# signal_band <file> <x> <y> — magenta / yellow / mint rule, 8px tall
signal_band() {
  magick "$1" \
    -fill "$MAGENTA" -draw "rectangle $2,$3 $(( $2 + 120 )),$(( $3 + 8 ))" \
    -fill "$SIGNAL" -draw "rectangle $(( $2 + 120 )),$3 $(( $2 + 360 )),$(( $3 + 8 ))" \
    -fill "$MINT" -draw "rectangle $(( $2 + 360 )),$3 $(( $2 + 480 )),$(( $3 + 8 ))" \
    "$1.tmp"
  mv "$1.tmp" "$1"
}

# --- 0: Paper Grid (light) ---------------------------------------------------

magick -size ${WIDTH}x${HEIGHT} xc:"$PAPER" \
  \( -size ${WIDTH}x${HEIGHT} "tile:$WORK/grid-light.png" \) -composite \
  \( -size 620x520 "tile:$WORK/hatch-light.png" \) -geometry +1300+560 -composite \
  -font "$font" -pointsize 96 -fill "$INK" -annotate +96+996 'ENDFIELD' \
  -font "$font" -pointsize 22 -fill '#6A685F' \
  -annotate +100+1034 'INTEGRATED  INDUSTRIES  //  TALOS-II' \
  -stroke "$INK" -strokewidth 2 -fill none \
  -draw "line 96,120 96,180" -draw "line 88,120 104,120" -draw "line 88,180 104,180" \
  -draw "line 1824,900 1884,900" -draw "line 1824,892 1824,908" -draw "line 1884,892 1884,908" \
  "$OUT/0-paper-grid.png"

signal_band "$OUT/0-paper-grid.png" 96 868

# --- 1: Signal Hatch (dark) --------------------------------------------------

magick -size ${WIDTH}x${HEIGHT} xc:"$INK" \
  \( -size ${WIDTH}x${HEIGHT} "tile:$WORK/grid-dark.png" \) -composite \
  \( -size ${WIDTH}x${HEIGHT} "tile:$WORK/hatch-dark.png" \) -composite \
  "$WORK/dark.png"

magick "$WORK/dark.png" \
  -font "$font" -pointsize 190 -fill "$SIGNAL" -annotate +120+640 'ENDFIELD' \
  -font "$font" -pointsize 24 -fill '#8A8878' \
  -annotate +126+700 'ARKNIGHTS: ENDFIELD  //  ENDFIELD INDUSTRIES' \
  -stroke "$SIGNAL" -strokewidth 2 -fill none \
  -draw "line 120,760 1836,760" \
  "$OUT/1-signal-hatch.png"

signal_band "$OUT/1-signal-hatch.png" 120 800

echo "wrote $OUT/0-paper-grid.png and $OUT/1-signal-hatch.png"
