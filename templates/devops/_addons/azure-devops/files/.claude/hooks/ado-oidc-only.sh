#!/usr/bin/env bash
# ado-oidc-only.sh — PreToolUse on Write|Edit of Azure pipeline files.
# Blocks introduction of static SPN secrets in pipeline YAML.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  *azure-pipelines*.yml|*azure-pipelines*.yaml|*.azure-pipelines/*.yml) ;;
  *) exit 0 ;;
esac

if printf '%s' "$content" | grep -Eq '(servicePrincipalKey|AZURE_CLIENT_SECRET|servicePrincipalPassword)'; then
  echo "BLOCKED: Azure pipeline introduces a static SPN secret reference." >&2
  echo "Use a Workload Identity Federation service connection (GA 2026)." >&2
  exit 2
fi
exit 0
