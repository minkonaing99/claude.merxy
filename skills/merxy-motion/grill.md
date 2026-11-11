# Grills

Format for both grills: numbered questions, each with a recommended answer, asked as one round. Ask a follow-up round only for answers that open new questions. A fact you can look up (files, the brand site, track length) is yours to find, never a question.

## Film grill

Settle all 9, skipping any the brief already answers:

1. **Purpose and platform**: YouTube intro, Short, ad, product film, other.
2. **Length and pads**: total seconds, and pad seconds at each end (pads ramp music from and to silence).
3. **Aspect**: 16:9, 9:16, or both.
4. **Music**: a file (path) or synthesized; any section preference, or let `beats.py rank` choose.
5. **Brand kit**: list the files in `brands/` and ask which one, or a new one (then run brand mode first).
6. **Reference**: URL(s) or none.
7. **Route**: recommend per routes.md, HyperFrames first.
8. **Message, copy and CTA**: the one thing the film says, headline copy, the URL or call to action.
9. **Deliverables**: MP4 only, or also a transparent overlay, a thumbnail frame, a 9:16 cut.

## Brand mode

`/merxy-motion brand <name>` refines `brands/<name>.md`.

1. If the kit is missing, draft one from the brand's site (ground, ink, accent hex, faces, logo URL, tagline, tone) using the kit format in `brands/merxylab.md`.
2. Grill the user section by section: identity and message, palette, type, logo use, motion feel, sound, copy voice, do/don't, open questions.
3. Show the changed sections as a diff and write them only after the user approves.
