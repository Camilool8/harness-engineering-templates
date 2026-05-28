## Snowflake (Cortex Managed MCP)

- **Managed MCP, OAuth only.** Static `SNOWFLAKE_PASSWORD` is refused by
  the `block-static-warehouse-creds.sh` shared hook.
- **Cortex Agent Evaluations** (GA Mar 13 2026) is the eval surface for
  agent runs against Snowflake — YAML-defined custom metrics, traced
  agent activity, config-comparison runs.
- **Read-only role.** The agent's Snowflake role grants `SELECT` only
  on the registered schemas. Mutation goes through migration PRs.
- **Cortex Managed MCP GA: Nov 4 2025.** Re-verify the endpoint and
  auth surface each quarter.
