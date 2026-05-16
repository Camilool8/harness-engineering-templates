## Safety — kill switch

This harness has an **out-of-band kill switch** for autonomous and long-running
work. Before every tool call and at the end of every turn, the
`kill-switch.sh` hook checks `.claude/KILL`.

**How it behaves.** If `.claude/KILL` exists, its first line selects a level:
- `throttle` — the hook pauses briefly before each tool call. Slow down; the
  operator is watching.
- `pause` — tool calls are blocked. Stop work, summarize current state for the
  human, and wait. Do not try to route around the block.
- `stop` — the run is aborted. Halt immediately.

**Rules.**
- The kill switch is operated by a human from **outside** your session. You do
  not control it and must not try to.
- You must **never** create, edit, move, or delete `.claude/KILL`, and never
  touch `.claude/hooks/kill-switch.sh` or its log. Disabling your own kill
  switch is a hard violation — the file is on the permission deny-list for
  exactly this reason.
- If a check blocks you, treat it as a deliberate operator instruction, not an
  error to work around.

See `KILLSWITCH.md` for the operator procedure.
