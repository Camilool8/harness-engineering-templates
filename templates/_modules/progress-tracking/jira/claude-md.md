## Progress tracking (Jira)

Work items live in **Jira**, accessed via the Atlassian MCP. Jira is the system
of record — treat it as audit-visible.

- **At the start of a task**, read the relevant Jira issue in full —
  description, acceptance criteria, linked issues and comments — before touching
  code.
- **As you work**, transition the issue through the project's workflow so it
  reflects reality: move it to `In Progress` when you start, comment material
  updates and blockers, and reference the issue key (e.g. `PROJ-123`) in commits
  and PRs.
- **Never transition an issue to a Done / Closed state** without verified
  evidence the acceptance criteria are met. Use the resolution field honestly.
  If unsure, leave it open and comment what remains. See the
  `tracking-progress-in-jira` skill.
