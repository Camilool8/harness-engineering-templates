# Addon — duckdb-mcp

MotherDuck official `duckdb-mcp` server. Local DuckDB + MotherDuck
hosted warehouse via a uniform interface.

## Adopt if

- You do local exploratory analysis.
- You want a uniform query interface across local Parquet and a hosted
  warehouse.

## Skip if

- Your work is exclusively against a remote vendor warehouse and you
  have no local exploration surface.

## What it contributes

- CLAUDE.md section: local DuckDB + MotherDuck; sample-then-scale as
  the default local pattern.
- MCP fragment: MotherDuck official MCP wiring.

## Provision before install

- DuckDB v1.x installed locally (`uv tool install duckdb`).
- Optionally, MotherDuck account for hosted DuckDB (with OAuth flow via
  `motherduck login`).

## Pairs with

`data-analyst-notebook` · `analytics-engineering`
