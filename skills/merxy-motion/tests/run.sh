#!/usr/bin/env bash
# Tests for the merxy-motion scripts. Run: bash tests/run.sh
set -uo pipefail

SKILL="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="${MOTION_HOME:-/Users/aurora/Documents/claude-motion}"
PY="$HOME_DIR/.venv/bin/python"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

check() {
  if eval "$2"; then PASS=$((PASS+1)); echo "ok   $1"
  else FAIL=$((FAIL+1)); echo "FAIL $1"; fi
}
near() { "$PY" -c "import sys; sys.exit(0 if abs(float('$1')-float('$2'))<=float('$3') else 1)"; }
dur() { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"; }

# Fixture: 30s, 120 BPM clicks, quiet first half, loud second half, big hit at 20.0s.
"$PY" - "$TMP/track.wav" <<'EOF'
import sys, numpy as np, soundfile as sf
sr = 44100; t = np.arange(30 * sr) / sr
y = np.zeros_like(t)
for b in np.arange(0, 30, 0.5):
    i = int(b * sr); n = int(0.05 * sr)
    amp = 0.15 if b < 15 else 0.5
    y[i:i+n] += amp * np.sin(2*np.pi*880*t[:n]) * np.exp(-t[:n]*60)
y += np.where(t >= 15, 0.08, 0.02) * np.sin(2*np.pi*110*t)
h = int(20.0 * sr); y[h:h+int(0.3*sr)] += 0.9 * np.random.default_rng(1).uniform(-1, 1, int(0.3*sr)) * np.exp(-np.arange(int(0.3*sr))/sr*10)
sf.write(sys.argv[1], np.clip(y, -1, 1), sr)
EOF

# beats.py rank
"$PY" "$SKILL/scripts/beats.py" rank "$TMP/track.wav" --length 8 --hit 5 --top 3 > "$TMP/rank.json" 2>"$TMP/rank.err"
check "rank exits 0" "[ -s '$TMP/rank.json' ]"
check "rank tempo ~120" "near \"\$('$PY' -c \"import json;print(json.load(open('$TMP/rank.json'))['tempo'])\")\" 120 3"
check "rank returns 3 windows" "[ \"\$('$PY' -c \"import json;print(len(json.load(open('$TMP/rank.json'))['windows']))\")\" = 3 ]"
check "best window puts hit at 20s near +5s" "near \"\$('$PY' -c \"import json;print(json.load(open('$TMP/rank.json'))['windows'][0]['start'])\")\" 15 1.1"

# cut_audio.sh
bash "$SKILL/scripts/cut_audio.sh" "$TMP/track.wav" "$TMP/cut.wav" 14 8 1 >/dev/null 2>"$TMP/cut.err"
check "cut exists" "[ -s '$TMP/cut.wav' ]"
check "cut duration 8.0s" "near \"\$(dur '$TMP/cut.wav')\" 8 0.03"
check "cut first sample silent" "'$PY' -c \"import soundfile as sf,sys;y,_=sf.read('$TMP/cut.wav');sys.exit(0 if abs(y[:10]).max()<1e-3 else 1)\""
check "cut last sample silent" "'$PY' -c \"import soundfile as sf,sys;y,_=sf.read('$TMP/cut.wav');sys.exit(0 if abs(y[-10:]).max()<1e-3 else 1)\""
LUFS=$(ffmpeg -hide_banner -nostats -ss 1 -t 6 -i "$TMP/cut.wav" -af ebur128 -f null - 2>&1 | awk '/Integrated loudness/{f=1} f&&/I:/{print $2; exit}')
check "cut steady section ~-14 LUFS ($LUFS)" "near '$LUFS' -14 1.0"

check "cut rejects window past track end" "! bash '$SKILL/scripts/cut_audio.sh' '$TMP/track.wav' '$TMP/bad.wav' 25 8 1 2>/dev/null"
check "cut rejects length <= 2*pad" "! bash '$SKILL/scripts/cut_audio.sh' '$TMP/track.wav' '$TMP/bad.wav' 5 2 1 2>/dev/null"
check "rank rejects --top 0" "! '$PY' '$SKILL/scripts/beats.py' rank '$TMP/track.wav' --length 8 --hit 5 --top 0 >/dev/null 2>&1"

# beats.py grid
"$PY" "$SKILL/scripts/beats.py" grid "$TMP/cut.wav" --out "$TMP/beats.json" 2>/dev/null
check "grid writes beats" "'$PY' -c \"import json,sys;d=json.load(open('$TMP/beats.json'));sys.exit(0 if len(d['beats'])>=10 and d['downbeats'] and 'hits' in d else 1)\""
check "grid finds hit near 6s" "'$PY' -c \"import json,sys;d=json.load(open('$TMP/beats.json'));sys.exit(0 if any(abs(h-6)<0.3 for h in d['hits']) else 1)\""

# render.mjs on a tiny seekable film
cat > "$TMP/film.html" <<'EOF'
<html><body style="margin:0"><div id=b style="width:100vw;height:100vh"></div>
<script>window.seek=t=>{document.getElementById("b").style.background=`hsl(${(t*90)%360},70%,50%)`};window.__ready=true</script></body></html>
EOF
(cd "$HOME_DIR" && node "$SKILL/scripts/render.mjs" --html "$TMP/film.html" --out "$TMP/film.mp4" --audio "$TMP/cut.wav" --duration 2 --width 320 --height 180 >/dev/null 2>"$TMP/render.err")
check "render mp4 exists" "[ -s '$TMP/film.mp4' ]"
check "render 30 fps" "[ \"\$(ffprobe -v error -select_streams v -show_entries stream=r_frame_rate -of csv=p=0 '$TMP/film.mp4')\" = '30/1' ]"
check "render 60 frames" "[ \"\$(ffprobe -v error -count_frames -select_streams v -show_entries stream=nb_read_frames -of csv=p=0 '$TMP/film.mp4')\" = 60 ]"
check "render yuv420p" "[ \"\$(ffprobe -v error -select_streams v -show_entries stream=pix_fmt -of csv=p=0 '$TMP/film.mp4')\" = yuv420p ]"
check "render tagged bt709" "[ \"\$(ffprobe -v error -select_streams v -show_entries stream=color_space -of csv=p=0 '$TMP/film.mp4')\" = bt709 ]"
(cd "$HOME_DIR" && node "$SKILL/scripts/render.mjs" --html "$TMP/film.html" --out "$TMP/odd.mp4" --duration 1 --width 320 --height 181 >/dev/null 2>"$TMP/odd.err"); RC=$?
check "render rejects odd height cleanly" "[ $RC -ne 0 ] && [ ! -e '$TMP/odd.mp4' ] && ! grep -q 'triggerUncaughtException' '$TMP/odd.err'"
check "render has audio" "[ -n \"\$(ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 '$TMP/film.mp4')\" ]"

# render.mjs --frames is deterministic
(cd "$HOME_DIR" && node "$SKILL/scripts/render.mjs" --html "$TMP/film.html" --frames 0.5,1.5,0.5 --frames-dir "$TMP/f" --width 320 --height 180 >/dev/null 2>>"$TMP/render.err")
check "frames written" "[ -s '$TMP/f/0001.png' ] && [ -s '$TMP/f/0003.png' ]"
check "same t gives same frame" "cmp -s '$TMP/f/0001.png' '$TMP/f/0003.png'"

# contact_sheet.sh
bash "$SKILL/scripts/contact_sheet.sh" "$TMP/f" "$TMP/sheet.png" 2 >/dev/null 2>"$TMP/sheet.err"
check "contact sheet exists" "[ -s '$TMP/sheet.png' ]"

echo "pass $PASS  fail $FAIL"
[ "$FAIL" -eq 0 ] || { tail -n 5 "$TMP"/*.err 2>/dev/null; exit 1; }
