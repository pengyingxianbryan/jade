---
name: designer-uxui
description: Use during /jade:apply when tasks involve frontend UI — enforces premium design standards using Next.js App Router, Tailwind CSS, and Motion
---

# Designer UX/UI — Premium Frontend Enforcement

## Overview

Build sites that feel premium, intentional, and alive. Motion is meaning — every animation must earn its place. The invisible details (hover weight, easing curves, tracking at scale) are what users feel without noticing. Treat craft as a moat.

## When This Skill Activates

This skill activates automatically during `/jade:apply` when any task involves:
- Frontend components, pages, or layouts
- UI implementation (hero sections, feature grids, CTAs, navigation)
- Design system setup (tokens, typography, color palette)
- Animation or interaction work
- Screenshot or URL reference recreation

It works **alongside** the TDD gate — TDD enforces correctness, this skill enforces design quality.

## Core Principles

- Light mode by default unless asked for dark
- Motion in service of the story, not decoration
- Typography drives hierarchy — bold display type, fluid scaling, tracked correctly at size
- Whitespace is a design element — disciplined layouts with maximalist hero moments
- Every interactive element has a hover state. Nothing is static.
- Mobile-first responsive — never an afterthought

---

## Stack

| Layer | Choice |
|---|---|
| Framework | Next.js 16+ (App Router, `app/` directory) / React 19.2.x |
| Styling | Tailwind CSS — extend config for custom design tokens |
| Animation | [Motion](https://motion.dev/) (`motion` package) |
| Typography | `next/font` with Google Fonts (Inter, Plus Jakarta Sans, Geist) |
| Icons | Lucide React |
| Language | TypeScript always |

```bash
npm install motion lucide-react
```

**Motion import path** (rebranded Framer Motion — same API):
```ts
import { motion, AnimatePresence, useScroll, useTransform, useInView } from "motion/react"
```

---

## Project Structure

```
app/
├── layout.tsx              # Root layout — fonts, metadata, global styles
├── page.tsx                # Home page
├── globals.css             # Tailwind base + custom CSS vars + easing curves
└── [page-name]/page.tsx    # Additional pages

components/
├── ui/                     # Reusable primitives (Button, Badge, Card)
├── sections/               # Page sections (Hero, Features, CTA, Footer)
└── layout/                 # Nav, Footer shared across pages

lib/
└── utils.ts                # cn() helper

tailwind.config.ts          # Extended design tokens
```

---

## Animation Decision Framework

Before writing any animation, answer in order:

### 1. Should this animate at all?

| Frequency | Decision |
|---|---|
| 100+ times/day (nav toggle, keyboard shortcut) | No animation. |
| Tens of times/day (hover states, list navigation) | Remove or drastically reduce |
| Occasional (modal open, section reveal) | Standard animation |
| Rare / first-time (hero load, page enter) | Full treatment |

Spectacle is rationed. Repeated actions must be instant.

### 2. What easing?

```
Entering or exiting?        → ease-out (starts fast, feels responsive)
Moving/morphing on screen?  → ease-in-out (natural arc)
Hover / color change?       → ease
Constant (progress, marquee)? → linear
```

**Never use ease-in for UI.** It delays the initial movement — the exact moment the user is watching.

Custom curves in `globals.css`:

```css
:root {
  --ease-out-expo:     cubic-bezier(0.16, 1, 0.3, 1);
  --ease-out-quart:   cubic-bezier(0.25, 1, 0.5, 1);
  --ease-in-out-expo: cubic-bezier(0.87, 0, 0.13, 1);
  --ease-spring:      cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

In Motion: `transition={{ ease: [0.16, 1, 0.3, 1] }}`

### 3. How long?

| Element | Duration |
|---|---|
| Button press feedback | 100-160ms |
| Tooltips, small popovers | 125-200ms |
| Dropdowns, selects | 150-250ms |
| Modals, drawers | 200-400ms |
| Scroll reveals, hero entrances | 600-1000ms |

Keep interactive UI under 300ms. Marketing animations can breathe longer.

---

## Scroll Storytelling Structure

Every landing page is a three-act narrative. The scroll is the director.

**Act 1 — Hook (above fold)**
- Hero loads with one confident animation. One thing moves. Everything else is still.
- Type appears: instant or a single staggered fade-up (0ms, 80ms, 160ms, no more).

**Act 2 — Narrative (10-80% scroll)**
- Each section reveals one idea. Scroll drives the reveal.
- Parallax is subtle: 0.1-0.2x scroll rate maximum. Heavy parallax causes motion sickness.
- Text pins and fades while assets transform.

**Act 3 — Conviction (bottom)**
- CTA is the only animated element. Everything else is still.
- Reinforce the core claim — no new information.

---

## Animation Patterns

All Motion components require `"use client"` in Next.js App Router.

### Scroll reveal — declarative (use for most sections)
```tsx
"use client"
import { motion } from "motion/react"

<motion.div
  initial={{ opacity: 0, y: 24 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, amount: 0.2 }}
  transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
/>
```

### Scroll reveal — imperative (when you need the boolean in logic)
```tsx
import { useRef } from "react"
import { motion, useInView } from "motion/react"

const ref = useRef(null)
const isInView = useInView(ref, { once: true, amount: 0.2 })

<motion.div
  ref={ref}
  initial={{ opacity: 0, y: 24 }}
  animate={isInView ? { opacity: 1, y: 0 } : {}}
  transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
/>
```

### Scroll-linked animations (parallax, progress bar)
```tsx
import { motion, useScroll, useTransform } from "motion/react"

const { scrollYProgress } = useScroll()
<motion.div className="fixed top-0 h-0.5 bg-violet-500 origin-left" style={{ scaleX: scrollYProgress }} />

const ref = useRef(null)
const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] })
const y = useTransform(scrollYProgress, [0, 1], [40, -40])
<motion.div ref={ref} style={{ y }} />
```

### Staggered children
```tsx
const container = {
  hidden: {},
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.1 } }
}
const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.16, 1, 0.3, 1] } }
}

