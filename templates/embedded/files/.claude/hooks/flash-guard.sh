#!/usr/bin/env bash
# PreToolUse hook — matcher: Bash
# Firmware flashing is irreversible and can brick hardware. This hook blocks
# any write-to-silicon command unless it is a --dry-run pass OR carries an
# explicit human approval token. Exit 2 = block.
#
# Approval token: set FLASH_APPROVED=1 in the environment (a human action),
# or include the literal string  [flash-approved]  in the command.
set -euo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

# Commands that write to silicon.
flash='idf\.py([[:space:]].*)?[[:space:]]flash'
flash="$flash|west[[:space:]]+flash"
flash="$flash|openocd"
flash="$flash|dfu-util"
flash="$flash|esptool(\.py)?([[:space:]].*)?[[:space:]]write_flash"
flash="$flash|st-flash[[:space:]]+write"
flash="$flash|JLinkExe|probe-rs[[:space:]]+(run|download)"

printf '%s' "$cmd" | grep -Eq "$flash" || exit 0

# A dry-run / simulation pass is always allowed.
if printf '%s' "$cmd" | grep -Eq -- '--dry-run|--simulate'; then
  exit 0
fi

# Explicit human approval lets it through.
if [ "${FLASH_APPROVED:-0}" = "1" ] || printf '%s' "$cmd" | grep -qF '[flash-approved]'; then
  echo "NOTE: flash command running with explicit human approval." >&2
  exit 0
fi

echo "BLOCKED: this command writes to silicon and is irreversible:" >&2
echo "  $cmd" >&2
echo "Do ONE of these first:" >&2
echo "  - run a --dry-run pass and confirm it is clean, or" >&2
echo "  - get a human to approve (export FLASH_APPROVED=1, or add" >&2
echo "    the token [flash-approved] to the command)." >&2

# Common, costly confusion: flash vs monitor.
if printf '%s' "$cmd" | grep -Eq 'idf\.py.*flash' && \
   ! printf '%s' "$cmd" | grep -Eq 'idf\.py.*monitor'; then
  echo "HINT: if you only meant to read serial output, you want" >&2
  echo "      'idf.py monitor' — NOT 'idf.py flash'." >&2
fi
exit 2
