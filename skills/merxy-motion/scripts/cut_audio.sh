#!/usr/bin/env bash
# Cut a window from a track: fade in from silence over PAD, fade out to silence
# over PAD, steady section normalized to -14 LUFS (sample peak -1 dBFS).
# Usage: cut_audio.sh <in> <out.wav> <start_s> <length_s> [pad_s=1]
set -euo pipefail

[ $# -ge 4 ] || { echo "usage: cut_audio.sh <in> <out.wav> <start_s> <length_s> [pad_s=1]" >&2; exit 2; }
IN="$1"; OUT="$2"; START="$3"; LEN="$4"; PAD="${5:-1}"
[ -f "$IN" ] || { echo "no such file: $IN" >&2; exit 2; }
for n in "$START" "$LEN" "$PAD"; do
  [[ "$n" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { echo "not a number: $n" >&2; exit 2; }
done
awk -v l="$LEN" -v p="$PAD" 'BEGIN{exit !(l>2*p)}' || { echo "need length > 2*pad" >&2; exit 2; }
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")
awk -v s="$START" -v l="$LEN" -v d="$DUR" 'BEGIN{exit !(s+l<=d+0.01)}' \
  || { echo "window $START+$LEN s runs past the track end (${DUR} s)" >&2; exit 2; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
ffmpeg -hide_banner -loglevel error -y -ss "$START" -t "$LEN" -i "$IN" -ac 2 -ar 48000 "$TMP/raw.wav"

# Measure integrated loudness of the steady section only, so fades do not skew it.
BODY=$(awk -v l="$LEN" -v p="$PAD" 'BEGIN{print l-2*p}')
measure() {
  ffmpeg -hide_banner -nostats -ss "$PAD" -t "$BODY" -i "$1" -af ebur128 -f null - 2>&1 \
    | awk '/Integrated loudness/{f=1} f&&/I:/{print $2; exit}'
}

# Gain toward -14 LUFS with a brickwall limiter at -1 dBFS. Limiting eats some
# loudness on peaky material, so re-measure and top up (at most 3 passes).
cp "$TMP/raw.wav" "$TMP/cur.wav"
for pass in 1 2 3; do
  NOW=$(measure "$TMP/cur.wav")
  awk -v m="${NOW:--99}" 'BEGIN{exit !(m>-50)}' || { echo "steady section is near-silent (${NOW:-?} LUFS); pick another window" >&2; exit 3; }
  GAIN=$(awk -v m="$NOW" 'BEGIN{print -14-m}')
  awk -v g="$GAIN" 'BEGIN{exit !(g<0.3 && g>-0.3)}' && break
  ffmpeg -hide_banner -loglevel error -y -i "$TMP/cur.wav" \
    -af "volume=${GAIN}dB,alimiter=limit=0.891:level=false:latency=true" "$TMP/next.wav"
  mv "$TMP/next.wav" "$TMP/cur.wav"
done
FINAL=$(measure "$TMP/cur.wav")

FADE_OUT=$(awk -v l="$LEN" -v p="$PAD" 'BEGIN{print l-p}')
ffmpeg -hide_banner -loglevel error -y -i "$TMP/cur.wav" \
  -af "afade=t=in:st=0:d=${PAD}:curve=qsin,afade=t=out:st=${FADE_OUT}:d=${PAD}:curve=qsin" \
  -t "$LEN" -c:a pcm_s16le "$OUT"

echo "cut $START+$LEN s, pad $PAD s, steady section $FINAL LUFS -> $OUT"
