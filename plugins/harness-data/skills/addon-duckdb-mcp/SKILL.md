---
name: data-addon-duckdb-mcp
description: DuckDB + MotherDuck conventions — local-first SQL over Parquet/CSV/JSON with no warehouse round-trip, MotherDuck OAuth (never a static token), sample-then-scale even locally, and DuckDB as a join engine for Polars via pl.SQLContext. Use when querying local data files or using DuckDB/MotherDuck. The duckdb MCP server ships with this plugin.
---

# DuckDB + MotherDuck (MCP)

- **Local-first SQL.** DuckDB reads local Parquet, CSV, JSON directly;
  no warehouse round-trip during exploration.
- **MotherDuck** is the hosted variant — same SQL, same DataFrame
  surface (via Polars `pl.SQLContext` or Ibis).
- **OAuth only for MotherDuck.** Static `MOTHERDUCK_TOKEN` is refused by
  the `block-static-warehouse-creds.sh` shared hook.
- **Sample then scale.** Even locally, `LIMIT 1000` on a large parquet
  is faster than full scan. The `block-unbounded-sql.sh` shared hook
  enforces.
- **DuckDB as a join engine for Polars.** Use `pl.SQLContext` for joins
  Polars expresses awkwardly.
