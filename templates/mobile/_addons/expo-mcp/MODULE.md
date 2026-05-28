# Module: mobile/addon/expo-mcp

> Config: `domain.addons` · Depends on: an Expo account with EAS paid plan.

**What it does.** Wires the hosted Expo MCP (`mcp.expo.dev`) into `.mcp.json` via Streamable HTTP + OAuth. The agent gets EAS Build/Submit/Workflow inspection, latest Expo docs, `npx expo install` resolution, and simulator/visual verification. Contributes the `eas-workflow-author` skill.

## Adopt if
- Using Expo SDK 54+ with EAS.
- Want OAuth-first MCP credential posture (post-Anodot reference standard).

## Skip if
- Not using Expo (e.g., bare RN, native-only).

## Dependencies
- Expo account, EAS paid plan.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Run `claude mcp add --transport http expo-mcp https://mcp.expo.dev/mcp`.
3. Run `/mcp` and OAuth-authenticate.
4. Copy `eas-workflow-author/SKILL.md` into `.claude/skills/`.

## Install (assemble.sh)
Add `expo-mcp` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## Expo MCP` section from `CLAUDE.md`.
- `claude mcp remove expo-mcp`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.claude/skills/eas-workflow-author/SKILL.md`
