#!/usr/bin/env bash
# checks/hook-lint.sh — every shell script must pass `bash -n`; and `shellcheck`
# at error severity when shellcheck is installed. Both are hard gates.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"
cd "$REPO" || exit 1

echo "== hook-lint: bash -n on every *.sh =="
while IFS= read -r sh; do
  if bash -n "$sh" 2>/dev/null; then ok "bash -n  $sh"; else fail "bash -n  $sh"; fi
done < <(find . -name '*.sh' -not -path './.git/*' | sort)

echo "== hook-lint: shellcheck (error severity) =="
if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r sh; do
    if shellcheck -S error "$sh" >/dev/null 2>&1; then
      ok "shellcheck  $sh"
    else
      fail "shellcheck  $sh"
      shellcheck -S error "$sh" 2>&1 | sed 's/^/      /' || true
    fi
  done < <(find . -name '*.sh' -not -path './.git/*' | sort)
else
  note "shellcheck not installed — skipped (CI installs it)"
fi

summary
