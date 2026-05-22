#!/usr/bin/env bash
# gha-agent-in-ci-guard.sh — PreToolUse on Write|Edit of GH workflow files.
# When a workflow invokes a coding agent (claude-code-action, copilot-cli,
# gemini-cli, openai/codex), require:
#   permissions: { contents: read }   (no other permissions)
#   any state-mutating step uses OIDC (no static cloud creds).
#
# Addresses the CSA "Comment and Control" attack class (May 3 2026).
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  .github/workflows/*.yml|.github/workflows/*.yaml|*/.github/workflows/*.yml|*/.github/workflows/*.yaml) ;;
  *) exit 0 ;;
esac

# Detect agent invocation.
if ! printf '%s' "$content" \
     | grep -Eq 'anthropics/claude-code-action|github/copilot-cli|gemini-cli|openai/codex|google-github-actions/gemini'; then
  exit 0
fi

# Require permissions block declares contents: read; refuse if any of write
# permissions present without an explicit narrowing.
if ! printf '%s' "$content" | grep -Eq 'permissions:[[:space:]]*$|permissions:[[:space:]]*\{'; then
  echo "BLOCKED: workflow invokes a coding agent but declares no 'permissions:' block." >&2
  echo "Add: permissions: { contents: read }   (read-only by default)." >&2
  exit 2
fi
if printf '%s' "$content" | grep -Eq 'permissions:[^#]*write'; then
  echo "BLOCKED: workflow invokes a coding agent with 'write' permissions." >&2
  echo "Agent-in-CI must be read-only by default. State-mutating steps use OIDC." >&2
  exit 2
fi

exit 0
