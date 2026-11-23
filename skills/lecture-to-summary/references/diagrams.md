# Visuals (lecture.html)

The user learns from pictures as much as prose. Every section that explains a mechanism, structure or comparison gets a visual: the original slide image, a redrawn diagram, or both.

## Slide images

Extract the slide pictures that carry meaning (diagrams, charts, tables, screenshots, worked examples) and place each one next to the paragraph that explains it. Skip logos, title slides and decoration.

- Render the page: `pdftoppm -png -r 150 -f N -l N <slides.pdf> lecture_N/assets/slide-N`. For a single embedded figure, `pdfimages -png -f N -l N <slides.pdf> lecture_N/assets/slide-N-img` and keep the one that matters.
- Crop to the region that matters when the page has other content: `magick <in.png> -crop WxH+X+Y +repage <out.png>`. Look at the image before using it.
- Save to `lecture_N/assets/`, reference with a relative path (`assets/slide-12.png`). The folder syncs with the vault, so the page still works offline.
- `<figure>` with `<img src="assets/slide-12.png" alt="...">` (alt says what the picture shows), and a `<figcaption>` carrying the slide label (`slide 12`) and one line on what to look at.
- Then explain the picture in words: walk through it piece by piece, as if pointing at it.

## Redrawn diagrams

When the slide diagram is cramped, unclear or missing a step, or when an idea has no picture but needs one (a process, a protocol between parties, a data layout, a before/after, a comparison), draw it with the `diagram-design` skill.

- Pick the diagram type that fits the idea (flowchart, sequence, layer stack, comparison, etc.).
- Skip its style-guide gate: use the lecture page's colors, not a brand profile.
- Take the SVG it produces and inline it in `lecture.html` inside a `<figure>` with a `<figcaption>` (slide label, or `own diagram, based on slide N`). Swap its colors for the page's CSS variables (`var(--accent)`, `var(--text)`, `var(--line)`).
- `role="img"` and an `aria-label` that states the flow in words. Labels are real `<text>`, at least 12px at the column width.
- Use the same names and symbols as the slide (PR_a, PU_a, H, k) so the user can match it to the deck.
- One idea per diagram. A slide that shows two approaches side by side becomes two rows of one figure.

## Keep related things together

- Put labels on the picture itself, next to the part they name, not in a separate legend or a list below.
- Put each image or diagram directly beside or above the paragraph that explains it, never in a gallery at the end.
- When the text refers to a part of the picture, use the same name the picture shows.
- A formula and its worked example sit in the same block, so the user never scrolls to match them.

## Explaining for a beginner

Assume the user is meeting the idea for the first time. For each visual: say what problem it shows, walk the picture step by step in the order things happen, name every box and arrow in plain words, then give one small concrete example run through it. Where a step is commonly misunderstood, say so.
