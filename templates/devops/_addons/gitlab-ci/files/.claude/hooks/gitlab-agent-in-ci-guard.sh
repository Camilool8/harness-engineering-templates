#!/usr/bin/env bash
# gitlab-agent-in-ci-guard.sh — PreToolUse on Write|Edit of GitLab CI files.
# Refuses pipelines that invoke a coding agent without read-only token scope.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  *.gitlab-ci.yml|*.gitlab-ci.yaml|*.gitlab/ci/*) ;;
  *) exit 0 ;;
esac

if ! printf '%s' "$content" | grep -Eq 'claude-code|copilot|gemini-cli|openai-codex'; then
  exit 0
fi

# Refuse if CI_JOB_TOKEN is given write scope via id_tokens: with write aud
# (e.g. `write_repository`) — conservative match on the suspect strings.
if printf '%s' "$content" | grep -Eq '(write_repository|api_access|write_registry)'; then
  echo "BLOCKED: GitLab CI invokes a coding agent with write-scoped tokens." >&2
  echo "Agent-in-CI must run read-only by default; protected branches enforce write." >&2
  exit 2
fi
exit 0
