## DevOps — observability-sre

### SLOs are code, not dashboards
- Every SLO is a YAML object compiled by Pyrra or Sloth into Prometheus
  recording rules + multi-window multi-burn-rate alerts. Dashboards are
  derived; the SLO YAML is the source of truth.

### Telemetry collection
- OpenTelemetry is the only vendor-neutral collection standard worth
  adopting. Vendor-specific agents are acceptable only where OTel coverage
  is incomplete (some Windows ETW signals, mainframe).
- Run `otelcol validate` in CI on every config change. A logs-pipeline
  pointing at a metrics-only exporter starts up cleanly and silently
  drops data.

### Alert hygiene
- Alert on error-budget burn rate, not raw error rate. Two-window
  (fast + slow) burn-rate alerts are the default.
- A noisy alert deleted is a noisy alert healed. `alert-curator` prunes.

### MCP discipline
- MCP servers are first-class IAM endpoints: rate-limit, scope per-tenant,
  audit. Per-tenant MCP cost guardrails are not built-in (2026).
- Datadog/Honeycomb/NR MCPs return raw fields by default — scrub PII and
  API keys at the source, not at the agent.
- PagerDuty MCP `trigger_incident` requires the typed-token confirmation
  card. A single "y" is insufficient.

### Done criteria
- A new SLO is not done until: YAML compiles, recording rules deploy,
  burn-rate alerts route to the correct on-call, the dashboard reads
  from the recording rule (not a raw query).
