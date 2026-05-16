## Memory

Durable, cross-session knowledge lives in `.claude/memory/` as small markdown
notes plus this `CLAUDE.md`.

- **At session start**, read `.claude/memory/MEMORY.md` (the index). Open the
  individual notes it lists that are relevant to the current task.
- **`CLAUDE.md` holds always-true project facts** — conventions, architecture,
  commands. Keep it short; it is loaded every turn.
- **`.claude/memory/*.md` holds everything else** — decisions, incidents,
  recurring procedures. When you learn something that a future session would
  need, write a new note and add it to the index. Do not let knowledge die in
  the conversation.
- See the `managing-file-memory` skill for the note format and pruning rules.
