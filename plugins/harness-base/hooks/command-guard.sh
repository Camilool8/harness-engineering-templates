#!/usr/bin/env bash
# PreToolUse hook — matcher: Bash
# Blocks irreversible / destructive shell commands. Exit 2 = block.
set -euo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

# Ordered: nuclear patterns first.
deny='rm[[:space:]]+-rf?[[:space:]]+(/|~|\$HOME|\*)'
deny="$deny|:\(\)\{.*\};:"                       # fork bomb
deny="$deny|mkfs|dd[[:space:]]+if="              # disk wipe
deny="$deny|git[[:space:]]+push[[:space:]].*--force([^-]|$)"
deny="$deny|git[[:space:]]+push[[:space:]].*-f([[:space:]]|$)"
deny="$deny|git[[:space:]]+reset[[:space:]]+--hard"
deny="$deny|git[[:space:]]+clean[[:space:]]+-[a-z]*f"
deny="$deny|DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)"
deny="$deny|TRUNCATE[[:space:]]+TABLE"
deny="$deny|chmod[[:space:]]+-R?[[:space:]]+777"
deny="$deny|--dangerously-skip-permissions"

if printf '%s' "$cmd" | grep -Eiq "$deny"; then
  echo "BLOCKED: this command looks destructive or irreversible:" >&2
  echo "  $cmd" >&2
  echo "Get explicit human approval, or ask the user to run it themselves." >&2
  exit 2
fi
exit 0
