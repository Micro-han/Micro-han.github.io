# 主页风格 C — 纸色底 · 蓝链 · 衬线标题

日期：2026-09-12
对象：`index.html` 视觉层（GitHub Pages 单文件站点）

## 概述

在现有信息架构上，把 8 月的全灰极简换成方案 **C**：纸色底、蓝色可点链接、衬线姓名与论文标题、正常大小的章节标题、轻卡片。不改文案、章节顺序、折叠逻辑、SEO 与图片策略。

## 目标

- 浅色模式不再是冷白 + 全灰链接；链接一眼可辨。
- 章节标题按普通标题排，不再用 11px 全大写灰字。
- 深色模式改成偏暖的深底，与纸色浅色配套。
- 桌面 / 移动、浅色 / 深色、lightbox、折叠、导航高亮行为与现在一致。

## 非目标

不新增中文站、Blog、引用数、新章节；不改论文/经历/新闻正文；不引入构建系统。

## 技术约束

- 样式与脚本仍内联在 `index.html`。
- 可多请求一种 Google Font（Source Serif 4），与现有 Inter 合并为一条 stylesheet。
- 深色模式仍用 `html.dark` + 首帧内联脚本，避免白闪。

## 视觉系统

### 浅色

| Token | 值 | 用途 |
|-------|-----|------|
| `--bg` | `#fbfaf6` | 页面底 |
| `--bg-soft` | `#f4f1ea` | 卡片 hover、配图衬底 |
| `--panel` | `#f4f1ea` | 论文配图面板 |
| `--card` | `#ffffff` | 论文 / Misc 卡片 |
| `--text` | `#1c1917` | 正文与标题 |
| `--text-sec` | `#44403c` | 次级文字 |
| `--text-muted` | `#78716c` | 日期、作者、年份 |
| `--border` | `#e7e4dc` | 分隔与卡片边 |
| `--border-strong` | `#d6d1c7` | 稍强调的边 |
| `--link` | `#1d4ed8` | 正文链接、venue、当前导航 |
| `--link-hover` | `#1e40af` | 链接悬停 |
| `--accent` | `#1d4ed8` | 焦点环、当前项指示 |

### 深色

| Token | 值 |
|-------|-----|
| `--bg` | `#161412` |
| `--bg-soft` | `#1f1c19` |
| `--panel` | `#221f1b` |
| `--card` | `#1c1a17` |
| `--text` | `#f5f0e8` |
| `--text-sec` | `#c4b8ac` |
| `--text-muted` | `#8a8278` |
| `--border` | `#2e2a24` |
| `--border-strong` | `#3f3830` |
| `--link` | `#93c5fd` |
| `--link-hover` | `#bfdbfe` |
| `--accent` | `#93c5fd` |

`theme-color` 分别改为 `#fbfaf6` / `#161412`。

### 字体

- 正文 / 导航：Inter（已有）。
- 姓名、论文与项目标题：`Source Serif 4`，回退 `Georgia, 'Times New Roman', 'Songti SC', serif`。
- 中文名「颜小涵」单独用 Inter / 系统黑体，避免衬线缺字。
- 章节 `h2`：16px、字重 650、`letter-spacing: -0.02em`、颜色 `--text`，底部分隔线保留，取消 uppercase 与 0.17em tracking。

### 链接

- 默认 `a { color: var(--link) }`。悬停用 `--link-hover`。
- 导航、底栏、品牌名仍用 muted / 正文色，不做成蓝链；当前项用 `--link` 下划线（桌面）或蓝色（底栏）。
- 配图 `a.paper-fig` 保持中性色，避免整块图变成蓝链。
- 取消正文链接的灰线下划线，改以颜色区分。

### 组件

- 论文 / 项目卡片：`--card` 底、1px `--border`、圆角 10px；hover 只改背景为 `--bg-soft`。
- Venue：蓝描边、蓝色字、圆角 4px，不再用灰框灰字。
- Misc 卡片同样 10px 圆角与暖边。
- 头像圆角 12px，不加厚阴影。
- 顶栏：纸色底，可加轻微 `backdrop-filter`；当前项蓝下划线。

## 验证

1. 本地起静态服务，1280 / 768 / 375 宽度看布局。
2. 浅色与深色各看一遍：hero、论文卡片、新闻链接、导航高亮、折叠。
3. 点开配图 lightbox，Esc 关闭。
4. 确认文案与 `src` / `href` 未改。
