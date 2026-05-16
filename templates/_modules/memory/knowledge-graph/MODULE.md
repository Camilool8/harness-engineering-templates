# Module: memory/knowledge-graph

> Config: `memory.backend: knowledge-graph` · Depends on: none (complements `memory/md-files`)

**What it does.** Adds a temporal knowledge-graph memory backed by a Zep MCP
server. Facts are stored as graph relations with provenance (who/what stated
them, when) and validity intervals, so the agent can answer "what was true
*then*" and reason across multiple hops. Built for regulated work where facts
change and that change must be auditable.

## Adopt if
- Facts have **provenance** — you must know the source and time of every claim.
- Facts **decay or get superseded**, and you need point-in-time answers, not
  just the latest value.
- Reasoning is **multi-hop** across related entities (this customer → their
  account → its policy → the regulation that governs it).
- You are in a regulated industry (finance, healthcare, legal) where memory is
  subject to audit.

## Skip if
- Your facts are stable and code-shaped — `memory/md-files` is cheaper and
  PR-reviewable.
- You only need fuzzy semantic recall over a large corpus — `memory/vector-store`
  is simpler.
- You have not yet hit a real provenance or temporal-reasoning need. A knowledge
  graph is the heaviest backend; do not adopt it speculatively.

## Dependencies
- A Zep MCP server. Hosted: a Zep Cloud API key. Self-hosted: run Zep
  (it manages its own graph store).
- `memory/md-files` recommended alongside this for code-shaped knowledge.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Merge `files/.claude/.mcp.json.fragment` into your project `.mcp.json`
   (`assemble.sh` does not merge JSON). Then export the credentials it
   references: `export ZEP_API_KEY=...` (and `ZEP_API_URL` if self-hosted).

## Install (assemble.sh)
Set `memory.backend: knowledge-graph` in `harness.config.yml`; run
`./assemble.sh`, then complete step 3 above (JSON merge + env vars) manually.

## Remove
- Delete `.claude/skills/using-graph-memory/`.
- Remove the `zep` entry from `.mcp.json` and delete `.mcp.json.fragment`.
- Remove the `## Memory (knowledge graph)` section appended to `CLAUDE.md`.

## Files
- `files/.claude/.mcp.json.fragment` — Zep MCP server entry to merge into `.mcp.json`.
- `files/.claude/skills/using-graph-memory/SKILL.md` — how to store provenance-
  aware facts and query them across time.
