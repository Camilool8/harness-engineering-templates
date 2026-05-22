#!/usr/bin/env bash
# prod-typed-token.sh — PreToolUse hook on Bash apply-class commands.
# When the resolved cloud account is tagged env=prod or blast-radius=nuclear,
# require the agent to have included a typed token line of the form:
#   CONFIRM <last-4-of-resource-id>
# propagated via $CLAUDE_USER_TOKEN. A single "y" or click is not enough.
#
# Exit 2 = block. Exit 0 = allow.
set -uo pipefail

event="$(cat)"
cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police apply-class commands.
printf '%s' "$cmd" \
  | grep -Eq '\b(terraform[[:space:]]+apply|tofu[[:space:]]+apply|pulumi[[:space:]]+up|cdk[[:space:]]+deploy)\b' \
  || exit 0

# Resolve the current cloud caller identity tag (best-effort, AWS shown; the
# real implementation should branch on the configured cloud).
acct_tag=""
if command -v aws >/dev/null 2>&1; then
  acct_id="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
  if [ -n "$acct_id" ]; then
    acct_tag="$(aws organizations describe-account --account-id "$acct_id" \
      --query 'Account.Tags[?Key==`env`].Value' --output text 2>/dev/null || true)"
  fi
fi

# Only gate prod / nuclear tiers.
case "$acct_tag" in
  prod|nuclear) ;;
  *) exit 0 ;;
esac

if [ -z "${CLAUDE_USER_TOKEN:-}" ]; then
  echo "BLOCKED: prod/nuclear apply requires a typed confirmation token." >&2
  echo "Surface the confirmation card to the responder; the typed token must" >&2
  echo "be propagated as CLAUDE_USER_TOKEN before this command is re-issued." >&2
  exit 2
fi

exit 0
