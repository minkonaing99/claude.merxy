# cheatsheet.html

A printable 1-2 page A4 reference for the lecture, generated on every run, next to `lecture.html`.

## Content

- **Math/procedure lecture**: every formula grouped by scheme or procedure (setup, keys, steps, check), key definitions, memory hooks, and common traps.
- **Concept lecture**: definitions, compare-and-contrast tables, lists with their memory hooks, and common traps.
- Every item carries its slide label (`s.12`). Material from outside the slides is marked `not on slides`.
- Exam mode: high-ranked items first in each group, marked with a small dot or `HIGH`.
- No prose paragraphs. Terse lines only.

## Format

- Self-contained HTML, same offline constraints as `lecture.html` (inline CSS, system fonts, no JS needed).
- Screen: readable at normal size, centered, 80% width.
- Print: `@page { size: A4; margin: 10mm; }`, two columns (`columns: 2`), 8.5-9.5pt font, `break-inside: avoid` on each block, no backgrounds that waste ink (light borders instead).
- Fit 1-2 printed pages. If it overflows, cut low-ranked items before shrinking the font below 8.5pt.
- Title line: course, lecture number and title, and the exam date in exam mode.
