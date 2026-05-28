#!/usr/bin/env bash
# lockfile-frozen.sh — PostToolUse hook on Bash.
# Refuses unfrozen Python installs unless UV_DEPS_UPDATE=1 is set
# (explicit deps-update mode).
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Allow uv sync, uv lock, uv run, uv pip install (the explicit-frozen forms).
# Block: pip install, uv add without --frozen-equivalent, uv pip install --upgrade.
if printf '%s' "$cmd" | grep -Eq '\bpip[[:space:]]+install\b' \
   && ! printf '%s' "$cmd" | grep -Eq '\b--no-deps\b'; then
  if [ "${UV_DEPS_UPDATE:-}" != "1" ]; then
    echo "BLOCKED: pip install outside an explicit deps-update mode." >&2
    echo "Use 'uv add <pkg>' (updates pyproject.toml + uv.lock atomically)." >&2
    echo "For a planned deps update: UV_DEPS_UPDATE=1 <command>." >&2
    exit 2
  fi
fi

if printf '%s' "$cmd" | grep -Eq '\buv[[:space:]]+pip[[:space:]]+install[[:space:]]+--upgrade\b'; then
  if [ "${UV_DEPS_UPDATE:-}" != "1" ]; then
    echo "BLOCKED: uv pip install --upgrade outside an explicit deps-update mode." >&2
    echo "For a planned deps update: UV_DEPS_UPDATE=1 <command>." >&2
    exit 2
  fi
fi

exit 0
