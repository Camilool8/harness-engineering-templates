## BigQuery (remote MCP, preview)

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
