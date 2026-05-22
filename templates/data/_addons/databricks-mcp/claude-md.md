## Databricks (Managed MCP, preview)

- **Public Preview status (May 7 2026)** — re-verify GA status each
  quarter.
- **Unity Catalog ACLs are the upstream gate.** Even with OAuth, the
  agent sees only what UC grants permit. Audit grants quarterly.
- **OAuth only.** `DATABRICKS_TOKEN` /
  `DATABRICKS_PERSONAL_ACCESS_TOKEN` are refused by
  `block-static-warehouse-creds.sh`.
- **Genie spaces are LLM-facing surfaces.** Treat Genie as a downstream
  consumer for lineage purposes; the `lineage-auditor` agent (in
  `analytics-engineering`) checks Genie space references.
- **Mosaic AI** (model serving) lives downstream of `ml-pipeline`'s
  registry; do not register from the agent — humans / CI publish.
