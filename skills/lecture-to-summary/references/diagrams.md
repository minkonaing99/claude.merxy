# Diagrams (lecture.html)

Redraw a slide diagram as inline SVG when the picture shows a **mechanism**: a process flow, a protocol between parties, a data layout, a sign/verify pipeline. Skip decorative images, photos and logos; describe those in one sentence if they carry meaning.

## Rules

- Inline `<svg>` with a `viewBox` and `style="width:100%;height:auto"`, inside a `<figure>` with a `<figcaption>` that carries the slide label (`slide 6`) and one line on what to notice.
- `role="img"` and an `aria-label` that states the flow in words.
- Colors come from the page's CSS variables (`var(--accent)`, `var(--text)`, `var(--line)`), so the diagram matches the page.
- Simplify: keep the boxes and arrows that carry the idea, drop textbook decoration. Labels are real `<text>`, at least 12px at the column width.
- Use the same names and symbols as the slide (PR_a, PU_a, H, k) so the user can match it to the deck.
- One idea per diagram. A slide that shows two approaches side by side becomes two rows of one figure.
