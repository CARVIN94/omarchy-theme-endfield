#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Gate: every colour a theme paints on paper must stay readable on it.

Reads colors.toml next to this script (or in the directory given as argv[1]) and
asserts WCAG contrast ratios:

  * body text (foreground, light_foreground, bright_foreground) >= 7.0
  * secondary text (dark_foreground, muted) and accent           >= 4.5
  * the eight terminal colours, normal and bright                >= 4.5
  * text drawn on a selection block (foreground on selection)     >= 7.0
  * every literal card pair in the theme's own shell.<section>.toml
    overrides — card text on the card, and selected-row text on
    the selected block — clears 7.0
  * the surface pairs Omarchy's own templates actually compose:
    `foreground` and `dark_foreground` on `dark_background` (hermes status
    bar, t3code sidebar), `foreground` on `lighter_background` (helix focus
    and highlight rows), and `accent` on `selection` (btop's selected row)

Plus one structural rule about the bright row: a `bright_*` value is the softer
step of its hue, so its luminance must be strictly above its base (a bright slot
darker than the colour it brightens reads as bold text getting heavier than body
text). No tolerance: a bright step that lands within noise of its base is not a
step at all — the dark variant shipped `#FFF84D` on `#FFFA00` and measured
*below* its base, which the old 1% tolerance let through.

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
BRIGHT_PAIRS = ("red", "yellow", "green", "cyan", "blue", "magenta")

# Foreground/background pairs the stock templates compose on surfaces other
# than `background`. Only pairs a shipped template actually writes are here:
# a surface nothing draws text on is a panel colour, not a text surface, and
# gating it would force the palette darker than the design needs.
SURFACE_PAIRS = (
    ("hermes status bar: text", "foreground", "dark_background"),
    ("hermes status bar: dim", "dark_foreground", "dark_background"),
    ("hermes status bar: strong", "accent", "dark_background"),
    ("t3code sidebar: text", "foreground", "dark_background"),
    ("helix focus row: text", "foreground", "lighter_background"),
    ("btop selected row: text", "accent", "selection"),
)


def srgb_to_linear(channel: float) -> float:
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def is_hex(value: object) -> bool:
    return isinstance(value, str) and bool(re.fullmatch(r"#[0-9a-fA-F]{6}", value))


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


def shell_pairs(theme_dir: Path) -> list[tuple[str, str, str, float]]:
    """Card pairs held as literals in the theme's section overrides.

    These are the colours a dark variant has to restate, and the ones no
    computed check would otherwise see: `text` on `background`, and
    `selected-text` on the `selected-background` block.
    """
    pairs: list[tuple[str, str, str, float]] = []
    for path in sorted(theme_dir.glob("shell.*.toml")):
        if path.name == "shell.toml":
            continue
        section_name = path.name[len("shell."):-len(".toml")]
        section = tomllib.loads(path.read_text()).get(section_name)
        if not isinstance(section, dict):
            continue
        text, card = section.get("text"), section.get("background")
        if is_hex(text) and is_hex(card):
            pairs.append((f"{section_name}: text on card", text, card, 7.0))
        sel_text = section.get("selected-text")
        sel_card = section.get("selected-background")
        if is_hex(sel_text) and is_hex(sel_card):
            pairs.append(
                (f"{section_name}: selected text on block", sel_text, sel_card, 7.0)
            )
    return pairs


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
    checks.extend(shell_pairs(theme_dir))
    for label, fg, against in SURFACE_PAIRS:
        checks.append((label, fg, colours.get(against, background), 4.5))

    failures: list[str] = []
    width = max(len(label) for label, *_ in checks)
    for label, key, against, floor in checks:
        if key not in colours and not is_hex(key):
            failures.append(f"{label}: missing from colors.toml")
            continue
        ratio = contrast(colours.get(key, key), against)
        verdict = "ok" if ratio >= floor else "FAIL"
        print(
            f"{label:<{width}}  {colours.get(key, key):<8} on {against:<8} "
            f"{ratio:5.2f}:1  floor {floor:.1f}  {verdict}"
        )
        if verdict == "FAIL":
            failures.append(f"{label}: {ratio:.2f}:1 < {floor:.1f}:1")

    print()
    for hue in BRIGHT_PAIRS:
        bright = colours.get(f"bright_{hue}")
        if not is_hex(bright) or not is_hex(colours.get(hue)):
            continue
        base_luma, bright_luma = luminance(colours[hue]), luminance(bright)
        verdict = "ok" if bright_luma > base_luma else "FAIL"
        print(
            f"bright_{hue:<14} {bright} L={bright_luma:.4f} vs {colours[hue]} "
            f"L={base_luma:.4f}  {verdict}"
        )
        if verdict == "FAIL":
            failures.append(
                f"bright_{hue}: L={bright_luma:.4f} is not lighter than "
                f"{colours[hue]} L={base_luma:.4f}"
            )

    if failures:
        print(f"\nUnreadable on {background}:", file=sys.stderr)
        for line in failures:
            print(f"  - {line}", file=sys.stderr)
        return 1
    print("\nAll colours clear their contrast floors.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
