#!/usr/bin/env bash
# ============================================================================
# assemble.sh — build a Claude Code harness from harness.config.yml
#
#   ./assemble.sh [config-file] [target-dir]
#
#   config-file  defaults to ./harness.config.yml
#   target-dir   defaults to .  (your project root)
#
# What it does:
#   1. Copies _base/ into the target.
#   2. For each picked module, copies its files/ tree in and appends its
#      claude-md.md snippet to the target CLAUDE.md.
#   3. Leaves a build manifest at .claude/HARNESS.lock so you can see what
#      was assembled and remove it later.
#
# No dependencies beyond coreutils + awk. macOS bash 3.2 compatible.
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${1:-$HERE/harness.config.yml}"
TARGET="${2:-.}"

[ -f "$CONFIG" ] || { echo "config not found: $CONFIG" >&2; exit 1; }
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

# --- flatten the YAML into  section.key=value  lines -------------------------
flatten() {
  awk '
    /^[a-zA-Z]/ { s=$1; sub(/:.*/,"",s); next }
    /^  [a-zA-Z]/ {
      l=$0; sub(/^  /,"",l);
      k=l; sub(/:.*/,"",k);
      v=l; sub(/^[^:]*:[ \t]*/,"",v); sub(/[ \t]*#.*/,"",v);
      gsub(/^[ \t]+|[ \t]+$/,"",v);
      if (v!="") print s"."k"="v;
    }
  ' "$CONFIG"
}
CFG="$(flatten)"
cfg() { printf '%s\n' "$CFG" | grep "^$1=" | head -1 | cut -d= -f2- || true; }

# --- copy _base --------------------------------------------------------------
echo "→ base"
cp -R "$HERE/_base/." "$TARGET/"
PICKED=()

# --- settings merge ----------------------------------------------------------
# Modules/recipes ship .claude/settings.fragment.json. After each is copied in,
# deep-merge it into .claude/settings.json (objects recurse, arrays concatenate)
# so module hooks add to the base hooks instead of overwriting them.
JQ_OK=0; command -v jq >/dev/null 2>&1 && JQ_OK=1

# Deep-merge $1 (fragment) into $2 (base): objects recurse, arrays concatenate.
merge_json() {
  local frag="$1" base="$2"
  [ -f "$frag" ] || return 0
  if [ "$JQ_OK" -eq 1 ] && [ -f "$base" ]; then
    jq -s '
      def deepmerge($a; $b):
        reduce ($b|keys_unsorted[]) as $k ($a;
          if   (($a[$k]|type)=="object") and (($b[$k]|type)=="object")
            then .[$k] = deepmerge($a[$k]; $b[$k])
          elif (($a[$k]|type)=="array")  and (($b[$k]|type)=="array")
            then .[$k] = ($a[$k] + $b[$k])
          else .[$k] = $b[$k] end);
      deepmerge(.[0]; .[1])' "$base" "$frag" > "$base.tmp" \
      && mv "$base.tmp" "$base" && rm -f "$frag" \
      && echo "  · merged $(basename "$frag")"
  else
    echo "  ! jq not found — $(basename "$frag") left for manual merge" >&2
  fi
}

# Merge any settings + mcp fragments the last copy step dropped into the target.
merge_fragments() {
  merge_json "$TARGET/.claude/settings.fragment.json" "$TARGET/.claude/settings.json"
  merge_json "$TARGET/.mcp.json.fragment"             "$TARGET/.mcp.json"
}

# --- helper: install a module dir into the target ---------------------------
install_module() {
  local mod="$1" dir="$HERE/_modules/$1"
  [ -d "$dir" ] || { echo "  ! module missing: $1 (skipped)" >&2; return; }
  echo "→ module: $1"
  [ -d "$dir/files" ] && { cp -R "$dir/files/." "$TARGET/"; merge_fragments; }
  if [ -f "$dir/claude-md.md" ]; then
    printf '\n' >> "$TARGET/CLAUDE.md"
    cat "$dir/claude-md.md" >> "$TARGET/CLAUDE.md"
  fi
  PICKED+=("$1")
}

# --- map config → modules ----------------------------------------------------
[ "$(cfg memory.backend)" != "none" ] && [ -n "$(cfg memory.backend)" ] && \
  install_module "memory/$(cfg memory.backend)"

[ "$(cfg progress.backend)" != "none" ] && [ -n "$(cfg progress.backend)" ] && \
  install_module "progress-tracking/$(cfg progress.backend)"

[ "$(cfg methodology.tdd)"         = "true" ] && install_module "methodology/tdd"
[ "$(cfg methodology.spec_driven)" = "true" ] && install_module "methodology/spec-driven"
[ "$(cfg methodology.eval_driven)" = "true" ] && install_module "methodology/eval-driven"
[ "$(cfg methodology.bdd)"         = "true" ] && install_module "methodology/bdd"

TOPO="$(cfg orchestration.topology)"
[ -n "$TOPO" ] && [ "$TOPO" != "single-agent" ] && install_module "orchestration/$TOPO"

[ "$(cfg safety.two_key)"     = "true" ] && install_module "safety/two-key"
[ "$(cfg safety.kill_switch)" = "true" ] && install_module "safety/kill-switch"
[ "$(cfg safety.sandbox)"     = "true" ] && install_module "safety/sandbox"

# --- domain recipe extras ----------------------------------------------------
# If the config lives in a recipe folder (templates/<domain>/), apply that
# folder's files/ tree and claude-md.md snippet too.
CONFIG_DIR="$(cd "$(dirname "$CONFIG")" && pwd)"
if [ "$CONFIG_DIR" != "$HERE" ]; then
  RECIPE="$(basename "$CONFIG_DIR")"
  if [ -d "$CONFIG_DIR/files" ]; then
    echo "→ recipe: $RECIPE"
    cp -R "$CONFIG_DIR/files/." "$TARGET/"
    merge_fragments
  fi
  if [ -f "$CONFIG_DIR/claude-md.md" ]; then
    printf '\n' >> "$TARGET/CLAUDE.md"
    cat "$CONFIG_DIR/claude-md.md" >> "$TARGET/CLAUDE.md"
  fi
  PICKED+=("recipe/$RECIPE")
fi

# --- substitute the project name --------------------------------------------
NAME="$(cfg project.name)"
if [ -n "$NAME" ]; then
  if command -v perl >/dev/null 2>&1; then
    perl -pi -e "s/<PROJECT_NAME>/$NAME/g" "$TARGET/CLAUDE.md" "$TARGET/AGENTS.md" 2>/dev/null || true
  fi
fi

# --- write the lock file -----------------------------------------------------
mkdir -p "$TARGET/.claude"
{
  echo "# Assembled by assemble.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# Config: $CONFIG"
  echo "base"
  for m in "${PICKED[@]:-}"; do [ -n "$m" ] && echo "module $m"; done
} > "$TARGET/.claude/HARNESS.lock"

chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true

echo ""
echo "✓ Harness assembled into: $TARGET"
echo "  Picked: base ${PICKED[*]:-(no modules)}"
echo "  Next:   review CLAUDE.md, fill <PLACEHOLDERS>, then run: claude"
