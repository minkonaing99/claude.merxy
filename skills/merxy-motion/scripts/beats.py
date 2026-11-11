"""Beat analysis for merxy-motion.

  rank <audio> --length 12 --hit 8.5 [--pad 1] [--top 3]
      Rank candidate windows of the full track. Prints JSON.
  grid <clip> --out beats.json
      Beat grid of an already-cut clip, times relative to the clip.
"""
import argparse
import json
import math
import sys

import librosa
import numpy as np

HOP = 512


def analyze(path):
    y, sr = librosa.load(path, sr=22050, mono=True)
    onset = librosa.onset.onset_strength(y=y, sr=sr, hop_length=HOP)
    tempo, beat_frames = librosa.beat.beat_track(onset_envelope=onset, sr=sr, hop_length=HOP, trim=False)
    rms = librosa.feature.rms(y=y, hop_length=HOP)[0]
    times = librosa.frames_to_time(np.arange(len(onset)), sr=sr, hop_length=HOP)
    beats = librosa.frames_to_time(beat_frames, sr=sr, hop_length=HOP)
    return {
        "tempo": float(np.atleast_1d(tempo)[0]),
        "beats": beats,
        "onset": onset / (onset.max() or 1),
        "rms": rms[: len(onset)] / (rms.max() or 1),
        "times": times,
        "duration": len(y) / sr,
    }


def downbeats(beats, onset, times):
    """Every 4th beat, phase chosen by the strongest summed onset."""
    if len(beats) < 4:
        return beats
    idx = np.searchsorted(times, beats).clip(0, len(onset) - 1)
    phase = max(range(4), key=lambda p: onset[idx[p::4]].mean())
    return beats[phase::4]


def hits(onset, times, beats, pct=98, floor=0.6, gap=0.75):
    """Big accents: onset peaks above both the percentile and the floor, at least
    `gap` seconds apart (strongest wins), snapped to the nearest beat when close."""
    peaks = librosa.util.peak_pick(onset, pre_max=8, post_max=8, pre_avg=8, post_avg=8, delta=0.05, wait=8)
    cut = max(np.percentile(onset, pct), floor * onset.max())
    strong = sorted((p for p in peaks if onset[p] >= cut), key=lambda p: -onset[p])
    kept = []
    for p in strong:
        if all(abs(times[p] - times[k]) >= gap for k in kept):
            kept.append(p)
    out = []
    for p in kept:
        t = times[p]
        if len(beats):
            b = beats[np.abs(beats - t).argmin()]
            t = b if abs(b - t) < 0.08 else t
        out.append(round(float(t), 3))
    return sorted(set(out))


def window_score(a, start, length, hit_at, pad):
    t, rms, onset = a["times"], a["rms"], a["onset"]
    body = (t >= start + pad) & (t < start + length - pad)
    half = start + length / 2
    if not (body & (t >= half)).any() or not (body & (t < half)).any():
        return None
    build = rms[body & (t >= half)].mean() - rms[body & (t < half)].mean()
    near_hit = np.abs(t - (start + hit_at)) <= 0.35
    near_start = np.abs(t - (start + pad)) <= 0.15
    parts = {
        "energy": float(rms[body].mean()),
        "build": float(build),
        "hit": float(onset[near_hit].max()) if near_hit.any() else 0.0,
        "attack": float(onset[near_start].max()) if near_start.any() else 0.0,
    }
    score = 1.0 * parts["energy"] + 0.6 * parts["build"] + 1.2 * parts["hit"] + 0.4 * parts["attack"]
    return round(score, 4), {k: round(v, 3) for k, v in parts.items()}


def rank(args):
    a = analyze(args.audio)
    starts = downbeats(a["beats"], a["onset"], a["times"])
    scored = []
    for s in starts:
        if s + args.length > a["duration"]:
            break
        r = window_score(a, s, args.length, args.hit, args.pad)
        if r:
            scored.append({"start": round(float(s), 3), "score": r[0], "parts": r[1]})
    if not scored:
        sys.exit(f"no window fits: track {a['duration']:.1f}s, {len(starts)} downbeats, length {args.length}s")
    scored.sort(key=lambda w: w["score"], reverse=True)
    picked = []
    for w in scored:
        if all(abs(w["start"] - p["start"]) >= args.length / 2 for p in picked):
            picked.append(w)
        if len(picked) >= args.top:
            break
    print(json.dumps({"tempo": round(a["tempo"], 2), "duration": round(a["duration"], 3), "windows": picked}, indent=2))


def grid(args):
    a = analyze(args.audio)
    data = {
        "tempo": round(a["tempo"], 2),
        "duration": round(a["duration"], 3),
        "beats": [round(float(b), 3) for b in a["beats"]],
        "downbeats": [round(float(b), 3) for b in downbeats(a["beats"], a["onset"], a["times"])],
        "hits": hits(a["onset"], a["times"], a["beats"]),
    }
    with open(args.out, "w") as f:
        json.dump(data, f, indent=2)
    print(f"{len(data['beats'])} beats, {len(data['hits'])} hits -> {args.out}")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("rank")
    r.add_argument("audio")
    r.add_argument("--length", type=float, required=True, help="window length in s, pads included")
    r.add_argument("--hit", type=float, required=True, help="where the big hit should land, s from window start")
    r.add_argument("--pad", type=float, default=0.0)
    r.add_argument("--top", type=int, default=3)
    g = sub.add_parser("grid")
    g.add_argument("audio")
    g.add_argument("--out", required=True)
    args = p.parse_args()
    if args.cmd == "rank":
        nums = (args.length, args.hit, args.pad)
        if not all(math.isfinite(n) for n in nums) or args.pad < 0 or args.top < 1:
            sys.exit("need finite numbers, pad >= 0, top >= 1")
        if args.length <= 2 * args.pad or not 0 <= args.hit <= args.length:
            sys.exit("need length > 2*pad and 0 <= hit <= length")
    (rank if args.cmd == "rank" else grid)(args)


if __name__ == "__main__":
    main()
