---
name: devops-addon-opentelemetry
description: OpenTelemetry conventions — pin Semantic Conventions to 1.41 and re-pin per minor bump, run otelcol validate in CI on every collector config change, and track Collector v0.11x+ CHANGELOG breaking changes. Use when configuring OTel collectors, exporters, or semantic-convention attributes.
---

## OpenTelemetry

- Semantic Conventions: pin to 1.41 (current 2026). Re-pin on each minor
  bump after reading the SemConv changelog.
- Run `otelcol validate` in CI on every collector config change. A logs
  pipeline pointing at a metrics-only exporter starts up cleanly and
  silently drops data.
- Collector v0.11x+ (2026) `otlpreceiver` no longer mis-attributes mixed
  signal payloads (data-loss fix); track CHANGELOG breaking changes per
  minor.
