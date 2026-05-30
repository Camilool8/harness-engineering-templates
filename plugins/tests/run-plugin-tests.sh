#!/usr/bin/env bash
# plugins/tests/run-plugin-tests.sh — validate every plugin, then run the
# Harness convention lint. Invoke from anywhere: ./plugins/tests/run-plugin-tests.sh
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PLUGINS="$(cd "$HERE/.." && pwd)"
fails=0

echo "### claude plugin validate --strict"
if command -v claude >/dev/null 2>&1; then
  for p in "$PLUGINS"/*/; do
    name="$(basename "$p")"
    [ "$name" = "tests" ] && continue
    [ -d "$p/.claude-plugin" ] || continue
    echo ""
    echo "--- $name"
    claude plugin validate --strict "$p" || fails=$((fails + 1))
  done
else
  echo "  · claude CLI not found — skipping plugin validate (CI installs it)"
fi

echo ""
echo "### lint-conventions.sh"
bash "$HERE/lint-conventions.sh" || fails=$((fails + 1))

echo ""
echo "### test-load-harness.sh"
bash "$HERE/test-load-harness.sh" || fails=$((fails + 1))

echo ""
echo "================================"
if [ "$fails" -eq 0 ]; then
  echo "ALL PLUGIN CHECKS PASSED"
else
  echo "$fails PLUGIN CHECK(S) FAILED"
fi
exit "$fails"
