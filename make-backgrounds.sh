#!/usr/bin/env bash
# Backgrounds in the reading the theme owner pointed at: a flat field with very
# faint contour lines and a single `//` marker. The reference is the wiki's
# module cards (fz.wiki — see ASSETS.md): paper or blue-black, contour texture,
# one monospace label, nothing else. No illustration, no hatch, no glow.
set -euo pipefail

cd "$(dirname "$0")"

WIDTH=3840
HEIGHT=2160
OUT=backgrounds
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

DEEP='#111827'
PAPER='#F6F5EF'
MINT='#00C7BD'

font=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font:style=Bold' || true)
[[ -f $font ]] || font=$(fc-match -f '%{file}' 'Noto Sans Mono:style=Black')
[[ -f $font ]] || { echo "no monospace bold font found" >&2; exit 1; }

# One contour field, drawn at half size so a 2x scale keeps the strokes thin
# and the curves wide — the wiki's lines span the whole card, not a corner.
python3 - "$WORK/contour.pgm" <<'PY'
import math
import sys

width, height = 1920, 1080
levels = (-0.66, -0.44, -0.22, 0.0, 0.22, 0.44, 0.66)
half_width = 0.005
pixels = bytearray(width * height)

for y in range(height):
    row = y * width
    cy = y / 520.0
    for x in range(width):
        value = math.sin(x / 760.0) * math.cos(cy) + 0.32 * math.sin((x + y) / 1150.0)
        for level in levels:
            if -half_width < value - level < half_width:
                pixels[row + x] = 255
                break

with open(sys.argv[1], "wb") as handle:
    handle.write(b"P5\n%d %d\n255\n" % (width, height))
    handle.write(bytes(pixels))
PY

# The field becomes the alpha of a flat colour, so the same curves serve both a
# white-on-deep and an ink-on-paper layer.
make_layer() {
  local opacity="$1" colour="$2" dest="$3"
  magick "$WORK/contour.pgm" -resize ${WIDTH}x${HEIGHT}\! -blur 0x1 -level 22%,78% \
    -alpha copy -channel A -evaluate multiply "$opacity" +channel \
    -fill "$colour" -colorize 100 \
    -define png:exclude-chunk=time,date,text "$dest"
}

make_layer 0.18 white "$WORK/lines-deep.png"
make_layer 0.07 black "$WORK/lines-paper.png"

magick -size ${WIDTH}x${HEIGHT} xc:"$DEEP" "$WORK/lines-deep.png" -compose over -composite \
  -font "$font" -pointsize 40 -fill "$MINT" -annotate +96+124 '// ENDFIELD' \
  -define png:exclude-chunk=time,date,text "$OUT/0-contour-deep.png"

magick -size ${WIDTH}x${HEIGHT} xc:"$PAPER" "$WORK/lines-paper.png" -compose over -composite \
  -font "$font" -pointsize 40 -fill '#6A685F' -annotate +96+124 '// ENDFIELD' \
  -define png:exclude-chunk=time,date,text "$OUT/1-contour-paper.png"

echo "wrote $OUT/{0-contour-deep,1-contour-paper}.png"
