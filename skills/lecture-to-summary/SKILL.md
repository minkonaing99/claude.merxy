---
name: lecture-to-summary
description: Lecture study pack for the Mahidol Obsidian vault. Fuses one lecture folder's slide PDF, class transcript and the user's notes.md into summary.md, a self-contained lecture.html that teaches the whole lecture with a self-test quiz, and a printable cheatsheet.html, then syncs deadlines into the course index. Use whenever the user points at a lecture folder (courses/<code>-.../lectures/lecture_N/), asks to summarize or study a lecture, turn a transcript + slides into notes, pull deadlines out of a lecture, or prepare for a quiz, test or exam on one or more lectures ("exam on lectures 5-8" builds a course-level exam-prep.html).
---

# Lecture to Summary

Turn a single lecture folder into a study pack the user trusts: `summary.md` (quick revision), `lecture.html` (learn the whole lecture without reopening the slides) and `cheatsheet.html` (printable reference). It fuses everything the user has for that class (slides, transcript, their own scrappy notes) and lifts any deadlines into the course-level index.

The user is doing an MSc and studying for real. The goal is material they trust: complete enough to learn and revise from, honest about what's uncertain, and traceable back to the slide so they can dig deeper.

## Modes

- **Understanding mode** (default): the outputs optimize for knowing why things work.
- **Exam mode**: turns on when the user mentions a quiz, test, exam, or a date they're studying for. Read [`references/exam-mode.md`](references/exam-mode.md) before Step 3 and apply it to every output.

## When this runs

The user points at one lecture folder, typically `courses/<code>-<name>/lectures/lecture_N/`. If they were vaguer ("summarize lecture 2"), find the matching folder before starting. Steps 1-6 operate on exactly one lecture folder per run. When an exam scope spans more than one lecture, also run Step 7.

## Step 1: Gather the inputs

Read everything in the lecture folder:

- **Transcript**: the `.txt` file (plain prose, no timestamps). This is the spoken lecture: the richest source for emphasis, examples, and anything the professor said but didn't put on a slide (deadlines, "this matters for your thesis", warnings).
- **Slides**: PDF(s) whose name matches the course code or says "Lecture"/"slides". Read with the Read tool's `pages` param; note page numbers as you go so you can cite them.
- **Raw notes**: `notes.md`, the user's own hand-typed notes. Treat as high-signal: whatever they bothered to write down mattered to them, even if terse or typo'd. Never edit or overwrite this file.
- **Supplementary PDFs**: any other PDF (e.g. a research paper with a different course code) is background reading, not the lecture itself. Use it only to clarify a concept, and label it as supplementary.
- **Earlier lectures**: list sibling `lecture_*/summary.md` files. When this lecture builds on an idea an earlier one covered, you will link back to it.

Ignore the course-level `materials/` folder unless the user explicitly points you there; it drifts from what was actually taught in this session.

If a source is missing (no transcript, or no slides), work from what exists and note the gap rather than stalling.

Then classify the lecture as **math/procedure**, **concept**, or **mixed**. The type picks the study tools in [`references/study-layer.md`](references/study-layer.md).

## Step 2: Check before overwriting

This skill generates `summary.md`, `lecture.html` and `cheatsheet.html`. All are its own output and normally safe to regenerate. But the user may have hand-edited one. Before overwriting a file that already exists, read it and look for signs of manual work: added prose outside the expected sections, extra sections, inline commentary, reworded bullets. If it looks like a clean prior generation, overwrite it. If it looks hand-edited, stop and ask whether to overwrite, keep, or merge. Losing the user's own edits is far worse than an extra question. Never touch `notes.md`.

## Step 3: Write summary.md

Write in the user's own voice. Invoke the `my-writing-tone` skill and write the prose (TL;DR, definitions, the assignment write-up, anything in sentences) in that voice, and strip AI-writing tells before saving. Bullet fragments and `term - definition` lines can stay terse; the tone matters most in the flowing prose.

Write to `lecture_N/summary.md`. Start with the vault's file convention so it fits the Obsidian graph:

```markdown
---
tags:
  - mahidol
---
# Lecture N - <short title>

> [[index]]
```

Then these sections, in this order. Six are always present; the **Assignment** section appears only when the lecture actually sets or discusses an assignment. Keep the whole thing to roughly one screen. Cut logistics chatter (screen-sharing fumbles, greetings, "can you hear me"). Keep substance.

### 1. TL;DR
2-4 sentences. What this lecture was actually about and why it matters for the course.

### 2. Deadlines & action items
A markdown checklist. Everything the user has to *do*: assignments, due dates, "next class is onsite", "bring X". Pull dates from wherever they appear (transcript often has the real date; notes may have a rougher version) and reconcile them:

```markdown
- [ ] Assignment 1 - due 2026-08-21 23:59
- [ ] Next class onsite - Sat 2026-08-22
```

Use ISO dates (`YYYY-MM-DD`) when the year is known. If a date is spoken ambiguously ("the 21st, I think"), pick the most likely value and flag the uncertainty. If there are no deadlines, write `- None this lecture.`

### 3. Assignment
Include this section **only if the lecture actually sets or explains an assignment**. Skip it entirely otherwise.

When present, give the user everything they need to start without reopening the slides or transcript: what to produce, exact requirements and format, any template or structure specified, worked examples given, constraints (allowed tools, length, topic restrictions), and how it will be assessed or used later. The due date stays in the Deadlines checklist; this section is the *what and how*.

### 4. Key concepts
The must-know terms and ideas, each as `**term** - short definition`, with a concrete example from the lecture where one was given. Favour the concepts the professor dwelt on or the user noted, not every term mentioned in passing.

### 5. What you need to know
The exam/thesis-relevant takeaways: what will be assessed or what the professor flagged as important. Concepts are *what things mean*; this is *what you're accountable for*.

