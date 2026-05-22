## Datadog

- The Datadog MCP server (GA March 9 2026) is remote-hosted; no local
  server install. Toolsets: Core, APM, Error Tracking, Feature Flags,
  DBM, Security, LLM Obs.
- There is no per-tenant cost guardrail in 2026 MCP implementations.
  Rate-limit at the MCP-server proxy if cost is a concern.
- The Datadog MCP returns raw fields by default — scrub PII and API keys
  at the source (the logging library), never at the agent.
