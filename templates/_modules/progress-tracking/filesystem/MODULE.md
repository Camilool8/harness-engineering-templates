# Module: progress-tracking/filesystem

> Config: `progress.backend: filesystem` · Depends on: none

**What it does.** Keeps work items, plans and status on disk in
`.claude/progress/`: a `plan.md` (the approach and decisions) and a `tasks.md`
(a markdown checklist). A skill teaches the agent to maintain both, tick items
the moment they are done, and record decisions as they are made.

## Adopt if
- You are solo or a small team and work does not need to be visible in an
  external tracker.
- You want progress to be git-diffable and travel with the branch.
- You want the lowest-friction option. **This is the default.**

## Skip if
- A team or external stakeholders already live in GitHub Issues, Linear or Jira
  — track there instead so there is one source of truth (`github-issues`,
  `linear`, `jira`).
- Work is ephemeral / one-shot and needs no durable plan — use
  `progress.backend: none`.

## Dependencies
- None. No MCP server, no external service.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Decide whether to commit `.claude/progress/`. Committing makes progress
   reviewable; gitignoring keeps it scratch. Default: commit it.

## Install (assemble.sh)
Set `progress.backend: filesystem` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `.claude/progress/` and `.claude/skills/tracking-progress-on-disk/`.
- Remove the `## Progress tracking` section appended to `CLAUDE.md`.

## Files
- `files/.claude/progress/plan.md` — plan template (approach, scope, decisions).
- `files/.claude/progress/tasks.md` — task checklist template.
- `files/.claude/skills/tracking-progress-on-disk/SKILL.md` — how to maintain
  the plan and task files.
