## DuckDB + MotherDuck (MCP)

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
