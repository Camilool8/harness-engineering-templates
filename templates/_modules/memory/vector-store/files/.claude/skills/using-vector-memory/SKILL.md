---
name: using-vector-memory
description: Store and retrieve durable facts from the Mem0 vector-memory MCP. Use at session start to recall task-relevant memories, and whenever you learn a durable user- or domain-fact worth keeping.
---

# Using vector memory

A Mem0 MCP server provides semantic memory for knowledge too large to hold in
context. This skill covers when and how to use it. It does **not** replace
file-memory — `CLAUDE.md` and `.claude/memory/*.md` still hold code-shaped
knowledge you grep and review.

## Retrieve — at session start and before non-trivial work

Query the memory MCP with a natural-language description of the current task
before acting. The server returns the most semantically similar memories.

- Treat results as **candidates, not facts.** Recall is fuzzy — it can return
  near-misses or stale entries.
- Verify a recalled fact against the codebase or the user before depending on
  it for an irreversible action.
- If recall returns nothing useful, proceed without it; do not invent memories.

## Store — when you learn something durable

Add a memory via the MCP when you learn a fact a future session would want:

- User or domain preferences ("this customer's invoices are net-60").
- Stable domain facts that do not belong in version-controlled files.
- Outcomes of long conversations worth condensing.

When storing:

- Write **one clear fact per memory**, in plain declarative prose.
- Include enough context to be self-contained ("the staging DB, not prod, uses
  the read-replica").
- Do **not** store secrets, credentials, or code — code-shaped knowledge goes in
  `.claude/memory/*.md`, secrets go nowhere.

## What stays out of vector memory

- Conventions, architecture, build commands → `CLAUDE.md`.
- Decisions and incidents you want PR-reviewable → `.claude/memory/*.md`.
- Transient task state → progress tracking.

When in doubt, prefer file-memory: it is auditable and git-diffable. Reach for
the vector store only for the large, fuzzy corpus it is built for.
