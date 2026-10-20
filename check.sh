#!/usr/bin/env bash
# Every gate this theme has, in one command. Nothing here needs the network.
#
#   bash check.sh
#
# Four checks, in the order a break is cheapest to explain:
#
#   1. the palette is readable — on paper *and* on the surfaces Omarchy's own
#      templates draw text on (check-contrast.py, both palettes);
#   2. every variant is a whole set, and every literal in a section override is
#      a value its own palette defines (check-variant.py);
#   3. preview.png still matches what make-preview.sh draws from colors.toml.
#      The switcher reads that file, so a stale card advertises a palette the
#      theme no longer has. The generator is deterministic (no timestamps, no
#      randomness), so "regenerate and compare bytes" is a real test.
#
# Exit 0 means all four pass. Anything else prints which one did not.
set -uo pipefail

cd "$(dirname "$0")"

failures=()

step() {
  local name="$1"
  shift
  printf '== %s\n' "$name"
  if "$@"; then
    printf '   ok\n\n'
  else
    printf '   FAILED: %s\n\n' "$name" >&2
    failures+=("$name")
  fi
}

step "palette: paper"        python3 check-contrast.py
step "palette: dark variant" python3 check-contrast.py variants/dark
step "variants: whole sets"  python3 check-variant.py

# preview.png is generated, so regenerate it into a scratch copy of the two
# files it reads and compare. Comparing against the working file would also
# pass if someone hand-edited both; comparing bytes keeps it honest.
printf '== preview: matches the palette\n'
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
cp colors.toml make-preview.sh "$scratch"/
if ! (cd "$scratch" && bash make-preview.sh >/dev/null); then
  printf '   FAILED: make-preview.sh could not run\n\n' >&2
  failures+=("preview: generator failed")
elif cmp -s "$scratch/preview.png" preview.png; then
  printf '   ok\n\n'
else
  printf '   FAILED: preview.png is stale — run bash make-preview.sh\n\n' >&2
  failures+=("preview: stale")
fi

if (( ${#failures[@]} )); then
  printf 'Gates failed:\n' >&2
  printf '  - %s\n' "${failures[@]}" >&2
  exit 1
fi
printf 'All gates pass.\n'
