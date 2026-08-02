# 主页优化设计 — 黑白极简 · 性能与 SEO · 仓库清理

日期：2026-08-02
对象：`https://micro-han.github.io/`（单文件静态站点，GitHub Pages）

## 概述

上一轮 redesign（`2026-05-23-homepage-redesign-design.md`）已经把站点重构成干净的单文件架构，信息架构基本合理。本轮不动信息架构，集中解决四件事：

1. **视觉**：把蓝色强调 + 卡片阴影换成灰阶 + 1px 细线的黑白极简语言。
2. **性能**：首屏 2.5 MB 以上的图片负担降到 60 KB 量级，消除布局抖动。
3. **SEO 与可访问性**：补齐标题层级、社交卡片、结构化数据，修复深色模式和导航高亮。
4. **仓库清理**：删除模板残留、重复目录和一份不属于站主的隐私文件。

### 目标

- 首屏（视口内）图片传输量 ≤ 100 KB，全站图片总量 ≤ 650 KB（含 185 KB 的 RE0 矢量图）。
- 页面具备 h1 → h2 的完整标题大纲。
- 深色模式跟随系统偏好，且首次加载无白闪。
- 导航（桌面顶栏与移动底部 tab）随滚动高亮当前章节。
- 仓库内不存在未被引用的二进制文件。

### 非目标

本轮不做：中文版页面、Google Scholar 引用数、Blog/Notes 入口、404 页面。这些在讨论中明确排除，理由是中文版需要长期同步两套内容，引用数没有公开 API 只能手写且会过期。

## 技术约束

- 本机没有 Node、Python、ImageMagick、gh CLI，只有 git 和 PowerShell。因此不引入任何构建系统，图片处理用 PowerShell 的 `System.Drawing`，也因此不生成 WebP（`System.Drawing` 无 WebP 编码器）。
- 单文件架构保留：所有样式内联在 `index.html` 的 `<style>` 里，所有脚本内联在 `<script>` 里，不引入外部依赖。
- 本地预览用 `.brainstorm/serve.ps1`（PowerShell `HttpListener` 静态服务器，已在 `.gitignore` 中），因为浏览器工具不允许打开 `file://`。

## 视觉系统

### 配色

浅色模式（`:root`）：

| Token | 值 | 用途 |
|-------|-----|------|
| `--bg` | `#ffffff` | 页面底色 |
| `--bg-soft` | `#fafafa` | 卡片 hover 底色 |
| `--text` | `#111111` | 正文与标题 |
| `--text-sec` | `#555555` | 次级文字、链接 |
| `--text-muted` | `#949494` | 作者、日期、章节 label |
| `--border` | `#e9e9e9` | 卡片与分隔线 |
| `--border-strong` | `#d6d6d6` | 链接下划线、venue 边框 |
| `--accent` | `#111111` | 导航高亮、当前章节指示 |

深色模式（`html.dark`，同时作为 `prefers-color-scheme: dark` 的默认）：

| Token | 值 |
|-------|-----|
| `--bg` | `#0d0d0f` |
| `--bg-soft` | `#16161a` |
| `--text` | `#ededf0` |
| `--text-sec` | `#a6a6ad` |
| `--text-muted` | `#6c6c74` |
| `--border` | `#232328` |
| `--border-strong` | `#34343c` |
| `--accent` | `#ededf0` |

原来的 `--venue-bg`、`--venue-text`、`--card-shadow`、`--card-shadow-hover`、`--photo-shadow`、`--timeline-dot` 全部移除。链接不再用颜色区分，改用 1px 下划线（`border-bottom: 1px solid var(--border-strong)`）。

### 字体

- 正文：`Inter`，回退链 `'Inter', system-ui, -apple-system, 'Noto Sans SC', sans-serif`。
- 姓名与论文标题：衬线，`Georgia, 'Times New Roman', 'Songti SC', serif`。不引入新的网络字体。
- 章节标题：10px、`font-weight: 700`、`text-transform: uppercase`、`letter-spacing: 0.17em`、颜色 `--text-muted`、下方 1px 边框。
- 正文 15px / `line-height: 1.75`；姓名 28px；论文标题 15px；作者与日期 13px。

