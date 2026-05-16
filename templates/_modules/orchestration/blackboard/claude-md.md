## Orchestration — blackboard

Agents coordinate through a shared file-system **blackboard** at
`docs/blackboard/`. There is no message passing — coordination happens entirely
through reads and writes at **known locations**.

**The board layout.**
- `docs/blackboard/STATE.md` — the root. Current goal, decisions, open
  questions, per-agent status. The orchestrator's primary read and write.
- `docs/blackboard/tasks/<id>.md` — one file per task. The orchestrator posts
  tasks here with `status: open`; a worker claims one by setting
  `status: claimed` and its agent name, and `status: done` when finished.
- `docs/blackboard/entries/<timestamp>-<agent>.md` — append-only findings.
  Workers write here; they never overwrite another agent's entry.

**Roles.**
- The **orchestrator reads** the whole board to decide the next action, posts
  tasks, and updates `STATE.md` decisions. It does not do the work itself.
- **Workers write.** A worker reads `STATE.md` plus its claimed task, does the
  work, writes a new file under `entries/`, and updates its task's status.
  Workers do not edit `STATE.md` decisions — they propose via an entry.

**Rules.**
- Read before you write — the board may have changed since you last looked.
- One writer per file. Use the timestamped/per-id naming so two agents never
  contend for the same file.
- Keep entries short and typed (frontmatter: `agent`, `task`, `status`,
  `summary`). The board is the shared memory; do not rely on conversation
  history that other agents cannot see.
