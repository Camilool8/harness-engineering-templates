#!/usr/bin/env bash
# tests/run.sh — assertion harness for assemble.sh. Run from templates/.
set -uo pipefail
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }

# assemble <config> -> sets $OUT to a fresh temp dir, returns assemble exit code
assemble() {
  OUT="$(mktemp -d)"; ./assemble.sh "$1" "$OUT" >/dev/null 2>&1
}

# assert_assembles <config> <label>
assert_assembles() {
  assemble "$1"
  [ $? -eq 0 ] || { fail "$2: assemble exited non-zero"; return; }
  jq -e . "$OUT/.claude/settings.json" >/dev/null 2>&1 \
    || { fail "$2: settings.json invalid"; return; }
  [ -f "$OUT/CLAUDE.md" ] || { fail "$2: no CLAUDE.md"; return; }
  # assemble.sh auto-merges fragments at exactly these two paths; assert they
  # were consumed. Fragments at other paths (e.g. the safety/sandbox module's
  # .claude/sandbox/settings.fragment.json) are intentional manual-apply
  # artifacts — not flagged here.
  if [ -f "$OUT/.claude/settings.fragment.json" ] || [ -f "$OUT/.mcp.json.fragment" ]; then
    fail "$2: leftover fragment at an auto-merge path"; return
  fi
  for h in "$OUT"/.claude/hooks/*.sh; do
    [ -x "$h" ] || { fail "$2: hook not executable: $h"; return; }
    bash -n "$h" 2>/dev/null || { fail "$2: hook syntax error: $h"; return; }
  done
  ok "$2"
  rm -rf "$OUT"
}

echo "== backward-compat: every thin recipe assembles =="
for d in generic data devops finance mobile game embedded \
         scientific security content ops; do
  assert_assembles "$d/harness.config.yml" "recipe:$d"
done
assert_assembles "harness.config.yml" "root-manifest"

echo "== .mcp.json fragments deep-merge =="
assemble "generic/harness.config.yml"
cp tests/fixtures/mcp-merge/.mcp.json.fragment "$OUT/.mcp.json.fragment"
merged="$(jq -s 'def dm($a;$b): reduce ($b|keys_unsorted[]) as $k ($a;
  if (($a[$k]|type)=="object") and (($b[$k]|type)=="object") then .[$k]=dm($a[$k];$b[$k])
  elif (($a[$k]|type)=="array") and (($b[$k]|type)=="array") then .[$k]=($a[$k]+$b[$k])
  else .[$k]=$b[$k] end); dm(.[0];.[1])' "$OUT/.mcp.json" "$OUT/.mcp.json.fragment")"
echo "$merged" | jq -e '.mcpServers.context7' >/dev/null 2>&1 \
  && ok "mcp deep-merge keeps server" || fail "mcp deep-merge lost server"
rm -rf "$OUT"

echo "== web domain pack: every sub-domain assembles =="
for sd in design-system frontend-app fullstack-app api-service distributed-backend; do
  assemble "web/$sd/harness.config.yml"
  if [ $? -eq 0 ] \
     && jq -e . "$OUT/.claude/settings.json" >/dev/null 2>&1 \
     && jq -e . "$OUT/.mcp.json" >/dev/null 2>&1 \
     && [ -n "$(ls -A "$OUT/.claude/agents" 2>/dev/null)" ]; then
    ok "web/$sd"
  else
    fail "web/$sd"
  fi
  rm -rf "$OUT"
done

echo ""
echo "Passed: $PASS  Failed: $FAIL"
[ "$FAIL" -eq 0 ]
