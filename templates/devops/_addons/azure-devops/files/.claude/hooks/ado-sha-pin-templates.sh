#!/usr/bin/env bash
# ado-sha-pin-templates.sh — PreToolUse on Write|Edit of Azure pipeline files.
# Blocks template: references that resolve to another repo without a SHA ref.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  *azure-pipelines*.yml|*azure-pipelines*.yaml|*.azure-pipelines/*.yml) ;;
  *) exit 0 ;;
esac

# A template reference targeting another repo looks like:
#   template: file.yml@repoAlias
# Anything with @repoAlias requires a corresponding `repositories:` block with
# a ref: <40-char SHA>. Conservative check: refuse if `template: ... @` is
# present and no `ref:` with a 40-char SHA is in the file.
if printf '%s' "$content" | grep -Eq '^[[:space:]]*-?[[:space:]]*template:[[:space:]]*[^[:space:]]+@'; then
  if ! printf '%s' "$content" | grep -Eq '^[[:space:]]*ref:[[:space:]]*[0-9a-f]{40}'; then
    echo "BLOCKED: Azure pipeline cross-repo template reference without SHA ref." >&2
    echo "Add: repositories: with ref: <40-char SHA> for every cross-repo template." >&2
    exit 2
  fi
fi
exit 0
