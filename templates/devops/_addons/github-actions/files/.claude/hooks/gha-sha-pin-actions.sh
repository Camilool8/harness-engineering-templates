#!/usr/bin/env bash
# gha-sha-pin-actions.sh — PreToolUse on Write|Edit of GH workflow files.
# Refuses any `uses:` reference without a 40-char hex SHA.
#
# The Trivy March 2026 attack force-pushed 76/77 version tags — Dependabot
# did not catch it. SHA-pinning is the only durable mitigation.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

case "$path" in
  .github/workflows/*.yml|.github/workflows/*.yaml|*/.github/workflows/*.yml|*/.github/workflows/*.yaml) ;;
  *) exit 0 ;;
esac

# Find every uses: reference; allow LOCAL references (./...) and SHA-pinned ones
# (owner/repo@<40 hex>). Anything else (tag, branch, no @) is blocked.
offenders="$(printf '%s\n' "$content" \
  | grep -E '^[[:space:]]*-?[[:space:]]*uses:[[:space:]]*' \
  | grep -Ev 'uses:[[:space:]]*\./|uses:[[:space:]]*[A-Za-z0-9._/-]+@[0-9a-f]{40}([[:space:]]|$)' \
  || true)"

if [ -n "$offenders" ]; then
  echo "BLOCKED: GitHub workflow references an action without a 40-char SHA pin." >&2
  echo "Tags can be force-pushed (Trivy March 2026 attack). Pin to a commit SHA:" >&2
  echo "  uses: owner/repo@<40-char-sha>  # vX.Y.Z" >&2
  echo "$offenders" >&2
  exit 2
fi
exit 0
