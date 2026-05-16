#!/usr/bin/env bash
# PreToolUse hook — matcher: Edit|Write|MultiEdit
# Protects the asset pipeline. Engine sidecar files (.meta, .uasset, .import,
# .tres/.tscn uid lines) carry stable GUIDs that bind references across the
# project. Rewriting or orphaning a GUID silently breaks every reference and
# produces an unreviewable source-control diff. Exit 2 = block.
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$path" ] && exit 0

case "$path" in
  *.meta|*.uasset|*.umap|*.import)
    echo "BLOCKED: '$path' is an engine-managed asset sidecar file." >&2
    echo "These carry GUIDs that bind asset references. Let the engine" >&2
    echo "regenerate them — never hand-edit. If a GUID change is truly" >&2
    echo "intended, get explicit human approval first." >&2
    exit 2
    ;;
esac

# Scene/resource files: warn (do not block) — they legitimately change, but a
# new_string that drops a guid:/uid= token is a classic orphaning bug.
case "$path" in
  *.unity|*.prefab|*.asset|*.tscn|*.tres|*.scn)
    old="$(printf '%s' "$input" | jq -r '.tool_input.old_string // empty' 2>/dev/null || true)"
    new="$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty' 2>/dev/null || true)"
    if [ -n "$old" ]; then
      old_ids="$(printf '%s' "$old"  | grep -Eo 'guid: [0-9a-f]{32}|uid="uid://[a-z0-9]+"' | sort -u || true)"
      new_ids="$(printf '%s' "$new"  | grep -Eo 'guid: [0-9a-f]{32}|uid="uid://[a-z0-9]+"' | sort -u || true)"
      missing="$(comm -23 <(printf '%s\n' "$old_ids") <(printf '%s\n' "$new_ids") 2>/dev/null || true)"
      if [ -n "${missing// }" ]; then
        echo "WARNING: this edit drops asset IDs from '$path':" >&2
        printf '  %s\n' $missing >&2
        echo "Confirm these references are intentionally removed, not orphaned." >&2
      fi
    fi
    ;;
esac
exit 0
