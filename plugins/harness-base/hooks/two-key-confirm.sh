#!/usr/bin/env bash
# two-key-confirm.sh — PreToolUse hook (matcher: Bash, plus any prod-tagged tool).
# OPT-IN: inert unless `two_key = true` under [harness] in .claude/HARNESS.toml.
#
# Irreversible actions require a typed `CONFIRM <token>` confirmation whose
# token matches a human-held nonce the LLM cannot self-generate. A single
# yes/click is insufficient.
#
# Block  -> exit 2 + reason on stderr.
# Allow  -> exit 0.
set -uo pipefail

# --- opt-in gate ----------------------------------------------------------
TOML="${CLAUDE_PROJECT_DIR:-.}/.claude/HARNESS.toml"
grep -Eq '^[[:space:]]*two_key[[:space:]]*=[[:space:]]*true' "$TOML" 2>/dev/null || exit 0

INPUT="$(cat)"

# --- extract the text to inspect ------------------------------------------
# For Bash, inspect the command. For other tools, scan the serialized input.
TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
if [ -z "$CMD" ]; then
  CMD="$(printf '%s' "$INPUT" | jq -rc '.tool_input // {}')"
fi

# --- destructive / production patterns ------------------------------------
# Extend this list for your environment's irreversible operations.
DANGER='(rm[[:space:]]+-[a-zA-Z]*r|drop[[:space:]]+(table|database)|truncate[[:space:]]+table|terraform[[:space:]]+(apply|destroy)|kubectl[[:space:]]+delete|helm[[:space:]]+(delete|uninstall)|aws[[:space:]]+s3[[:space:]]+rb|--force[[:space:]]*push|git[[:space:]]+push[[:space:]].*--force|deploy[[:space:]]+.*prod|--env[[:space:]]*=?[[:space:]]*prod|stripe[[:space:]].*(charge|payout|transfer)|flash[[:space:]]|dd[[:space:]]+if=)'

if ! printf '%s' "$CMD" | grep -Eiq "$DANGER"; then
  exit 0   # not a gated action
fi

# --- resolve the human-held nonce -----------------------------------------
NONCE=""
if [ -n "${HARNESS_TWO_KEY_TOKEN:-}" ]; then
  NONCE="$HARNESS_TWO_KEY_TOKEN"
elif [ -f ".claude/.two-key-nonce" ]; then
  NONCE="$(head -n1 .claude/.two-key-nonce | tr -d '[:space:]')"
fi

if [ -z "$NONCE" ]; then
  echo "TWO-KEY: destructive command detected but no second key is configured." >&2
  echo "A human must set HARNESS_TWO_KEY_TOKEN or create .claude/.two-key-nonce." >&2
  echo "Command refused: ${CMD}" >&2
  exit 2
fi

# --- require a matching typed confirmation token --------------------------
# The agent must include `CONFIRM <token>` in the command. Extract and compare.
SUPPLIED="$(printf '%s' "$CMD" | grep -oE 'CONFIRM[[:space:]]+[A-Za-z0-9._-]+' | head -n1 | awk '{print $2}')"

if [ -n "$SUPPLIED" ] && [ "$SUPPLIED" = "$NONCE" ]; then
  exit 0   # second key turned — allow
fi

echo "TWO-KEY CONFIRMATION REQUIRED — this is an irreversible action." >&2
echo "" >&2
echo "Command: ${CMD}" >&2
echo "" >&2
echo "A single yes/click is NOT sufficient. To proceed you must obtain the" >&2
echo "confirmation token from the human who holds the second key, then re-run" >&2
echo "the SAME command with this appended:   CONFIRM <token>" >&2
echo "" >&2
echo "You cannot read or generate the token yourself — ask the human." >&2
exit 2
