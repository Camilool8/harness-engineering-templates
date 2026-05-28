---
name: data-addon-bigquery-mcp
description: Google BigQuery remote MCP conventions (preview) — GCP Workload Identity Federation auth never a static service-account key, a read-only bigquery.jobUser + dataViewer role, mandatory partition pruning, and in-place query streaming. Use when querying BigQuery, wiring the BigQuery MCP, or setting up read-only warehouse access on GCP.
---

# BigQuery (remote MCP, preview)

- **Preview status (Jan 2026)** — re-verify GA status each quarter.
- **GCP Workload Identity Federation** authenticates the MCP. Static
  `BIGQUERY_SERVICE_ACCOUNT_KEY_JSON` is refused by the
  `block-static-warehouse-creds.sh` shared hook.
- **Read-only role.** The agent's GCP service account holds
  `bigquery.jobUser` + `bigquery.dataViewer`. No `bigquery.dataEditor`.
- **Partition pruning is mandatory.** Queries against partitioned tables
  without a partition filter are blocked by `block-unbounded-sql.sh`
  (no `WHERE`) and also waste cost; review every plan.
- **In-place query.** Results stream back via the MCP; do not export
  full tables to the agent host.

## MCP setup (opt-in)

This addon's BigQuery MCP carries a secret OAuth token, so it is **not**
auto-started by the plugin. Add it to your project's `.mcp.json` only when
you want governed BigQuery access, then set `BIGQUERY_OAUTH_TOKEN` in your
environment (mint it via Workload Identity Federation — never a static
service-account key):

```json
{
  "mcpServers": {
    "bigquery": {
      "type": "http",
      "url": "https://bigquery.googleapis.com/mcp",
      "headers": { "Authorization": "Bearer ${BIGQUERY_OAUTH_TOKEN}" }
    }
  }
}
```
