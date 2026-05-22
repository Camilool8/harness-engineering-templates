# Module: devops/addon/opentelemetry

> Config: `domain.addons` · Depends on: none

**What it does.** Wires OpenTelemetry defaults: Semantic Conventions 1.41
pin, `otelcol validate` in CI for every collector config change, and the
common pipeline-misroute gotcha (logs pipeline → metrics-only exporter
silently drops data). Drops a CLAUDE.md section so the agent does not
mis-route signal types or skip validation.

## Adopt if
- You collect telemetry from any service (the default in 2026).

## Skip if
- Never; OTel is the only vendor-neutral standard worth adopting.

## Dependencies
- `otelcol` (or `otelcol-contrib`) on PATH for CI validation.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `opentelemetry` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## OpenTelemetry` section from `CLAUDE.md`.

## Files
- `claude-md.md` — SemConv 1.41 pin, `otelcol validate` rule, pipeline
  misroute gotcha, collector CHANGELOG follow-up note.
