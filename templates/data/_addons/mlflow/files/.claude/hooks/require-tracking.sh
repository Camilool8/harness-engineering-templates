#!/usr/bin/env bash
# require-tracking.sh — PreToolUse hook on Bash.
# Refuses `python train…` invocations whose target script lacks
# `import mlflow`. Ensures every training run is logged.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police python <something>train<something> invocations.
printf '%s' "$cmd" | grep -Eq '\bpython[[:space:]]+[^[:space:]]*train[^[:space:]]*\.py\b' || exit 0

# Extract the script path.
script="$(printf '%s' "$cmd" | grep -oE 'python[[:space:]]+[^[:space:]]*train[^[:space:]]*\.py' | awk '{print $NF}' | head -1)"
[ -z "$script" ] && exit 0

# Resolve relative to CLAUDE_PROJECT_DIR.
script_path="${CLAUDE_PROJECT_DIR:-.}/$script"
[ -f "$script_path" ] || script_path="$script"
[ -f "$script_path" ] || exit 0   # if we can't find it, don't block

# Check for `import mlflow` (or wandb, aim — accept any registered tracker).
if ! grep -Eq '^[[:space:]]*import[[:space:]]+(mlflow|wandb|aim)' "$script_path" \
   && ! grep -Eq '^[[:space:]]*from[[:space:]]+(mlflow|wandb|aim)' "$script_path"; then
  echo "BLOCKED: $script lacks a tracker import (mlflow / wandb / aim)." >&2
  echo "Every training run must be logged. Add 'import mlflow' (or wandb / aim)." >&2
  exit 2
fi

exit 0
