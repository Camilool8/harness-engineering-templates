---
name: data-addon-snowflake-mcp
description: Snowflake Cortex Managed MCP conventions — OAuth only never a static password, Cortex Agent Evaluations as the agent-run eval surface, a SELECT-only read-only role, and mutation routed through migration PRs. Use when querying Snowflake, wiring the Snowflake Cortex MCP, or setting up read-only warehouse access.
---

# Snowflake (Cortex Managed MCP)

- **Managed MCP, OAuth only.** Static `SNOWFLAKE_PASSWORD` is refused by
  the `block-static-warehouse-creds.sh` shared hook.
- **Cortex Agent Evaluations** (GA Mar 13 2026) is the eval surface for
  agent runs against Snowflake — YAML-defined custom metrics, traced
  agent activity, config-comparison runs.
- **Read-only role.** The agent's Snowflake role grants `SELECT` only
  on the registered schemas. Mutation goes through migration PRs.
- **Cortex Managed MCP GA: Nov 4 2025.** Re-verify the endpoint and
  auth surface each quarter.

## MCP setup (opt-in)

This addon's Snowflake MCP carries a secret OAuth token (and an account
identifier), so it is **not** auto-started by the plugin. Add it to your
project's `.mcp.json` only when you want governed Snowflake access, then set
`SNOWFLAKE_ACCOUNT` and `SNOWFLAKE_OAUTH_TOKEN` in your environment (OAuth —
never a static `SNOWFLAKE_PASSWORD`):

```json
{
  "mcpServers": {
    "snowflake": {
      "type": "http",
      "url": "https://${SNOWFLAKE_ACCOUNT}.snowflakecomputing.com/api/v2/cortex/mcp",
      "headers": { "Authorization": "Bearer ${SNOWFLAKE_OAUTH_TOKEN}" }
    }
  }
}
```
