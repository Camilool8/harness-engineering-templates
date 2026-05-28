#!/usr/bin/env bash
# audit-log-warehouse-query.sh — PostToolUse hook.
# Matchers: Bash (warehouse CLI: snow sql, bq query, databricks sql, duckdb)
# and warehouse MCP query tools (mcp__snowflake__*, mcp__bigquery__*,
# mcp__databricks__*, mcp__felt__*, mcp__duckdb__*).
#
# Appends one JSON line per query to .claude/logs/agent_audit.jsonl. The log
# is the EU AI Act Annex IV (Aug 2 2026) compliance evidence path and the
# NIST AI RMF / ISO 42001 rebuttable-presumption surface (Texas RAIGA,
# Colorado AI Act, California AI Transparency Act).
#
# Exit 0 always — this hook records, never blocks.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"

# Pull query text — may be in any of these fields depending on tool.
sql="$(printf '%s' "$event" | jq -r '
  .tool_input.query // .tool_input.sql // .tool_input.statement //
  .tool_input.command // empty' 2>/dev/null)"
[ -z "$sql" ] && exit 0

# Only police Bash and warehouse MCP calls.
case "$tool" in
  Bash)
    # For Bash, only log when the command matches a warehouse CLI invocation.
    printf '%s' "$sql" | grep -Eq '\b(snow|bq|databricks|duckdb|motherduck)\b' || exit 0
    ;;
  mcp__snowflake__*|mcp__bigquery__*|mcp__databricks__*|mcp__felt__*|mcp__duckdb__*) ;;
  *) exit 0 ;;
esac

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
session="${CLAUDE_SESSION_ID:-unknown}"
row_count="$(printf '%s' "$event" | jq -r '.tool_response.row_count // .tool_response.rows // empty' 2>/dev/null)"
byte_count="$(printf '%s' "$event" | jq -r '.tool_response.byte_count // .tool_response.bytes // empty' 2>/dev/null)"
cost_estimate="$(printf '%s' "$event" | jq -r '.tool_response.cost_estimate // empty' 2>/dev/null)"

# Build the audit record. `jq -n` builds JSON safely (no string escaping bugs).
record="$(jq -nc \
  --arg ts "$ts" \
  --arg session "$session" \
  --arg tool "$tool" \
  --arg query "$sql" \
  --arg rows "$row_count" \
  --arg bytes "$byte_count" \
  --arg cost "$cost_estimate" \
  '{timestamp:$ts, session_id:$session, tool_name:$tool, query:$query,
    row_count:($rows // null), byte_count:($bytes // null),
    cost_estimate:($cost // null)}')"

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"
printf '%s\n' "$record" >> "$log_dir/agent_audit.jsonl"

exit 0
