# Data — analytics-engineering sub-domain

Warehouse-modeled tables, contracts, unit tests, semantic layer, and
lineage — the dbt-centric deliverable.

## Adopt if

- Your deliverable is dbt models (Core or Cloud).
- You ship with contracts, unit tests, a semantic layer, and lineage.
- You publish a paved path for downstream consumers (BI, analysts, ML).

## Skip if

- You do ad-hoc analysis with no dbt project → use `data-analyst-notebook`.
- You train models → use `ml-pipeline`.
- You build LLM products → use `llm-app`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` toolchain. |
| `dbt-core` | Default — dbt-core + dbt remote MCP + `dbt-labs/dbt-agent-skills`; contributes `semantic-modeler` and `contract-author` agents. |
| `snowflake-mcp` | Default — Snowflake Cortex Managed MCP. |
| `bigquery-mcp` | Default (preview) — Google BigQuery MCP. |
| `databricks-mcp` | Default (preview) — Databricks MCP. |
| `duckdb-mcp` | Default — local DuckDB for dev. |

This is the most multi-warehouse-by-default sub-domain in the pack;
preview-tagged warehouse MCPs are included in defaults per the §4
resolution of the spec.

## Agent team

| Agent | Role |
|---|---|
| `analytics-architect` | Read-only; designs the layer cake (staging → marts → semantic layer); drafts contracts and unit tests before models. |
| `dbt-implementer` | Read-write; writes dbt models, contracts, unit tests; auto-activated by prompts matching `dbt-labs/dbt-agent-skills`. |
| `lineage-auditor` | Read-only; refuses "done" if a new mart is not referenced by ≥1 downstream consumer manifest, or if a deprecated model still has live consumers. |
| `semantic-modeler` | Contributed by `dbt-core` addon; owns the semantic-layer manifest; refuses metrics without contract+unit-test. |
| `contract-author` | Contributed by `dbt-core` addon; writes contracts before models; refuses contract-breaking PRs without a migration note. |
| `eval-curator` | Shared; refuses PRs touching both eval/** and dbt models/**. |
| `dataset-card-author` | Shared; emits dataset cards for source tables. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack provenance. |
