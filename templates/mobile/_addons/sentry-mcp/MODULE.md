# Module: mobile/addon/sentry-mcp

> Config: `domain.addons` · Depends on: Sentry account.

**What it does.** Wires Sentry's hosted MCP (`mcp.sentry.dev`) into `.mcp.json` via Streamable HTTP + OAuth. The agent gets issue search, breadcrumbs, source-mapped stack traces, releases, replays. Contributes the `mobile-crash-triager` agent.

## Adopt if
- Using Sentry for any mobile target.

## Skip if
- Using Firebase Crashlytics exclusively (still consider Sentry — different strengths).

## Dependencies
- Sentry account, OAuth-capable.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Run `claude mcp add --transport http sentry-mcp https://mcp.sentry.dev/mcp`.
3. OAuth-authenticate.
4. Copy `mobile-crash-triager.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `sentry-mcp` to `domain.addons` and run `./assemble.sh`.

## Remove
- Remove the `## Sentry MCP` section from `CLAUDE.md`.
- `claude mcp remove sentry-mcp`.
- Delete `.claude/agents/mobile-crash-triager.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.claude/agents/mobile-crash-triager.md`
