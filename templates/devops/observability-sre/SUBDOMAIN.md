# DevOps — observability-sre sub-domain

Telemetry collection, dashboards, alert rules, SLOs / error budgets, and
on-call automation. AI agents touch production observability via MCP, not
via copy-pasted dashboards.

## Adopt if

- You operate the observability stack (OTel collectors, vendor agents,
  dashboards, alerts, SLOs).
- You define SLOs as code (Pyrra, Sloth, or equivalent) and emit multi-window
  multi-burn-rate alerts.
- You wire AI agents to telemetry via MCP servers (Datadog/Honeycomb/NR/
  Sentry/PagerDuty).

## Skip if

- You only consume observability — you are an app team — no devops harness
  needed.
- Your deliverable is the K8s platform → use `kubernetes-platform` (which
  ships its own telemetry concerns).

## Addons that pair well

| Addon | When to add |
|---|---|
| `opentelemetry` | Day-1 for any new project (only vendor-neutral standard worth adopting). |
| `datadog` | Day-1 if Datadog is the production observability stack. |
| `aws` / `azure` / `gcp` | The cloud(s) you collect from. |

## Agent team

| Agent | Role |
|---|---|
| `slo-architect` | Read-only; defines SLOs, SLIs, error budgets, burn-rate alert math. |
| `telemetry-implementer` | Read-write bounded to telemetry config files; implements collectors, exporters, dashboards. |
| `alert-curator` | Read-write bounded to alert-rule files; curates alert taxonomy; deletes noisy alerts. |
| `log-triage` | Read-only; queries log MCP; returns top-N candidates + correlated trace IDs. |
| `trace-analyzer` | Read-only; summarises the slowest span; returns root-cause hypothesis. |
| `incident-commander` | Shared. |
