# Module: mobile/addon/firebase-mcp

> Config: `domain.addons` · Depends on: Firebase CLI, gcloud (for ADC).

**What it does.** Wires Firebase's official MCP server (`firebase-tools mcp`) into `.mcp.json`. The agent gets Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config, App Hosting, and Realtime DB tools. Contributes the `crashlytics-triager` agent.

## Adopt if
- Using Firebase services (Auth, Firestore, FCM, Crashlytics, etc.).

## Skip if
- No Firebase in the project.

## Dependencies
- `firebase-tools` installed (`npm i -g firebase-tools` or `npx`).
- Firebase CLI login (`firebase login`) or Application Default Credentials (`gcloud auth application-default login`).

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Add the `firebase` block to `.mcp.json`.
3. Copy `crashlytics-triager.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `firebase-mcp` to `domain.addons` and run `./assemble.sh`.

## Remove
- Remove the `## Firebase MCP` section from `CLAUDE.md`.
- Remove `firebase` from `.mcp.json`.
- Delete `.claude/agents/crashlytics-triager.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.mcp.json.fragment`
- `files/.claude/agents/crashlytics-triager.md`
