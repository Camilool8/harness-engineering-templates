#!/usr/bin/env bash
# PostToolUse hook — matcher: Edit|Write|MultiEdit
# Brand-voice guard. Flags banned clichés / filler phrases in edited content
# files. Advisory (warn, exit 0) — the human author makes the final call, but
# every banned phrase is surfaced loudly.
set -euo pipefail

BANNED_FILE=".claude/banned-phrases.txt"

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$path" ] && exit 0

case "$path" in
  *.md|*.mdx|*.markdown|*.txt|*.html|*.qmd) ;;
  *) exit 0 ;;
esac

[ -f "$BANNED_FILE" ] || exit 0
[ -f "$path" ] || exit 0

hits=""
while IFS= read -r phrase; do
  case "$phrase" in ''|\#*) continue;; esac
  if grep -iqF "$phrase" "$path"; then
    hits="$hits|$phrase"
  fi
done < "$BANNED_FILE"

if [ -n "$hits" ]; then
  echo "BRAND-VOICE WARNING: '$path' contains banned phrases:" >&2
  printf '%s\n' "${hits#|}" | tr '|' '\n' | sed 's/^/  - /' >&2
  echo "Rewrite these in the brand voice before this draft ships." >&2
fi
exit 0
