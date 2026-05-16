# Module: orchestration/blackboard

> Config: `orchestration.topology: blackboard` · Depends on: none

**What it does.** Scaffolds a file-system **blackboard**: a `docs/blackboard/`
directory with a `STATE.md` template and known sub-locations. Heterogeneous
agents coordinate by reading and writing this shared workspace at known paths —
the orchestrator reads to decide the next action, workers write their outputs.

## Adopt if
- State is durable and the next-action decision depends on accumulated shared
  context — not a fixed sequence, not a clean fan-out.
- Agents are heterogeneous and join/leave at different times; a researcher, a
  data agent and an implementer all contribute to one evolving picture.
- You want coordination state that is git-diffable and human-inspectable, and
  you want shorter per-agent prompts (each agent reads only the board, not every
  prior transcript).

## Skip if
- The stages are fixed and knowable — use `orchestration/pipeline`.
- The work is a clean parallel fan-out with cheap aggregation — use
  `orchestration/supervisor-worker`.
- The task is small enough for one agent — use the `single-agent` base default;
  a blackboard is pure ceremony there.

## Dependencies
- Claude Code sub-agents, or any multi-agent setup, that can read and write
  files at agreed paths.
- No MCP server required. The board is just files.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Commit `docs/blackboard/` so the convention travels with the repo. The
   `entries/` and `tasks/` directories ship with `.gitkeep` files.

## Install (assemble.sh)
Set `orchestration.topology: blackboard` in `harness.config.yml`; run
`./assemble.sh`.

## Remove
- Delete the `docs/blackboard/` directory.
- Remove the `## Orchestration — blackboard` section from `CLAUDE.md`.

## Files
- `files/docs/blackboard/STATE.md` — the board's root: current goal, open
  questions, decisions, agent status. The orchestrator's primary read.
- `files/docs/blackboard/entries/.gitkeep` — holds worker-written findings, one
  timestamped markdown file per contribution.
- `files/docs/blackboard/tasks/.gitkeep` — holds task files the orchestrator
  posts and workers claim.
