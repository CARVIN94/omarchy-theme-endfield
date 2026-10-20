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

Neither pattern ships in this theme, and neither can: Omarchy themes contribute
colours, and a `colors.toml` has no way to paint a hatch or a three-stop band.
What travels instead is the *reading* of them — signal colour as a filled block
with ink on it (the selected row), and a hard ink rule rather than a hairline
(the cards). If you are looking for the stripes in the theme directory, they
are not there by design.

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
the sampled red is the hue both palettes shade from: `#A8241A` on paper and
`#F0454F` on the deep field are that hue moved until it clears 4.5:1 on its own
surface, not a warmer orange. The opus
is an article (`cv41270760`); its own body sits behind Bilibili's risk control
(the article endpoint answers `-352`), so the readable part is the opus summary,
which names the traits the theme takes literally: 现代主义 / 极简主义, 大面积留白,
基本几何图形（圆方三角）, 扁平, 层级规划清晰, 少量颜色. **Paper dialogs over an ink
field** is the reading behind `shell.menu.toml`'s ink scrim — the theme dims with
ink instead of washing the desktop towards paper.

**The third-party wiki** at <https://www.fz.wiki/wiki/武器>, which the theme
owner pointed at as a good reading of the look. Its Tailwind theme keeps the
site's own signals — `#FFFA00` for yellow and `#00FFA2` for mint — and adds the
holographic mint `#00C7BD` / `#009E96` / `#33E0D8` on deep fields `#111827` /
`#181818` under paper `#F2F1EF`. Counting the hex values in its stylesheet
bundle (`/_next/static/chunks/2iorhwvje_rbj.css`, 341 KB) puts that split in
numbers: `#111827` ×16, `#F2F1EF` ×10, `#181818` ×8, `#F2CC00` ×8, `#FFFA00` ×6,
`#00FFA2` ×5, `#00C7BD` ×5. It is the same split this theme makes: paper for the
interface, blue-black plus holographic cyan for telemetry — and both ends follow
it: `variants/dark/colors.toml` takes its field and its cyan from here. Values
come from its `:root` block, its stylesheet hex counts and its `/deco/` and
`icon_card/` assets; no artwork from that site is redistributed here.

The same page carries an accent switcher whose presets are the wiki's own
reading of the game's signals. Each preset is eight values — `a`/`as`/`af`/`ag`
(accent, strong, faint, glow) for the light field and `da`/`das`/`daf`/`dag` for
the dark one, plus `fg` for the text that sits *on* the accent:

| Preset | Light `a` / `as` / `af` / `ag` | Dark `da` / `das` / `daf` / `dag` | `fg` |
| --- | --- | --- | --- |
| Endfield 黄 | `#f2cc00` `#d9ad00` `#fff1a6` `#ffd84a` | `#d8bf00` `#b99b00` `#272302` `#ecd548` | `#111827` |
| 赛博青 | `#00c7bd` `#009e96` `#b3f0ec` `#33e0d8` | `#00c7bd` `#009e96` `#052f2e` `#33e0d8` | `#111827` |
| 暗焰红 | `#ef4444` `#dc2626` `#fecaca` `#f87171` | `#f87171` `#ef4444` `#2a0a0a` … | `#ffffff` |

Two things in that table are worth keeping. First, the wiki's *own* name for its
amber is **"Endfield 黄"**: the same yellow the official site spends as
`#FFFA00`, read one step warmer, with `#111827` — the deep field — as the ink on
it. That is where the paper palette's `bright_yellow` `#8A6A00` is shaded from
(the `d9ad00` strong amber, darkened until it clears 4.5:1 on paper white).
Second, every preset pairs its accent with the *field* as the foreground, never
with white: the accent block carries the background colour as its ink, which is
the rule `shell.menu.toml` follows with `selected-text`.

**The community footage** (`BV19q3G6REyu`, `BV1PUdpBLETP`) — frame sampling put
signal yellow `#FBFA0D` first by area, then rust `#9B8570`, deep blue-black
`#2B4D69` / `#172733` / `#05080B`, mint `#8CB4B3` / `#75AFAA` and cool white
`#E9E8E5`. The blue belongs to the scenery; the panels read as the neutral dark
above, which is what `variants/dark/colors.toml` uses.

Colours the site never uses (a terminal needs an orange, a green, a brown)
are shaded from a measured signal so they stay legible on paper white, and
`check-contrast.py` fails if any of them drops below its WCAG floor — or if a
`bright_*` value comes out darker than the colour it brightens.

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

## `preview.png`

`omarchy-theme-switcher` looks for `preview.png` (then `.jpg`, `.jpeg`, `.webp`,
`.gif`, `.bmp`) at the top level of every theme directory and caches a scaled
copy, so this file is read by the switcher — not only by the README.

It is generated by `make-preview.sh` from `colors.toml`: one paper field, the
palette as twelve labelled swatches in two rows, the hex under each name, and a
`//` footer. Two rules it follows, both the theme's own:

* a swatch's label is the **field colour on a dark swatch and the ink colour on
  a light one** — the same "text on a block" rule the menu's selected row
  follows (`shell.menu.toml`), decided here by WCAG relative luminance;
* every swatch carries a 1px rule of its own label colour at 40%, because the
  `background` swatch is the field itself and would otherwise be invisible.

It used to be the official version key visual with a strip of swatches beneath
it. The artwork is gone with the rest of the game art (this repository ships
none), so the whole card is generated here and the PNG is a few dozen KB.
