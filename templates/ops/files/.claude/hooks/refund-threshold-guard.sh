#!/usr/bin/env bash
# PreToolUse hook — matcher: Bash
# Customer-money gate. Inspects refund/credit commands for an amount, auto-
# allows small amounts, and HARD-BLOCKS anything at or above the threshold so
# a human approves it. Exit 2 = block.
#
# REFUND_THRESHOLD (env) sets the auto-allow ceiling; default 50.
set -euo pipefail

THRESHOLD="${REFUND_THRESHOLD:-50}"

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

# Only gate commands that move customer money.
printf '%s' "$cmd" | grep -Eiq 'refund|credit|chargeback|reimburse' || exit 0

# Extract the largest monetary amount in the command (handles $, commas).
amount="$(printf '%s' "$cmd" \
  | grep -Eo '\$?[0-9][0-9,]*(\.[0-9]+)?' \
  | tr -d '$,' \
  | sort -n | tail -1 || true)"

if [ -z "$amount" ]; then
  echo "BLOCKED: refund/credit command with no detectable amount:" >&2
  echo "  $cmd" >&2
  echo "State the amount explicitly so it can be checked against the threshold." >&2
  exit 2
fi

# Integer comparison (drop cents) for portability.
amt_int="${amount%.*}"
if [ "$amt_int" -ge "$THRESHOLD" ]; then
  echo "BLOCKED: refund/credit of \$$amount is at or above the \$$THRESHOLD threshold." >&2
  echo "This is an irreversible customer-money action — do NOT execute it." >&2
  echo "Escalate to a human: draft the refund, summarize the case, and hand" >&2
  echo "off for approval via the privileged publisher / on-call channel." >&2
  exit 2
fi

echo "NOTE: refund/credit of \$$amount is under the \$$THRESHOLD threshold — auto-allowed." >&2
exit 0
