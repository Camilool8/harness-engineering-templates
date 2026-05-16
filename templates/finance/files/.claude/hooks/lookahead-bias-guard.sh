#!/usr/bin/env bash
# lookahead-bias-guard.sh — PreToolUse hook on Write|Edit|MultiEdit.
# Scans edited Python for the validation mistakes that silently inflate a
# backtest's measured performance:
#   - train_test_split(shuffle=True)   — shuffles time-ordered data
#   - KFold(shuffle=True) with no TimeSeriesSplit present — same problem
#   - .shift(-N)                       — pulls future data into a feature
#
# For time-series and financial data the only honest split is chronological.
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
[ -z "$path" ] && exit 0
case "$path" in *.py) ;; *) exit 0 ;; esac

content="$(printf '%s' "$event" | jq -r '
  .tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"
[ -z "$content" ] && exit 0

# Normalize whitespace so "shuffle = True" matches too.
norm="$(printf '%s' "$content" | tr -s '[:space:]' ' ')"

block() {
  echo "BLOCKED (lookahead-bias-guard): $1" >&2
  echo "  $2" >&2
  exit 2
}

if printf '%s' "$norm" | grep -Eq 'train_test_split\([^)]*shuffle *= *True'; then
  block "train_test_split(shuffle=True) on time-ordered data." \
        "Use shuffle=False, or split chronologically with an explicit cutoff date."
fi

if printf '%s' "$norm" | grep -Eq 'KFold\([^)]*shuffle *= *True' \
   && ! printf '%s' "$norm" | grep -Eq 'TimeSeriesSplit'; then
  block "KFold(shuffle=True) with no TimeSeriesSplit in this file." \
        "Time-series CV must use TimeSeriesSplit (or purged/combinatorial CV)."
fi

if printf '%s' "$norm" | grep -Eq '\.shift\( *-[0-9]'; then
  block "a .shift(-N) call leaks future values into a feature." \
        "Only shift forward; a negative shift is look-ahead bias."
fi

exit 0
