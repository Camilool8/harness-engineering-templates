# shellcheck shell=bash
# plugins/tests/lib/common.sh — shared helpers. Source from a tests/*.sh script.
# Provides: ok / fail / note / summary, and $REPO (repo root) + $PLUGINS (plugins dir).
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
PLUGINS="$REPO/plugins"
