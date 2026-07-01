# Taste Profile

Concrete design moves extracted from winners the user actually picked. Primary learned artifact — read in Stage 0, append after every Stage 5. Future Design Reads start from here.

Empty until the first bake-off. Each entry: date · page kind · what was picked (font / palette / layout / motion / density) · one-line why it won.

| Date | Page kind | Type | Palette | Layout | Motion | Density | Why it won |
|---|---|---|---|---|---|---|---|
| 2026-06-26 | Landing hero (DTC coffee) | Fraunces display, light weight (300) at huge size (clamp→180px), italic accent word in contrast color | Warm dawn: cream `#fff6ea` bg, ink `#241405`, dawn-orange accents `#f4a259`/`#d96b3a`, radial sun glow | Left-aligned oversized two-line headline w/ italic second line, blurred radial sun top-right, horizontal stat strip below | Pill buttons w/ translateY lift + soft shadow on hover (M5) | Airy (D4 but generous whitespace) | Picked the EXPLORE lane over two safer variants. Chose warmth + drama over restraint despite asking for "calm". Wants brand-forward boldness, big expressive serif, atmospheric color, NOT swiss/minimal. |
| 2026-06-27 | Full landing (Pizza House) | Fraunces 400/300 italic accent word in gold; oversized display (clamp→8.5rem); Hanken Grotesk body | Dark wood-fired: char-black `#140d08` bg, cream `#f7ece0` text, ember `#f2691e`/`#ff8c42`, gold `#f4b860` accent, ember radial glow | Full-bleed photo hero w/ dark warm overlay; alternating big-photo menu ROWS (refused tidy card grid); centered big-quote story; ember radial CTA | Pill btn translateY lift + glow shadow (M6); scroll parallax + side-slide reveals on winner | Bold (D4), full-bleed imagery as loudest element | Picked lane C (Wood-Fired Maximal V8/M6/D4) over light-editorial (A) and the literal restrained brief (B). Brief said "warm, family-friendly, not corporate" → reads quiet; picked the DARKEST, BOLDEST, most photo-forward lane. Same pattern as coffee. |
| 2026-06-28 | Full site (Natural Mountain dairy) | **A:** Fraunces 300/400 + terracotta italic accent + Hanken body. **C:** Bricolage Grotesque 700/800 + gold italic accent + Hanken body | **A:** warm cream `#F6F0E2`, ink `#241A12`, sage, butter `#E8B04B`, terracotta `#BC5E36`. **C:** deep pine `#13241A`, cream `#F4EBD9`, gold `#F0B43C`, berry, moss | **A:** side-by-side serif hero + soft photo cards + editorial provenance rows. **C:** full-bleed pasture-cow hero + immersive overlay cards (asymmetric span) + alternating photo rows | M6 both: scroll reveals (y+fade), hero parallax (scrub), card hover lift, stat count-up; gsap.matchMedia + reduced-motion | A airy D3 · C bold D4 | **Picked BOTH the warm-LIGHT editorial (A) AND the dark maximal (C)** — wanted two sites, not one. First time a LIGHT lane survived alongside the dark one. Rejected the Swiss-restrained lane (B) outright. Through-line held: expressive display serif/organic + italic accent word + real photography as the loudest element. Temperature (light vs dark) is negotiable; the warmth + photo-forward + big-display DNA is not. |

## Signals (running)
- **The real constant (3/3 food jobs): expressive big display + italic accent word in a contrast color + REAL photography as the loudest element.** Temperature is negotiable — dark won twice (coffee glow / pizza char), and on the dairy job the user kept BOTH a warm-LIGHT editorial AND a dark maximal. Don't assume dark; assume warm + photo-forward + a dramatic display face with one italic accent word. Refine of the old "always darkest" read.
- **Says "calm/clean/family" but never picks the restrained lane. CONFIRMED 3/3** (coffee→EXPLORE, pizza→dark maximal, dairy→rejected the Swiss-clean lane though brief said "mountain-clean"). Discount stated restraint ~1 notch; ALWAYS keep ≥1 bold lane. State the warning up front so they can override with words.
- **Photography is non-negotiable for food/drink.** Verify image URLs render before judging (a broken/wrong photo sinks a good layout). Real pasture/product shots beat icons/illustration.
- Loves **expressive display**: Fraunces 300 (light serif) and Bricolage Grotesque 700/800 (organic) both won. Italic accent word every time.
- Comfortable with **gradients + glow + radial atmosphere**; never picks the gradient-banned restrained variant.
- Pill buttons + soft shadow read premium. Squared/sharp buttons (the Swiss lane) lost.
- **Will take TWO winners when torn** — don't force a single pick if two lanes both land; offer to ship both.

## Rejections (#4 — losers carry signal)
What was passed over and why. Anti-preferences converge taste faster. Append a row per losing variant.

| Date | Page kind | Rejected lane | Why it lost |
|---|---|---|---|
| 2026-06-26 | Coffee hero | Swiss-grid / restrained (gradient-banned) | too cold / minimal — user wants warmth + drama |
| 2026-06-26 | Coffee hero | Editorial safe | not bold enough vs the explore lane |
| 2026-06-27 | Pizza landing | Light-editorial (A) | reads quiet; food needs appetite/photography |
| 2026-06-27 | Pizza landing | Restrained literal-brief (B) | "family-friendly" taken literally = generic, passed over |
| 2026-06-28 | Natural Mountain (dairy) | Creamery Swiss (B) — restrained hairline grid, uppercase Hanken, squared buttons, pine accent | Too cold/restrained; squared buttons + Swiss grid read as catalogue, not appetite. 3rd straight loss for the restrained/Swiss lane even when the brief literally said "mountain-clean". Note: A (light-editorial) did NOT lose this time — the user took it as one of two winners — so "light editorial loses" is NOT a rule; "restrained/Swiss/cold loses" IS. |
