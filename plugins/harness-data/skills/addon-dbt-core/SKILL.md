---
name: data-addon-dbt-core
description: dbt-core conventions — contract-first models with contract.enforced true, mandatory unit tests, a semantic layer as the single metric source of truth, the dbt remote MCP as the governed agent surface, and auto-activating dbt-agent-skills. Use when building dbt models, contracts, unit tests, or semantic-layer metrics, or wiring the dbt MCP.
---

# dbt-core (contracts + semantic layer + agent skills)

- **Contract-first.** Every staging+ model declares
  `contract.enforced: true` with explicit column types. The
  `contract-author` agent writes the contract before the model body.
- **Unit tests are mandatory** per dbt Labs Feb 2026 best practice. The
  `dbt-build-model` skill scaffolds them.
- **Semantic layer is the metric source of truth.** The
  `semantic-modeler` agent owns the manifest; no metric defined twice.
- **dbt remote MCP (GA Oct 2025)** is the governed agent surface for
  project lineage / models / tests. Token via env, not embedded.
- **dbt-agent-skills (Feb 9 2026)** auto-activate by prompt match; this
  addon ships the 3 highest-leverage.

## MCP setup (opt-in)

This addon's dbt Cloud MCP carries a secret token, so it is **not**
auto-started by the plugin. Add it to your project's `.mcp.json` only when
you want governed dbt project access, then set `DBT_CLOUD_TOKEN` in your
environment (via env injection — never embed the token in the config):

```json
{
  "mcpServers": {
    "dbt": {
      "type": "http",
      "url": "https://cloud.getdbt.com/mcp",
      "headers": { "Authorization": "Bearer ${DBT_CLOUD_TOKEN}" }
    }
  }
}
```
