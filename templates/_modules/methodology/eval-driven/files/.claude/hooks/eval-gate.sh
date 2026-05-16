#!/usr/bin/env bash
# eval-gate.sh — Stop hook.
# Before "done" is allowed, runs the FAST eval subset if an eval harness exists.
#   - No evals/run.sh   -> no-op, allow stop (module may be installed before the
#                          harness is written; do not punish that).
#   - run.sh present    -> run it with --fast; exit 2 to block "done" on failure.
#
# Exit 2 = block the Stop (reason on stderr). Exit 0 = allow.
set -uo pipefail

# Drain stdin (the Stop event JSON); not needed for the decision.
cat >/dev/null 2>&1 || true

RUNNER="evals/run.sh"

# No eval harness yet -> nothing to gate on.
[ -f "$RUNNER" ] || exit 0

if [ ! -x "$RUNNER" ]; then
  echo "eval-gate: $RUNNER exists but is not executable. Run: chmod +x $RUNNER" >&2
  exit 2
fi

# Run the fast subset. Pass both the flag and the env var so either contract works.
output="$(EVAL_FAST=1 "$RUNNER" --fast 2>&1)"
status=$?

if [ "$status" -ne 0 ]; then
  echo "eval-gate: the fast eval subset FAILED — work is not done." >&2
  echo "------------------------------------------------------------" >&2
  printf '%s\n' "$output" >&2
  echo "------------------------------------------------------------" >&2
  echo "Do error analysis on the failures, fix the regression, and re-run." >&2
  echo "See evals/RUNBOOK.md and the running-evals skill." >&2
  exit 2
fi

exit 0