### 其他

- 圆角统一 6px（头像 14px）。
- 全站无 `box-shadow`，无 `transform` 动画。hover 只改背景色，`transition: background-color 0.2s ease`。
- 章节间距 32px，卡片内边距 16px。

## 页面结构

顺序保持不变，但把原来混在 hero 里的时间线拆成独立章节：

```
Bio（头像、姓名、职位、链接、自我介绍）
Education & Experience
Publications
Projects
Awards
News
Misc
Footer
```

所有章节标题使用 `<h2>`，页面唯一的 `<h1>` 是姓名。Misc 内的小标题用 `<h3>`。

## 内容变更

### 职位与时间线

- Hero 副标题：`Algorithm Engineer @ AgiBot` → `Large Model Algorithm Engineer @ AgiBot`。
- Experience：AgiBot 一条职位改为 `Large Model Algorithm Engineer`，时间改为 `2026 – Present`。
- Experience：NIO 一条职位改为 `Large Model Algorithm Engineer`，时间由 `Apr 2024 – Mar 2025` 改为 `2024 – 2025`。
- Experience：AIR, Tsinghua University 的 `Research Intern / Dec 2023 – Apr 2024` 保持不变。
- Education 两条保持不变。

时间线一律采用年份粒度（AIR 那条除外，它已公开且是实习），原因是站主有保密协议，不披露入职与离职的具体月份。

### Bio 自我介绍

新增一段三句话的介绍，替代现在只有一行的 "Research interests"：

> I am a large model algorithm engineer at **AgiBot**, working on vision-language-action models for real-world robotic manipulation. Before that I received my M.S. from Tongji University, where I worked on 3D scene understanding and zero-shot instance segmentation. My interests are **multimodal large models**, **3D computer vision** and **reinforcement learning** — feel free to [drop me an email](mailto:yxhop666@gmail.com) if we share any.

### Publications

- 按年份分组，年份用小号 muted 标签（`2026` / `2025` / `2024`）。
- 默认展示前 3 篇：ALOE、HOLO、RE0。
- 其余 4 篇（SGGS、AttenPoint、GreedyAgent、ASGMVLP）包在折叠容器里，按钮文案 `Show 4 more` / `Show less`，与 News 的折叠交互一致。
- venue 徽章由实心药丸改成 1px 边框的方角标签，颜色用 `--text-sec`。
- `* indicates equal contribution` 脚注保留。

### News

- 删除 `[04/2024] I joined NIO for an internship!` 这一条（涉及职业时间线，与保密约定不符）。
- 新增 `[02/2026] Our paper ALOE is released on arXiv.`，链接指向 `https://arxiv.org/abs/2602.12691`。该月份由 arXiv 编号 `2602.12691` 推得。
- 不新增任何 AgiBot 入职条目。
- 其余条目原样保留。变更后共 8 条：默认展示最近 4 条（ALOE、HOLO 录用、硕士毕业、SGGS），其余 4 条（RE0、AttenPoint、ASGMVLP、AIR 实习）折叠，按钮文案 `Show 4 more` / `Show less`。

### Awards / Misc / Footer

- Awards 与 News 由 `.section-card` 卡片改为细线分隔的行列表，日期右对齐、muted。
- Misc 四个卡片改成 1px 边框、无阴影，内容由 `<ul>` 改为一行描述文字。
- Footer 改为 `Last updated Aug 2026 · Built with plain HTML & CSS`。

## 性能

### 图片处理

用 `tools/resize-images.ps1`（新增并提交，方便以后加论文时复用）批量重采样，参数：最大宽度 640px、JPEG 质量 80、双三次插值。原地覆盖，原始文件通过 git 历史可恢复。

