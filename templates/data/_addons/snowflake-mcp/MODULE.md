# Addon — snowflake-mcp

Snowflake Cortex Managed MCP. GA Nov 4 2025; server-side credentials,
OAuth-only auth.

## Adopt if

- Your warehouse is Snowflake.
- Your tenant has Cortex enabled.

## Skip if

- You are not on Snowflake, or your tenant has not provisioned Managed
  MCP.

## What it contributes

- CLAUDE.md section: Managed-MCP + OAuth-only posture; Cortex Agent
  Evaluations as the eval surface.
- MCP fragment: Snowflake Cortex Managed MCP wiring.

## Provision before install

- Cortex enabled on the Snowflake account.
- OAuth integration provisioned (`CREATE SECURITY INTEGRATION ... TYPE=OAUTH`).
- Agent role granted with read-only privileges on the relevant schemas.

## Pairs with

`analytics-engineering` · `data-analyst-notebook`
