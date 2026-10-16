<h1 align="center">omarchy-theme-endfield</h1>

<p align="center">《明日方舟：终末地》设计语言的 Omarchy 主题</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-10b981?style=flat-square" alt="MIT license"></a>
  <img src="https://img.shields.io/badge/Omarchy-4.0.4-4d6bfe?style=flat-square" alt="Omarchy 4.0.4">
  <img src="https://img.shields.io/badge/%E9%85%8D%E8%89%B2-%E5%AE%9E%E6%B5%8B%E5%8F%96%E8%89%B2-ffd400?style=flat-square" alt="配色为实测取色">
</p>

<p align="center">
  <a href="#快速安装">快速安装</a> ·
  <a href="#配色">配色</a> ·
  <a href="#设计规矩">设计规矩</a> ·
  <a href="#深色变体">深色变体</a> ·
  <a href="#视频动态壁纸">动态壁纸</a> ·
  <a href="#闸门">闸门</a> ·
  <a href="ASSETS.md">素材出处</a>
</p>

纸白、墨黑、一格信号黄、硬 2px 描边、直角 —— 照官网 <https://endfield.hypergryph.com>
和游戏自己的面板怎么画，就怎么画。

**配色全部是量出来的，不是选的。** `colors.toml` 里每个值都能追到出处：官网 CSS 的
字面 hex 计数、17 张游戏内 UI 存档的取色、第三方 wiki 的 `:root`、社区视频抽帧。
来源、次数、每个值扮演什么角色都记在 [`ASSETS.md`](ASSETS.md)。

![预览](preview.png)

## 快速安装

需要 Omarchy 4.x（本主题在 4.0.4 上验证）。

```bash
omarchy theme install https://github.com/CARVIN94/omarchy-theme-endfield
omarchy theme set theme-endfield
```

**安装出来的主题名是 `theme-endfield`，不是 `endfield`。** `omarchy theme install`
从仓库名推主题名：去掉开头的 `omarchy-`、结尾的 `-theme`，`omarchy-theme-endfield`
剩下的就是 `theme-endfield`。想要短名字，装完把目录改个名再 set —— 自己手写的主题目录
不受"从 git 克隆来的主题"那套安全名单限制：

```bash
mv ~/.config/omarchy/themes/theme-endfield ~/.config/omarchy/themes/endfield
omarchy theme set endfield
```

> 本地改着玩：直接从 checkout 安装，改完重跑 set 即可。
>
> ```bash
> omarchy theme install /path/to/omarchy-theme-endfield
> omarchy theme set theme-endfield
> ```

## 主题包含什么

