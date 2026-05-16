---
id: "0001"
type: semantic
title: "Example: why we use markdown memory"
created: 2026-01-01
updated: 2026-01-01
tags: [meta, memory]
status: active
---

# Why we use markdown memory

**Context.** This is an example note. Replace or delete it once real memory
accumulates.

**Decision.** Durable knowledge lives in `.claude/memory/*.md` because it is
cheap, git-diffable, reviewable in pull requests, and survives model upgrades.

**Consequences.** Every new note must be added to `MEMORY.md`. When a note is
superseded, move it to `archive/` rather than deleting it, so the reasoning
trail is preserved.

**Links.** See `.claude/skills/managing-file-memory/SKILL.md` for the procedure.
