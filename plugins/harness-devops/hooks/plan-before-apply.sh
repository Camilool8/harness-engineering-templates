#!/usr/bin/env bash
# plan-before-apply.sh — PreToolUse hook on Bash.
# IaC safety gate. The agent proposes; a human or CI applies.
#
#   - terraform apply / tofu apply / pulumi up / cdk deploy is blocked unless a
#     plan file produced within the last 15 minutes exists. A stale plan is a
#     different reality — rubber-stamping it is the classic anti-pattern.
#   - Any apply whose plan / command references a protected resource type
#     (databases, stateful buckets, KMS keys) being destroyed is blocked
#     UNCONDITIONALLY, regardless of plan freshness.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

PLAN_MAX_AGE=900   # 15 minutes

event="$(cat)"
cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Is this an apply-class command?
if ! printf '%s' "$cmd" | grep -Eq '\b(terraform[[:space:]]+apply|tofu[[:space:]]+apply|pulumi[[:space:]]+up|cdk[[:space:]]+deploy)\b'; then
  exit 0
fi

# Unconditional block: destroying a protected resource type.
protected='aws_db_instance|aws_rds_cluster|aws_s3_bucket|_kms_key|aws_dynamodb_table|google_sql_database_instance|azurerm_key_vault'
if printf '%s' "$cmd" | grep -Eq '(-destroy|destroy)' \
   && printf '%s' "$cmd" | grep -Eq "$protected"; then
  echo "BLOCKED: apply/destroy touches a protected resource type." >&2
  echo "Databases, stateful buckets and KMS keys are never destroyed by the agent." >&2
  exit 2
fi

# A recent plan file must exist (any *.plan / *.tfplan / plan.json under cwd).
recent_plan="$(find . -maxdepth 4 \
  \( -name '*.tfplan' -o -name '*.plan' -o -name 'plan.json' \) \
  -type f -mmin "-$((PLAN_MAX_AGE/60))" 2>/dev/null | head -1)"

if [ -z "$recent_plan" ]; then
  echo "BLOCKED: no plan file from the last 15 minutes found." >&2
  echo "Run 'terraform plan -out=tf.plan' (or the tofu/pulumi/cdk equivalent)," >&2
  echo "have a human review the plan, then apply THAT plan file." >&2
  exit 2
fi

echo "plan-before-apply: using recent plan $recent_plan" >&2
exit 0
