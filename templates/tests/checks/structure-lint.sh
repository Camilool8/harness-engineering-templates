#!/usr/bin/env bash
# checks/structure-lint.sh — convention checks across the harness templates.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"
cd "$TPL"

echo "== structure-lint: MODULE.md standard sections =="
MODULE_SECTIONS=("## Adopt if" "## Skip if" "## Dependencies"
  "## Install (manual)" "## Install (assemble.sh)" "## Remove" "## Files")
while IFS= read -r m; do
  miss=""
  grep -q '^# Module:' "$m"  || miss="$miss [# Module: title]"
  grep -q '^> Config:' "$m"  || miss="$miss [> Config: line]"
  grep -q '\*\*What it does\.\*\*' "$m" || miss="$miss [What it does]"
  for s in "${MODULE_SECTIONS[@]}"; do
    grep -qF "$s" "$m" || miss="$miss [$s]"
  done
  if [ -z "$miss" ]; then ok "MODULE.md  $m"; else fail "MODULE.md  $m —$miss"; fi
done < <(find _modules web -name 'MODULE.md' 2>/dev/null | sort)

echo "== structure-lint: agent frontmatter + least-privilege =="
while IFS= read -r a; do
  case "$a" in */README.md) continue;; esac
  miss=""
  head -1 "$a" | grep -qx -- '---' || miss="$miss [no frontmatter]"
  for k in name description tools model; do
    grep -q "^$k:" "$a" || miss="$miss [$k]"
  done
  # least-privilege: architects/auditors/reviewers/critics must be read-only
  name_line="$(grep -m1 '^name:' "$a" | sed 's/^name:[[:space:]]*//')"
  case "$name_line" in
    *-architect|*-auditor|*-reviewer|*-critic)
      tools_line="$(grep -m1 '^tools:' "$a")"
      case "$tools_line" in
        *Edit*|*Write*) miss="$miss [least-privilege: $name_line has Edit/Write]";;
      esac;;
  esac
  if [ -z "$miss" ]; then ok "agent  $a"; else fail "agent  $a —$miss"; fi
done < <(find _modules web -path '*/agents/*.md' 2>/dev/null | sort)

echo "== structure-lint: SKILL.md frontmatter =="
while IFS= read -r s; do
  miss=""
  head -1 "$s" | grep -qx -- '---' || miss="$miss [no frontmatter]"
  grep -q '^name:' "$s"        || miss="$miss [name]"
  grep -q '^description:' "$s" || miss="$miss [description]"
  if [ -z "$miss" ]; then ok "SKILL.md  $s"; else fail "SKILL.md  $s —$miss"; fi
done < <(find . -name 'SKILL.md' 2>/dev/null | sort)

echo "== structure-lint: references.md Verified header =="
while IFS= read -r r; do
  if grep -q '^> Verified:' "$r"; then ok "dossier  $r"
  else fail "dossier  $r — missing '> Verified:' header"; fi
done < <(find web -name 'references.md' 2>/dev/null | sort)

echo "== structure-lint: JSON validity =="
while IFS= read -r j; do
  if jq -e . "$j" >/dev/null 2>&1; then ok "json  $j"
  else fail "json  $j — invalid JSON"; fi
done < <(find . \( -name '*.json' -o -name '*.fragment.json' -o -name '.mcp.json.fragment' \) \
           -not -path './tests/*' 2>/dev/null | sort)

summary
