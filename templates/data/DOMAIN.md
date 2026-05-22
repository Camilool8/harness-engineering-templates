# Data domain pack

Curated harness content for data teams: exploratory analysis, ML pipelines,
LLM applications, and analytics engineering.

> **Status: curated three-layer pack** (third after `web/` and `devops/`).
> Specialised via per-warehouse MCP, per-toolchain, per-tracker, and per-eval
> addons.

## Sub-domain decision guide

| Sub-domain | Adopt if… |
|---|---|
| [`data-analyst-notebook`](data-analyst-notebook/) | You do exploratory analysis or ad-hoc reporting; your output is a reactive, reproducible notebook that reads from a warehouse and produces charts, tables, or memos. |
| [`ml-pipeline`](ml-pipeline/) | You train models, run evaluation suites, package model artifacts, register them, or run inference services; you need tracking discipline and lockfile-frozen environments. |
| [`llm-app`](llm-app/) | You build LLM products — RAG, agentic pipelines, prompt-driven products — where the unit test is an eval suite, not a metric. |
| [`analytics-engineering`](analytics-engineering/) | Your deliverable is dbt models with contracts, unit tests, a semantic layer, and lineage; you publish a paved path for downstream consumers. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance and the curated agent team.

## Addons

Composable extras declared in `domain.addons`. Each sub-domain config ships sensible defaults; override as needed.

| Addon | Pairs with | Purpose |
|---|---|---|
| `uv` | all four | Astral `uv` Python toolchain; lockfile-frozen install hook. |
| `polars` | `data-analyst-notebook`, `ml-pipeline` | Polars + lazy-frame idioms; DuckDB-via-SQLContext for heavy joins. |
| `snowflake-mcp` | `analytics-engineering`, `data-analyst-notebook` | Snowflake Cortex Managed MCP (GA Nov 4 2025); server-side credentials. |
| `bigquery-mcp` | `analytics-engineering`, `data-analyst-notebook` | Google BigQuery MCP (preview Jan 2026); GCP WIF + read-only role. |
| `databricks-mcp` | `ml-pipeline`, `analytics-engineering` | Databricks MCP (Public Preview May 7 2026); Unity Catalog ACLs. |
| `duckdb-mcp` | `data-analyst-notebook`, `analytics-engineering` | MotherDuck official `duckdb-mcp`; local-then-remote uniform interface. |
| `dbt-core` | `analytics-engineering` | dbt-core + dbt remote MCP (GA Oct 2025) + `dbt-labs/dbt-agent-skills` (Feb 9 2026); contributes `semantic-modeler` and `contract-author` agents. |
| `marimo` | `data-analyst-notebook` | marimo-team reactive `.py` notebooks + `marimo pair` (April 2026). |
| `mlflow` | `ml-pipeline`, `llm-app` | MLflow 3.5.1+ MCP extra + GenAI tracing; ships `require-tracking.sh` hook and `run-comparator` agent. |
| `wandb-mcp` | `ml-pipeline`, `llm-app` | W&B official `wandb-mcp-server`; Weave + Reports. |
| `langfuse` | `llm-app` | Langfuse OSS LLM observability; contributes `trace-triager` agent. |
| `inspect-ai` | `llm-app`, `ml-pipeline` | UK AISI `inspect-ai` (Apache-2.0, May 2026); 200+ pre-built evals; sandbox-isolated. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`_addons/`](_addons/).

## Assemble

The sub-domain config is the assemble unit. Pass it directly to `assemble.sh`:

```bash
./assemble.sh data/data-analyst-notebook/harness.config.yml ./my-notebook-project
./assemble.sh data/ml-pipeline/harness.config.yml ./my-ml-project
./assemble.sh data/llm-app/harness.config.yml ./my-llm-app
./assemble.sh data/analytics-engineering/harness.config.yml ./my-dbt-project
```

## See also

- [`docs/how-to/pick-a-recipe.md`](../../docs/how-to/pick-a-recipe.md) — decision flow including the sub-domain choice.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain and addon catalog.
- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §2 — engineering guide for the data domain.
- [`references.md`](references.md) — curated data-platform dossier (refresh quarterly).
