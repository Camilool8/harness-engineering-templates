---
name: data-addon-databricks-mcp
description: Databricks Managed MCP conventions (Public Preview) — Unity Catalog ACLs as the upstream gate, OAuth only never a personal access token, Genie spaces treated as downstream lineage consumers, and Mosaic AI model serving published by humans/CI not the agent. Use when querying Databricks, wiring the Databricks MCP, or working with Unity Catalog.
---

# Databricks (Managed MCP, preview)

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

## MCP setup (opt-in)

This addon's Databricks MCP carries a secret OAuth token (and a workspace
host), so it is **not** auto-started by the plugin. Add it to your project's
`.mcp.json` only when you want governed Databricks access, then set
`DATABRICKS_WORKSPACE` and `DATABRICKS_OAUTH_TOKEN` in your environment (use
the OAuth flow — never a personal access token):

```json
{
  "mcpServers": {
    "databricks": {
      "type": "http",
      "url": "https://${DATABRICKS_WORKSPACE}.cloud.databricks.com/api/2.0/mcp",
      "headers": { "Authorization": "Bearer ${DATABRICKS_OAUTH_TOKEN}" }
    }
  }
}
```
