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
  * `chromium.theme` is mirrored, since it is one palette value read straight
    from the theme directory. `icons.theme` and `keyboard.rgb` are not: they
    carry the signal yellow both variants share;
  * the variant directory holds no file the theme itself does not ship.

Exit code 0 means every variant is complete; 1 lists what is missing.
Run: uv run check-variant.py
"""

from __future__ import annotations

import sys
import tomllib
from pathlib import Path

MIRRORED = ("chromium.theme",)


def section_keys(path: Path) -> set[str]:
    section_name = path.name[len("shell."):-len(".toml")]
    section = tomllib.loads(path.read_text()).get(section_name)
    return set(section) if isinstance(section, dict) else set()


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
