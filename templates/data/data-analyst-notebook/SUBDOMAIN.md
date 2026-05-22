# Data — data-analyst-notebook sub-domain

Ad-hoc and exploratory analysis where the deliverable is a reactive,
reproducible notebook that explains a data question end-to-end.

## Adopt if

- You do exploratory analysis or ad-hoc reporting.
- Your output is a notebook or a small set of cells.
- You read from a warehouse and produce charts, tables, or memos.
- You want sample-then-scale on every query.

## Skip if

- Your deliverable is a trained model + serving stack → use `ml-pipeline`.
- Your deliverable is an LLM app → use `llm-app`.
- Your deliverable is warehouse-modeled tables → use `analytics-engineering`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` Python toolchain with lockfile guard. |
| `polars` | Default — Polars + lazy-frame idioms; DuckDB-via-SQLContext. |
| `marimo` | Default — reactive `.py` notebooks; `marimo pair` agent surface. |
| `duckdb-mcp` | Default — local DuckDB + MotherDuck for local-then-remote workflows. |
| `snowflake-mcp` | Default — Snowflake Cortex Managed MCP. |
| `bigquery-mcp` | Add when your warehouse is BigQuery (preview-tagged). |
| `databricks-mcp` | Add when your warehouse is Databricks (preview-tagged). |

## Agent team

| Agent | Role |
|---|---|
| `notebook-architect` | Read-only; frames the analysis question, picks the warehouse + sample size + DataFrame engine, drafts the cell outline. |
| `notebook-implementer` | Read-write; fills cells one at a time; for marimo edits the `.py` directly; for Jupyter routes through marimo-pair or Jupyter-MCP. |
| `chart-critic` | Vision-judge; PostToolUse on chart-write; scores against the canonical sins list; different family from generator. |
| `restart-run-all-checker` | Default-FAIL on completeness; verifies kernel-fresh Restart-and-Run-All before allowing "done". |
| `eval-curator` | Shared; refuses PRs touching both eval/** and model/notebook code. |
| `dataset-card-author` | Shared; emits the dataset card for any new dataset introduced. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack audit-log provenance. |
