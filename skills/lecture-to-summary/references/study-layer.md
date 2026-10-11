# Study layer (lecture.html)

The sections that come after the slide walk-through in `lecture.html`. They turn reading into learning. Pick the tools by lecture type (classified in Step 1); a **mixed** lecture gets both sets, each applied to the slides it fits.

## Always

- **Start here** (right after the table of contents): a 4-6 step plan for working through the page: read, learn the pattern, do the examples, quiz yourself, re-test from a blank page.
- **How to memorize it**:
  - The shared pattern behind related ideas, so the user learns one recipe plus the differences instead of N separate facts.
  - Side-by-side comparison tables.
  - Memory hooks for lists (acronym sentences, short phrases), each with its slide label.
  - Common traps: the mistakes a student is most likely to make on this material.
- **Mixed practice quiz**: one section holding every practice question, interleaved across topics (never grouped by topic), in the quiz markup from [`quiz-js.md`](quiz-js.md). Mix question kinds. Understanding mode: 10+ questions. Exam mode: 15+.

## Math / procedure lectures

- **Derive, don't memorize**: for each formula family, show how the dependent results (e.g. a verify step) fall out of the one equation worth memorizing.
- **Worked examples**: at least two per major formula or procedure, every intermediate step shown, small numbers a student can do by hand. Add a "what goes wrong" case where one fits (tampered input, wrong parameter, reused value). Run every number before writing it. Label each `own example, based on slide N`.
- **Hand techniques**: any arithmetic shortcut the quiz will need (modular inverse by search, square-and-multiply), labelled `not on slides`.
- **Quiz questions**: calculations with full worked answers, derivation questions, and "why" questions about each step.

## Concept lectures

- **Compare and contrast tables** for every pair or group of ideas a student could confuse.
- **Explain it simply** prompts: "explain X to a classmate in two sentences", with a model answer.
- **Scenario questions**: a short realistic situation, the user picks or justifies the concept that applies.
- **Quiz questions**: scenarios, compare-and-contrast, "what would happen if", and definition recall.
