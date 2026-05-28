#!/usr/bin/env bash
# contract-drift-check-api.sh — advisory PostToolUse hook on Write|Edit|MultiEdit.
# Sub-domain-specific to api-service.
#
# Reads the tool-use event from stdin (JSON), checks if a handler file was
# modified without a corresponding schema/spec change, and reminds the agent
# to keep the OpenAPI schema in sync.
#
# Always exits 0 (advisory — does not block the tool call).

set -euo pipefail

# --- sub-domain self-gate -------------------------------------------------
# Inert unless .claude/HARNESS.toml selects the api-service sub-domain.
TOML="${CLAUDE_PROJECT_DIR:-.}/.claude/HARNESS.toml"
grep -Eq '^[[:space:]]*subdomain[[:space:]]*=[[:space:]]*"api-service"' "$TOML" 2>/dev/null || exit 0

INPUT="$(cat)"

# Extract the file path from the tool-use event.
FILE_PATH=""
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""' 2>/dev/null || true)"
fi

# Only fire on handler/route source files (not on openapi.yaml itself).
case "$FILE_PATH" in
  openapi.yaml|openapi.json|*.openapi.yaml|*.openapi.json)
    # Schema file itself was edited — no reminder needed.
    ;;
  **/routes/**|**/handlers/**|**/controllers/**|\
  **/src/**/*.ts|**/src/**/*.js|\
  **/app/**/*.ts|**/app/**/*.js)
    echo "⚠  Contract drift reminder: '$FILE_PATH' was modified."
    echo "   If this change alters request shape, response shape, or error codes,"
    echo "   update openapi.yaml first and run the contract-reviewer agent before marking done."
    ;;
  "")
    # No path found — silently exit.
    ;;
esac

exit 0
