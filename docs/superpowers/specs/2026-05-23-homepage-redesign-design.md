# Homepage Redesign — Structured Minimal

## Overview

Redesign Neos Yan's academic homepage with a structured minimal aesthetic (Apple-inspired), improved mobile experience, system-preference dark mode, updated content, and optimized page structure.

## Design Direction

**Structured Minimal**: Retain paper thumbnails at reduced size, ultra-lightweight card borders, subtle gray hierarchy for content layering. Clean typography, generous whitespace, minimal decorative elements.

## Page Structure

**Current:** Bio → News → Publications → Projects → Awards → Misc

**New:** Bio (with integrated timeline) → Publications → Projects → Awards → News → Misc

Rationale: Publications are the most important content for an academic homepage. News is time-sensitive and less critical for first impressions.

## Section-by-Section Design

### 1. Navigation Bar

**Desktop:**
- Sticky top bar, frosted glass effect retained
- Brand text: plain dark/white text (no gradient), font-weight 500
- Links: neutral gray, subtle underline on hover (no background highlight)
- Slim height (~48px)

**Mobile:**
- Fixed bottom tab bar (iOS-style), always visible
- 5 tabs: Bio / Pubs / Projects / Awards / More (News + Misc)
- Icon + label for each tab
- Active tab indicated by accent color

### 2. Hero / Bio Section

- Centered layout retained
- Name: large, bold, pure black/white text (remove gradient effect)
- Subtitle: "Algorithm Engineer @ AgiBot" (updated from NIO)
- Profile photo: slightly smaller (max-width 180px), rounded corners 12px
- Social links: minimal text links instead of icon circles (e.g., "Email · Scholar · GitHub · LinkedIn · ORCID")
- Remove institution logo section entirely

**Education & Experience Timeline:**
- Integrated below the bio text
- Simple vertical timeline with dots and lines
- Entries: AgiBot (current) → NIO (intern) → Tongji (M.S.) → AIR Tsinghua (intern) → Hohai (B.S.)
- Each entry: role/degree, institution, date range, one-line description
- Compact, no cards — just clean typography with a thin left border

### 3. Publications Section

- Section heading: uppercase tracking, small font, thin underline (remove decorative gradient bar)
- Equal contribution note: keep as subtle footnote

**Paper cards:**
- Thumbnail: reduced to ~120px width, 6px border-radius
- Layout: horizontal (thumbnail left, text right) on desktop, vertical stack on mobile
- Card: 1px solid border (#eee light / #222 dark), no shadow, no hover lift
- On hover: very subtle background tint only
- Title: 16px semibold
- Authors: 14px gray, self-name bolded + underlined
- Venue badge: small pill, solid muted color (not gradient)
- Links (paper/code/site): text links with subtle icon, not badge buttons
- Description: 13px muted text, 2 lines max

**New paper to add:**
- ALOE: Action-Level Off-Policy Evaluation for Vision-Language-Action Model Post-Training
- Authors: R Yang, H Wang, C Liu, X Yan, Y Wang, X Du, S Yue, Y Liu, C Zhang, ...
- Venue: arXiv 2026
- Link: https://scholar.google.com.hk/citations?view_op=view_citation&hl=en&user=uKG381EAAAAJ&citation_for_view=uKG381EAAAAJ:qjMakFHDy7sC

### 4. Projects Section

- Same card treatment as Publications (lightweight border, small thumbnail)
- Keep existing 2 projects (Kaggle, GameJam)

### 5. Awards Section

- Simple list with left accent border retained but thinner (2px)
- Remove background color on items — use whitespace for separation
- Date right-aligned in muted text

### 6. News Section (moved down)

- Compact timeline format instead of cards
- Date in muted small text, content inline
- "Show more" toggle retained
- No left border accent — use date prominence for structure

### 7. Misc Section

- Grid of minimal cards retained
- Remove hover shadow effects
- Thinner border, more padding

### 8. Footer

- Update "Last Updated" to current date
- Minimalist single-line footer

## Visual System

### Typography

- Primary font: Inter (keep)
- Chinese fallback: Noto Sans SC (keep)
- Heading scale: reduce by ~15% across the board
- Body: 15px, line-height 1.75
- Use letter-spacing: -0.02em on headings for tightness

### Colors (Light Mode)

| Token | Value |
|-------|-------|
| --bg-primary | #fafafa |
| --bg-card | #ffffff |
| --text-primary | #111111 |
| --text-secondary | #555555 |
| --text-muted | #999999 |
| --border | #eeeeee |
| --accent | #111111 |
| --link | #333333 |
| --link-hover | #000000 |

### Colors (Dark Mode — via prefers-color-scheme)

| Token | Value |
|-------|-------|
| --bg-primary | #0a0a0a |
| --bg-card | #141414 |
| --text-primary | #e5e5e5 |
| --text-secondary | #a0a0a0 |
| --text-muted | #666666 |
| --border | #222222 |
| --accent | #e5e5e5 |
| --link | #cccccc |
| --link-hover | #ffffff |

### Spacing

- Section gap: 48px
- Card internal padding: 20px
- Consistent 8px grid system

### Transitions

- All hover transitions: 0.2s ease
- No transform animations (no translateY, no scale)
- Background color change only on hover

## Mobile Responsiveness

### Breakpoint: 768px

- Bottom tab bar appears, top navbar hides
- Paper cards stack vertically (image on top, text below)
- Name font-size: 28px → 24px
- Section headings: 18px
- Timeline entries: full width
- Cards: full bleed with 16px horizontal padding

### Breakpoint: 480px

- Further font-size reduction
- Social links wrap to 2 lines if needed
- Tab bar icons only (no labels) to save space

## Content Updates

1. **Add ALOE paper** to Publications (arXiv 2026)
2. **Update affiliation**: NIO → AgiBot in bio subtitle and institution references
3. **Update footer date**: September 2025 → May 2026
4. **Add timeline entries**: AgiBot (current role), keep NIO as past internship, add AIR Tsinghua internship

## Technical Notes

- Single HTML file architecture retained (no build system)
- All styles remain in `<style>` tag
- Dark mode via `@media (prefers-color-scheme: dark)` — no JS toggle needed
- Mobile bottom nav requires minimal JS for scroll-to-section behavior (extend existing script)
- Remove jQuery dependency if carousel is not used (currently only Misc section references it, but carousel is not in use)
- Remove Bulma Carousel CSS/JS if unused
