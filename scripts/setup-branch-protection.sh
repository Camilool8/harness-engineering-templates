#!/usr/bin/env bash
# scripts/setup-branch-protection.sh — apply branch protection to main.
# Run once by the repo owner: `gh auth login` first, then `./scripts/setup-branch-protection.sh`.
# Requires the GitHub CLI (`gh`) with admin rights on the repo.
set -euo pipefail

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Applying branch protection to main on ${REPO}…"

gh api -X PUT "repos/${REPO}/branches/main/protection" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Verify (tests)", "Governance (deletion policy)"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

echo "Done. main now requires: PR + the Verify and Governance checks + 1 CODEOWNERS review."
echo "enforce_admins is false — you (owner) keep an emergency admin-merge path;"
echo "the documented override for the deletion gate is the 'override-deletion' label."
