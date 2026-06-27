---
name: design-bakeoff
description: Orchestrate all frontend/design skills into one website-design pipeline. Diverging variants, objective gates, real-pixel judging, a learned taste profile, and effort tiers. Use whenever the user wants to design or redesign a website, landing page, portfolio, dashboard, or app UI and wants the best UI/UX outcome. Triggers on "design a site/landing/portfolio/dashboard", "redesign this", "/design-bakeoff", or any frontend visual-design request.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# design-bakeoff

One brain (this file) drives the design engines. The engines stay pristine — steer them by HOW you invoke them, never by editing them. Improve the SYSTEM, not the parts.

## Engines (never edited — call-time steering only)

| Role | Skill | Driven how |
|---|---|---|
| Design read | `taste-skill` §0 | infer page kind / audience / vibe, set dials |
| Generator A | `taste-skill` | landing/portfolio ONLY (refuses dashboards) |
| Generator B | `impeccable craft` | any surface incl. dashboards/app UI |
| Generator C | `stitch-skill` | DESIGN.md spec → build (only if user drives Google Stitch) |
| Judge 1 | `emil-design-eng` | feel/motion critique, Before/After table |
| Judge 2 | `impeccable audit`/`polish` | fix hierarchy, a11y, spacing, type, color |
| Motion | `gsap-*` | gsap-core → timeline/scrolltrigger/react, only if MOTION dial > 4 |
| Video/frames | `hyperframes` (router) → `motion-graphics` / `general-video` / `website-to-video` / `product-launch-video` / `remotion` | hero loops, accent motion-graphics, post-launch promo |
| Copy | `humanizer`, `edit-article` | de-AI the copy deck; long-form content |
| Web quality | `next-best-practices`, `react-best-practices` | port correctness — hydration, RSC, bundle, re-renders |
| SEO | `nextjs-seo`, `api-design-patterns` | meta/OG/sitemap/JSON-LD/CWV/favicons; form+API design |
| Ship | `hostinger-deploy`, `e2e` / `playwright-cli` | smoke test + deploy live |

`design-an-interface` is NOT here — it designs code/API module shapes, not visual UI.

## Owned artifacts (this dir)

- `taste-profile.md` — concrete moves from YOUR past picks (fonts, palette, layout, motion, density). The primary learned artifact. Read it in Stage 0.
- `references.md` — swipe file: real-pixel tokens extracted from sites you rate. Persists across jobs.
- `scoreboard.md` — secondary metric: generator win tally. Used only to retire a dead engine.

## Pipeline

