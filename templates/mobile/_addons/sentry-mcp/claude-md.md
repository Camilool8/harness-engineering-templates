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
