---
name: tracking-progress-in-jira
description: Track work in Jira via the Atlassian MCP. Use when picking up assigned issues, transitioning workflow states, reporting progress, and linking commits and PRs in enterprise or regulated projects.
---

# Tracking progress in Jira

Jira is the work-item spine and the system of record. In enterprise and
regulated contexts it is read in audits — keep it accurate.

## Picking up work

1. List issues assigned to the current user, or open the issue key the user
   named.
2. Read it **in full** — description, acceptance criteria, linked issues,
   labels, and all comments. Constraints and decisions often live in the thread.
3. If acceptance criteria are missing or ambiguous, ask in a comment before
   writing code. Do not infer scope silently.

## Transitioning workflow states

Each Jira project defines its own workflow; use the project's real transitions,
not assumed ones. Keep the issue's state matching reality:

- Move to `In Progress` when you genuinely start.
- Move to `In Review` (or the project equivalent) when a PR is open.
- Move to `Done` / `Closed` only when verified and merged (see below).
- If blocked, transition to the project's blocked state and comment why.

## Reporting progress

Comment on the issue when there is something material: a decision and its
rationale, a blocker with what is needed to clear it, or a meaningful
checkpoint. Reference the issue key (`PROJ-123`) in branch names, commit
messages and PRs so Jira's development panel links them.

## Closing — only with verified evidence

- Transition an issue to a Done / Closed state **only** when its acceptance
  criteria are demonstrably met — tests pass, behavior confirmed, change merged.
- Set the **resolution field honestly** (`Done`, `Won't Do`, `Duplicate`, etc.);
  do not close as `Done` work that was abandoned.
- An open, unmerged PR means the issue is not Done.
- If you cannot verify the criteria, leave the issue open and comment what
  remains. In a regulated context, a premature closure is an audit finding.
