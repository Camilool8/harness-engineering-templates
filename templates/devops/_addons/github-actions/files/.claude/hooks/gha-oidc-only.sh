#!/usr/bin/env bash
# gha-oidc-only.sh — PreToolUse on Write|Edit|MultiEdit of GitHub workflow files.
# Refuses to introduce static cloud credentials (AWS_ACCESS_KEY_ID,
# AZURE_CLIENT_SECRET, GCP key JSON) into a workflow.
#
# Exit 2 = block. Exit 0 = allow.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  .github/workflows/*.yml|.github/workflows/*.yaml|*/.github/workflows/*.yml|*/.github/workflows/*.yaml) ;;
  *) exit 0 ;;
esac

if printf '%s' "$content" \
   | grep -Eq '(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AZURE_CLIENT_SECRET|GOOGLE_APPLICATION_CREDENTIALS_JSON|aws_access_key_id|aws_secret_access_key)'; then
  echo "BLOCKED: GitHub workflow introduces a static cloud credential reference." >&2
  echo "Use OIDC: 'permissions: id-token: write' + configure-aws-credentials" >&2
  echo "(or the cloud equivalent)." >&2
  exit 2
fi
exit 0
