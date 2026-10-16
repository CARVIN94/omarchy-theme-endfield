#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Gate: every colour a theme paints on paper must stay readable on it.

Reads colors.toml next to this script and asserts WCAG contrast ratios:

  * body text (foreground, light_foreground, bright_foreground) >= 7.0
  * secondary text (dark_foreground, muted) and accent           >= 4.5
  * the eight terminal colours, normal and bright                >= 4.5
  * text drawn on a selection block (foreground on selection)     >= 7.0

Exit code 0 means the palette passes; 1 lists what it could not read.
Run: uv run check-contrast.py [theme-dir]
"""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

BODY = ("foreground", "light_foreground", "bright_foreground")
SECONDARY = ("dark_foreground", "muted", "accent")
TERMINAL = (
    "red", "yellow", "orange", "green", "cyan", "blue", "magenta", "brown",
    "bright_red", "bright_yellow", "bright_green", "bright_cyan",
    "bright_blue", "bright_magenta",
)


def srgb_to_linear(channel: float) -> float:
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def luminance(hex_colour: str) -> float:
    value = hex_colour.lstrip("#")
    if not re.fullmatch(r"[0-9a-fA-F]{6}", value):
        raise ValueError(f"not a six-digit hex colour: {hex_colour!r}")
    r, g, b = (int(value[i : i + 2], 16) / 255 for i in (0, 2, 4))
    return (
        0.2126 * srgb_to_linear(r)
        + 0.7152 * srgb_to_linear(g)
        + 0.0722 * srgb_to_linear(b)
    )


def contrast(one: str, other: str) -> float:
    high, low = sorted((luminance(one), luminance(other)), reverse=True)
    return (high + 0.05) / (low + 0.05)


def main() -> int:
    theme_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent
    colours = tomllib.loads((theme_dir / "colors.toml").read_text())

    background = colours["background"]
    selection = colours.get("selection", background)

    checks: list[tuple[str, str, str, float]] = []
    for key in BODY:
        checks.append((key, key, background, 7.0))
    for key in SECONDARY:
        checks.append((key, key, background, 4.5))
    for key in TERMINAL:
        checks.append((key, key, background, 4.5))
    checks.append(("foreground on selection", "foreground", selection, 7.0))

    failures: list[str] = []
    width = max(len(label) for label, *_ in checks)
    for label, key, against, floor in checks:
        if key not in colours:
            failures.append(f"{label}: missing from colors.toml")
            continue
        ratio = contrast(colours[key], against)
        verdict = "ok" if ratio >= floor else "FAIL"
        print(
            f"{label:<{width}}  {colours[key]:<8} on {against:<8} "
            f"{ratio:5.2f}:1  floor {floor:.1f}  {verdict}"
        )
        if verdict == "FAIL":
            failures.append(f"{label}: {ratio:.2f}:1 < {floor:.1f}:1")

    if failures:
        print(f"\nUnreadable on {background}:", file=sys.stderr)
        for line in failures:
            print(f"  - {line}", file=sys.stderr)
        return 1
    print("\nAll colours clear their contrast floors.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
