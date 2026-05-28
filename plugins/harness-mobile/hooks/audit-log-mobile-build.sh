#!/usr/bin/env bash
# audit-log-mobile-build.sh — PostToolUse hook.
# Matchers: Bash (mobile build/sim CLIs: xcodebuild, xcrun simctl, xcrun
# devicectl, gradle, gradlew, adb, expo, eas, fastlane, pod, flutter, dart)
# and XcodeBuildMCP / Sentry / Expo / Firebase MCP tools.
#
# Appends one JSON line per invocation to .claude/logs/agent_audit.jsonl.
# The log is the Play Console "evidence of testing" surface and the iOS
# build provenance trail for store-submission audits.
#
# Exit 0 always — this hook records, never blocks.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"

cmd="$(printf '%s' "$event" | jq -r '
  .tool_input.command // .tool_input.cmd // .tool_input.query // empty' 2>/dev/null)"

case "$tool" in
  Bash)
    [ -z "$cmd" ] && exit 0
    printf '%s' "$cmd" | grep -Eq '\b(xcodebuild|xcrun|gradle|gradlew|adb|expo|eas|fastlane|pod|flutter|dart)\b' || exit 0
    ;;
  mcp__XcodeBuildMCP__*|mcp__xcodebuildmcp__*|mcp__expo__*|mcp__firebase__*|mcp__sentry__*) ;;
  *) exit 0 ;;
esac

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
session="${CLAUDE_SESSION_ID:-unknown}"
exit_code="$(printf '%s' "$event" | jq -r '.tool_response.exit_code // .tool_response.code // empty' 2>/dev/null)"

record="$(jq -nc \
  --arg ts "$ts" \
  --arg session "$session" \
  --arg tool "$tool" \
  --arg command "$cmd" \
  --arg exit_code "$exit_code" \
  '{timestamp:$ts, session_id:$session, tool_name:$tool, command:$command,
    exit_code:($exit_code // null)}')"

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"
printf '%s\n' "$record" >> "$log_dir/agent_audit.jsonl"

exit 0