PNG 照片类配图转成 JPEG 并相应改扩展名与 HTML 引用：

| 文件 | 现在 | 处理后 |
|------|------|--------|
| `papers/HOLO_WACV2026/holo.jpeg` | 1171 KB | 覆盖，≈ 70 KB |
| `papers/AttenPoint_PRCV2024/PRCV.png` | 643 KB | → `PRCV.jpg`，≈ 60 KB |
| `papers/SGGS_ICASSP2025/sggs1.png` | 594 KB | → `sggs1.jpg`，≈ 60 KB |
| `papers/ASG_MICCAI2024/ASGMVLP.jpg` | 359 KB | 覆盖，≈ 50 KB |
| `papers/ALOE_arXiv2026/aloe.png` | 189 KB | → `aloe.jpg`，≈ 45 KB |
| `papers/GreedyAgent_ICIC2024/ICIC.jpg` | 54 KB | 覆盖，≈ 40 KB |
| `projects/LLM_Kaggle2023/kaggleLLAM.jpg` | 137 KB | 覆盖，≈ 45 KB |
| `projects/eScape_GameJam2023/eScape.png` | 114 KB | → `eScape.jpg`，≈ 40 KB |
| `assets/images/microhan.png` | 439 KB | 保留原图供 `og:image`；另生成 `assets/images/avatar-320.jpg`（320×320，q85，≈ 25 KB）供页面使用 |

`papers/Re0_ICRA2025/segmentation_result.svg`（185 KB）是矢量图，保留不动。

### 加载策略

- 所有论文与项目配图加 `loading="lazy"`、`decoding="async"` 和显式 `width="640" height="427"`（配合 CSS `aspect-ratio` 消除布局抖动）。
- 头像用 `loading="eager"` + `fetchpriority="high"`，尺寸 `width="320" height="320"`。
- 字体链接补 `<link rel="preconnect" href="https://fonts.googleapis.com">` 与 `<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>`，URL 保留 `display=swap`，并把 `system-ui` 放进回退链，使 Google Fonts 不可达时立即用系统字体渲染而非白等。
- Inter 只请求实际用到的字重：400、500、600、700；删除 300，并删除 `Noto Sans SC` 的网络请求（中文只有姓名三个字，系统字体足够）。`'Noto Sans SC'` 仍留在 CSS 回退链里，供本地已安装该字体的访客使用。

## SEO 与可访问性

### head 补充

- `<meta name="description" content="Xiaohan Yan (颜小涵) — large model algorithm engineer at AgiBot, working on vision-language-action models, multimodal large models and 3D computer vision.">`
- `<link rel="canonical" href="https://micro-han.github.io/">`
- Open Graph：`og:type=profile`、`og:title`、`og:description`、`og:url`、`og:image`（指向 `https://micro-han.github.io/assets/images/microhan.png`）、`og:image:alt`。
- Twitter Card：`twitter:card=summary`（用 `summary` 而非 `summary_large_image`，因为头像不是 1.91:1）。
- `<meta name="theme-color">` 两条，分别配 `prefers-color-scheme` 的浅色与深色值。

### 结构化数据

`<script type="application/ld+json">` 内嵌一个 `Person`：`name`、`alternateName`（颜小涵）、`jobTitle`、`worksFor`（AgiBot）、`alumniOf`（Tongji University、Hohai University）、`url`、`image`、`knowsAbout`、`sameAs`（Google Scholar、GitHub、LinkedIn、ORCID）。不为 7 篇论文单独生成 `ScholarlyArticle`，收益低且维护成本高。

### 新增文件

- `robots.txt`：允许全部抓取，声明 sitemap 位置。
- `sitemap.xml`：单条 URL，`lastmod` 2026-08-02。

### 可访问性

