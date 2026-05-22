#!/usr/bin/env bash
# manifest-validate.sh — PostToolUse on Write|Edit of *.yaml under K8s
# manifest paths. Runs kubeconform → kube-linter → kyverno apply on a 10 s
# budget. Non-zero verdict surfaces on stderr but does not block (PostToolUse
# is informational); failure becomes a "done" blocker.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

case "$path" in
  *manifests/*.yaml|*manifests/*.yml|*deploy/*.yaml|*deploy/*.yml|*kustomize/*.yaml|*kustomize/*.yml|*helm/*.yaml|*helm/*.yml) ;;
  *) exit 0 ;;
esac

ok=1
if command -v kubeconform >/dev/null 2>&1; then
  timeout 5 kubeconform "$path" >&2 || ok=0
fi
if command -v kube-linter >/dev/null 2>&1; then
  timeout 5 kube-linter lint "$path" >&2 || ok=0
fi
if command -v kyverno >/dev/null 2>&1; then
  for p in policies/*.yaml; do
    [ -f "$p" ] || continue
    timeout 5 kyverno apply "$p" --resource "$path" >&2 || ok=0
  done
fi

if [ "$ok" -eq 0 ]; then
  echo "manifest-validate: pipeline failed — change is NOT done." >&2
fi
exit 0
