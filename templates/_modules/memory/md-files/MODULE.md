# Module: memory/md-files

> Config: `memory.backend: md-files` · Depends on: none

**What it does.** Gives the agent durable, cross-session memory as plain
markdown: `CLAUDE.md` for always-loaded semantic memory plus a `.claude/memory/`
directory of small, frontmattered episodic / semantic / procedural notes with an
index. A skill teaches the agent when and how to write, index and prune them.

## Adopt if
- Your knowledge is code-shaped — conventions, gotchas, decisions, runbooks.
- You want memory that is git-diffable, reviewable in PRs, and greppable.
- You are solo or a small team and the corpus comfortably fits in context.
- You are unsure which backend to use. **This is the default — start here.**

## Skip if
- The corpus has measurably outgrown the context window (you are summarising
  memory to fit it) — move to `memory/vector-store`.
- Facts have provenance, expiry or contradict each other over time, and you need
  multi-hop reasoning over them — move to `memory/knowledge-graph`.
- The agent is one-shot / CI-only and keeps no state — use `memory.backend: none`.

## Dependencies
- None. No MCP server, no external service. Just files and `jq`-free bash.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Commit `.claude/memory/` so memory travels with the repo.

## Install (assemble.sh)
Set `memory.backend: md-files` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `.claude/memory/` and `.claude/skills/managing-file-memory/`.
- Remove the `## Memory` section appended to `CLAUDE.md`.

## Files
- `files/.claude/memory/MEMORY.md` — the index the agent reads at session start.
- `files/.claude/memory/0001-example-decision.md` — example semantic memory note.
- `files/.claude/skills/managing-file-memory/SKILL.md` — procedure for writing,
  indexing and pruning memory notes.
