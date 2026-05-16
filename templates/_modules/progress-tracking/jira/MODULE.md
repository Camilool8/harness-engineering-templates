# Module: progress-tracking/jira

> Config: `progress.backend: jira` · Depends on: none

**What it does.** Makes Jira the work-item spine for enterprise and regulated
teams. The agent reads its assigned issues, transitions them through the
project's workflow as work genuinely progresses, comments updates, and links
commits and PRs — but never transitions an issue to a closed state without
verified evidence. Uses the Atlassian MCP server.

## Adopt if
- Your organisation already runs on Jira — it is the system of record for work,
  and audits or compliance reviews read it.
- Work must be traceable to tickets for governance reasons.
- Stakeholders outside engineering track delivery in Jira.

## Skip if
- You are solo or small and nobody depends on Jira — `progress-tracking/filesystem`
  is far lower friction.
- The team's work items live in GitHub Issues or Linear — use `github-issues`
  or `linear` so there is exactly one tracker.

## Dependencies
- The Atlassian MCP server (`@atlassian/mcp-server` or Atlassian's hosted
  Remote MCP).
- Atlassian credentials: site URL, user email, and an API token —
  `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Merge `files/.claude/.mcp.json.fragment` into your project `.mcp.json`
   (`assemble.sh` does not merge JSON). Export the three credentials it
   references.

## Install (assemble.sh)
Set `progress.backend: jira` in `harness.config.yml`; run `./assemble.sh`, then
complete step 3 above (JSON merge + credentials) manually.

## Remove
- Delete `.claude/skills/tracking-progress-in-jira/`.
- Remove the `atlassian` entry from `.mcp.json` and delete `.mcp.json.fragment`.
- Remove the `## Progress tracking (Jira)` section from `CLAUDE.md`.

## Files
- `files/.claude/.mcp.json.fragment` — Atlassian MCP server entry to merge into `.mcp.json`.
- `files/.claude/skills/tracking-progress-in-jira/SKILL.md` — how to read issues,
  transition workflow states, and close only with verified evidence.
