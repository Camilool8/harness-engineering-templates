#!/usr/bin/env bash
# block-unbounded-sql.sh — PreToolUse hook.
# Matchers: Bash and warehouse MCP query tools (mcp__snowflake__*,
# mcp__bigquery__*, mcp__databricks__*, mcp__felt__*).
#
# Enforces sample-then-scale and read-only discipline:
#   - A SELECT against the warehouse with neither WHERE nor LIMIT is blocked —
#     run LIMIT 1000 / TABLESAMPLE first, validate, then graduate.
#   - DROP / TRUNCATE / DELETE / UPDATE / INSERT / MERGE / ALTER is blocked —
#     warehouse mutation must go through a reviewed migration PR.
#
# Exit 2 = block (reason on stderr, fed back to the agent). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"

# Pull the SQL out of whichever field carries it.
sql="$(printf '%s' "$event" | jq -r '
  .tool_input.query // .tool_input.sql // .tool_input.statement //
  .tool_input.command // empty' 2>/dev/null)"
[ -z "$sql" ] && exit 0

# Only police Bash and warehouse MCP calls.
case "$tool" in
  Bash|mcp__snowflake__*|mcp__bigquery__*|mcp__databricks__*|mcp__felt__*) ;;
  *) exit 0 ;;
esac

lc="$(printf '%s' "$sql" | tr '[:upper:]' '[:lower:]')"

# Destructive / mutating SQL: route through a migration PR.
if printf '%s' "$lc" | grep -Eq '\b(drop|truncate|delete[[:space:]]+from|update[[:space:]]+[a-z_."]+[[:space:]]+set|insert[[:space:]]+into|merge[[:space:]]+into|alter[[:space:]]+table)\b'; then
  echo "BLOCKED: destructive / mutating SQL against the warehouse." >&2
  echo "DDL/DML must go through a reviewed migration PR, not an agent query." >&2
  exit 2
fi

# Unbounded SELECT: force sample-then-scale.
if printf '%s' "$lc" | grep -Eq '\bselect\b'; then
  if ! printf '%s' "$lc" | grep -Eq '\blimit\b' \
     && ! printf '%s' "$lc" | grep -Eq '\bwhere\b' \
     && ! printf '%s' "$lc" | grep -Eq '\btablesample\b'; then
    echo "BLOCKED: SELECT against the warehouse with no WHERE, LIMIT or TABLESAMPLE." >&2
    echo "Run LIMIT 1000 (or TABLESAMPLE) first, inspect the shape, then scale up." >&2
    exit 2
  fi
fi

exit 0
