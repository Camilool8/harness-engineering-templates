# KILLSWITCH — operator runbook

Out-of-band stop control for this agent. The agent cannot see, edit, or disable
any of this — that is the point. You operate it from a separate terminal.

## How it works

A `PreToolUse` + `Stop` hook (`.claude/hooks/kill-switch.sh`) reads
`.claude/KILL` before every tool call. The file's **first line** is the
escalation level. No file means normal operation.

## The three levels

| Level | First line of `.claude/KILL` | Effect |
|-------|------------------------------|--------|
| Throttle | `throttle` | Hook sleeps a few seconds before each tool call. Use to slow a run down while you assess it. |
| Pause | `pause` | Tool calls are blocked. The agent is told to stop and summarize. State is preserved; resumable. |
| Stop | `stop` | The run is aborted. Hard halt. |

Any unrecognized contents fail safe and abort.

## Engage (from a separate terminal, at the project root)

```sh
echo throttle > .claude/KILL    # slow it down
echo pause    > .claude/KILL    # suspend tool calls
echo stop     > .claude/KILL    # abort the run
```

You may add notes on lines 2+ — only the first line is read as the level.

## Clear / resume

```sh
rm .claude/KILL                 # return to normal operation
```

After a `stop`, remove the file and restart the agent session to resume.

## Audit

Every check is appended to `.claude/kill-switch.log.jsonl` — one JSON object per
line with timestamp, event, tool, level, and action taken. Use it to confirm
when the switch engaged and what the agent attempted.

## Why it is built this way

The policy check lives in an **infrastructure-layer hook**, not in agent code.
A misbehaving or prompt-injected agent that could rewrite its own stop logic
would simply disable it. `.claude/KILL`, the hook script, and the log are all on
the tool-permission deny-list so the agent cannot clear the signal itself.

Throttle the env var `HARNESS_KILL_THROTTLE` (seconds) to tune the throttle
delay.
