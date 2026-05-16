# Module: memory/vector-store

> Config: `memory.backend: vector-store` · Depends on: none (complements `memory/md-files`)

**What it does.** Adds a semantic-retrieval memory backed by a Mem0 MCP server,
for corpora too large to keep in context. The agent stores and recalls facts via
MCP tools instead of reading whole files. File-memory (`CLAUDE.md`) still holds
code-shaped knowledge — this module is additive, not a replacement.

## Adopt if
- Memory has measurably outgrown the context window — you are summarising or
  truncating `.claude/memory/` to make it fit.
- The knowledge is conversational or naturally semantic-retrieval-shaped:
  long user histories, customer-specific personalization, large KBs.
- You want fuzzy recall ("what did we decide about rate limiting?") rather than
  exact grep.

## Skip if
- File-memory still fits in context and works — **do not adopt this first.**
  Measure where `md-files` breaks before adding infrastructure.
- Your knowledge is code-shaped (conventions, decisions you grep) — keep it in
  `memory/md-files`; vector recall is fuzzy and not PR-reviewable.
- Facts have provenance, expiry, or contradict over time — use
  `memory/knowledge-graph` instead.

## Dependencies
- A Mem0 MCP server. Hosted: a Mem0 Platform API key. Self-hosted: run the
  `mem0/mem0-mcp` server (it can sit on Chroma or another vector DB).
- `memory/md-files` is recommended alongside this for code-shaped knowledge.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Merge `files/.claude/.mcp.json.fragment` into your project `.mcp.json`
   (`assemble.sh` does not merge JSON — do this by hand). Then export the API
   key the fragment references: `export MEM0_API_KEY=...`.

## Install (assemble.sh)
Set `memory.backend: vector-store` in `harness.config.yml`; run `./assemble.sh`,
then complete step 3 above (JSON merge + env var) manually.

## Remove
- Delete `.claude/skills/using-vector-memory/`.
- Remove the `mem0` entry from `.mcp.json` and delete `.mcp.json.fragment`.
- Remove the `## Memory (vector store)` section appended to `CLAUDE.md`.

## Files
- `files/.claude/.mcp.json.fragment` — Mem0 MCP server entry to merge into `.mcp.json`.
- `files/.claude/skills/using-vector-memory/SKILL.md` — when and how to store and
  retrieve facts via the memory MCP.
