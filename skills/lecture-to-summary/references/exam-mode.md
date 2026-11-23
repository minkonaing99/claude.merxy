# Exam mode

Turns on when the user mentions a quiz, test, exam, or a date they are studying for. Apply everything below on top of the normal steps.

## Before writing

Get two facts: the **exam date** and the **scope** (which lectures). Take them from the user's message when present. If either is missing, ask once, in a single question. If the user skips it, assume the exam is tomorrow and covers this lecture only, and state that assumption at the top of `lecture.html`.

If the scope spans more than one lecture, also run Step 7 ([`exam-prep.md`](exam-prep.md)).

## Likely-tested ranking

Rank every `lecture.html` section and every `summary.md` key concept as **high**, **med** or **low** likelihood of being tested. Evidence, strongest first:

1. The professor said it will be tested, or repeated it (transcript).
2. The user wrote it down (`notes.md`).
3. It has a formula, an algorithm, or a numbered list on the slide.
4. The slide spends several pages on it, or shows a worked example.
5. Mentioned once, in passing: low.

This ranking runs on every lecture, not only in exam mode. Show it as stars: high = 3 stars, med = 2, low = 1. In `lecture.html`, use the template's `.stars` span (see SKILL.md, Importance stars). In `summary.md`, append the stars after each key concept, e.g. `**Hypothesis** - ... ★★★`.

## Timed study plan

Replace the "start here" plan with one timed to the hours left before the exam. Example for an exam tomorrow: tonight block 1 (high items, read and derive), block 2 (worked examples), block 3 (full quiz, then re-read weak topics); morning block (blank-page recall of formulas + cheatsheet + re-quiz the missed questions). Put high-ranked sections first and give each block a time box.

## Practice

The mixed practice quiz holds 15+ questions, interleaved across topics, with high-ranked topics appearing most often.