- 章节标题改为 `<h2>`，Misc 小标题为 `<h3>`。
- 当前章节的导航项加 `aria-current="location"`。
- 主题切换按钮加 `aria-pressed`，图标 `aria-hidden="true"`。
- 折叠按钮加 `aria-expanded` 与 `aria-controls`。
- 所有 `img` 保留有意义的 `alt`；纯装饰性图标 `alt=""`。
- 补 `:focus-visible` 样式（2px `--accent` 外描边），键盘导航可见。

## 交互

### 深色模式

`<head>` 里内联一小段同步脚本，在首帧渲染前决定主题：读 `localStorage.theme`，若无则读 `window.matchMedia('(prefers-color-scheme: dark)')`，命中深色时给 `<html>` 加 `dark` class。切换按钮写入 `localStorage` 并更新 `aria-pressed`。同时监听 `matchMedia` 的 `change`，仅在用户从未手动切换过（`localStorage` 无值）时跟随系统变化。

### 导航高亮

用一个 `IntersectionObserver` 观察全部 `section`，`rootMargin` 设为 `-45% 0px -50% 0px`，命中的 section id 同时驱动桌面顶栏与移动底部 tab 的高亮 class 和 `aria-current`。这修复了现有代码中 `.tab-bar a.active` 样式已定义但从未被应用的问题。

### 折叠

Publications 与 News 共用一个 `toggleFold(btn)` 函数，切换目标容器的 `hidden` 属性，同步按钮文案与 `aria-expanded`。移除现有的 `toggleNews`。

### 平滑滚动

现有的锚点平滑滚动逻辑保留，但偏移量计算要考虑移动端顶栏已隐藏的情况（现有实现已正确处理，只需在重写时保持）。

## 响应式

断点保持 768px 与 480px。

- **768px 以下**：桌面顶栏隐藏，底部 tab bar 显示；`body` 补 `padding-bottom: 72px`；论文卡片改纵向堆叠、配图 100% 宽 `aspect-ratio: 3/2`；时间线由两列改单列；Misc 网格两列；容器内边距 16px。
- **480px 以下**：姓名 22px；hero 链接 12px 并允许换行；tab bar 只保留图标（隐藏文字标签）。

## 清理清单

删除以下未被 `index.html` 引用的文件：

- `data/` 整个目录（32 个文件，约 8 MB，与 `assets/` 完全重复）
- `stylesheet.css`、`script/functions.js`（Jon Barron 模板残留，页面无引用）
- `assets/doc/Ji_wenbo_Goethe_B2_zertifikat.pdf`、`assets/doc/JI_wenbo_testdaf_zertifikat.pdf`（不属于站主的第三方证书，公开可下载）
- `assets/institution_logo/` 整个目录（10 个文件，新设计不再展示机构 logo）
- `assets/misc/` 整个目录（15 个文件，社交图标已改为文字链接）
- `assets/rewards/ccfcsp.png`、`assets/rewards/ccsp.png`、`assets/rewards/yxh_cv_cn.pdf`（无引用；`rewards_bsc_all.pdf`、`2019EC.png`、`JSCPC.png` 保留，页面有链接）
- `assets/images/microhan.jpg`（无引用，页面用的是 `.png`）

`.gitignore` 增加 `.brainstorm/`，使本地预览产物不进仓库。

## 验证

1. 用 `.brainstorm/serve.ps1` 起本地服务，在 1280px、768px、375px 三个宽度下检查布局，浅色与深色各一遍。
2. 对比处理前后图片体积，确认全站图片总量 ≤ 650 KB，且首屏视口内传输量 ≤ 100 KB。
3. 用浏览器可访问性快照确认 h1 → h2 大纲成立，且每个章节都有对应 `h2`。
4. 滚动全页，确认桌面顶栏与移动 tab 的高亮跟随当前章节。
5. 切换系统深色偏好，确认首次加载无白闪；手动切换后刷新，确认偏好被记住。
6. 确认 Publications 与 News 的折叠展开正常，`aria-expanded` 随之变化。
7. `git status` 确认删除清单已全部执行，且没有仍被引用的文件被误删（全站搜索 `src=` 与 `href=` 逐一核对）。
