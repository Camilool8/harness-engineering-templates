#!/usr/bin/env bash
# PostToolUse hook — matcher: *
# Append-only audit trail of every tool call. Never blocks (exit 0 always).
# Retention: keep matched to your regulatory regime (6 months min for any
# high-risk system; 7 years for finance). Rotate audit.jsonl accordingly.
set -uo pipefail

input="$(cat)"
dir="${CLAUDE_PROJECT_DIR:-.}/.claude/audit"
mkdir -p "$dir"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if command -v jq >/dev/null 2>&1; then
  printf '%s' "$input" | jq -c --arg ts "$ts" \
    '{ts:$ts, session:(.session_id // null), tool:(.tool_name // null), cwd:(.cwd // null), input:(.tool_input // {})}' \
    >> "$dir/audit.jsonl" 2>/dev/null \
  || echo "{\"ts\":\"$ts\",\"parse_error\":true}" >> "$dir/audit.jsonl"
else
  echo "{\"ts\":\"$ts\",\"raw\":true}" >> "$dir/audit.jsonl"
fi
exit 0
