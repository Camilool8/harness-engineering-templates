---
name: tracking-progress-in-linear
description: Track work in Linear via the Linear MCP. Use when picking up assigned issues, advancing workflow states, reporting progress, and linking branches and PRs.
---

# Tracking progress in Linear

Linear is the work-item spine. This skill defines how to keep its board honest.

## Picking up work

1. List issues assigned to the current user, or open the issue the user named.
2. Read it **in full** — description, acceptance criteria, sub-issues, labels,
   and all comments. Decisions and constraints often live in the thread.
3. If acceptance criteria are missing or ambiguous, ask in a comment before
   writing code.

## Advancing workflow states

Move the issue so its state always matches reality:

- Set `In Progress` when you genuinely start — not before.
- Set `In Review` when a PR is open and awaiting review.
- Set `Done` only when the work is verified and merged (see below).
- If you stop or get blocked, reflect it — move to `Blocked` / `Todo` and
  comment why. Do not leave an issue `In Progress` that nobody is progressing.

## Reporting progress

Comment on the issue when there is something material: a decision, a blocker
with what is needed to clear it, or a meaningful checkpoint. Reference the issue
identifier (`ENG-123`) on the branch name and in the PR so Linear links them.

## Completing — only with verified evidence

- An issue moves to `Done` only when its acceptance criteria are **demonstrably
  met** — tests pass, behavior confirmed, the change is merged.
- An open, unmerged PR means the issue is `In Review`, never `Done`.
- If you cannot verify the criteria, leave the issue short of `Done` and comment
  what remains. An honest in-progress state beats a premature `Done`.
