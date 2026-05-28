#!/usr/bin/env bash
# kubectl-context-guard.sh — PreToolUse hook on Bash.
# Parses kubectl / helm / k commands, reads the CURRENT context, and gates
# destructive verbs against production-pattern contexts.
#
#   - Nuclear patterns (delete namespace/pvc/pv/crd, delete --all) are blocked
#     UNCONDITIONALLY on a prod context — ordered first so they match before
#     generic "delete pod".
#   - On a prod context: delete / drain / cordon / scale --replicas=0, and any
#     apply/replace/create without --dry-run=server, are blocked.
#   - Non-prod contexts pass through.
#
# Prod is matched by context name: *prod*, *prd*, *production*.
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police kubectl / helm / k invocations.
printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])(kubectl|helm|k)([[:space:]]|$)' || exit 0

ctx="$(kubectl config current-context 2>/dev/null || true)"
[ -z "$ctx" ] && exit 0

is_prod=0
printf '%s' "$ctx" | grep -Eiq '(prod|prd|production)' && is_prod=1

# Nuclear patterns — checked first, unconditional on prod.
nuclear='delete[[:space:]]+(namespace|ns|pvc|pv|crd|persistentvolume)'
nuclear="$nuclear|delete[[:space:]].*--all([[:space:]]|$)"
nuclear="$nuclear|delete[[:space:]].*--all-namespaces"
if [ "$is_prod" -eq 1 ] && printf '%s' "$cmd" | grep -Eq "$nuclear"; then
  echo "BLOCKED: nuclear kubectl pattern on production context '$ctx'." >&2
  echo "Deleting namespaces/PVCs/PVs/CRDs or --all on prod is never agent-driven." >&2
  exit 2
fi

# Other destructive verbs on prod.
if [ "$is_prod" -eq 1 ]; then
  if printf '%s' "$cmd" | grep -Eq '\b(delete|drain|cordon)\b'; then
    echo "BLOCKED: '$ctx' is a production context — delete/drain/cordon is gated." >&2
    echo "Propose the change via Git (GitOps); let Argo CD / a human apply it." >&2
    exit 2
  fi
  if printf '%s' "$cmd" | grep -Eq 'scale\b' \
     && printf '%s' "$cmd" | grep -Eq 'replicas=?0\b'; then
    echo "BLOCKED: scale-to-zero on production context '$ctx'." >&2
    exit 2
  fi
  if printf '%s' "$cmd" | grep -Eq '\b(apply|replace|create)\b' \
     && ! printf '%s' "$cmd" | grep -Eq 'dry-run=server'; then
    echo "BLOCKED: apply/replace/create on '$ctx' without --dry-run=server." >&2
    echo "On prod the agent writes manifests to Git, not the live cluster." >&2
    exit 2
  fi
fi

exit 0
