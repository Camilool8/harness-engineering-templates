# Addon — polars

Polars DataFrame library + lazy-frame idioms. The 2026 DataFrame default
per HE §2.2 and brief B.

## Adopt if

- Your DataFrame surface is non-trivial.
- pandas would be the only constraint stopping you from going faster.

## Skip if

- Your project is pandas-locked by an upstream library; keep pandas as
  ecosystem glue.

## What it contributes

- CLAUDE.md section: lazy-frames first, `scan_parquet` over
  `read_parquet`, DuckDB-via-SQLContext for heavy joins.

## Pairs with

`data-analyst-notebook` · `ml-pipeline`
