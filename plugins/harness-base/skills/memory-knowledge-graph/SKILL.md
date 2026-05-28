---
name: using-graph-memory
description: Store and query provenance-aware, time-bounded facts in the Zep knowledge-graph MCP. Use when working with facts that have a source, change over time, or need multi-hop reasoning across related entities.
---

# Using graph memory

A Zep MCP server provides a temporal knowledge graph: facts are relations
between entities, each carrying provenance and a validity interval. This skill
covers how to store and query them in a way that survives audit.

## Query — before acting on any entity

When the task involves an entity (a customer, account, policy, ticket), query
the graph for what it knows about that entity first.

- Ask for **multi-hop** context when needed — follow relations rather than
  asking for one isolated fact.
- When history matters, ask for the state **as of** a specific date. The graph
  can answer "what was the credit limit on 2026-01-10", not just "now".
- Each returned fact carries its source and time. **Surface that provenance** to
  the user when it informs a decision; do not present a fact as bare truth.

## Store — with provenance, always

When you learn a durable fact, store it via the MCP. Every stored fact must
include:

- **The fact** — a clear subject-relation-object statement.
- **The source** — where it came from (a document, a user statement, a system
  of record). A fact with no source must not be stored.
- **The observation time** — when the fact was stated or became true.

If you cannot supply a source, you do not have a fact — you have a guess. Do not
store guesses.

## Updating facts — supersede, never overwrite

When a fact changes (a customer moves, a policy is revised):

- Store the **new** fact with its own source and time.
- The graph marks the prior fact as no longer valid from that point; it is
  retained, not deleted. This is what makes point-in-time queries and audit
  possible.
- Never edit a past fact to make it "current" — that destroys the history a
  regulated review depends on.

## What stays out of the graph

- Conventions, architecture, build commands → `CLAUDE.md`.
- Code decisions and incidents → `.claude/memory/*.md`.
- Secrets and credentials → nowhere.

The graph is for evolving, provenance-bearing domain facts. Keep code-shaped
knowledge in files where it is cheap and PR-reviewable.

## MCP setup (opt-in)

This skill needs the Zep MCP server. It is **not** auto-started by the plugin —
add it to your project's `.mcp.json` only if you want a knowledge graph, then
set `ZEP_API_KEY` (and `ZEP_API_URL` for self-hosted) in your environment:

```json
{
  "mcpServers": {
    "zep": {
      "command": "npx",
      "args": ["-y", "@getzep/zep-mcp-server"],
      "env": { "ZEP_API_KEY": "${ZEP_API_KEY}", "ZEP_API_URL": "${ZEP_API_URL}" }
    }
  }
}
```
