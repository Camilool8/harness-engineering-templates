# <PROJECT_NAME> — agent instructions

`CLAUDE.md` is the source of truth for this project. It is read natively by
Claude Code; this `AGENTS.md` exists for cross-tool portability (Codex, Cursor,
Windsurf, Cline, Copilot, Gemini, Goose, Amp).

**Keep them in sync.** Two low-friction options:

1. Symlink so there is one file: `ln -sf CLAUDE.md AGENTS.md`
2. Or keep tool-agnostic rules here and Claude-specific rules (skill triggers,
   MCP-aware workflows) in `CLAUDE.md`.

MCP servers (`.mcp.json`) and skills (`SKILL.md`) are already universally
compatible across agents — no duplication needed there.

→ Read `CLAUDE.md`.
