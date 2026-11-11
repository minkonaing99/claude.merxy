# Studio rules

Look, Sound, Encode, The loop and Verify apply to every route. The render contract applies to the custom route only; HyperFrames and Remotion bring their own deterministic renderers.

## Look

- Banned defaults: centered title on a gradient, everything fading in, corner labels and frame borders, glow on UI chrome, generic particle bursts.
- One display face, one UI face. One accent color unless the brief says otherwise. The brand kit sets all three.
- Every 2 to 4 seconds something new happens on screen. Zero dead frames, pads included: a hold still drifts slowly.
- Everything reads at phone size: check the contact sheet at 480 px wide.

## Sound

- Score and SFX are synthesized in code unless a track is supplied.
- Every hit lands on the measured grid in `beats.json`. SFX sit under the music.
- Loudness: steady section at -14 LUFS, true peak at most -1 dBTP. Pads ramp from and to silence.

## Encode

- Default 1920x1080, 30 fps, unless the brief says otherwise.
- H.264, yuv420p, CRF 16, AAC 320k, `+faststart`.

## Render contract (custom route)

- Every film is a pure function of time: `window.seek(t)` paints frame t. It may return a promise.
- The film sets `window.__ready = true` once fonts, images and layout are loaded and `seek` is safe to call. On a failed init it sets `window.__error` to the message instead.
- Motion is computed from `t` alone: no CSS transitions or animations, no setTimeout, no requestAnimationFrame in render mode (`window.__RENDER__` is true), no state carried between frames.
- Seeded noise only (mulberry32). Springs are closed-form functions of t.
- Render with `scripts/render.mjs`.

## The loop

Run before showing the user anything rendered.

1. Render one frame per beat (custom: `render.mjs --frames <beats> --frames-dir projects/<film>/frames/loop-N`; HyperFrames: `hyperframes snapshot` at the beat times), then `contact_sheet.sh` on that folder, then LOOK at the sheet.
2. Score 1-10 on: hook in the first 2s, readability at phone size, motion quality, variety, brand accuracy, sound sync, plus one criterion per reference ("matches <reference> craft").
3. Fix the 3 worst problems.
4. Repeat until every score is 8+. Keep each round's sheet and scores in `projects/<film>/loop.md`.

## Verify

- `ffprobe`: duration, fps, resolution, `yuv420p`, an audio stream present.
- `ffmpeg -af ebur128` on the steady section: -14 LUFS within 1 LU.
- First and last 0.05s silent when the film has pads.
- Watch three frames from the final MP4 (start, biggest hit, end) to confirm the encode matches the loop.
