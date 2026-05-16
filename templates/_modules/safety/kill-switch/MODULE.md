# Module: safety/kill-switch

> Config: `safety.kill_switch` · Depends on: none

**What it does.** Adds an out-of-band stop control for autonomous or
long-running agent loops. A hook checks for a `.claude/KILL` file before every
tool call and at every Stop; the file's contents select one of three escalation
levels — `throttle`, `pause`, `stop`. Every check is appended to a JSONL log.
A human creates or edits `.claude/KILL` from outside the agent's session.

## Adopt if
- The agent runs autonomously, in a loop, or for long unattended sessions where
  a human cannot watch every step.
- You need a way to halt a misbehaving run *now*, without killing the process
  and losing state.
- You want graduated control — slow the agent down, pause it, or hard-stop it —
  rather than only an all-or-nothing kill.

## Skip if
- Every session is short and fully supervised — closing the terminal is already
  your kill switch.
- The agent has no autonomous loop and always waits for human input between
  actions.

## Dependencies
- `jq` (parses the hook's stdin event).
- The `.claude/KILL` file must be writable by a human/operator out-of-band and
  the check must run at the **infrastructure layer** (hook), not in agent-
  controlled code — see the policy note below.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. `chmod +x .claude/hooks/kill-switch.sh`.
4. Register the hook in `.claude/settings.json` under **both** `hooks.PreToolUse`
   (matcher `*`) and `hooks.Stop` so it fires before every tool call and at end
   of turn.
5. Add `.claude/KILL` to your tool-permission **deny-list** (and `.gitignore`)
   so the agent cannot Edit/Write/delete its own kill switch.

## Install (assemble.sh)
Set `safety.kill_switch: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `.claude/hooks/kill-switch.sh` and `KILLSWITCH.md`.
- Delete `.claude/KILL` and `.claude/kill-switch.log.jsonl` if present.
- Remove the `kill-switch.sh` entries from `.claude/settings.json` `PreToolUse`
  and `Stop`.
- Remove the `## Safety — kill switch` section from `CLAUDE.md`.

## Policy note — why this lives in the hook
The kill-switch check must run at the **infrastructure layer** (a `PreToolUse`
hook), never inside agent-authored code. A misbehaving or injected agent that
could edit its own kill logic would simply disable it. The hook runs outside the
agent's reach, and `.claude/KILL` must be on the permission deny-list so the
agent cannot delete the file to clear the signal.

## Files
- `files/.claude/hooks/kill-switch.sh` — hook wired to `PreToolUse` (`*`) and
  `Stop`. Reads `.claude/KILL`; on `stop`/`pause` exits 2 to abort, on
  `throttle` sleeps then allows; appends every check to a JSONL log.
- `files/KILLSWITCH.md` — operator runbook: how to engage each level
  out-of-band and how to clear it.
- `files/.claude/settings.fragment.json` — settings fragment registering the hook
  on `PreToolUse` and `Stop` plus the self-protection `permissions.deny` rules.
  `assemble.sh` deep-merges it into `.claude/settings.json`; merge by hand for a
  manual install.
