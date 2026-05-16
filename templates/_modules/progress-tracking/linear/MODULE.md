# Module: progress-tracking/linear

> Config: `progress.backend: linear` · Depends on: none

**What it does.** Makes Linear the work-item spine. The agent reads its assigned
issues, moves them through workflow states as work genuinely progresses, comments
updates, and links branches and PRs — but never marks an issue Done without
verified evidence. Uses the Linear MCP server.

## Adopt if
- Your product team already runs on Linear — issues, cycles and projects are the
  team's source of truth.
- You want the agent's work reflected in the same board humans watch.
- You rely on Linear's cycle / project structure for planning.

## Skip if
- You are solo or the team does not use Linear — `progress-tracking/filesystem`
  is lower friction.
- Work items live in GitHub Issues or Jira — use `github-issues` or `jira` so
  there is exactly one tracker.

## Dependencies
- The Linear MCP server (`@linear/mcp-server` or Linear's hosted MCP).
- A Linear API key, exposed as `LINEAR_API_KEY`.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Merge `files/.claude/.mcp.json.fragment` into your project `.mcp.json`
   (`assemble.sh` does not merge JSON). Export the key: `export LINEAR_API_KEY=...`.

## Install (assemble.sh)
Set `progress.backend: linear` in `harness.config.yml`; run `./assemble.sh`,
then complete step 3 above (JSON merge + key) manually.

## Remove
- Delete `.claude/skills/tracking-progress-in-linear/`.
- Remove the `linear` entry from `.mcp.json` and delete `.mcp.json.fragment`.
- Remove the `## Progress tracking (Linear)` section from `CLAUDE.md`.

## Files
- `files/.claude/.mcp.json.fragment` — Linear MCP server entry to merge into `.mcp.json`.
- `files/.claude/skills/tracking-progress-in-linear/SKILL.md` — how to read
  issues, advance workflow states, and complete only with verified evidence.
