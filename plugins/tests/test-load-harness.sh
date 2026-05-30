#!/usr/bin/env bash
# plugins/tests/test-load-harness.sh — exercises each pack's SessionStart
# load-harness.sh against the REAL pack skill dirs, using temp projects for the
# HARNESS.toml marker. Self-contained pass/fail counters.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PLUGINS="$(cd "$HERE/.." && pwd)"
pass=0; fail=0
ok()   { printf '  ok   %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  FAIL %s\n' "$1"; fail=$((fail+1)); }

# run <pack> <domain> <toml-body-or-empty>  -> stdout = loader output
run() {
  local pack="$1" domain="$2" body="$3"
  local tmp; tmp="$(mktemp -d)"
  if [ -n "$body" ]; then
    mkdir -p "$tmp/.claude"
    printf '%s' "$body" > "$tmp/.claude/HARNESS.toml"
  fi
  CLAUDE_PROJECT_DIR="$tmp" CLAUDE_PLUGIN_ROOT="$PLUGINS/harness-$pack" \
    bash "$PLUGINS/harness-$pack/hooks/load-harness.sh" "$domain"
  local rc=$?
  rm -rf "$tmp"
  return $rc
}

# ctx <output> -> the additionalContext string (empty if output is empty)
ctx() { [ -z "$1" ] && return 0; printf '%s' "$1" | jq -r '.hookSpecificOutput.additionalContext'; }

echo "== test-load-harness =="

# 1. No HARNESS.toml -> empty output.
out="$(run web web "")"
[ -z "$out" ] && ok "no marker -> empty" || bad "no marker should be empty, got: $out"

# 2. Wrong domain table -> empty output.
out="$(run web web '[data]
subdomain = "ml-pipeline"
')"
[ -z "$out" ] && ok "wrong domain -> empty" || bad "wrong domain should be empty"

# 3. web unprefixed resolve.
out="$(run web web '[web]
subdomain = "fullstack-app"
')"
c="$(ctx "$out")"
printf '%s' "$out" | jq -e . >/dev/null 2>&1 && ok "web: valid JSON" || bad "web: invalid JSON"
case "$c" in *"web/fullstack-app"*) ok "web: header present";; *) bad "web: header missing";; esac
[ -n "$c" ] && ok "web: non-empty context" || bad "web: empty context"

# 4. data prefixed resolve.
out="$(run data data '[data]
subdomain = "ml-pipeline"
')"
c="$(ctx "$out")"
case "$c" in *"data/ml-pipeline"*) ok "data: header present";; *) bad "data: header missing";; esac
case "$c" in *"NOTE: HARNESS.toml selected subdomain"*) bad "data: unexpected warning";; *) ok "data: resolved (no warning)";; esac

# 5. analyst-notebook resolves to data-analyst-notebook.
out="$(run data data '[data]
subdomain = "analyst-notebook"
')"
c="$(ctx "$out")"
case "$c" in *"NOTE: HARNESS.toml selected subdomain"*) bad "analyst-notebook: should resolve";; *) ok "analyst-notebook: resolved";; esac

# 6. Bad subdomain -> domain skill + warning, valid JSON, exit 0.
out="$(run web web '[web]
subdomain = "does-not-exist"
')"; rc=$?
c="$(ctx "$out")"
case "$c" in *"NOTE: HARNESS.toml selected subdomain"*) ok "bad subdomain: warning present";; *) bad "bad subdomain: warning missing";; esac
printf '%s' "$out" | jq -e . >/dev/null 2>&1 && ok "bad subdomain: valid JSON" || bad "bad subdomain: invalid JSON"

# 7. Static guard: loader must fail-open when jq is absent.
grep -q 'command -v jq >/dev/null 2>&1 || exit 0' "$PLUGINS/harness-web/hooks/load-harness.sh" \
  && ok "loader has jq fail-open guard" || bad "loader missing jq fail-open guard"

echo "-- load-harness: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
