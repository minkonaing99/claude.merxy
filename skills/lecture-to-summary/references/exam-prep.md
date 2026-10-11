# Exam prep across lectures (Step 7)

Runs in exam mode when the scope covers more than one lecture. Output: `courses/<code>-.../exam-prep.html`, at the course root next to `index.md`.

## Before building

1. List every lecture in scope and check that each has `summary.md`, `lecture.html` and `cheatsheet.html`.
2. If any are missing, stop and ask: give the count of missing lectures and roughly how long a full run takes per lecture, and let the user choose to generate them first, skip them, or cancel. Never generate or skip silently.
3. Build from the existing per-lecture outputs, not from raw slides again. Re-open a slide PDF only to check a fact.

## Contents

1. **Timed study plan** to the exam date, topics ordered by likely-tested rank across all lectures (see [`exam-mode.md`](exam-mode.md)).
2. **How the lectures connect**: what builds on what, as a short list or a small inline SVG (rules in [`diagrams.md`](diagrams.md)), each node linking to `lectures/lecture_N/lecture.html#section`.
3. **Merged cheatsheet**: the per-lecture cheatsheets combined and deduplicated, grouped by topic rather than by lecture, printable with the same print CSS as [`cheatsheet.md`](cheatsheet.md). Each item keeps its source as `L8 s.12` (lecture, slide).
4. **Mixed quiz**: questions drawn from every lecture's quiz plus new cross-lecture questions, shuffled so consecutive questions come from different lectures. Uses the quiz markup and JS from [`quiz-js.md`](quiz-js.md); each question's `data-href` points to `lectures/lecture_N/lecture.html#section`, so weak topics link back to the right lecture.

Same design, offline constraints and 80% width rule as `lecture.html`.
