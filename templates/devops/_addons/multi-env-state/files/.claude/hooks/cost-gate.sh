#!/usr/bin/env bash
# cost-gate.sh — PostToolUse hook on Bash invocations of terraform/tofu plan.
# Runs infracost diff against the plan JSON, evaluates against an OPA policy,
# and warns or blocks if the monthly delta exceeds the env threshold.
#
# This is a soft gate by default — emits the cost delta on stderr; blocks
# only when an OPA policy file at .opa/cost.rego or policy/cost.rego is
# present AND its `deny` rule fires.
#
# Exit 0 = allow (always; the warning is informational unless OPA denies).
# Exit 2 = block (OPA deny).
set -uo pipefail

event="$(cat)"
cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only run after terraform/tofu plan invocations.
printf '%s' "$cmd" | grep -Eq '\b(terraform|tofu)[[:space:]]+plan\b' || exit 0

plan_json="$(find . -maxdepth 4 \
  \( -name '*.tfplan.json' -o -name 'plan.json' \) \
  -type f -mmin -2 2>/dev/null | head -1)"

[ -z "$plan_json" ] && exit 0
command -v infracost >/dev/null 2>&1 || exit 0

delta="$(infracost diff --path "$plan_json" --format json 2>/dev/null \
  | jq -r '.diffTotalMonthlyCost // 0' 2>/dev/null || echo 0)"
echo "cost-gate: monthly delta = \$$delta" >&2

policy=""
for p in policy/cost.rego .opa/cost.rego .infracost/policy.rego; do
  if [ -f "$p" ]; then policy="$p"; break; fi
done

if [ -n "$policy" ] && command -v opa >/dev/null 2>&1; then
  if printf '{"delta": %s}' "$delta" \
     | opa eval -d "$policy" -I 'data.cost.deny' --format raw 2>/dev/null \
     | grep -q '^\['; then
    echo "BLOCKED: cost OPA policy denied delta \$$delta" >&2
    exit 2
  fi
fi
exit 0
