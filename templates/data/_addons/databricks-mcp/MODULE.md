# Addon — databricks-mcp

Databricks MCP. Public Preview May 7 2026 (preview: true). Covers Unity
Catalog, Vector Search, Genie, SQL execution.

## Adopt if

- Your warehouse / ML platform is Databricks.

## Skip if

- You are not on Databricks.

## What it contributes

- CLAUDE.md section: Unity Catalog ACLs as the upstream gate, Databricks
  AI/BI Genie + Mosaic linkage.
- MCP fragment: Databricks Managed MCP wiring.

## Provision before install

- Databricks workspace with Unity Catalog.
- Service Principal with OAuth, with Unity Catalog grants for the
  relevant catalogs / schemas.
- Genie space configured (optional, for natural-language analytics).

## Status

**preview: true** (Public Preview May 7 2026). Re-verify GA status each
quarter.

## Pairs with

`ml-pipeline` · `analytics-engineering`
