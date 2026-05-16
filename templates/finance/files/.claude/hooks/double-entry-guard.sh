#!/usr/bin/env bash
# double-entry-guard.sh — PreToolUse / PostToolUse hook.
# Matchers: Bash, accounting MCP write tools (mcp__quickbooks__*, mcp__xero__*),
# and any tool whose input carries a journal payload.
#
# Enforces the double-entry invariant: for any journal entry the agent is about
# to post, the sum of debits must equal the sum of credits — to the cent. An
# unbalanced entry is refused.
#
# It looks for a JSON journal payload of the shape:
#   { "lines": [ { "debit": 100.00 }, { "credit": 100.00 }, ... ] }
# in .tool_input.journal, .tool_input.entry, .tool_input.payload, or the
# Bash command string. If no journal payload is present it no-ops.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"

payload="$(printf '%s' "$event" | jq -c '
  .tool_input.journal // .tool_input.entry // .tool_input.payload // empty
' 2>/dev/null)"

# Fall back to a JSON object embedded in a Bash command.
if [ -z "$payload" ]; then
  cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
  payload="$(printf '%s' "$cmd" | grep -oE '\{.*"lines".*\}' | head -1 || true)"
fi
[ -z "$payload" ] && exit 0

# Must contain a lines array to be a journal payload.
printf '%s' "$payload" | jq -e '.lines | type == "array"' >/dev/null 2>&1 || exit 0

# Sum debits and credits as integer cents to avoid float drift.
sums="$(printf '%s' "$payload" | jq -r '
  ([ .lines[] | ((.debit  // 0) * 100 | round) ] | add // 0),
  ([ .lines[] | ((.credit // 0) * 100 | round) ] | add // 0)
' 2>/dev/null)"

debit_cents="$(printf '%s' "$sums" | sed -n 1p | tr -dc '0-9-')"
credit_cents="$(printf '%s' "$sums" | sed -n 2p | tr -dc '0-9-')"

if [ -z "$debit_cents" ] || [ -z "$credit_cents" ]; then
  echo "BLOCKED (double-entry-guard): could not parse the journal payload." >&2
  echo "Post a well-formed { \"lines\": [...] } entry with numeric debit/credit." >&2
  exit 2
fi

# cents -> decimal display, portably (no locale-dependent awk).
fmt() { printf '%d.%02d' $(( ${1#-} / 100 )) $(( ${1#-} % 100 )); }

if [ "$debit_cents" -ne "$credit_cents" ]; then
  echo "BLOCKED (double-entry-guard): journal entry does not balance." >&2
  echo "  debits  = $(fmt "$debit_cents")" >&2
  echo "  credits = $(fmt "$credit_cents")" >&2
  echo "Sum of debits must equal sum of credits, to the cent." >&2
  exit 2
fi

exit 0