### Stage 0 — Design Read + grounding (always, but cache-aware)
1. Run `taste-skill` §0: infer page kind, audience, vibe. State the one-line Design Read.
2. **Read `taste-profile.md` + `references.md` first.** If they cover this job, skip fresh grounding (reuse cache — cost drops as profile matures).
3. **Real-pixel grounding** (Q5, #2): if the user names/links sites or drops screenshots, ground in the *actual* pixels — not my memory of them.
   - **Live sites → read computed styles, not just a screenshot.** Open the ref in claude-in-chrome and pull real values via `getComputedStyle` (font-family, font-size scale ratio, line-height, letter-spacing, color/bg hex, contrast, spacing rhythm, border-radius, transition/easing curves). Far more accurate than eyeballing. Screenshot only supplements (composition/mood).
   - **Static screenshots / images** → image Read for principles.
   - Extract *principles* not layouts; append concrete tokens to `references.md`. Variants anchor to these real tokens, not my priors.
4. Set dials `VARIANCE / MOTION / DENSITY`. Ask at most ONE clarifying question, only if the read genuinely diverges.

### Stage 1 — Effort tier (governor, Q6)
Auto-detect job size from the Design Read; this gates everything downstream:
- **Tweak** (one component / color / copy) → no bake-off. Single pass, judges only. Seconds.
- **Page** (one full page / section) → round-robin OR 2-variant bake-off. Ask which.
- **Site** (multi-page / new brand / redesign) → full 3-variant bake-off + grounding + winner port.

**Scope default — build the WHOLE page, not just the hero.** "landing" / "page" / "site" means every standard section for that page kind, e.g. landing = hero + value-prop / how-it-works + features + social-proof + pricing/plans + CTA + footer. Only build a fragment when the user explicitly scopes one ("hero", "pricing section", "this button"). If the user said a fragment, build that fragment; otherwise default to the full page. State the section list in the Design Read so scope is confirmed before generating.

### Stage 2 — Generators with divergence contracts (Q4)
**Scope guard:** non-landing surface → drop A (taste-skill refuses it). No Google Stitch → drop C.

**Controlled content first (#3) — fair comparison demands it.** Before spawning variants, lock TWO shared inputs so you judge DESIGN, not content:
- **One real copy deck** — write the actual headline, subhead, section copy, CTA labels ONCE (no lorem), then run it through `humanizer` so it doesn't read AI-generated (AI-sounding copy sinks a premium site). Long-form/blog content → `edit-article`. Every variant uses the same humanized words. Different copy across variants confounds the pick.
- **One image strategy** — pick a source and stick to it across variants: real photos (Unsplash/Pexels URLs), AI-gen, or sized placeholders with a written art-direction note. Visual sites (food/travel/product) live on photography — a missing/ugly image sinks a good layout. Same image set per variant = controlled variable.
Only the DESIGN diverges (layout/type/color/motion); copy + imagery are held constant.

Every bake-off variant is **static single-file** (`index.html`, CDN deps, no build) — Q2. This keeps the taste race fast, fair (same render path), and install/port-free. **Variants are built STATIC (no motion) by default** — you judge layout/type/color first, pick the winner, then motion goes on the winner only (Stage 4). Cheaper, no animation work thrown away.

**Exception — motion-first briefs:** when motion IS the message (kinetic-type / Awwwards / "make it move" / any lane with MOTION dial ≥ 7), ship a **motion signature inside each variant** so motion is judged as a divergence axis, not chosen blind. Use CDN GSAP, wrapped in `gsap.matchMedia()` honoring `prefers-reduced-motion`. Default off; turn on only when the brief makes motion the point (state which mode in the Design Read).

Each variant gets a **divergence contract** so they CAN'T converge — assign per variant:
- a **direction lane** (e.g. editorial/type-driven · Swiss-grid/restrained · kinetic/Awwwards-maximal),
- a distinct **dial set** (calm V5/M3/D2 · bold V8/M6/D4 · experimental V9/M9/D4),
- one **banned crutch** it must avoid (no centered hero · no card grid · no gradient),
- (motion-first briefs only) a distinct **motion signature** matched to its dial M.

The Design Read gates lanes to plausible-for-this-audience only (public-sector never gets the maximal lane). Spawn eligible generators as **parallel subagents**, each carrying its contract + the `references.md` tokens.

Explore rate: ~1 job in 4, ignore `taste-profile.md` and push one variant deliberately off-axis — keeps taste from ossifying.

### Stage 3 — Judging: gates → pixels → your eye (Q1)
LLM judges NARROW, they never DECIDE. Taste is the user's.
1. **Objective gates first, fail-fast** (Q6): render each static variant, run axe / contrast-ratio / Lighthouse a11y+perf. A variant that fails a gate is OUT — never reaches pixel/judge stage. Don't pay to judge broken work.
2. **Responsive gate (#1) — judge mobile AND desktop.** Screenshot each survivor at BOTH **mobile (375px)** and **desktop (1440px)**. Mobile is most traffic; a desktop-only win that breaks on mobile (overflow, unreadable type, broken nav, tap targets <44px) **fails the gate** — same as a11y. This is correctness, not taste. Both viewports go to the judges and to you.
3. **Real pixels** (Q1b): the mobile + desktop screenshots per survivor. For motion-first briefs (variants already animated), also capture motion — short GIF/clip (claude-in-chrome `gif_creator`) or live browser to scrub. `emil-design-eng` reads the IMAGES (feel/motion Before-After table), `impeccable audit` fixes the code. Score on: hierarchy, responsive integrity, motion feel, anti-slop (no AI-purple / Inter / centered-hero / glassmorphism), brief fit, reference fidelity.
4. **Your eye decides** (Q1c): present 2-3 survivors side by side, each with mobile + desktop shots (+ clips for motion-first). The USER picks the winner. I only narrowed.

### Stage 4 — Motion (winner only, default path)
Add motion to the chosen winner: `gsap-core`, then `gsap-timeline` / `gsap-scrolltrigger` / `gsap-react` / `gsap-frameworks` per host. Match the winner's MOTION dial — entrance reveals, scroll parallax/pin, hover micro-interactions, count-ups; restraint for low dials, don't add motion the lane didn't call for. Always `gsap.matchMedia()` + `prefers-reduced-motion`. Run `gsap-performance` (transforms only, no layout thrash, 60fps). Then show the user the animated winner to confirm before port. (Motion-first briefs already animated in Stage 2 — here just polish + perf-pass.)

### Stage 4.5 — Video / frames (winner, conditional)
Only when the brief or page wants real video/motion-graphics beyond DOM/GSAP. **Route through `hyperframes` first** (it dispatches intent), then:
- **Accent motion-graphics** (logo sting, stat/number count-up, kinetic headline, animated badge, social/overlay) → `motion-graphics`. Render MP4 or **transparent overlay** to layer on the page.
- **Hero / section background video** (ambient loop, b-roll) → `general-video` (or supply real footage). Embed muted + `loop` + `playsinline` + `poster` (winner's hero frame).
- **Post-launch promo** (capture the finished site → social clip) → `website-to-video`; **product/SaaS launch** → `product-launch-video`.
- React-native video build → `remotion`.

**Web-embed safety (loophole #6, non-negotiable):**
- `prefers-reduced-motion: reduce` AND `prefers-reduced-data: reduce` → show the `poster` still, never autoplay.
- `poster` always set (no blank flash); `preload="none"` / lazy-load below the fold; muted for autoplay.
- Video must not block LCP — poster image is the LCP candidate, not the video.
Skip this stage entirely for static/low-motion briefs.

### Stage 5 — Port + quality + learn
1. **Port winner** (Q2): the single chosen static variant → the user's real framework (Next/Vite/etc). Only the winner pays build cost.
2. **Quality pass (loophole #3):** the port is NOT trusted until it passes the relevant best-practices skill — `next-best-practices` (RSC boundaries, hydration, async APIs, no data waterfalls) and `react-best-practices` (bundle size, re-renders, code-split). Fix what they flag.
3. **SEO pass:** `nextjs-seo` — metadata/`generateMetadata`, OG + twitter images, sitemap.xml, robots.txt, canonical, JSON-LD, favicons/manifest, Core Web Vitals. If the site has forms/backend, `api-design-patterns` for the endpoints.
4. **Export design tokens (#5, #7):** emit the winner's colors / type scale / spacing / radius / motion as `DESIGN.md` + CSS custom properties (or `tailwind.config`). **Write `DESIGN.md` to the project root** so `impeccable` reads it next run = future work auto-on-brand (closes the loop). Use `impeccable`'s token output; don't hand-roll.
5. **Taste profile** (Q3, primary): extract WHY the user picked it — concrete tokens (font, palette, layout pattern, motion style, density) — append to `taste-profile.md`. This is the compounding artifact; future Design Reads start from it.
6. **Capture rejections (#4):** also log each LOSING variant and one line on *why it lost* (too cold / cramped / generic / motion overdone) to `taste-profile.md`'s rejection list. Losers carry as much signal as winners — anti-preferences converge taste 2-3× faster.
7. **Swipe file**: promote any reference that drove the winner into `references.md` for reuse.
8. **Generator tally** (secondary): log winner's generator to `scoreboard.md`. Used only to retire an engine that never wins.
9. **Distill (#6) — every ~10 entries:** collapse `taste-profile.md` into stable preferences (always true) vs context-dependent ones (true for landing, not dashboard), resolving contradictions. Append-only profiles rot into noise; distillation keeps signal sharp. Trigger when the table passes ~10 rows.

### Stage 6 — Ship (optional, on user approval)
Only when the user asks to go live. Confirm before deploying (outward-facing, hard to reverse).
1. **Smoke test:** `e2e` / `playwright-cli` on critical flows (nav, forms, CTAs) at mobile + desktop.
2. **Deploy:** `hostinger-deploy` (static frontend + PHP backend default; follows its pre/post-deploy checklist).
3. Report the live URL + post-deploy checklist results.

## Laws
- Judges narrow; the user decides. Never auto-pick a winner on taste.
- Engines are never edited — all intelligence lives in this file + the owned artifacts.
- A generated UI is unfinished until gates pass (a11y + responsive) AND both judges run.
- Copy + imagery are held constant across variants; only design diverges (fair comparison).
- Ground in real computed styles, not memory of a site; judge mobile + desktop, not desktop alone.
- Embedded video never autoplays under reduced-motion/data; always poster + lazy + muted; poster is the LCP, not the video.
- The port is unfinished until it passes best-practices + SEO; `DESIGN.md` goes to project root so the loop closes.
- Ship only on explicit approval — deploy is outward-facing and hard to reverse.
- Cost bends down as `taste-profile.md` / `references.md` mature; quality bends up. Reuse the cache.
- Match implementation complexity to the dials: maximalism needs elaborate code, minimalism needs precision.
