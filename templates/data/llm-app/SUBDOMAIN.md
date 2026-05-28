# Data — llm-app sub-domain

LLM-powered applications — RAG, agentic pipelines, prompt-driven products
— where the unit test is an eval suite, not a metric.

## Adopt if

- You build LLM products.
- Prompts are the intervention surface.
- You ship behind a model-version pin.
- Your CI gate is an eval suite (assertion + judge + human) and a
  prompt-regression check.

## Skip if

- Your deliverable is a trained model → use `ml-pipeline`.
- Your deliverable is an exploratory notebook → use
  `data-analyst-notebook`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` Python toolchain with lockfile guard. |
| `langfuse` | Default — OSS LLM observability + dataset / score management; contributes `trace-triager` agent. |
| `inspect-ai` | Default — UK AISI sandbox-isolated eval framework. |
| `mlflow` | Default — MLflow 3.5.1+ GenAI tracing surface. |
| `wandb-mcp` | Default — W&B Weave for traces and Reports for human review. |

## Agent team

| Agent | Role |
|---|---|
| `llm-app-architect` | Read-only; picks the three-tier eval shape (assertion → judge → human); refuses to start higher tiers until lower tiers exist. |
| `prompt-implementer` | Read-write; edits prompts; refuses to bump model-version pin and edit a prompt in the same diff. |
| `eval-author` | Read-write; writes evals in the separate eval package. |
| `judge-runner` | Read-only; runs LLM-judge evals; refuses if `--judge-model` matches the family of the generator. |
| `trace-triager` | Contributed by `langfuse` addon; reads recent traces, flags regressions, summarises latency + cost deltas. |
| `eval-curator` | Shared; refuses PRs touching both eval/** and prompts/**. |
| `dataset-card-author` | Shared; emits dataset cards for eval sets. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack audit-log provenance. |
