#!/usr/bin/env bash
# preview.png in the theme's own idiom: one flat paper field, the palette as a
# band of labelled swatches, a `//` label, nothing else — the flatness the
# backgrounds keep, and the reading the wiki's module cards use (ASSETS.md).
#
# The theme switcher (`omarchy-theme-switcher`) looks for preview.png in the
# theme directory, so this file has a job beyond the README. It used to be the
# official key visual with a strip of swatches under it; the artwork is gone
# (ASSETS.md: no game artwork ships here), so every pixel is this repository's
# own and the card is small enough to diff.
#
# Label colour follows the theme's own rule for text on a block: a swatch gets
# the field colour as ink when it is dark, and the ink colour when it is light.
set -euo pipefail

cd "$(dirname "$0")"

OUT=preview.png



WIDTH=1920
HEIGHT=1080
MARGIN=96
COLUMNS=6
BAND_TOP=368
SWATCH_HEIGHT=230
GAP=26
NAME_SIZE=24
HEX_SIZE=19
FOOT_SIZE=26

# The band shows the same twelve tokens the old strip did, in the same order.
TOKENS=(
  background dark_background foreground dark_foreground accent selection
  red orange green cyan blue magenta
)

read_colour() {
  local key="$1" value
  value=$(grep -m1 -E "^${key}[[:space:]]*=" colors.toml | sed -E 's/.*"(#[0-9A-Fa-f]{6})".*/\1/')
  [[ -n $value ]] || { echo "colors.toml has no $key" >&2; exit 1; }
  printf '%s' "$value"
}

# WCAG relative luminance, printed as a 0-4 digit integer scaled by 10000.
luminance() {
  awk -v hex="$1" '
    function lin(c) { return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ^ 2.4 }
    BEGIN {
      r = strtonum("0x" substr(hex, 2, 2)) / 255
      g = strtonum("0x" substr(hex, 4, 2)) / 255
      b = strtonum("0x" substr(hex, 6, 2)) / 255
      printf "%d", (0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)) * 10000
    }'
}

# #RRGGBB + alpha -> the rgba() form ImageMagick's -stroke wants.
rgba_of() {
  local hex="${1#\#}"
  printf 'rgba(%d,%d,%d,%s)' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}" "$2"
}

PAPER=$(read_colour background)
INK=$(read_colour foreground)
ACCENT=$(read_colour accent)
MUTED=$(read_colour muted)

font=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font:style=Bold' || true)
[[ -f $font ]] || font=$(fc-match -f '%{file}' 'Noto Sans Mono:style=Bold')
[[ -f $font ]] || { echo "no monospace bold font found" >&2; exit 1; }

band_width=$((WIDTH - MARGIN * 2))
swatch_width=$(( (band_width - GAP * (COLUMNS - 1)) / COLUMNS ))
row_height=$((SWATCH_HEIGHT + GAP))
step=$((swatch_width + GAP))

args=(
  -size "${WIDTH}x${HEIGHT}" "xc:$PAPER"
  -font "$font"
  -fill "$INK" -pointsize 132 -annotate +${MARGIN}+228 'ENDFIELD'
  -fill "$ACCENT" -pointsize 32 -annotate +${MARGIN}+286 '// OMARCHY THEME - PAPER'
  -fill "$INK" -draw "rectangle ${MARGIN},322 $((WIDTH - MARGIN)),324"
  -fill "$MUTED" -pointsize "$FOOT_SIZE" -annotate +${MARGIN}+1020 \
    '// VALUES MEASURED, NOT PICKED - SEE ASSETS.MD'
)

index=0
for token in "${TOKENS[@]}"; do
  colour=$(read_colour "$token")
  column=$((index % COLUMNS))
  row=$((index / COLUMNS))
  x=$((MARGIN + column * step))
  right=$((x + swatch_width))
  top=$((BAND_TOP + row * row_height))

  # A dark swatch takes the field colour as its ink; a light one takes the ink —
  # the theme's own rule for text sitting on a block.
  if (( $(luminance "$colour") < $(luminance "$ACCENT") )); then label="$PAPER"; else label="$INK"; fi

  args+=(
    -stroke "$(rgba_of "$label" 0.4)" -strokewidth 1 -fill "$colour" \
      -draw "rectangle ${x},${top} ${right},$((top + SWATCH_HEIGHT))" -stroke none
    -fill "$label" -pointsize "$NAME_SIZE" -annotate "+$((x + 18))+$((top + 44))" "$token"
    -fill "$label" -pointsize "$HEX_SIZE" -annotate "+$((x + 18))+$((top + 76))" "${colour#\#}"
  )
  index=$((index + 1))
done

magick "${args[@]}" -depth 8 -strip -define png:exclude-chunk=time,date,text "$OUT"
echo "wrote $OUT ($(du -h "$OUT" | cut -f1))"
