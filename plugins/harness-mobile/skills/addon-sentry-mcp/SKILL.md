---
name: mobile-addon-sentry-mcp
description: Sentry's hosted MCP (mcp.sentry.dev, Streamable HTTP + OAuth) for mobile crash triage — issue/event search, source-mapped stack traces, releases, session replays, and the Seer AI root-cause agent. Use when wiring or driving the Sentry MCP for an iOS or Android target with an OAuth-only posture and no SENTRY_AUTH_TOKEN in env.
---

## Sentry MCP

The agent has access to **Sentry's hosted MCP** at `https://mcp.sentry.dev/mcp` (Streamable HTTP + OAuth). Tools (~20):

- `search_issues`, `search_events`, `get_issue_details`
- Project / team / organization / DSN management
- Releases, session replays
- **Seer** integration — Sentry's AI debugging agent for root-cause analysis

### Credentials posture
OAuth-only, remote hosted. Reference standard post-Anodot. No `SENTRY_AUTH_TOKEN` in env.

### Mobile relevance
Crash issues for iOS/Android SDKs, release tracking for App Store/Play submissions, replay/session triage on production users.
