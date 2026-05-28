---
name: tracking-progress-in-github
description: Track work in GitHub Issues via the GitHub MCP or gh CLI. Use when picking up assigned work, reporting progress, and linking commits and PRs to issues.
---

# Tracking progress in GitHub

GitHub Issues are the work-item spine. This skill defines how to interact with
them honestly.

## Picking up work

1. List issues assigned to the current user, or read the issue the user named.
2. Read the issue **in full** — description, acceptance criteria, labels, and
   every existing comment. Past comments often carry decisions and constraints.
3. If the issue is ambiguous or missing acceptance criteria, ask in a comment
   rather than guessing.

## Reporting progress

While working, comment on the issue when there is something material to report:

- A decision or trade-off made.
- A blocker, with what is needed to unblock it.
- A meaningful checkpoint ("API done, tests next").

Keep comments concise and factual. Do not narrate every small step — comment
when a teammate reading later would want to know.

## Linking commits and PRs

- Reference the issue number in commit messages and PR descriptions (`#123`),
  so GitHub cross-links the work.
- Open PRs against the issue; prefer `Closes #123` in the PR body so the merge
  closes the issue automatically.

## Closing — only with verified evidence

Do **not** close an issue to signal "I think I'm done".

- An issue is closed only when its acceptance criteria are **demonstrably met**
  — tests pass, behavior confirmed, the change is merged.
- Prefer letting the merged PR close it via `Closes #123` rather than closing by
  hand.
- If you cannot verify the criteria, leave the issue open and comment what
  remains. An open issue with an honest status beats a closed one that is wrong.

## Tooling

Use the GitHub MCP tools when available. If the MCP is not configured, fall back
to the `gh` CLI (`gh issue view`, `gh issue comment`, `gh pr create`).

To wire the MCP, add it to your project's `.mcp.json` (it is not auto-started by
the plugin) and set `GITHUB_TOKEN`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@github/github-mcp-server"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```
