# Data — ml-pipeline sub-domain

Training, evaluation, packaging, and (where in-scope) serving of supervised
or self-supervised models. The deliverable is a versioned model artifact
plus the eval suite that gates it.

## Adopt if

- You train models, run evaluation suites, package model artifacts,
  register them, or run inference services.
- You need tracking discipline (every run logged) and lockfile-frozen
  environments.
- Your eval suite is data-rooted (held-out test set, k-fold, time-series
  CV) — not assertion-rooted on LLM outputs.

## Skip if

- Your deliverable is a chat-style LLM app, RAG pipeline, or agentic
  system whose unit test is an eval suite over prompts → use `llm-app`.
- Your deliverable is dbt models → use `analytics-engineering`.
- Your deliverable is a notebook explaining a question → use
  `data-analyst-notebook`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` Python toolchain with lockfile guard. |
| `polars` | Default — Polars + lazy-frame idioms for feature engineering. |
| `mlflow` | Default — tracking, model registry, GenAI tracing; contributes `run-comparator` agent and `require-tracking.sh` hook. |
| `wandb-mcp` | Default — W&B official MCP for runs / artifacts / reports. |
| `inspect-ai` | Default — UK AISI eval framework for agentic ML evals. |
| `databricks-mcp` | Default (preview) — Unity Catalog / Mosaic / Vector Search. |

## Agent team

| Agent | Role |
|---|---|
| `pipeline-architect` | Read-only; drafts training-loop / eval-suite split; enforces eval-suite-as-separate-package; picks tracker. |
| `training-implementer` | Read-write; writes `train.py`; refuses runs without tracking import. |
| `eval-implementer` | Read-write; writes evals in the separate eval package. |
| `data-versioner` | Read-write (limited); emits a data hash for every input parquet/arrow/DuckDB snapshot. |
| `run-comparator` | Contributed by `mlflow` addon; pulls last N runs and flags suspicious improvements. |
| `eval-curator` | Shared; refuses PRs touching both eval/** and model code. |
| `dataset-card-author` | Shared; emits the dataset card for any new dataset. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack provenance. |
