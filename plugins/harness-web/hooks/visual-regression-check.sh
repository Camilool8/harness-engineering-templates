#!/usr/bin/env bash
# visual-regression-check.sh — advisory PostToolUse hook on Write|Edit|MultiEdit.
# Sub-domain-specific to design-system.
#
# Reads the tool-use event from stdin (JSON), checks if a component source
# file or story file was written, and reminds the agent to update visual
# snapshots via the visual-regression-tester agent.
#
# Always exits 0 (advisory — does not block the tool call).

set -euo pipefail

# --- sub-domain self-gate -------------------------------------------------
# Inert unless .claude/HARNESS.toml selects the design-system sub-domain.
TOML="${CLAUDE_PROJECT_DIR:-.}/.claude/HARNESS.toml"
grep -Eq '^[[:space:]]*subdomain[[:space:]]*=[[:space:]]*"design-system"' "$TOML" 2>/dev/null || exit 0

INPUT="$(cat)"

# Extract the file path from the tool-use event (Write/Edit provides "path").
FILE_PATH=""
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""' 2>/dev/null || true)"
fi

# Only fire on component source files and story files.
case "$FILE_PATH" in
  *.stories.tsx|*.stories.ts|*.stories.jsx|*.stories.js|\
  *.story.tsx|*.story.ts|\
  **/components/**/*.tsx|**/components/**/*.ts|\
  **/components/**/*.jsx|**/components/**/*.js)
    echo "⚠  Visual snapshot reminder: '$FILE_PATH' was modified."
    echo "   Run the visual-regression-tester agent to check for snapshot diffs"
    echo "   and update the baseline if the change is intentional."
    ;;
  "")
    # No path found — silently exit.
    ;;
esac

exit 0
