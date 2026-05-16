#!/usr/bin/env bash
# PreToolUse hook — matcher: Write|Edit|MultiEdit
# Blocks writes that contain obvious hardcoded secrets. Exit 2 = block.
# This is a deterministic gate: it survives --dangerously-skip-permissions.
set -euo pipefail

input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null || true; }

content="$(get '.tool_input.content')$(get '.tool_input.new_string')"
path="$(get '.tool_input.file_path')"
[ -z "$content" ] && exit 0

# Allow example/placeholder files to carry illustrative fake keys.
case "$path" in
  *.example|*.sample|*.md|*/fixtures/*|*/__fixtures__/*) exit 0 ;;
esac

patterns='AKIA[0-9A-Z]{16}'
patterns="$patterns|ASIA[0-9A-Z]{16}"
patterns="$patterns|ghp_[A-Za-z0-9]{36}"
patterns="$patterns|github_pat_[A-Za-z0-9_]{60,}"
patterns="$patterns|sk-[A-Za-z0-9]{32,}"
patterns="$patterns|xox[baprs]-[A-Za-z0-9-]{10,}"
patterns="$patterns|AIza[0-9A-Za-z_-]{35}"
patterns="$patterns|-----BEGIN [A-Z ]*PRIVATE KEY-----"
patterns="$patterns|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]+"

if printf '%s' "$content" | grep -Eq "$patterns"; then
  echo "BLOCKED: possible hardcoded secret in '$path'." >&2
  echo "Use environment variables or a secret manager. If this is a false" >&2
  echo "positive, rename the file to *.example or move it under fixtures/." >&2
  exit 2
fi
exit 0