### 6. Open questions / gaps
Honest uncertainty: things left unclear, questions to ask, gaps between slides and what was said, topics deferred to a later class. If the lecture was clear and complete, a short list or "None" is fine.

### 7. Source map
For each substantive point, which source backs it: `[slide N]`, `[transcript]`, `[notes]`, `[supplementary: <filename>]`, `[outside the slides]`. A compact bulleted list mapping claim to source.

See `references/example-summary.md` for a filled-in example.

## Step 4: Build lecture.html

Write `lecture_N/lecture.html`: a single self-contained page the user can read to learn the whole lecture without reopening the slide PDF. It is the full teaching version: the slides expanded back into explained prose using what the professor actually said.

**Content model.** Walk the slides in order. For each slide (or small group of related slides), write a section that fuses the slide's content with the matching spoken explanation from the transcript. Terse bullets become clear paragraphs; every concrete example, analogy and aside the professor gave gets woven in where it belongs. Keep the slide order so it still maps to the deck. Write the teaching prose in the user's voice via `my-writing-tone`.

**Understanding tools in every section:**
- **Big picture first**: open with 2-3 lines on what problem this section solves, before any formula or detail.
- **Analogy**: one everyday comparison where it fits naturally. Skip it where it would be forced.
- **Prerequisite refresher**: a short box for background the lecture assumes but doesn't teach (e.g. modular inverse, hashing), labelled `not on slides`.
- **In plain words**: end the section with a 1-2 sentence recap, as if explaining to a classmate who missed class.
- **Builds on**: when an earlier lecture's `summary.md` covers the base idea, link to it (`../lecture_M/lecture.html#section` or the summary).

**Diagrams.** Redraw the slides' process and flow diagrams as inline SVG: see [`references/diagrams.md`](references/diagrams.md).

**Study layer.** After the slide walk-through, add the study sections for this lecture type: see [`references/study-layer.md`](references/study-layer.md). Its quiz is interactive: see [`references/quiz-js.md`](references/quiz-js.md).

**Design.** This is a page the user reads for hours, so its craft matters. Invoke `emil-design-eng` for typography, spacing rhythm and the small touches that make a reading surface feel considered. The requirements below are the hard constraints it stays inside.

**Technical requirements.** One file, fully self-contained, because the vault syncs over iCloud and must open offline:
- All CSS inline in one `<style>` block, all JS inline in one `<script>`. No external stylesheets, CDN, web fonts, images, or JS libraries.
- System font stack, generous line-height, light comfortable background. Width follows the Content width rule at the end of this file.
- Start with the lecture title, an in-page table of contents (anchor links), and a short "start here" study plan.
- Semantic structure: `<h1>`/`<h2>`, `<p>`, `<ul>`, `<blockquote>` for the professor's direct quotes. Callout boxes for important rules, deadlines and the assignment.

Every section teaches something; nothing restates a slide title.

## Step 5: Build cheatsheet.html

Write `lecture_N/cheatsheet.html` on every run: see [`references/cheatsheet.md`](references/cheatsheet.md).

## Step 6: Sync deadlines to the course index

The course `index.md` is one level up from `lectures/` (e.g. `courses/<code>-.../index.md`). It's the single place the user checks for all course due dates.

Upsert the deadlines into a `## Deadlines` section there:

- If no `## Deadlines` section exists, add one (after the course metadata bullets, before any other section).
- Each deadline is one checklist line, same format as in the summary, tagged with its lecture:
  ```markdown
  ## Deadlines
  - [ ] Assignment 1 - due 2026-08-21 23:59 (lecture 1)
  - [ ] Final report - due 2026-12-07 (lecture 1)
  ```
- **Dedupe on re-run.** Match on item + date. Same deadline already there: leave it. Date changed: update it. Preserve deadlines from other lectures and any the user checked off (`- [x]`).
- Only real due dates and required actions go up; "read more about X" stays in the summary.

If no course `index.md` exists (lecture folder outside the vault), skip this step and say so.

## Step 7: Exam prep across lectures (exam scope > 1 lecture)

When the exam covers several lectures, build the course-level `exam-prep.html`: see [`references/exam-prep.md`](references/exam-prep.md).

## Working principles

- **Fuse, don't concatenate.** One coherent picture from overlapping sources. When the transcript and notes say the same thing, merge them; when the notes add something not on the slides, keep it.
- **The transcript carries the deadlines and the emphasis.** Slides give structure; the spoken track gives what matters and what's due.
- **Trust the user's notes.** They were in the room. A terse line in `notes.md` often marks the single most important thing in the lecture.
- **Cite the slide everywhere you explain.** Every explanation, concept, formula, worked example and practice answer in every output carries the slide page it comes from, inline where the user reads it (`[slide 12]` in markdown, a small `slide 12` label in HTML), so the user can open the deck at that page. Section headings alone are not enough. Material from elsewhere is labelled (`[transcript]`, `[own example, based on slide 12]`, `[not on slides]`).
- **Outside knowledge, labelled.** Add facts beyond the lecture sources only when they are likely tested or needed to understand the lecture (a well-known attack, a prerequisite definition). Always label them `not on slides`.
- **Verify every number.** Run each calculation (e.g. a Python one-liner) before writing it into any output.
- **Be honest.** A trustworthy doc with an "Open questions" section beats a falsely complete one.

## Content width

In `lecture.html`, the content column is exactly 80% of the viewport width, horizontally centered: `main { width: 80%; margin: 0 auto; }`. No narrower cap (`min(80vw, 46rem)`, a fixed `max-width` in px or rem) on top of it, so wide screens get the full 80%. Tables and formula blocks fill that column. The one exception is phones (`max-width: 600px`), where the column goes full width with a 1rem side gutter.
