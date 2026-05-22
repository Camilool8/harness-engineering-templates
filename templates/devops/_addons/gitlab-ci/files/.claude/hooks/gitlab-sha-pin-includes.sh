#!/usr/bin/env bash
# gitlab-sha-pin-includes.sh — PreToolUse on Write|Edit of GitLab CI files.
# Refuses include:project / include:remote without a 40-char SHA ref.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  *.gitlab-ci.yml|*.gitlab-ci.yaml|*.gitlab/ci/*) ;;
  *) exit 0 ;;
esac

# Look for include: blocks with project: or remote: but no matching ref: <40-char SHA>.
if printf '%s' "$content" | grep -Eq '^[[:space:]]*-?[[:space:]]*(project|remote):[[:space:]]*'; then
  if ! printf '%s' "$content" | grep -Eq "^[[:space:]]*ref:[[:space:]]*[\"']?[0-9a-f]{40}[\"']?"; then
    echo "BLOCKED: GitLab CI include:project / include:remote without a 40-char SHA ref." >&2
    echo "Add: ref: <40-char-sha> for every cross-repo include." >&2
    exit 2
  fi
fi
exit 0
