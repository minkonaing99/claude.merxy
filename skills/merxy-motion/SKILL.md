---
name: merxy-motion
description: Make a motion film (intro, short, ad, product film) in the claude-motion studio, or refine a brand kit with `brand <name>`.
argument-hint: "<brief> | brand <name>"
disable-model-invocation: true
---

# merxy-motion

Studio home: `/Users/aurora/Documents/claude-motion` (`$HOME_DIR` below). Every film is built there, whatever folder the session started in.

| Path | What |
|---|---|
| `$HOME_DIR/projects/<film>/` | one folder per film: brief, audio, beats.json, source, frames |
| `$HOME_DIR/out/` | final renders only |
| `$HOME_DIR/brands/<brand>.md` | brand kits; logo and font files in `brands/<brand>/` |
| `$HOME_DIR/docs/reference-<name>.md` | studied references, reused across films |
| `$HOME_DIR/lessons.md` | craft lessons, read before every film |
| `$HOME_DIR/.venv/bin/python` | the only Python to use (numpy, librosa, soundfile) |
| `scripts/` (this skill) | `beats.py`, `cut_audio.sh`, `render.mjs`, `contact_sheet.sh`, each with usage in its header |

Rules for every film: [rules.md](rules.md). Picking and driving a route: [routes.md](routes.md).

## Modes

- `/merxy-motion brand <name>`: follow **Brand mode** in [grill.md](grill.md), then stop.
- `/merxy-motion <brief>`: run **Film mode** below.

## Film mode

1. **Reference.** For each reference URL in the brief: if `docs/reference-<name>.md` exists, read it. Otherwise sample 12-20 frames across the video (built-in browser: seek the `<video>`, screenshot the player) and write that file: ground, palette, type, motion patterns, chapter pattern, pacing, end card. Done when the file exists and names what to take and what stays out (their copy, mascot, logo).
2. **Grill.** Run the film grill in [grill.md](grill.md): one round of numbered questions with recommended answers, covering only the checklist items the brief left open. Done when all 9 checklist items are settled. Write them to `projects/<film>/brief.md`.
3. **Load.** Read `lessons.md` and the chosen brand kit. Apply every lesson that touches this film.
4. **Route.** Pick the route with [routes.md](routes.md) and state it in one line with the reason.
5. **Audio.** Copy the track to `assets/audio/`. Write its source and license to `projects/<film>/license.md`; if the license is unknown, flag it in the checkpoint. Then:
   - `beats.py rank <track> --length <total s> --hit <s> --pad <s> --top 3` to rank windows.
   - `cut_audio.sh <track> projects/<film>/audio.wav <start> <total s> <pad>` for the best window.
   - `beats.py grid projects/<film>/audio.wav --out projects/<film>/beats.json`.
   Synthesized score instead: write it in code, render to `audio.wav`, then run `grid` the same way.
6. **Storyboard.** Write `projects/<film>/storyboard.md`: a table of time, beat, what lands, copy. Every event sits on a time from `beats.json`.
7. **Checkpoint.** Stop. Show the top 3 audio windows (start, why), the chosen one, the route, and the storyboard table. Build only after the user approves.
8. **Build.** Follow the route's section in [routes.md](routes.md) and every rule in [rules.md](rules.md).
9. **Loop.** Run **The loop** in [rules.md](rules.md) until every score is 8+.
10. **Render and verify.** Full render to `out/<film>.mp4`, then run every check under **Verify** in [rules.md](rules.md). Done when all checks pass.
11. **Deliver.** Report the path, the final contact sheet, the score table, and 2 lines on the audio window.
12. **Learn.** Propose additions in two short lists: brand-kit updates (approved copy, colors, faces, do/don't) and `lessons.md` entries (craft, process, tooling). Write each one only after the user approves it.
