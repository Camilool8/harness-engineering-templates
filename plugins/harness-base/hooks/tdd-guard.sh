#!/usr/bin/env bash
# tdd-guard.sh — PreToolUse hook on Write|Edit.
# OPT-IN: inert unless `tdd = true` under [harness] in .claude/HARNESS.toml.
#
# Enforces a pragmatic red-green-refactor gate:
#   - Edits to TEST files are always allowed (you must be able to write red).
#   - Edits to IMPLEMENTATION files require a FRESH failing-test marker at
#     .claude/.tdd-last-fail, written by the agent after it observed a real
#     test failure (see the practicing-tdd skill).
#   - The marker is consumed (deleted) once an implementation edit is allowed.
#
# Exit 2 = block the tool call (reason on stderr). Exit 0 = allow.
set -uo pipefail

# --- opt-in gate ----------------------------------------------------------
TOML="${CLAUDE_PROJECT_DIR:-.}/.claude/HARNESS.toml"
grep -Eq '^[[:space:]]*tdd[[:space:]]*=[[:space:]]*true' "$TOML" 2>/dev/null || exit 0

MARKER=".claude/.tdd-last-fail"
MARKER_MAX_AGE=900   # seconds; a failure older than 15min is considered stale

event="$(cat)"

# Extract the target file path from either Write or Edit input.
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"

# No path or jq unavailable -> do not block (fail open; other gates still apply).
[ -z "$path" ] && exit 0

base="$(basename "$path")"

is_test=0
case "$base" in
  *[Tt]est*|*[Ss]pec*|*.test.*|*.spec.*) is_test=1 ;;
esac
case "$path" in
  */tests/*|*/test/*|*/__tests__/*|*/spec/*|*/specs/*) is_test=1 ;;
esac

# Test files: always allowed — writing the failing test IS the red step.
[ "$is_test" -eq 1 ] && exit 0

# Non-source artifacts (docs, config, data) are out of scope for the TDD gate.
case "$base" in
  *.md|*.txt|*.json|*.yml|*.yaml|*.toml|*.ini|*.cfg|*.lock|.gitignore|Dockerfile|*.env) exit 0 ;;
esac

# Implementation file: require a fresh failing-test marker.
if [ ! -f "$MARKER" ]; then
  echo "TDD gate: editing implementation file '$path' is blocked." >&2
  echo "No observed failing test. Write a failing test first, run it, confirm it" >&2
  echo "fails, then record it: echo \"\$(date +%s)\" > $MARKER" >&2
  exit 2
fi

now="$(date +%s)"
marked="$(cat "$MARKER" 2>/dev/null | tr -dc '0-9')"
if [ -z "$marked" ]; then
  echo "TDD gate: marker $MARKER is malformed. Re-run the failing test and" >&2
  echo "re-record: echo \"\$(date +%s)\" > $MARKER" >&2
  exit 2
fi

age=$(( now - marked ))
if [ "$age" -gt "$MARKER_MAX_AGE" ] || [ "$age" -lt 0 ]; then
  echo "TDD gate: failing-test marker is stale (${age}s old)." >&2
  echo "Re-run the failing test to confirm it still fails, then re-record:" >&2
  echo "echo \"\$(date +%s)\" > $MARKER" >&2
  rm -f "$MARKER"
  exit 2
fi

# Fresh failure observed: allow this green step and consume the marker.
rm -f "$MARKER"
exit 0
