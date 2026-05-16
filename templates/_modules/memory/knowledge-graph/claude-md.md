## Memory (knowledge graph)

Durable facts about entities and their relationships live in the **Zep
knowledge-graph MCP**. Every fact carries provenance (source, time stated) and
a validity interval, so the graph can answer point-in-time questions.

- **Before acting**, query the graph for facts about the entities in the task.
  Ask for the state *as of* the relevant date when history matters.
- **When you learn a durable fact**, store it via the MCP with its source and
  observation time. When a fact changes, record the new fact — do not overwrite;
  the graph supersedes the old one and keeps both.
- **Never assert a fact without provenance.** If you cannot cite where a fact
  came from, do not store it.
- Code-shaped knowledge (conventions, architecture) still belongs in `CLAUDE.md`
  and `.claude/memory/*.md`. See the `using-graph-memory` skill.
