# shellcheck shell=bash
# tests/lib/common.sh — shared helpers. Source this from a checks/*.sh script.
# Provides: ok / fail / note / summary, and $REPO (repo root) + $TPL (templates dir).
_PASS=0; _FAIL=0
ok()   { echo "  ✓ $1"; _PASS=$((_PASS + 1)); }
fail() { echo "  ✗ $1"; _FAIL=$((_FAIL + 1)); }
note() { echo "  · $1"; }
summary() {
  echo ""
  echo "  ${0##*/}: ${_PASS} passed, ${_FAIL} failed"
  [ "$_FAIL" -eq 0 ]
}
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TPL="$REPO/templates"
