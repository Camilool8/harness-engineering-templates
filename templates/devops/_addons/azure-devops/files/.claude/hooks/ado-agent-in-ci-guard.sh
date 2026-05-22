#!/usr/bin/env bash
# ado-agent-in-ci-guard.sh — PreToolUse on Write|Edit of Azure pipeline files.
# Refuses pipelines that invoke a coding agent without read-only token scope.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  *azure-pipelines*.yml|*azure-pipelines*.yaml|*.azure-pipelines/*.yml) ;;
  *) exit 0 ;;
esac

if ! printf '%s' "$content" | grep -Eq 'claude-code|copilot-cli|gemini-cli|openai-codex|claude-code-action'; then
  exit 0
fi

# Azure DevOps uses `System.AccessToken` and explicit `checkout: { persistCredentials: true }`
# to grant write. Refuse if persistCredentials: true is present alongside the agent.
if printf '%s' "$content" | grep -Eq 'persistCredentials:[[:space:]]*true'; then
  echo "BLOCKED: pipeline invokes a coding agent with persistCredentials: true." >&2
  echo "Agent-in-CI must run read-only by default. State-mutating steps use WIF." >&2
  exit 2
fi
exit 0
