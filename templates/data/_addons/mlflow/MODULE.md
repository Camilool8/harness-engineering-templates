# Addon — mlflow

MLflow 3.5.1+ tracking, model registry, GenAI tracing. Ships the
`require-tracking.sh` hook and `run-comparator` agent.

## Adopt if

- You train models OR run GenAI evals.
- You want an OSS tracker (vs commercial W&B).

## Skip if

- You have chosen W&B and adding MLflow would duplicate state.

## What it contributes

- CLAUDE.md section: MLflow 3.5.1+ MCP extra, every run logged, GenAI
  tracing for LLM-app use.
- MCP fragment: MLflow MCP server.
- Hook: `require-tracking.sh` (PreToolUse on `Bash` matching
  `python\s+train`). Refuses `python train…` invocations whose target
  script lacks `import mlflow`.
- Agent: `run-comparator` (haiku) — pulls last N runs, summarises
  deltas, flags suspicious improvements.

## Provision before install

- MLflow ≥ 3.5.1 (`uv add mlflow[mcp]`).
- MLflow tracking server endpoint (Databricks-hosted, self-hosted, or
  local `mlflow ui`).
- Auth: OAuth or Databricks PAT depending on host.

## Pairs with

`ml-pipeline` (primary), `llm-app` (GenAI tracing).
