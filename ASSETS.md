# Assets and where the colours come from

## Palette provenance

Every value in `colors.toml` was measured, not guessed. The sources:

**The official site** — <https://endfield.hypergryph.com> (Next.js build
`official-v4`). Its CSS ships literal hex values rather than custom properties,
so the roles below come from counting how each value is used
(`color`, `background-color`, `background-image`, `border`) across the
stylesheet bundles it loads:

| Value | Uses | Role on the site |
| --- | --- | --- |
| `#191919` | 85 | Ink: body copy, and the fill of the 45° hatch blocks |
| `#FFFA00` | 56 | Signal yellow: CTA backgrounds, highlight text |
| `#F6F5EF` | — | Paper: the dominant field, sampled from the landing screenshot (1.1 M of its 2.07 M pixels) |
| `#D9D9D9` `#BFBFBF` `#B3B3B3` `#A6A6A6` `#7E7E7E` | 20+ | Grey ramp for secondary copy and rules |
| `#2E2E2E` `#3C3C3C` `#424242` `#414348` `#35373C` | 6+ | Dark surface steps and borders |
| `#00FFA2` `#FF00F0` `#FF1AAC` | 9 / 6 | The mint/magenta signal pair, used in gradient bands |
| `#617BA6` | — | Technical blue (drawing marks on the key visual) |

Its two recurring idioms are the ones this theme copies as *behaviour* rather
than as wallpaper:

* `repeating-linear-gradient(-45deg, #1f1f22, #1f1f22 3px, transparent 0, transparent 6px)`
  — the warning hatch. The in-game archive below shows the same stripe filled
  yellow behind call-to-action blocks.
* `linear-gradient(90deg, #ff00f0 11.25rem, #fffa00 0, #fffa00 22.5625rem, #00ffa2 0)`
  — the magenta/yellow/mint signal band.

**The in-game UI archives** (Bilibili opus `1256332716420366418`,「新版本导览」,
and `1251580820439695369`,「挽弓试炼」) — sampling the seventeen archived
screenshots puts the panel fields at neutral near-black `#1E1E19` / `#232323` /
`#191A1A` / `#202124` and the type at warm off-white `#ECEAEB` / `#F3F2E8`,
with signal yellow reserved for filled blocks (the selected navigation tab,
the confirm button). The same archive shows the 45° hatch used as a yellow
warning block, exactly as the site styles it.

**The colour and interaction breakdowns** (Bilibili opus `1012354732615794692`,
「浅谈终末地的设计-vol.01色彩运用」, and `1053380062703779875`,「《终末地》交互拆解」)
— the first is built around one sentence repeated over a yellow field,
「这是一个黄色的背景和一段黑色的文字」, which is exactly the accent-block rule the
selected row follows. The second samples game red `#D72F3B` on `#1D1819`, the
dark loading screen at `#202020` with yellow `#FCFE34`, and paper dialogs at
`#EDEBEB` over ink `#1B1918`. That near-black is what the dark variant uses, and
it is why its `red` is a shaded `#D72F3B` rather than a warmer orange.

**The third-party wiki** at <https://www.fz.wiki/wiki/武器>, which the theme
owner pointed at as a good reading of the look. Its Tailwind theme keeps the
site's own signals — `#FFFA00` for yellow and `#00FFA2` for mint — and adds the
holographic mint `#00C7BD` / `#009E96` / `#33E0D8` on deep fields `#111827` /
`#181818` under paper `#F2F1EF`. It is the same split this theme makes: paper for
the interface, blue-black plus holographic cyan for telemetry — and both ends
follow it: `variants/dark/colors.toml` takes its field and its cyan from here.
Values come from its `:root` block, its stylesheet hex counts and its `/deco/`
and `icon_card/` assets; no artwork from that site is redistributed here.

**The community footage** (`BV19q3G6REyu`, `BV1PUdpBLETP`) — frame sampling put
signal yellow `#FBFA0D` first by area, then rust `#9B8570`, deep blue-black
`#2B4D69` / `#172733` / `#05080B`, mint `#8CB4B3` / `#75AFAA` and cool white
`#E9E8E5`. The blue belongs to the scenery; the panels read as the neutral dark
above, which is what `variants/dark/colors.toml` uses.

Colours the site never uses (a terminal needs an orange, a green, a brown)
are shaded from a measured signal so they stay legible on paper white, and
`check-contrast.py` fails if any of them drops below its WCAG floor.

## Reference reading

The design notes this theme was built against, recorded so the reasoning stays
auditable:

* Harry Huang, *《终末地》UI 设计分析* —
  <https://blog.harryh.cn/Design/UI-Philosophy-Of-Endfield/> (CC BY-NC-SA 4.0).
  It names the traits implemented here: the **accent block** (a high-contrast
  fill marking the selected tab — the signal-yellow selected row) and
  **restrained corner radius**. Radius is the one trait a theme cannot set: the
  shell mirrors Hyprland's `decoration:rounding`, so square corners come from
  that setting.
* The Bilibili breakdowns above — the colour note and the interaction teardown —
  used as palette evidence for the dark variant and for the game red.

## Files in `backgrounds/`

| File | Origin | Licence |
| --- | --- | --- |
| `0-deep.png` | Flat `#111827` — the wiki's deep field, 3840×2160 | MIT, this repo |
| `1-paper.png` | Flat `#EDEBE1` — the site's secondary paper tone, 3840×2160 | MIT, this repo |
| `omarchy.png` | Flat `#F6F5EF` — the fallback Omarchy loads when a theme has no chosen background | MIT, this repo |

Nothing here ships game artwork, and none of it is drawn: each file is a single
colour, reproducible in one line.

```bash
magick -size 3840x2160 xc:'#111827' -define png:exclude-chunk=time,date,text backgrounds/0-deep.png
```

If you want texture on your desktop, point `omarchy theme bg` at your own
pictures — `~/.config/omarchy/backgrounds/<theme>/` takes them.

`omarchy.png` is not a wallpaper anyone should see: it is the 1 KB solid block
every stock theme carries so the background layer never has to open a file that
is not there. Drop your own images into `~/.config/omarchy/backgrounds/<theme>/`
instead.
