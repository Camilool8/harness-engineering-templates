#!/usr/bin/env bash
# Stop hook — runs project verification before a turn may complete.
# Exit 2 = block "done" and feed the failure back to the agent.
#
# It runs .claude/verify.sh if that file exists and is executable.
# Copy verify.sh.example -> verify.sh and fill in your real commands.
set -uo pipefail

v="${CLAUDE_PROJECT_DIR:-.}/.claude/verify.sh"
[ -x "$v" ] || exit 0   # no verify script configured → do not gate.

if ! out="$("$v" 2>&1)"; then
  echo "Verification failed — work is NOT complete:" >&2
  printf '%s\n' "$out" | tail -n 25 >&2
  echo "Fix the failures above, then finish." >&2
  exit 2
fi
exit 0
