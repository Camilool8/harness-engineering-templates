---
name: tracking-progress-on-disk
description: Maintain plan and task files in .claude/progress/ as work proceeds. Use at the start of any non-trivial task and continuously while working, to keep the plan and checklist in sync with reality.
---

# Tracking progress on disk

Work items and status live in `.claude/progress/`. This skill defines how to
keep them honest.

## At the start of a task

1. Read `.claude/progress/plan.md` and `.claude/progress/tasks.md`.
2. If the plan is empty or stale for this work, fill in Objective, Scope and
   Approach before writing code.
3. Break the work into concrete checklist items in `tasks.md`. Each item should
   be small enough to finish and verify in one sitting.

## While working

- **Tick a task the moment it is genuinely done** — not when started, not
  "mostly". A box is checked only after the work is verified.
- **Add tasks as they surface.** New work discovered mid-task goes into the
  checklist immediately, so nothing lives only in your head.
- **Move blocked items** to the Blocked section with the reason.
- Keep exactly one small set of items in `In progress` — avoid claiming many
  things are simultaneously underway.

## Recording decisions

When you make a non-obvious choice — a library, a trade-off, a scope cut —
append a dated entry to the `Decisions` section of `plan.md`. Do not rewrite
past entries; the log is append-only so the reasoning trail survives.

## Honesty rules

- A stale checklist is worse than no checklist. If reality and the files
  disagree, fix the files.
- Do not tick a box to look productive. Do not leave a finished task unticked.
- If scope changes, update `plan.md` Scope — do not silently drift.

These files are the single on-disk source of truth for what is done, what is
left, and why. Treat them as a contract with the next session.
