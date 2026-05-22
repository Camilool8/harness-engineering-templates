# Module: devops/addon/datadog

> Config: `domain.addons` · Depends on: none (pairs with `opentelemetry`)

**What it does.** Wires the Datadog MCP server (GA March 9 2026,
remote-hosted, 16+ core tools + APM/Errors/FeatureFlags/DBM/Security/LLM
Obs toolsets) and a CLAUDE.md section covering the per-tenant cost
guardrail gap and the PII-scrub-at-source rule.

## Adopt if
- Datadog is the production observability stack.

## Skip if
- The project uses a different observability vendor (Honeycomb / New Relic /
  Sentry — addons deferred to follow-up cycle).

## Dependencies
- Datadog tenant + API/App keys configured in the environment for the
  MCP server to authenticate.
- The Node.js runtime (`npx`) to launch the Datadog MCP server.

## Install (manual)
1. Copy `files/.mcp.json.fragment` into your project root (deep-merge if a
   `.mcp.json` already exists).
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `datadog` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `datadog` server entry from `.mcp.json`.
- Remove the `## Datadog` section from `CLAUDE.md`.

## Files
- `claude-md.md` — Datadog MCP capabilities + cost-guardrail + PII rules.
- `files/.mcp.json.fragment` — Datadog MCP server registration.
