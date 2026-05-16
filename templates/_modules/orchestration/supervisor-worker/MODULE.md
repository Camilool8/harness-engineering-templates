# Module: orchestration/supervisor-worker

> Config: `orchestration.topology: supervisor-worker` · Depends on: none

**What it does.** Installs an orchestrator-worker topology as four least-privilege
sub-agents: an Opus-tier read-only **planner** that returns a typed plan, a Sonnet
**implementer** with a bounded scope, and a two-stage review pair —
**spec-reviewer** then **quality-reviewer** (a different model family) — that gates
each task before it is accepted.

## Adopt if
- The work decomposes into independent sub-tasks where parallel exploration
  genuinely beats deeper sequential reasoning — open-ended research, codebase
  fan-out, parallel migrations.
- You want fresh-context-per-task isolation so a test-writer's intent cannot leak
  into the implementer, and a reviewer's earlier praise cannot suppress later
  criticism.
- You can absorb the cost: orchestrator-worker runs roughly an order of magnitude
  more tokens than a single chat.

## Skip if
- The work is inherently sequential — multi-agent then adds latency, cost and
  context fragmentation with no upside. Use `single-agent` (the base default) or
  `orchestration/pipeline`.
- The task needs unified design decisions across sub-tasks — isolated workers
  produce the "Mario backgrounds + non-game birds" failure. Isolate research,
  share design.
- It is a short bug fix or spike where sub-agent spin-up costs more than the
  in-context drift it prevents.

## Dependencies
- Claude Code sub-agents (file-based agents in `.claude/agents/`).
- Access to two model families — one for the implementer, a different one for the
  quality-reviewer. Same-family review is sycophantic and is not supported here.
- No MCP server required.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Confirm the four agents appear in `.claude/agents/`; adjust the `model:` field
   of `quality-reviewer.md` if your different-family model has another id.

## Install (assemble.sh)
Set `orchestration.topology: supervisor-worker` in `harness.config.yml`; run
`./assemble.sh`.

## Remove
- Delete `.claude/agents/planner.md`, `implementer.md`, `spec-reviewer.md` and
  `quality-reviewer.md`.
- Remove the `## Orchestration — supervisor / worker` section from `CLAUDE.md`.

## Files
- `files/.claude/agents/planner.md` — Opus-tier, read-only (Read/Grep/Glob/WebFetch);
  returns a typed plan with tasks, file paths, acceptance criteria.
- `files/.claude/agents/implementer.md` — Sonnet, Edit/Write/Bash; executes ONE
  bounded task and returns a typed diff summary.
- `files/.claude/agents/spec-reviewer.md` — read-only; checks the diff against the
  task's acceptance criteria. Runs first.
- `files/.claude/agents/quality-reviewer.md` — read-only, **different model
  family**; checks code quality. Runs only after spec-reviewer passes.
