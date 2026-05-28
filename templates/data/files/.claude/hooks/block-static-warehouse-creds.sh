#!/usr/bin/env bash
# block-static-warehouse-creds.sh — PreToolUse hook on Bash.
# Refuses to proceed if static warehouse credentials are present in env when
# a Managed-MCP / OAuth alternative exists for that warehouse. Codifies the
# post-ShinyHunters (April 2026) credential-posture default: agent hosts do
# not hold long-lived warehouse creds.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police warehouse CLI invocations. Other Bash is fine.
printf '%s' "$cmd" | grep -Eq '\b(snow|bq|databricks|duckdb|motherduck)\b' || exit 0

issues=()
[ -n "${SNOWFLAKE_PASSWORD:-}" ]                       && issues+=("SNOWFLAKE_PASSWORD set — use Snowflake Cortex Managed MCP / OAuth.")
[ -n "${BIGQUERY_SERVICE_ACCOUNT_KEY_JSON:-}" ]        && issues+=("BIGQUERY_SERVICE_ACCOUNT_KEY_JSON set — use GCP Workload Identity Federation.")
[ -n "${DATABRICKS_TOKEN:-}" ]                         && issues+=("DATABRICKS_TOKEN set — use Databricks MCP with OAuth / Service Principal Federation.")
[ -n "${DATABRICKS_PERSONAL_ACCESS_TOKEN:-}" ]         && issues+=("DATABRICKS_PERSONAL_ACCESS_TOKEN set — use OAuth.")
[ -n "${MOTHERDUCK_TOKEN:-}" ]                         && issues+=("MOTHERDUCK_TOKEN set — use the MotherDuck OAuth flow via duckdb-mcp.")

if [ "${#issues[@]}" -gt 0 ]; then
  echo "BLOCKED: static warehouse credentials present in env (post-ShinyHunters 2026 posture)." >&2
  for i in "${issues[@]}"; do echo "  - $i" >&2; done
  echo "Remove the static cred from env; use the Managed-MCP / OAuth path." >&2
  exit 2
fi

exit 0
