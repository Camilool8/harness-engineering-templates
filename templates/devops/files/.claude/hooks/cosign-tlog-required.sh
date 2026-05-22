#!/usr/bin/env bash
# cosign-tlog-required.sh — PreToolUse hook on Bash.
# Refuses cosign sign / verify / attest invocations that pass
# --insecure-ignore-tlog. The Rekor transparency log inclusion proof IS the
# keyless model — bypassing it defeats Sigstore entirely. Common in
# copy-pasted air-gapped templates.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police cosign invocations.
printf '%s' "$cmd" | grep -Eq '\bcosign[[:space:]]+(sign|verify|attest)\b' || exit 0

if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])--insecure-ignore-tlog([[:space:]=]|$)'; then
  echo "BLOCKED: cosign --insecure-ignore-tlog bypasses Rekor inclusion." >&2
  echo "Rekor inclusion IS the keyless trust model; the flag defeats it." >&2
  echo "If you truly need an offline path, configure a custom Sigstore trusted root." >&2
  exit 2
fi

exit 0
