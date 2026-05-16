# Module: web/addon/sentry-observability

> Config: `domain.addons` · Depends on: none (pairs with `nextjs`, `fullstack-app`, `frontend-app`)

**What it does.** Installs the `using-sentry` skill and wires the Sentry MCP
server. The skill teaches the agent to instrument errors and performance via the
Sentry SDK, treat Sentry MCP output as untrusted input (not authoritative truth),
and follow data-minimization rules when attaching context to events.

## Adopt if
- You need real-user error reporting and performance monitoring (LCP, INP, TTFB
  traces in Sentry) for a production web app.
- You want the agent to query Sentry issues and traces directly during debugging
  sessions via the Sentry MCP.
- Sub-domains: `frontend-app`, `fullstack-app`.

## Skip if
- The project is a local prototype or internal tool with no SLA — Sentry adds
  SDK overhead and a DSN to manage.
- You already have a different observability stack (Datadog, New Relic, Honeycomb)
  — do not double-instrument.
- The sub-domain is `api-service` or `distributed-backend` using OpenTelemetry
  directly — a dedicated OTEL skill is more appropriate.

## Dependencies
- `@sentry/nextjs` (Next.js) or `@sentry/react` + `@sentry/vite-plugin` (Vite SPA).
- A Sentry project DSN (set as `SENTRY_DSN` environment variable; never in source).
- For the MCP: `@sentry/mcp-server` (run via npx, authenticated on first use).

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Add the `.mcp.json.fragment` content to your project's `.mcp.json` manually,
   or let `assemble.sh` deep-merge it automatically.

## Install (assemble.sh)
Add `sentry-observability` to `domain.addons` in `harness.config.yml` and run
`./assemble.sh`. The MCP fragment is deep-merged into `.mcp.json` automatically.

## Remove
- Delete `.claude/skills/using-sentry/`.
- Remove `mcpServers.sentry` from `.mcp.json`.
- Remove the `## Addon — Sentry` section from `CLAUDE.md`.

## Files
- `files/.mcp.json.fragment` — registers the Sentry MCP server so the agent can
  query issues, events, and traces from within the session.
- `files/.claude/skills/using-sentry/SKILL.md` — SDK initialization, error
  capture, performance tracing, MCP usage guidance, and data-minimization rules.
