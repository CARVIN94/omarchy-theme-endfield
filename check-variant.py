#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Gate: a palette variant is a whole set, not just a colors.toml.

Omarchy copies the theme directory and then *replaces* each generated
`shell.<section>` with the theme's own `shell.<section>.toml`, because such a
file replaces the section body rather than merging into it. So a variant that
ships only `colors.toml` leaves every colour the shipped overrides state as
literals — the bar, the menu card and the Chromium frame — on the old palette,
while the terminals, btop and the window border go dark. That half-swapped
desktop is what this gate exists to catch:

  * every `variants/<name>/` ships a `colors.toml` whose key set matches the
    shipped one;
  * for every `shell.<section>.toml` the theme ships, the variant ships the
    same file with the same key set — no missing key (it would silently inherit
    the shipped literal) and no extra key (the section would lose it);
  * every hex literal in a `shell.<section>.toml` is a value its own
    `colors.toml` defines. Matching key sets alone let the palette and the
    overrides drift apart: change `colors.toml` and leave the old literal in
    the section and the desktop is half-swapped again, with both gates green.
    A section may only name a palette *value*, never invent one;
  * `chromium.theme` is mirrored, since it is one palette value read straight
    from the theme directory, and it must equal that palette's `background`.
    `icons.theme` and `keyboard.rgb` are not: they carry the signal yellow both
    variants share;
  * the variant directory holds no file the theme itself does not ship.

Exit code 0 means every variant is complete; 1 lists what is missing.
Run: uv run check-variant.py
"""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

MIRRORED = ("chromium.theme",)
HEX = re.compile(r"#[0-9a-fA-F]{6}\b")


def section_keys(path: Path) -> set[str]:
    section_name = path.name[len("shell."):-len(".toml")]
    section = tomllib.loads(path.read_text()).get(section_name)
    return set(section) if isinstance(section, dict) else set()


def palette_values(colours_file: Path) -> set[str]:
    """Every colour a palette defines, lowercased for comparison."""
    palette = tomllib.loads(colours_file.read_text())
    return {value.lower() for value in palette.values() if isinstance(value, str)}


def literal_colours(section_file: Path) -> set[str]:
    """Hex literals written straight into a section override."""
    return {match.lower() for match in HEX.findall(section_file.read_text())}


def chromium_colour(path: Path) -> str:
    """`chromium.theme` holds `R,G,B`, which is a palette colour spelled differently."""
    r, g, b = (int(part) for part in path.read_text().strip().split(","))
    return f"#{r:02x}{g:02x}{b:02x}"


def check_literals(name: str, dir: Path, colours_file: Path) -> list[str]:
    """Every hex in a section override must be a value that palette defines."""
    failures: list[str] = []
    if not colours_file.is_file():
        return failures
    known = palette_values(colours_file)
    for section_file in sorted(dir.glob("shell.*.toml")):
        if section_file.name == "shell.toml":
            continue
        for colour in sorted(literal_colours(section_file) - known):
            failures.append(
                f"{name}: {section_file.name} writes {colour.upper()}, which "
                f"{colours_file.name} does not define"
            )
    return failures


def main() -> int:
    theme_dir = Path(__file__).parent
    variants_dir = theme_dir / "variants"
    if not variants_dir.is_dir():
        print("no variants/ directory — nothing to check")
        return 0

    shipped_colours = set(tomllib.loads((theme_dir / "colors.toml").read_text()))
    shipped_sections = {
        path.name: section_keys(path) for path in sorted(theme_dir.glob("shell.*.toml"))
        if path.name != "shell.toml"
    }

    failures: list[str] = []
    failures.extend(check_literals("theme", theme_dir, theme_dir / "colors.toml"))
    shipped_chromium = theme_dir / "chromium.theme"
    if shipped_chromium.is_file():
        expected = chromium_colour(shipped_chromium)
        if expected not in palette_values(theme_dir / "colors.toml"):
            failures.append(
                f"theme: chromium.theme is {expected.upper()}, which colors.toml "
                f"does not define"
            )

    for variant in sorted(p for p in variants_dir.iterdir() if p.is_dir()):
        name = f"variants/{variant.name}"
        colours_file = variant / "colors.toml"
        if not colours_file.is_file():
            failures.append(f"{name}: no colors.toml")
        else:
            keys = set(tomllib.loads(colours_file.read_text()))
            for prefix, missing in (
                ("colours key", shipped_colours - keys),
                ("colours key the theme does not define", keys - shipped_colours),
            ):
                for key in sorted(missing):
                    failures.append(f"{name}: {prefix} {key!r}")

        failures.extend(check_literals(name, variant, colours_file))

        for file_name, shipped_keys in shipped_sections.items():
            candidate = variant / file_name
            if not candidate.is_file():
                failures.append(
                    f"{name}: no {file_name} — the shipped override would keep its "
                    f"{len(shipped_keys)} literal values on the other palette"
                )
                continue
            for key in sorted(shipped_keys ^ section_keys(candidate)):
                failures.append(f"{name}: {file_name} key {key!r} is not in both")

        for file_name in MIRRORED:
            if (theme_dir / file_name).is_file() and not (variant / file_name).is_file():
                failures.append(f"{name}: no {file_name}")
                continue
            candidate = variant / file_name
            if candidate.is_file() and colours_file.is_file():
                expected = chromium_colour(candidate)
                if expected not in palette_values(colours_file):
                    failures.append(
                        f"{name}: {file_name} is {expected.upper()}, which its "
                        f"colors.toml does not define"
                    )

        for path in sorted(variant.iterdir()):
            if path.is_file() and not (theme_dir / path.name).is_file():
                failures.append(f"{name}: {path.name} is not shipped by the theme")

        if not any(failure.startswith(f"{name}:") for failure in failures):
            print(f"{name}: complete ({len(shipped_sections)} section overrides mirrored)")

    if failures:
        print("\nVariant sets are incomplete:", file=sys.stderr)
        for line in failures:
            print(f"  - {line}", file=sys.stderr)
        return 1
    print("\nEvery variant mirrors the shipped theme.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
