#!/usr/bin/env bash
# Claude Code status line script
# Shows: folder | git branch | model | ctx % | 5h % | cost

input=$(cat)

# --- Extract fields ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '
  .rate_limits.five_hour.resets_at //
  .rate_limits.five_hour.reset_at //
  .rate_limits.five_hour.resets //
  empty')
extra_pct=$(echo "$input" | jq -r '
  .rate_limits.extra.used_percentage //
  .rate_limits.extra_usage.used_percentage //
  .rate_limits.overage.used_percentage //
  .usage.extra.used_percentage //
  empty')
session_cost=$(echo "$input" | jq -r '.session_cost // empty')

# --- Folder (last 2 path segments) ---
parent=$(basename "$(dirname "$cwd")")
base=$(basename "$cwd")
if [ -n "$parent" ] && [ "$parent" != "." ] && [ "$parent" != "/" ]; then
  folder="${parent}/${base}"
else
  folder="$base"
fi

# --- Git branch (skip lock, silent) ---
branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- Progress bar (10 chars wide) ---
build_bar() {
  local pct="$1"
  local width=10
  local filled=0
  if [ -n "$pct" ]; then
    filled=$(printf '%.0f' "$(echo "$pct * $width / 100" | bc -l 2>/dev/null || echo 0)")
  fi
  [ "$filled" -gt "$width" ] && filled=$width
  local empty=$(( width - filled ))
  local bar=""
  local i
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done
  echo "$bar"
}

# --- Color a percentage value by threshold ---
# < 61%  → no color (plain)
# 61–85% → yellow
# >= 86% → red
color_pct() {
  local pct="$1"
  local label="$2"
  local YELLOW=$'\e[33m'
  local RED=$'\e[31m'
  local RESET=$'\e[0m'
  local int_pct
  int_pct=$(printf '%.0f' "$pct")
  if [ "$int_pct" -ge 86 ]; then
    printf "%s%s%s" "${RED}" "${label}" "${RESET}"
  elif [ "$int_pct" -ge 61 ]; then
    printf "%s%s%s" "${YELLOW}" "${label}" "${RESET}"
  else
    printf "%s" "${label}"
  fi
}

# --- Assemble line ---
# Segment separator
SEP=" | "

line=""

# Folder
line="${line} ${folder}"

# Git branch
if [ -n "$branch" ]; then
  line="${line}${SEP}${branch}"
fi

# Model
if [ -n "$model" ]; then
  line="${line}${SEP}${model}"
fi

# Context: percentage only (no progress bar)
if [ -n "$used_pct" ]; then
  ctx_label=$(printf '%.0f' "$used_pct")
  line="${line}${SEP}ctx:$(color_pct "$used_pct" "${ctx_label}%")"
fi

# 5-hour rate limit: percentage only (only when present)
if [ -n "$five_pct" ]; then
  five_label=$(printf '%.0f' "$five_pct")
  reset_str=""
  if [ -n "$five_reset" ]; then
    if [[ "$five_reset" =~ ^[0-9]+$ ]]; then
      reset_str=$(date -r "$five_reset" "+%-I:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    else
      clean="${five_reset%%.*}"
      clean="${clean%Z}"
      clean="${clean%+*}"
      reset_str=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null \
                  | xargs -I{} date -r {} "+%-I:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]')
      [ -z "$reset_str" ] && reset_str=$(date -d "$five_reset" "+%-I:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    fi
  fi
  if [ -n "$reset_str" ]; then
    line="${line}${SEP}5h:$(color_pct "$five_pct" "${five_label}% (${reset_str})")"
  else
    line="${line}${SEP}5h:$(color_pct "$five_pct" "${five_label}%")"
  fi
fi

# Extra usage: only when present and non-zero
if [ -n "$extra_pct" ]; then
  extra_int=$(printf '%.0f' "$extra_pct")
  if [ "$extra_int" -gt 0 ]; then
    line="${line}${SEP}extra:$(color_pct "$extra_pct" "${extra_int}%")"
  fi
fi

# Session cost (only when present and non-zero)
if [ -n "$session_cost" ] && [ "$session_cost" != "0" ] && [ "$session_cost" != "0.0" ]; then
  cost_label=$(printf '$%.2f' "$session_cost")
  line="${line}${SEP}${cost_label}"
fi

printf "%s" "$line"
