# design-bakeoff — User Guide

How to drive the website-design pipeline. Read `SKILL.md` for the engine internals; this file is for **using** it.

---

## 1. What it is (in one breath)

One command that runs a full design studio: it reads your brief, grounds in real design tokens, generates 2-3 deliberately different variants, gates them on accessibility + responsive correctness, has two AI judges critique them, then **you** pick the winner. Only the winner gets motion, gets ported to your framework, and gets an SEO pass. Every pick teaches a taste profile so the next run starts smarter.

You never invoke `taste-skill`, `impeccable`, `gsap-*`, `emil-design-eng` etc. by hand. `design-bakeoff` chains them. Invoking them piecemeal skips the grounding, the divergence, the gates, and the learning loop.

---

## 2. When to use it

| Use design-bakeoff | Use something else |
|---|---|
| Landing page, portfolio, marketing site | Backend/API logic → not a design task |
| Dashboard, admin panel, app UI | Code module/API shape → `design-an-interface` |
| Redesign an existing site | Pure copywriting → `edit-article` / `humanizer` |
| "Make this section better" | A video/motion-graphic → `hyperframes` |
| Any "which design is best?" question | Fixing one CSS bug → just edit it |

Triggers: "design a site/landing/portfolio/dashboard", "redesign this", "/design-bakeoff", or any visual-design request where you want the best outcome, not the first draft.

---

## 3. How to write the brief (the one thing that matters most)

The pipeline is only as good as the brief. Use this shape:

```
Design a [PAGE KIND] for [PRODUCT + what it does].
Audience: [who they are].
Vibe: [2-3 words] like [reference site/brand].
Brand: [existing colors/font OR "none, generate one"].
Motion: [none / subtle / cinematic].
Scope: [full page / just hero / specific section].
Ship to: [Next / Vite / static HTML].
```

**Only the first line is required.** Everything else sharpens the result; omit a line and the pipeline infers it (and states its inference in the Design Read so you can correct it).

### Why each line matters

- **Page kind** → sets the effort tier and which generators run. "dashboard" drops the landing-only generator automatically.
- **Audience** → gates the aesthetic lanes. A public-sector audience never gets the experimental/maximal lane; a design-studio audience does.
- **Vibe + reference** → the single biggest quality lever. Naming a real brand (stripe, linear, vercel, notion, cursor, raycast...) makes the pipeline pull that brand's **real measured tokens** from the 74-brand awesome-design-md library instead of guessing.
- **Brand** → "none" fires `brandkit` to generate an identity first. Existing brand → tokens are preserved.
- **Motion** → sets the MOTION dial, which gates the gsap stage. "none" = static; "cinematic" = motion becomes a judged divergence axis.
- **Scope** → Tweak vs Page vs Site. Controls cost. "just the hero" won't rebuild your whole page.
- **Ship to** → the port target + which best-practices skill validates it.

### Weak vs strong brief

**Weak:** `make me a landing page`
→ pipeline has to guess everything; you'll iterate more.

**Strong:**
```
Design a landing page for Komment, a tool that auto-generates API
docs from code comments. Audience: backend engineers. Vibe: precise,
technical, like Linear + Stripe docs. Brand: none. Motion: subtle
scroll reveals. Scope: full page. Ship to: Next.
```
→ brand-matches Linear/Stripe tokens, builds 2-3 divergent variants, gates them, you pick, adds gsap scroll reveals to the winner, ports to Next + SEO. One shot.

---

## 4. What happens after you send the brief

| Stage | What you'll see | Your move |
|---|---|---|
| **0 · Design Read** | One line: "Reading this as: [kind] for [audience], [vibe], leaning [aesthetic]." + dial values. | Correct it if the read is wrong. This is your cheapest steering point. |
| **1 · Effort tier** | It picks Tweak / Page / Site. May ask ONE question. | Answer if asked; else it proceeds. |
| **2 · Generate** | 2-3 static HTML variants, each a different direction lane, sharing one copy deck + image set. | Wait. |
| **3 · Gate + judge** | Broken variants (a11y/responsive fail) are dropped. Survivors shown at mobile + desktop with judge notes. | **You pick the winner.** The pipeline never auto-picks on taste. |
| **4 · Motion** | Winner gets gsap animation matched to the MOTION dial. Shown for confirm. | Approve or adjust. |
| **5 · Port + learn** | Winner ported to your framework, best-practices + SEO pass, `DESIGN.md` written to project root, taste profile updated. | Review the port. |
| **6 · Ship** | Only if you say "go live". | Explicit approval required. |

---

## 5. Effort tiers (what each costs)

| Tier | Trigger | What runs | Rough cost |
|---|---|---|---|
| **Tweak** | one component / color / copy | no bake-off, single pass, `impeccable audit` only | seconds, ~3 skills |
| **Page** | one full page or section | 2-variant bake-off + gates + judges | minutes, ~6-8 skills |
| **Site** | multi-page / new brand / redesign | full 3-variant bake-off + grounding + winner port | longer, ~10-14 skills |

The **firing matrix** in `SKILL.md` controls exactly which skills fire per tier — the pipeline won't fire all 20 engines on a tweak.

---

## 6. Steering mid-flight

You steer by **how you phrase the brief and the Design Read correction**, never by editing the engine skills.

- **Wrong aesthetic?** Correct the Design Read line immediately: "no, make it warmer / more brutalist / less corporate."
- **Want a specific brand feel?** Name it. "like Stripe" pulls Stripe's real tokens.
- **Too much motion?** "drop motion to subtle" resets the dial.
- **Want a lane you didn't get?** Ask for it: "give me one brutalist variant."
- **Force fresh exploration?** "ignore my taste profile this round" pushes an off-axis variant.

---

## 7. The learning loop (why runs get better)

Every winner and every loser is logged to `taste-profile.md` with the reason it won/lost. Over ~10 jobs the pipeline distills your stable preferences (always true) from context-dependent ones (true for landing, not dashboard). Cost bends **down** as the profile matures (less grounding needed); quality bends **up** (starts from your proven moves). The rejections matter as much as the picks — anti-preferences converge taste 2-3× faster.

You don't manage this. Just keep picking winners honestly.

---

## 8. Motion keyword → dial cheat sheet

| You say | MOTION dial | gsap that fires |
|---|:--:|---|
| none / static / calm | 0-3 | none |
| subtle / tasteful / scroll reveals | 4-6 | gsap-core + gsap-scrolltrigger |
| cinematic / kinetic / Awwwards / "make it move" | 7-10 | full gsap chain; motion judged as a divergence axis in Stage 2 |

All motion always ships with `gsap.matchMedia()` + `prefers-reduced-motion` fallback and a 60fps perf pass. You never get motion that breaks accessibility.

---

## 9. Common mistakes

- **Invoking sub-skills directly** ("use taste-skill on this"). You lose grounding, divergence, gates, and learning. Use `design-bakeoff`.
- **Vague brief.** "make it pop" gives the pipeline nothing. Name a vibe or a reference.
- **Skipping the Design Read correction.** It's the cheapest moment to redirect. Read it, correct it.
- **Expecting an auto-winner.** By design, the pipeline narrows to 2-3 and *you* choose. That's the point — taste is yours.
- **Asking for "go live" implicitly.** Deploy needs explicit approval; it's outward-facing.
