#!/usr/bin/env bash
# plugins/tests/lint-conventions.sh — Harness conventions that `claude plugin
# validate` does NOT enforce. JSON validity and frontmatter *shape* are covered
# by `claude plugin validate --strict`; this script adds the project-specific
# rules: agent least-privilege, SKILL.md description quality, and dossier
# provenance headers. Scoped to plugins/.
set -uo pipefail
. "$(dirname "$0")/lib/common.sh"
cd "$PLUGINS" || exit 1

echo "== lint: agent least-privilege =="
# Architects/auditors/reviewers/critics must be read-only (no Edit/Write).
while IFS= read -r a; do
  case "$a" in */README.md) continue;; esac
  name_line="$(grep -m1 '^name:' "$a" | sed 's/^name:[[:space:]]*//')"
  case "$name_line" in
    *-architect|*-auditor|*-reviewer|*-critic)
      tools_line="$(grep -m1 '^tools:' "$a")"
      case "$tools_line" in
        *Edit*|*Write*) fail "agent  $a — least-privilege: $name_line has Edit/Write";;
        *)              ok   "agent  $a";;
      esac;;
    *) ok "agent  $a";;
  esac
done < <(find . -path '*/agents/*.md' 2>/dev/null | sort)

echo "== lint: SKILL.md description quality =="
# Anthropic checks presence; we require a description >= 80 chars so the model
# has enough signal to auto-trigger the skill.
while IFS= read -r s; do
  miss=""
  head -1 "$s" | grep -qx -- '---' || miss="$miss [no frontmatter]"
  grep -q '^name:' "$s"        || miss="$miss [name]"
  desc="$(grep -m1 '^description:' "$s" | sed 's/^description:[[:space:]]*//')"
  if [ -z "$desc" ]; then
    miss="$miss [description]"
  elif [ "${#desc}" -lt 80 ]; then
    miss="$miss [description <80 chars (${#desc})]"
  fi
  if [ -z "$miss" ]; then ok "SKILL.md  $s"; else fail "SKILL.md  $s —$miss"; fi
done < <(find . -name 'SKILL.md' 2>/dev/null | sort)

echo "== lint: references.md Verified header =="
while IFS= read -r r; do
  if grep -q '^> Verified:' "$r"; then ok "dossier  $r"
  else fail "dossier  $r — missing '> Verified:' header"; fi
done < <(find . -name 'references.md' 2>/dev/null | sort)

summary
