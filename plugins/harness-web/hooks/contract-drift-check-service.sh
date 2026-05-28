#!/usr/bin/env bash
# contract-drift-check-service.sh — advisory PostToolUse hook on Write|Edit|MultiEdit.
# Sub-domain-specific to distributed-backend.
#
# Reads the tool-use event from stdin (JSON), checks if a service handler,
# event producer, or consumer file was modified without a corresponding
# schema/contract change, and reminds the agent to keep contracts in sync.
#
# Always exits 0 (advisory — does not block the tool call).

set -euo pipefail

# --- sub-domain self-gate -------------------------------------------------
# Inert unless .claude/HARNESS.toml selects the distributed-backend sub-domain.
TOML="${CLAUDE_PROJECT_DIR:-.}/.claude/HARNESS.toml"
grep -Eq '^[[:space:]]*subdomain[[:space:]]*=[[:space:]]*"distributed-backend"' "$TOML" 2>/dev/null || exit 0

INPUT="$(cat)"

# Extract the file path from the tool-use event.
FILE_PATH=""
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""' 2>/dev/null || true)"
fi

# Only fire on service source files that could affect contracts.
# Skip schema/contract files themselves.
case "$FILE_PATH" in
  # Schema/contract files — no reminder needed.
  openapi.yaml|openapi.json|asyncapi.yaml|asyncapi.json|\
  *.openapi.yaml|*.openapi.json|*.asyncapi.yaml|\
  **/pact/**|**/__pacts__/**|**/contracts/**)
    ;;
  # Handler, producer, consumer, or route files.
  **/handlers/**|**/routes/**|**/consumers/**|**/producers/**|\
  **/events/**|**/messages/**|\
  **/src/**/*.ts|**/src/**/*.js|\
  **/services/**/*.ts|**/services/**/*.js)
    echo "⚠  Contract drift reminder: '$FILE_PATH' was modified."
    echo "   If this change alters an API endpoint, event schema, or message"
    echo "   format, update the AsyncAPI/OpenAPI schema and Pact contracts first."
    echo "   Run the contract-reviewer agent before marking this change done."
    ;;
  "")
    # No path found — silently exit.
    ;;
esac

exit 0
