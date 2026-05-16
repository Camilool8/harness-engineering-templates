#!/usr/bin/env bash
# checks/assemble-coverage.sh — discover every assemblable unit and assemble it.
# A new module/addon/sub-domain is covered the moment its folder exists.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"
cd "$TPL"

# assert_assembled <output-dir> <label>
assert_assembled() {
  local out="$1" label="$2"
  jq -e . "$out/.claude/settings.json" >/dev/null 2>&1 || { fail "$label — settings.json invalid"; return; }
  jq -e . "$out/.mcp.json"            >/dev/null 2>&1 || { fail "$label — .mcp.json invalid"; return; }
  if [ -f "$out/.claude/settings.fragment.json" ] || [ -f "$out/.mcp.json.fragment" ]; then
    fail "$label — leftover fragment at an auto-merge path"; return
  fi
  for h in "$out"/.claude/hooks/*.sh; do
    [ -e "$h" ] || continue
    [ -x "$h" ] || { fail "$label — hook not executable: ${h##*/}"; return; }
  done
  ok "$label"
}

echo "== coverage: thin recipes + root manifest =="
for d in generic data devops finance mobile game embedded scientific security content ops; do
  out="$(mktemp -d)"
  if ./assemble.sh "$d/harness.config.yml" "$out" >/dev/null 2>&1; then
    assert_assembled "$out" "recipe:$d"
  else fail "recipe:$d — assemble exited non-zero"; fi
  rm -rf "$out"
done
out="$(mktemp -d)"
./assemble.sh harness.config.yml "$out" >/dev/null 2>&1 && assert_assembled "$out" "root-manifest" \
  || fail "root-manifest — assemble exited non-zero"
rm -rf "$out"

echo "== coverage: web sub-domains =="
while IFS= read -r sd; do
  name="$(basename "$(dirname "$sd")")"
  out="$(mktemp -d)"
  if ./assemble.sh "$sd" "$out" >/dev/null 2>&1; then assert_assembled "$out" "subdomain:$name"
  else fail "subdomain:$name — assemble exited non-zero"; fi
  rm -rf "$out"
done < <(find web -mindepth 2 -maxdepth 2 -name 'harness.config.yml' | sort)

echo "== coverage: cross-cutting modules =="
# probe: copy the root manifest, flip the one key that selects this module.
probe_for_module() {            # probe_for_module <category> <option> <tmpfile>
  local cat="$1" opt="$2" f="$3"
  cp harness.config.yml "$f"
  case "$cat" in
    memory)          sed -i.x "s/^  backend: .*/  backend: $opt/" "$f" ;;  # first 'backend:' is memory
    progress-tracking)
      # second 'backend:' is progress — rewrite via awk
      awk -v o="$opt" 'BEGIN{n=0} /^  backend:/{n++; if(n==2){print "  backend: " o; next}} {print}' "$f" > "$f.a" && mv "$f.a" "$f" ;;
    methodology)
      key="$opt"; [ "$opt" = "spec-driven" ] && key="spec_driven"
      [ "$opt" = "eval-driven" ] && key="eval_driven"
      sed -i.x "s/^  $key: .*/  $key: true/" "$f" ;;
    orchestration)   sed -i.x "s/^  topology: .*/  topology: $opt/" "$f" ;;
    safety)
      key="$opt"; [ "$opt" = "two-key" ] && key="two_key"
      [ "$opt" = "kill-switch" ] && key="kill_switch"
      sed -i.x "s/^  $key: .*/  $key: true/" "$f" ;;
  esac
  rm -f "$f.x"
}
while IFS= read -r moddir; do
  opt="$(basename "$moddir")"; cat="$(basename "$(dirname "$moddir")")"
  [ "$cat" = "memory" ] && [ "$opt" = "md-files" ] && { :; }   # md-files is the default; still probe
  f="$(mktemp)"; probe_for_module "$cat" "$opt" "$f"
  out="$(mktemp -d)"
  if ./assemble.sh "$f" "$out" >/dev/null 2>&1; then assert_assembled "$out" "module:$cat/$opt"
  else fail "module:$cat/$opt — assemble exited non-zero"; fi
  rm -rf "$out" "$f"
done < <(find _modules -mindepth 2 -maxdepth 2 -type d | sort)

echo "== coverage: web addons =="
# probe: a real web sub-domain config with domain.addons set to just this addon.
# The probe must live inside a sub-domain dir so assemble.sh detects the pack.
PROBE_HOST="web/frontend-app"
while IFS= read -r addondir; do
  addon="$(basename "$addondir")"
  f="$PROBE_HOST/.probe-${addon}.harness.config.yml"
  sed "s/^\(  addons:\).*/\1 [$addon]/" "$PROBE_HOST/harness.config.yml" > "$f"
  out="$(mktemp -d)"
  if ./assemble.sh "$f" "$out" >/dev/null 2>&1 \
     && ! ./assemble.sh "$f" "$out" 2>&1 >/dev/null | grep -q "addon not found"; then
    assert_assembled "$out" "addon:$addon"
  else
    fail "addon:$addon — assemble failed or addon not found"
  fi
  rm -rf "$out" "$f"
done < <(find web/_addons -mindepth 1 -maxdepth 1 -type d | sort)

echo "== coverage: .mcp.json deep-merge fixture =="
out="$(mktemp -d)"
./assemble.sh generic/harness.config.yml "$out" >/dev/null 2>&1
cp tests/fixtures/mcp-merge/.mcp.json.fragment "$out/.mcp.json.fragment"
merged="$(jq -s '
  def dm($a;$b): reduce ($b|keys_unsorted[]) as $k ($a;
    if (($a[$k]|type)=="object") and (($b[$k]|type)=="object") then .[$k]=dm($a[$k];$b[$k])
    elif (($a[$k]|type)=="array") and (($b[$k]|type)=="array") then .[$k]=($a[$k]+$b[$k])
    else .[$k]=$b[$k] end); dm(.[0];.[1])' "$out/.mcp.json" "$out/.mcp.json.fragment")"
echo "$merged" | jq -e '.mcpServers.context7' >/dev/null 2>&1 \
  && ok "mcp deep-merge keeps server" || fail "mcp deep-merge lost server"
rm -rf "$out"

summary
