---
name: managing-file-memory
description: Write, index and prune durable knowledge as markdown notes in .claude/memory/. Use when you learn a fact, make a decision, resolve an incident, or discover a recurring procedure that a future session would need.
---

# Managing file memory

Durable knowledge lives as small markdown notes in `.claude/memory/`. This skill
defines how to write, index and prune them. The goal: a future session can
recover what this session learned by reading files, not transcripts.

## When to write a note

Write a note when something would be expensive to rediscover:

- **Semantic** — a decision, constraint, or non-obvious fact ("we pin Node 20
  because 22 breaks the native addon").
- **Episodic** — an incident or debugging session and its outcome ("auth flakes
  traced to clock skew on CI runners — fixed by NTP sync").
- **Procedural** — a recurring runbook ("how to cut a release").

Do **not** write a note for transient task state — that belongs in progress
tracking. Do not duplicate `CLAUDE.md`; `CLAUDE.md` is for always-true facts.

## Note format

Filename: `NNNN-kebab-slug.md`, where `NNNN` is the next free 4-digit id.

```markdown
---
id: "0007"
type: semantic        # semantic | episodic | procedural
title: "Short human title"
created: 2026-05-15
updated: 2026-05-15
tags: [auth, ci]
status: active        # active | archived
---

# Short human title

**Context.** Why this came up.
**Decision / Finding / Procedure.** The substance.
**Consequences.** What this implies for future work.
**Links.** Related notes, files, PRs.
```

Keep each note under ~40 lines. One idea per note. Notes are cheap; make many.

## Index discipline

`.claude/memory/MEMORY.md` is the index — the agent reads it at session start.
Every note **must** appear in it. After writing or editing a note:

1. Add or update its row in the matching section of `MEMORY.md`.
2. Set the row's `Updated` date.

A note not in the index is invisible. Never skip this step.

If `.claude/memory/MEMORY.md` does not exist yet, create it from this skeleton:

```markdown
# Memory index

The agent reads this file at session start, then opens the notes relevant to
the task. Keep one row per note. Newest at the top within each section.

## Semantic — what is known (decisions, facts, constraints)

| Note | Title | Updated |
|---|---|---|

## Episodic — what happened (incidents, debugging sessions, outcomes)

| Note | Title | Updated |
|---|---|---|

## Procedural — how things should be done (recurring runbooks)

| Note | Title | Updated |
|---|---|---|

## Archive

Stale or superseded notes are moved to `.claude/memory/archive/` and listed
here so history is not lost.

| Note | Title | Archived | Reason |
|---|---|---|---|
```

## Pruning

Memory rots. On any session that touches `.claude/memory/`:

- If a note is **superseded** by a newer decision, set its `status: archived`,
  move the file to `.claude/memory/archive/`, and move its index row to the
  Archive table with a reason. Do not delete — provenance matters.
- If a note is **wrong**, correct it and bump `updated`.
- If two notes overlap, merge them and archive the loser.

Aim to keep the active index short enough to scan in seconds.
