---
goal: "<the current overall objective — one line>"
updated: 2026-01-01
phase: open
---

# Blackboard — STATE

The shared coordination surface. The orchestrator reads this whole file to
decide the next action; it is the single source of truth for the current run.

## Goal

<Restate the objective and what "done" means.>

## Decisions

Settled, board-wide decisions every agent must honor. Append, do not rewrite —
strike through superseded entries so history survives.

| # | Decision | Made by | Date |
|---|----------|---------|------|
| 1 | _none yet_ | | |

## Open questions

Unknowns blocking progress. A worker that resolves one writes an `entries/`
file and the orchestrator moves the answer into Decisions.

| # | Question | Raised by | Status |
|---|----------|-----------|--------|
| 1 | _none yet_ | | open |

## Agent status

One row per active agent. Workers update their own row; the orchestrator reads
it to know who is busy.

| Agent | Claimed task | Status | Last update |
|-------|--------------|--------|-------------|
| _none yet_ | | idle | |

## Tasks

Live tasks are files under `tasks/`. This is the index.

| Task file | Summary | Status |
|-----------|---------|--------|
| _none yet_ | | |
