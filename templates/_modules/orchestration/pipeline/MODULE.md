# Module: orchestration/pipeline

> Config: `orchestration.topology: pipeline` · Depends on: none

**What it does.** Installs a fixed sequential pipeline as four stage agents —
**spec-writer → architect-reviewer → implementer → tester** — wired as a DAG.
Each stage consumes the previous stage's typed output and a programmatic gate
between stages blocks progression on failure.

## Adopt if
- The steps are knowable in advance and the same every time — gating between
  them is the value you want.
- The work is inherently sequential: later stages cannot start before earlier
  stages produce their output (a spec before an implementation, an
  implementation before a test run).
- You want a replayable, auditable trail — each stage's typed output is the
  hand-off record.

## Skip if
- The work decomposes into independent parallel sub-tasks — use
  `orchestration/supervisor-worker` for fan-out and aggregation.
- The stages are not knowable up front, or routing between them depends on
  shared evolving state — use `orchestration/blackboard`.
- It is a short change where four-stage hand-off is pure overhead — use the
  `single-agent` base default.

## Dependencies
- Claude Code sub-agents (file-based agents in `.claude/agents/`).
- A test runner reachable from the shell for the `tester` stage.
- Access to a different model family for `architect-reviewer` than for
  `implementer` (review-stage independence).
- No MCP server required.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Confirm the four stage agents appear in `.claude/agents/`.

## Install (assemble.sh)
Set `orchestration.topology: pipeline` in `harness.config.yml`; run
`./assemble.sh`.

## Remove
- Delete `.claude/agents/spec-writer.md`, `architect-reviewer.md`,
  `implementer.md` and `tester.md`.
- Remove the `## Orchestration — pipeline` section from `CLAUDE.md`.

## Files
- `files/.claude/agents/spec-writer.md` — Opus-tier, read-only; turns a goal into
  a typed spec with acceptance criteria.
- `files/.claude/agents/architect-reviewer.md` — read-only, **different model
  family** than the implementer; gates the spec for soundness before any code.
- `files/.claude/agents/implementer.md` — Sonnet, Edit/Write/Bash; implements the
  approved spec, returns a typed diff.
- `files/.claude/agents/tester.md` — Bash + Edit on test files only; runs and
  reports verification, the final gate.
