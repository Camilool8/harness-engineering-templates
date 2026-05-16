# .claude/agents/

Sub-agent definitions land here — one `.md` per agent.

`_base` ships **no** sub-agents: the correct default is **one well-equipped
agent**. Add sub-agents only when the `orchestration` module you picked needs
them, or when a task genuinely warrants a fresh isolated context.

When you do add them, hold these invariants (see `docs/AGENT_ROLES.md`):

- **Least privilege.** A reviewer is read-only (`Read, Grep, Glob`); an
  implementer gets `Edit, Write, Bash`. Never the same tool set.
- **Different model family for evaluators.** Same-model review is sycophantic.
- **Typed return contracts.** Sub-agents return structured summaries, not
  free-form prose. Verbose logs stay in the child's context.
- **Spawn budgets.** Cap `max_subagents` / depth so orchestration cannot
  recurse away from you.
