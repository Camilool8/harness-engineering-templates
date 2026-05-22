# DevOps — observability-sre reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **OpenTelemetry is the only collection standard worth adopting in 2026.** Vendor-specific agents are acceptable only where OTel coverage is incomplete (some Windows ETW signals, mainframe). Semantic Conventions 1.41 is current.
- **Define SLOs as code, not as dashboards.** Pyrra and Sloth both compile a `ServiceLevelObjective` YAML into Prometheus recording rules + multi-window multi-burn-rate alerts; Pyrra ships a UI, Sloth is GitOps-friendlier.
- **AI agents get production observability via MCP, not via copy-pasted dashboards.** Datadog MCP GA'd Mar 9 2026 (16+ core tools + APM/Errors/FeatureFlags/DBM/Security/LLM toolsets, remote, no local server). New Relic AI MCP is GA mid-2026. Honeycomb MCP is AI-native and now lives on AWS Marketplace as hosted. Sentry MCP exposes Seer root-cause. PagerDuty MCP exposes 60+ tools including incident triggering.
- **Two-key / typed-token confirmation for any agent-initiated prod action** (restart, rollback, traffic-shift). Komodor's war-room model puts a Main / Incident-Commander agent in front of specialist agents and routes high-risk actions to human approval explicitly.
- **Alert on error-budget burn rate, not on raw error rate.** Two-window (fast + slow) burn-rate alerts (Google SRE workbook pattern) are now the Prometheus default — both Pyrra and Sloth generate them out of the box.

## Common gotchas / failure modes

- **OTel Collector pipeline misrouting after upgrades** — `service` no longer validates pipeline-type vs component-type, so a `logs` pipeline pointing at a `metrics`-only exporter starts up cleanly and silently drops data. Run `otelcol validate` in CI.
- **MCP-issued LLM queries against Datadog/New Relic can blow your monthly query budget** — there is no per-tenant cost guardrail in 2026 MCP implementations; rate-limit at the MCP-server proxy.
- **Pyrra's auto-generated dashboards over-cardinality with histogram-based SLIs** — keep histogram bucket count low or your Prometheus ingestion will choke.
- **Honeycomb / NR / Datadog MCPs return raw fields by default** — agents can extract API keys / customer PII embedded in logs unless you scrub at the source.
- **PagerDuty MCP can `trigger_incident` from an LLM** — no built-in confirmation flow; require a typed-token (OWASP cheat-sheet pattern) wrapper or a war-room-style human-in-the-loop.

## Version-sensitive notes

- **OTel Collector receivers and processors continued maturing through v0.11x (2026)** — `otlpreceiver` no longer mis-attributes mixed signal payloads (data-loss fix); `kafkareceiver` added `otlp_json` encoding. Schedule a check on every minor version.
- **Datadog MCP GA: Mar 9 2026.** Before this date many teams ran the unofficial community server; switch to the official remote endpoint.
- **New Relic AI MCP launched late 2025 and went GA mid-2026** with Amazon Quick integration in May 2026.
- **Honeycomb Metrics GA + MCP expansion: Mar 11 2026.** Now available as hosted on AWS Marketplace.

## Cited links

- [Pyrra (pyrra-dev/pyrra) GitHub](https://github.com/pyrra-dev/pyrra) — canonical SLO-as-K8s-CRD with auto-generated dashboards.
- [Sloth + Pyrra comparison](https://0xdc.me/blog/service-level-objectives-made-easy-with-sloth-and-pyrra/) — GitOps-native alternative; lightweight.
- [Datadog MCP Server GA press release (Mar 9 2026)](https://www.datadoghq.com/about/latest-news/press-releases/datadog-launches-mcp-server/) — feature list, tool counts, official remote endpoint.
- [Honeycomb MCP docs](https://docs.honeycomb.io/integrations/mcp) — agent-native query of traces, triggers, SLOs.
- [New Relic AI MCP launch blog](https://newrelic.com/blog/news/new-relic-ai-mcp-server-launch) — standardized agent-ecosystem narrative.
- [Sentry MCP docs](https://docs.sentry.io/ai/monitoring/mcp/) — Seer root-cause from IDE.
- [PagerDuty MCP server integration guide](https://support.pagerduty.com/main/docs/pagerduty-mcp-server-integration-guide) — official tool list and scope.
- [OTel Collector CHANGELOG](https://github.com/open-telemetry/opentelemetry-collector/blob/main/CHANGELOG.md) — track receiver/pipeline breaking changes per minor.
