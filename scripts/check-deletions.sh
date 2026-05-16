#!/usr/bin/env bash
# scripts/check-deletions.sh — fail a PR that deletes files without justification.
# Renames (git R) are allowed silently. A pure deletion (git D) must either be
# named in the PR body, or the PR must carry the `override-deletion` label.
#
# Env: PR_BODY (PR description), PR_LABELS (newline- or comma-separated label
#      names), BASE_REF (default: origin/main).
set -uo pipefail
BASE_REF="${BASE_REF:-origin/main}"
PR_BODY="${PR_BODY:-}"
PR_LABELS="${PR_LABELS:-}"

deleted="$(git diff --diff-filter=D --name-only "${BASE_REF}...HEAD")"
if [ -z "$deleted" ]; then
  echo "✓ No files deleted in this PR."
  exit 0
fi

if printf '%s' "$PR_LABELS" | tr ',' '\n' | grep -qx 'override-deletion'; then
  echo "✓ 'override-deletion' label present — owner override applied."
  echo "  Deleted files (justification waived):"
  printf '%s\n' "$deleted" | sed 's/^/    /'
  exit 0
fi

missing=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if printf '%s' "$PR_BODY" | grep -qF "$f"; then
    echo "  ✓ justified: $f"
  else
    echo "  ✗ unjustified: $f"
    missing="$missing $f"
  fi
done <<EOF
$deleted
EOF

if [ -n "$missing" ]; then
  echo ""
  echo "This PR deletes files without justification:"
  for f in $missing; do echo "  - $f"; done
  echo ""
  echo "Fix it one of these ways:"
  echo "  1. If you RENAMED the file, ensure git records it as a rename"
  echo "     (keep the change in one commit) — renames are allowed automatically."
  echo "  2. Otherwise, fill the '## Deletions' section of the PR description:"
  echo "     list each deleted path with a reason and its replacement."
  echo "  3. A maintainer may add the 'override-deletion' label to waive this."
  exit 1
fi

echo "✓ All deletions are justified in the PR description."
exit 0
