#!/usr/bin/env bash
# kill-switch.sh — out-of-band stop for autonomous / long-running loops.
# Wired to BOTH hooks.PreToolUse (matcher "*") and hooks.Stop.
# OPT-IN: inert unless `kill_switch = true` under [harness] in .claude/HARNESS.toml.
#
# Reads .claude/KILL. Its first line is the escalation level:
#   throttle  -> sleep briefly, then allow (exit 0)
#   pause     -> block this tool call (exit 2)
#   stop      -> abort the run (exit 2)
# Absent / empty file -> allow (exit 0).
#
# Every check is appended to .claude/kill-switch.log.jsonl (append-only).
#
# POLICY: this check runs at the infrastructure layer (a hook), never inside
# agent code. The agent must not edit this file or .claude/KILL — add both to
# your project's permission deny-list (see the safety-kill-switch skill).
set -uo pipefail

# --- opt-in gate ----------------------------------------------------------
TOML="${CLAUDE_PROJECT_DIR:-.}/.claude/HARNESS.toml"
grep -Eq '^[[:space:]]*kill_switch[[:space:]]*=[[:space:]]*true' "$TOML" 2>/dev/null || exit 0

KILL_FILE=".claude/KILL"
LOG=".claude/kill-switch.log.jsonl"
THROTTLE_SECONDS="${HARNESS_KILL_THROTTLE:-5}"

INPUT="$(cat)"
EVENT="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // "unknown"')"
TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // "-"')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

log() {
  # $1 = level, $2 = action
  printf '{"ts":"%s","event":"%s","tool":"%s","level":"%s","action":"%s"}\n' \
    "$TS" "$EVENT" "$TOOL" "$1" "$2" >> "$LOG" 2>/dev/null || true
}

# --- no kill file -> normal operation -------------------------------------
if [ ! -f "$KILL_FILE" ]; then
  log "none" "allow"
  exit 0
fi

LEVEL="$(head -n1 "$KILL_FILE" | tr -d '[:space:]' | tr 'A-Z' 'a-z')"

case "$LEVEL" in
  throttle)
    log "throttle" "sleep+allow"
    sleep "$THROTTLE_SECONDS"
    exit 0
    ;;
  pause)
    log "pause" "block"
    echo "KILL SWITCH: level=pause. Tool calls are suspended by the operator." >&2
    echo "Stop work, summarize current state, and wait. Do not route around this." >&2
    echo "The operator clears it by removing or editing .claude/KILL." >&2
    exit 2
    ;;
  stop)
    log "stop" "abort"
    echo "KILL SWITCH: level=stop. The run is aborted by the operator." >&2
    echo "Halt immediately. See the safety-kill-switch skill to resume." >&2
    exit 2
    ;;
  *)
    # Unrecognized contents: fail safe -> treat as stop.
    log "${LEVEL:-empty}" "abort-failsafe"
    echo "KILL SWITCH: .claude/KILL present with unrecognized level '${LEVEL:-<empty>}'." >&2
    echo "Failing safe — aborting. Operator: write throttle|pause|stop or remove the file." >&2
    exit 2
    ;;
esac