<motion.ul variants={container} initial="hidden" whileInView="show" viewport={{ once: true }}>
  {items.map(i => <motion.li variants={item} key={i.id} />)}
</motion.ul>
```

### Enter/exit (modals, dropdowns, toasts)
```tsx
import { AnimatePresence, motion } from "motion/react"

<AnimatePresence mode="wait">
  {isOpen && (
    <motion.div
      key="modal"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
    />
  )}
</AnimatePresence>
```

### Layout animations
```tsx
<motion.div layout />                    // animate any layout change
<motion.div layoutId="hero-card" />      // shared element transition
```

### Hover micro-interactions
- Buttons: `whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}`
- Cards: `whileHover={{ y: -4 }} transition={{ duration: 0.2 }}`
- Spring feel: `transition={{ type: "spring", stiffness: 400, damping: 20 }}`

### Advanced: 3D card tilt (use for feature/product showcase cards)
```tsx
function addTilt(card: HTMLElement, intensity = 8) {
  card.addEventListener('mousemove', (e) => {
    const rect = card.getBoundingClientRect()
    const x = (e.clientX - rect.left) / rect.width - 0.5
    const y = (e.clientY - rect.top) / rect.height - 0.5
    card.style.transform = `perspective(1000px) rotateX(${-y * intensity}deg) rotateY(${x * intensity}deg)`
  })
  card.addEventListener('mouseleave', () => {
    card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0)'
    card.style.transition = 'transform 500ms var(--ease-out-expo)'
  })
}
```

---

## Design System Defaults

### Typography

Large type needs tighter tracking. Small type needs more air.

```css
.display-xl  { font-size: clamp(3rem, 8vw, 7rem); letter-spacing: -0.03em; font-weight: 700; }
.title       { font-size: clamp(2rem, 5vw, 4rem); letter-spacing: -0.02em; font-weight: 600; }
.headline    { font-size: clamp(1.5rem, 3vw, 2.5rem); letter-spacing: -0.01em; }
.body        { font-size: clamp(1rem, 1.5vw, 1.125rem); line-height: 1.7; }
```

In Tailwind: `text-5xl md:text-7xl font-bold tracking-tight` for display; `text-base text-zinc-500 leading-relaxed` for sub.

Gradient text — use on one key phrase per section maximum:
```tsx
<span className="bg-gradient-to-r from-violet-600 to-blue-500 bg-clip-text text-transparent">
```

### Color Palette (Light Mode Default)

```
Background:   #FFFFFF / #FAFAFA
Surface:      zinc-50 / zinc-100
Border:       zinc-200
Text primary: zinc-950
Text muted:   zinc-500
Accent:       violet-600 → blue-500 (adjust to brand)
```

Dark mode palette (when requested — Apple-style):
```
Background:   #000000
Surface:      #1c1c1e
Accent:       brand color (one only)
Text primary: #f5f5f7
Text muted:   #86868b
```

Extend `tailwind.config.ts` with project brand colors as CSS custom properties.

### Layout

- Max content width: `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`
- Narrower for text-heavy: `max-w-3xl`
- Section padding: `py-24 md:py-32`
- Hero padding: `pt-32 pb-24`

Sticky scroll narrative (text scrolls, asset stays in view):
```css
.narrative { display: grid; grid-template-columns: 1fr 1fr; align-items: start; }
.narrative-asset { position: sticky; top: 50%; transform: translateY(-50%); }
```

---

## UI Patterns

### Glass card (light mode)
```tsx
<div className="rounded-2xl border border-zinc-200 bg-white/80 backdrop-blur-[20px] p-6 shadow-sm hover:shadow-md transition-shadow duration-200">
```
Rules: blur minimum 16px; border opacity 0.08-0.15. Never stack two glass elements.

### Gradient border card
```tsx
<div className="relative rounded-2xl p-[1px] bg-gradient-to-br from-violet-500/30 to-blue-500/30">
  <div className="rounded-2xl bg-white p-6">{/* content */}</div>
