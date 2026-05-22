#!/usr/bin/env bash
# gitlab-oidc-only.sh — PreToolUse on Write|Edit of GitLab CI files.
# Blocks introduction of static cloud secrets in variables: or secrets: blocks.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  *.gitlab-ci.yml|*.gitlab-ci.yaml|*.gitlab/ci/*) ;;
  *) exit 0 ;;
esac

if printf '%s' "$content" \
   | grep -Eq '(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AZURE_CLIENT_SECRET|GOOGLE_APPLICATION_CREDENTIALS_JSON)'; then
  echo "BLOCKED: GitLab CI introduces a static cloud credential reference." >&2
  echo "Use id_tokens: for short-lived federated credentials." >&2
  exit 2
fi
exit 0
