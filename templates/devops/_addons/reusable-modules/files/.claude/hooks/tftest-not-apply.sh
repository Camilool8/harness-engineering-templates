#!/usr/bin/env bash
# tftest-not-apply.sh — PreToolUse hook on Write|Edit of *.tftest.hcl.
# Refuses test files that use `command = apply` against non-mock providers.
# Engineers using AI to generate tests routinely omit `command = plan` and
# run up four-figure cloud bills before noticing.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
content="$(printf '%s' "$event" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"

# Only police *.tftest.hcl writes.
case "$path" in
  *.tftest.hcl) ;;
  *) exit 0 ;;
esac

# Look for `command = apply` outside a mock_provider block.
# Conservative: any occurrence triggers a block unless the file also declares mock_provider.
if printf '%s' "$content" | grep -Eq 'command[[:space:]]*=[[:space:]]*"?apply"?'; then
  if ! printf '%s' "$content" | grep -Eq 'mock_provider[[:space:]]'; then
    echo "BLOCKED: *.tftest.hcl uses command = apply without mock_provider." >&2
    echo "Real-cloud apply in tests bills real money. Use command = plan, or" >&2
    echo "declare a mock_provider block for the providers used in the test." >&2
    exit 2
  fi
fi

exit 0
