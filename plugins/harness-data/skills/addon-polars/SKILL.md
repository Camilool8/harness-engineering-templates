---
name: data-addon-polars
description: Polars idioms — lazy frames via scan_parquet with a single final collect, with_columns over column assignment, DuckDB via pl.SQLContext for heavy joins, Polars v1.40 as the minimum, and pandas only as ecosystem glue. Use when doing DataFrame work, feature engineering, or choosing a DataFrame engine for analysis or ML.
---

# Polars

- **Lazy frames first.** `pl.scan_parquet` over `pl.read_parquet`.
  Materialize only at the final `collect()`.
- **`with_columns` over column assignment.** Polars is column-oriented;
  assignments fight the engine.
- **DuckDB via `pl.SQLContext` for heavy joins** — when the join
  predicate is complex, drop into SQL via `ctx.execute(...)` and stream
  back as a lazy frame.
- **Polars v1.40 (April 2026)** is the minimum version; first-class
  scikit-learn / XGBoost integration shipped that release line.
- **pandas only as ecosystem glue** for libraries that require pandas
  I/O (some ML / plotting libs).
