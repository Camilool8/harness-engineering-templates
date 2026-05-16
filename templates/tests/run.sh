#!/usr/bin/env bash
# tests/run.sh — runs every check in checks/ and prints one summary.
# Invoke from anywhere: ./templates/tests/run.sh
set -uo pipefail
CHECKS_DIR="$(cd "$(dirname "$0")/checks" && pwd)"
fails=0
for chk in "$CHECKS_DIR"/*.sh; do
  echo ""
  echo "### ${chk##*/}"
  bash "$chk" || fails=$((fails + 1))
done
echo ""
echo "================================"
if [ "$fails" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "$fails CHECK(S) FAILED"
fi
exit "$fails"