</div>
```

### Announcement badge / pill
```tsx
<div className="inline-flex items-center gap-1.5 rounded-full border border-violet-200 bg-violet-50 px-3 py-1 text-xs font-medium text-violet-700">
  <span className="h-1.5 w-1.5 rounded-full bg-violet-500" />
  New — What's shipping this week
</div>
```

### Primary CTA button
```tsx
<motion.button
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  className="inline-flex items-center gap-2 rounded-full bg-zinc-900 px-6 py-3 text-sm font-semibold text-white shadow-lg hover:bg-zinc-800 transition-colors"
>
  Get started <ArrowRight className="h-4 w-4" />
</motion.button>
```

### Ghost / "learn more" button
```tsx
<button className="inline-flex items-center gap-1.5 text-sm font-medium text-violet-600 hover:text-violet-700 transition-colors group">
  Learn more
  <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
</button>
```

### Feature grid (3-col, Apple bento style)
```tsx
<div className="grid grid-cols-1 md:grid-cols-3 gap-px bg-zinc-200 rounded-3xl overflow-hidden">
  {features.map(f => (
    <div key={f.title} className="bg-zinc-50 p-10 space-y-4">
      <div className="w-12 h-12 rounded-2xl bg-violet-100 flex items-center justify-center">
        <f.Icon className="h-6 w-6 text-violet-600" />
      </div>
      <h3 className="text-xl font-semibold tracking-tight text-zinc-900">{f.title}</h3>
      <p className="text-sm text-zinc-500 leading-relaxed">{f.description}</p>
    </div>
  ))}
</div>
```

### Scrolled nav (glass on scroll)
```tsx
"use client"
const [scrolled, setScrolled] = useState(false)
useEffect(() => {
  const handler = () => setScrolled(window.scrollY > 40)
  window.addEventListener('scroll', handler, { passive: true })
  return () => window.removeEventListener('scroll', handler)
}, [])

<header className={cn(
  "fixed top-0 inset-x-0 z-50 h-16 transition-all duration-300",
  scrolled ? "bg-white/80 backdrop-blur-xl border-b border-zinc-200/50 shadow-sm" : "bg-transparent"
)}>
```

---

## Performance Rules

### Only animate `transform` and `opacity`
GPU-composited. Skip layout + paint entirely. Never animate `height`, `top`, `margin`, or `width`.

### `will-change` — surgically
Apply only to actively animating elements. Remove after animation completes. Overuse consumes GPU memory.

### `prefers-reduced-motion` — always
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

In Motion, check `useReducedMotion()` hook and skip animations when true.

### Passive scroll listeners — always
```js
window.addEventListener('scroll', handler, { passive: true })
```

---

## Handling References

**Screenshot provided:** Analyze layout, color palette, typographic hierarchy, spacing rhythm. Recreate the visual language — not a pixel-perfect copy, but a faithful interpretation.

**URL provided:** Treat as aesthetic direction. Identify hero pattern, section flow, motion approach, palette, type choices. Adapt; don't reproduce content.

**Concept only:** Make strong creative decisions. Before outputting code, state choices in 3-4 lines:
- Palette (background, accent, surface)
- Font choice
- Motion style (subtle / moderate / expressive)
- Layout approach (centered, asymmetric, bento, editorial)

---

## Multi-page Sites

1. Establish the design system first: `tailwind.config.ts`, `globals.css`, `components/ui/`, `components/layout/`
2. Shared Nav + Footer in `components/layout/`
3. Each page gets section components in `components/sections/[page]/`
4. Same easing curves, same spacing scale, same type ramp throughout

State which pages you'll build upfront. For large scope, confirm with user before generating.

---

## Review Checklist

Before marking a UI task complete during `/jade:apply`, verify:

| Issue | Fix |
|---|---|
| `transition: all` | Specify: `transition: opacity 400ms, transform 600ms` |
| `ease-in` on any interactive element | Switch to `ease-out` with custom cubic-bezier |
| Duration > 300ms on interactive element | Reduce; long durations only for scroll reveals |
| Hover state without touch device guard | Wrap in `@media (hover: hover) and (pointer: fine)` |
| All section elements reveal at once | Add stagger delay (50-80ms per item) |
| Parallax > 0.3x scroll rate | Reduce to 0.1-0.2x; heavy parallax causes motion sickness |
| `backdrop-filter` blur below 16px | Increase to 16-40px; below 16px is invisible |
| Two glass elements stacked | Blur compounds — restructure |
| Gradient text on small type | Only use on display sizes (32px+) |
| Missing `prefers-reduced-motion` | Add media query or Motion's `useReducedMotion()` |
| Scroll listener without `{ passive: true }` | Add passive flag |
| More than one accent color | Strip to a single accent |

---

## Inspiration

Study for technique, not to copy:
- **linear.app** — dark glass, subtle grain, perfect type
- **vercel.com** — ambient glow, animation precision
- **stripe.com** — gradient animation, trust through craft
- **apple.com/iphone** — scroll-linked narrative, type staging
- **godly.website** — the bar

---

The goal is not to impress with animation skill. It is to make the user believe in the product. The craft is in service of the story. Build accordingly.
