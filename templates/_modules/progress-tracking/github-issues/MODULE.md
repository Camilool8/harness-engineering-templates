# Module: progress-tracking/github-issues

> Config: `progress.backend: github-issues` · Depends on: none

**What it does.** Makes GitHub Issues the work-item spine. The agent reads its
assigned issues, comments progress as it works, and links commits and PRs to
issues — but never closes an issue without verified evidence. Uses the GitHub
MCP server, with the `gh` CLI as a fallback.

## Adopt if
- The repository already runs on GitHub Issues — issues are the team's single
  source of truth.
- External stakeholders or teammates need work visible without reading the repo.
- You want progress, commits and PRs cross-linked automatically.

## Skip if
- You are solo and nobody reads the tracker — `progress-tracking/filesystem` is
  lower friction.
- The team's work items live in Linear or Jira — use `linear` or `jira` so
  there is one tracker, not two.

## Dependencies
- A GitHub MCP server (`github/github-mcp-server`) **or** the `gh` CLI installed
  and authenticated (`gh auth login`).
- A GitHub token with `repo` scope, exposed as `GITHUB_TOKEN`.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Merge `files/.claude/.mcp.json.fragment` into your project `.mcp.json`
   (`assemble.sh` does not merge JSON). Export the token: `export GITHUB_TOKEN=...`.
   If you prefer the CLI path, skip the merge and just run `gh auth login`.

## Install (assemble.sh)
Set `progress.backend: github-issues` in `harness.config.yml`; run
`./assemble.sh`, then complete step 3 above (JSON merge + token) manually.

## Remove
- Delete `.claude/skills/tracking-progress-in-github/`.
- Remove the `github` entry from `.mcp.json` and delete `.mcp.json.fragment`.
- Remove the `## Progress tracking (GitHub Issues)` section from `CLAUDE.md`.

## Files
- `files/.claude/.mcp.json.fragment` — GitHub MCP server entry to merge into `.mcp.json`.
- `files/.claude/skills/tracking-progress-in-github/SKILL.md` — how to read
  issues, comment progress, and close only with verified evidence.
