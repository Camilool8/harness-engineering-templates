## Memory (vector store)

Durable memory is split by shape:

- **Code-shaped knowledge** — conventions, architecture, decisions you grep —
  stays in `CLAUDE.md` and `.claude/memory/*.md`. Read those first.
- **Large, fuzzy, conversational knowledge** lives in the **Mem0 memory MCP**.
  At session start, query it for facts relevant to the task before acting.
  When you learn a durable user- or domain-fact, store it via the MCP.

Treat vector recall as fuzzy: it returns the most similar memories, not an
exact set. Verify a recalled fact before relying on it. See the
`using-vector-memory` skill for the store/retrieve procedure.
