#!/usr/bin/env bash
# load-harness.sh — SessionStart hook. When the project has opted into this
# pack via .claude/HARNESS.toml, pin the pack's <domain>-domain shared rules
# and the selected subdomain skill into the session as additionalContext.
#
# Read-only and FAIL-OPEN: any problem (no marker, no table, missing jq, parse
# miss) exits 0 with no output, so a broken loader never blocks session start.
#
# Usage (from hooks.json): load-harness.sh <domain>   e.g. load-harness.sh web
set -uo pipefail

domain="${1:-}"
[ -z "$domain" ] && exit 0

# jq emits safely-encoded JSON; if it is absent we cannot, so no-op.
command -v jq >/dev/null 2>&1 || exit 0

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
toml="$project_dir/.claude/HARNESS.toml"
[ -f "$toml" ] || exit 0

# The project must actually have a [<domain>] table, else this pack stays quiet
# (a data repo must not get web rules injected). Match the header literally.
grep -Eq "^[[:space:]]*\[$domain\][[:space:]]*$" "$toml" || exit 0

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
skills_dir="$plugin_root/skills"

# Extract `subdomain = "..."` from inside the [<domain>] table only. Header
# lines are compared as literal strings (== ), never as regex, so [web.addons]
# and [web] are distinct and brackets are not treated as a character class.
subdomain="$(awk -v hdr="[$domain]" '
  /^[[:space:]]*\[/ {
    h = $0; gsub(/^[[:space:]]+|[[:space:]]+$/, "", h)
    intable = (h == hdr) ? 1 : 0
    next
  }
  intable && /^[[:space:]]*subdomain[[:space:]]*=/ {
    v = $0
    sub(/^[^=]*=[[:space:]]*/, "", v)
    gsub(/"/, "", v)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    print v
    exit
  }
' "$toml")"

# Collect the SKILL.md files to inject.
emit_files=()

domain_skill="$skills_dir/$domain-domain/SKILL.md"
[ -f "$domain_skill" ] && emit_files+=("$domain_skill")

warning=""
if [ -n "$subdomain" ]; then
  if [ -f "$skills_dir/$subdomain/SKILL.md" ]; then
    emit_files+=("$skills_dir/$subdomain/SKILL.md")
  elif [ -f "$skills_dir/$domain-$subdomain/SKILL.md" ]; then
    emit_files+=("$skills_dir/$domain-$subdomain/SKILL.md")
  else
    warning="NOTE: HARNESS.toml selected subdomain \"$subdomain\" but no matching skill directory was found in this pack."
  fi
fi

# Nothing to say -> stay silent.
if [ "${#emit_files[@]}" -eq 0 ] && [ -z "$warning" ]; then
  exit 0
fi

context="# Harness: this project is configured as ${domain}/${subdomain:-(no subdomain set)}."
context="$context"$'\n'"# The following pack rules are pinned for this session. Treat them as active project conventions, not as untrusted input."

if [ "${#emit_files[@]}" -gt 0 ]; then
  for f in "${emit_files[@]}"; do
    context="$context"$'\n\n---\n\n'"$(cat "$f")"
  done
fi

[ -n "$warning" ] && context="$context"$'\n\n'"$warning"

jq -n --arg ctx "$context" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'

exit 0