| 文件 | 作用 |
| --- | --- |
| `colors.toml` | 整套配色。Omarchy 由它渲染 Alacritty、foot、Ghostty、kitty、btop、helix、Neovim、tmux、VS Code、Chromium、Obsidian、Claude 和 shell |
| `shell.menu.toml`、`shell.launcher.toml`、`shell.popups.toml`、`shell.bar.toml` | 段覆盖，合并进生成的 `shell.toml`；只钉住改动的几个段，其余继续跟随官方模板 |
| `backgrounds/` | 两张 wiki 模块卡片式的等高线背景（冷黑 `#111827` / 纸白），以及纯色兜底 `omarchy.png` |
| `icons.theme`、`keyboard.rgb`、`chromium.theme` | Yaru-yellow 图标、信号黄键盘灯、纸白 Chromium 边框 |
| `preview.png` | 主题切换器的缩略图 |
| `extras/endfield-video-wallpaper` | 可选的视频壁纸启动脚本，见[视频动态壁纸](#视频动态壁纸) |

**故意不带 `.lua`、终端配置和 `vscode.json`。** Omarchy 会拒绝 stage 从 git 仓库
克隆来的主题里的这些文件（它们会执行代码或拉起程序），因为这些配置本来就会由
`colors.toml` 经官方模板生成。这里只提供颜色。

## 配色

| Token | 值 | 角色 |
| --- | --- | --- |
| `background` | `#F6F5EF` | 纸 —— 官网的主导底色（首页 207 万像素里占 110 万） |
| `foreground` | `#191919` | 墨 —— 正文与斜纹块填充（官网 CSS 出现 85 次） |
| `selection` | `#FFFA00` | 信号黄，也是选中行的底色（官网 56 次） |
| `accent` | `#7D6B00` | 信号黄压暗版，为了在纸白上可读 |
| `cyan` | `#0B6E62` | 薄荷信号色压暗版 |
| `magenta` | `#A3107F` | 品红信号色压暗版 |
| `blue` | `#35598F` | 主视觉上的技术蓝 |

官网从没用过的色（终端总得有橙、绿、棕）由实测信号色按同一色相压暗派生，
`check-contrast.py` 会在任何一个掉到 WCAG 底线以下时变红。

## 设计规矩

规矩来自游戏自己的界面，不来自通用审美：

- 菜单/启动器的选中行是**信号黄底 + 墨字**，不是背景色的一个淡淡染色。
- 面板用硬 **2px 墨色描边**，不是发丝线。
- 直角。shell 的圆角镜像 Hyprland 的 `decoration:rounding`，所以"直角"就是把它设为 `0`。
- 红色只用于警示与活动强调，取值 `#D72F3B`（游戏实测），按落点底色压暗。

## 深色变体

`variants/dark/colors.toml` 是这套美学的另一半：游戏面板本身。底色与青绿取自
第三方 wiki（fz.wiki，见 [`ASSETS.md`](ASSETS.md)）的读数 —— 冷蓝黑 `#111827`
配全息青 `#00C7BD`，官网的薄荷 `#00FFA2` 退到 `bright_cyan` 保留。

它是变体、不是第二个主题：覆盖掉主题里的 `colors.toml` 再 set 即可。

```bash
cp variants/dark/colors.toml ~/.config/omarchy/themes/theme-endfield/colors.toml
omarchy theme set theme-endfield
```

## 视频动态壁纸

Omarchy 自己的背景渲染器只会画静态图：`Background.qml` 用的是 QML `Image`，
把 current-background 指向 `.mp4` 什么都不会显示。视频要另找一个 layer-shell
播放器 —— `mpvpaper` 就够了，本主题只需要不挡它的路：它画在 `background` 层，
和 Omarchy 背景服务同一层，同层内后创建的在上面；用 `hyprctl layers` 可以验证
（期望看到 `... background: omarchy-background, mpvpaper`）。

官方仓库没有这个包，但可以**全程用户级**编译，不碰 pacman：

```bash
uv tool install meson ninja
git clone --depth 1 https://github.com/GhostNaN/mpvpaper
cd mpvpaper && meson setup build --prefix="$HOME/.local" && ninja -C build install
```

参数里最关键的是 `-p -a MAX`：全屏或最大化窗口盖住壁纸时自动暂停 mpv，
你在干活的时候它不烧 GPU。

```bash
mpvpaper -p -a MAX -o "no-audio loop hwdec=nvdec panscan=1.0" '*' /path/to/video.mp4
```

### 视频放哪、怎么换

本仓库带一份可直接用的启动脚本，装到用户级 bin：

```bash
install -Dm755 extras/endfield-video-wallpaper ~/.local/bin/endfield-video-wallpaper
```

它只读一个目录：

```bash
~/.local/share/endfield-wallpaper/      # 视频都放这（mp4/webm/mkv/mov，文件名随意）
```

换视频就是**把文件丢进目录**：一个 → `loop` 循环播它；多个 → 自动写一份
`.endfield-playlist.m3u`，`loop-playlist shuffle` 随机轮播。改完不用重登，
重启那一个进程就行：

```bash
pkill -x mpvpaper && ~/.local/bin/endfield-video-wallpaper &
```

（必须 `-x`：`pkill -f mpvpaper` 会把执行这条命令的 shell 自己也匹上，连它一起杀。）

### 先量视频宽度

Pascal 及更老的 NVDEC 拒绝宽度超过 **4096** 的 H.264。4302×1920 的素材会静默回退软解，
4K60 掉成幻灯片。直接问解码器：

```bash
mpv --no-config --no-audio --vo=null --hwdec=nvdec -v video.mp4 2>&1 | grep 'Failed setup for format cuda'
```

**没有输出就是没问题。** 有输出就重编到 3840 宽，同一个文件就能 60fps 零丢帧：

```bash
ffmpeg -i wide.mp4 -vf "scale=3840:-2:flags=lanczos" \
  -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -movflags +faststart video.mp4
```

随会话启动：`~/.config/hypr/autostart.lua` 加一行
`o.launch_on_start("endfield-video-wallpaper")`。不想跑视频的人，
`omarchy theme bg next` 照旧切静态背景。

## 闸门

每个前景色都必须在自己那套底色上可读。脚本读 `colors.toml`，低于 WCAG 底线就报错
（正文 7:1，次级文字与终端色 4.5:1）：

```bash
uv run check-contrast.py                 # 出厂纸白主题
uv run check-contrast.py variants/dark   # 深色变体
```

## 素材与出处

配色、背景、证据链（含每个 hex 的出现次数与角色）都在 [`ASSETS.md`](ASSETS.md)。
一句话版：**仓库里没有任何游戏美术资源** —— 两张背景和兜底色都是
`make-backgrounds.sh` 自己生成的，所以配置、脚本、图全部 MIT。
想把官方图当桌面，把自己的图片丢进 `~/.config/omarchy/backgrounds/theme-endfield/`，
`omarchy theme bg next` 会认。

## 致谢

- Harry Huang《[终末地 UI 设计分析](https://blog.harryh.cn/Design/UI-Philosophy-Of-Endfield/)》（CC BY-NC-SA 4.0）—— 强调色块与克制圆角两条规矩来自这篇。
- <https://www.fz.wiki/wiki/武器> —— 深色变体的冷底与全息青、以及"平面场 + 极淡等高线 + 一个 `//` 标记"的背景做法参照了它。
- B 站 UI 存档（[新版本导览](https://www.bilibili.com/opus/1256332716420366418)、[挽弓试炼](https://www.bilibili.com/opus/1251580820439695369)）与[交互拆解](https://www.bilibili.com/opus/1053380062703779875) —— 面板底色、游戏红、加载页黄都从这些截图取色。

## 许可证

MIT，见 [`LICENSE`](LICENSE)。

## 免责声明

《明日方舟：终末地》及其美术资源版权归鹰角网络（HYPERGRYPH）所有。这是非官方粉丝主题，
与鹰角无任何关联。
