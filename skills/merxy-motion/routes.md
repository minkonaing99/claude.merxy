# Routes

Pick one per film. HyperFrames is the house default.

| Brief looks like | Route |
|---|---|
| Intro, title card, logo sting, kinetic type, UI motion, beat-synced promo, explainer | **HyperFrames** |
| Data-driven, templated or batch videos, React-heavy UI | **Remotion** |
| Sketch, hand-drawn, pen-on-paper look | **claude-animation** |
| Something the other three fight against (exotic per-frame canvas, WebGL you write yourself) | **Custom** |

## HyperFrames

- Invoke `/hyperframes` with the brief, the brand kit and the storyboard. It routes to the right sub-skill (`/motion-graphics` for short intros and stings, `/music-to-video` for beat-led pieces, `/general-video` for longer multi-scene work).
- Hand it `projects/<film>/audio.wav` and `beats.json`; the cut is already made and normalized.
- Search `/hyperframes-registry` before hand-building any named effect.
- Build inside `projects/<film>/`. Its renderer replaces `render.mjs`; pass the Encode settings from rules.md.

## Remotion

- `/remotion-create` to scaffold inside `projects/<film>/`, `/remotion-best-practices` for the rest, `/remotion-render` to export with the Encode settings.
- Drive timing from `beats.json` converted to frames (`Math.round(t * fps)`).

## claude-animation

- Invoke `claude-animation:claude-animation` for rigs, pens and synthesized sound.
- It renders through Node canvas; mux `audio.wav` and encode with the Encode settings.

## Custom

- One `projects/<film>/index.html` exposing `window.seek(t)`, following the render contract in rules.md.
- Full render: `node scripts/render.mjs --html projects/<film>/index.html --out out/<film>.mp4 --duration <s> --audio projects/<film>/audio.wav`, run from `$HOME_DIR` (Playwright resolves from there).
