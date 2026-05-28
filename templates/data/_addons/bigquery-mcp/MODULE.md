# Addon — bigquery-mcp

Google BigQuery MCP. Preview as of Jan 2026 (preview: true). GCP WIF +
read-only role; in-place query.

## Adopt if

- Your warehouse is BigQuery.

## Skip if

- You are not on BigQuery.

## What it contributes

- CLAUDE.md section: GCP WIF for the MCP, read-only role for the agent,
  partition-pruning expectations.
- MCP fragment: BigQuery remote MCP wiring.

## Provision before install

- GCP project with BigQuery enabled.
- Workload Identity Federation pool + provider mapped to the agent's
  OIDC identity.
- Service account with `bigquery.jobUser` + `bigquery.dataViewer` on
  the relevant datasets.

## Status

**preview: true** (Google preview Jan 2026). Re-verify GA status each
quarter.

## Pairs with

`analytics-engineering` · `data-analyst-notebook`
