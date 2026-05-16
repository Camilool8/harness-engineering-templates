#!/usr/bin/env bash
# PostToolUse hook — matcher: Edit|Write|MultiEdit
# Blue-team posture: run semgrep on edited code as an advisory SAST pass.
# Non-blocking — findings go to stderr, exit is always 0.
set -euo pipefail

command -v semgrep >/dev/null 2>&1 || exit 0   # semgrep optional.

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$path" ] && exit 0
[ -f "$path" ] || exit 0

case "$path" in
  *.py|*.js|*.ts|*.jsx|*.tsx|*.go|*.rb|*.java|*.php|*.c|*.cpp|*.cs|*.rs) ;;
  *) exit 0 ;;
esac

out="$(semgrep --config auto --quiet --error --timeout 30 "$path" 2>/dev/null || true)"
if [ -n "$out" ]; then
  echo "SAST (semgrep) findings on '$path' — advisory, review before relying on this code:" >&2
  printf '%s\n' "$out" >&2
fi
exit 0
