---
name: operating-the-kill-switch
description: Provides an out-of-band stop control (throttle/pause/stop) for autonomous or long-running agent loops via a .claude/KILL file the agent cannot disable. Use for unattended or multi-step autonomous runs; arm with kill_switch = true in .claude/HARNESS.toml.
---

# Safety — kill switch

An **out-of-band kill switch** for autonomous and long-running work. Before every
tool call and at the end of every turn, the `kill-switch.sh` hook checks
`.claude/KILL`.

## Arming the gate

Add this to `.claude/HARNESS.toml` (create the file if needed):

```toml
[harness]
kill_switch = true
```

For the switch to be tamper-proof, add the kill file, the log, and (if you
vendor it) the hook to your project's permission deny-list so the agent cannot
clear its own signal — see
[`docs/reference/recommended-permissions.md`](https://github.com/Camilool8/harness-engineering-templates/blob/main/docs/reference/recommended-permissions.md):

```json
{ "permissions": { "deny": ["Write(./.claude/KILL)", "Edit(./.claude/KILL)", "Bash(rm*.claude/KILL*)"] } }
```

## How it behaves (agent)

If `.claude/KILL` exists, its first line selects a level:
- `throttle` — the hook pauses briefly before each tool call. Slow down; the
  operator is watching.
- `pause` — tool calls are blocked. Stop work, summarize current state for the
  human, and wait. Do not try to route around the block.
- `stop` — the run is aborted. Halt immediately.

Rules for the agent:
- The kill switch is operated by a human from **outside** your session. You do
  not control it and must not try to.
- Never create, edit, move, or delete `.claude/KILL` or its log. Disabling your
  own kill switch is a hard violation.
- If a check blocks you, treat it as a deliberate operator instruction, not an
  error to work around.

## Operator runbook (human, separate terminal at the project root)

```sh
echo throttle > .claude/KILL    # slow it down
echo pause    > .claude/KILL    # suspend tool calls
echo stop     > .claude/KILL    # abort the run
rm .claude/KILL                 # clear / resume normal operation
```

Only the first line is read as the level; lines 2+ may hold notes. Any
unrecognized contents fail safe and abort. Tune the throttle delay with the
`HARNESS_KILL_THROTTLE` env var (seconds).

Every check is appended to `.claude/kill-switch.log.jsonl` (one JSON object per
line: timestamp, event, tool, level, action) so you can audit when the switch
engaged and what the agent attempted.
