#!/usr/bin/env bash
# Tile every PNG in a folder (sorted by name) into one contact sheet.
# Usage: contact_sheet.sh <frames_dir> <out.png> [columns=6] [tile_width=480]
set -euo pipefail

[ $# -ge 2 ] || { echo "usage: contact_sheet.sh <frames_dir> <out.png> [columns=6] [tile_width=480]" >&2; exit 2; }
DIR="$1"; OUT="$2"; COLS="${3:-6}"; W="${4:-480}"
[[ "$COLS" =~ ^[1-9][0-9]*$ && "$W" =~ ^[1-9][0-9]*$ ]] || { echo "columns and width must be positive integers" >&2; exit 2; }

N=$(find "$DIR" -maxdepth 1 -name '*.png' | wc -l | tr -d ' ')
[ "$N" -gt 0 ] || { echo "no PNGs in $DIR" >&2; exit 2; }
[ "$COLS" -le "$N" ] || COLS=$N
ROWS=$(( (N + COLS - 1) / COLS ))

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
i=0
find "$DIR" -maxdepth 1 -name '*.png' | sort | while IFS= read -r f; do
  i=$((i+1)); cp "$f" "$TMP/$(printf '%04d' "$i").png"
done

ffmpeg -hide_banner -loglevel error -y -framerate 1 -i "$TMP/%04d.png" \
  -vf "scale=${W}:-2,pad=iw+8:ih+8:4:4:white,tile=${COLS}x${ROWS}:color=white" \
  -frames:v 1 "$OUT"
echo "$N frames, ${COLS}x${ROWS} -> $OUT"
