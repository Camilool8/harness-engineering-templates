# Data / ml-pipeline — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **MLflow 3.5.1+ vs W&B Weave for tracking.** MLflow is the open-standard
  default; W&B is the commercial counterpart with strong reporting.
  Both ship official MCP servers in 2026.
- **Eval-suite-isolated-package.** Evals live in `eval/` as an out-of-tree
  package; models in `src/`. Models import nothing from evals; evals
  import the model. The `eval-curator` shared agent encodes the
  separation as Default-FAIL.
- **Point-in-time correctness on feature stores.** Any feature pulled at
  training time must be the value as-of the prediction timestamp, not
  the value as-of the training-job timestamp. Databricks / Hopsworks 2026
  docs treat this as a hard gate.

## Common gotchas

- **Leakage via fit-before-split.** Scaler / imputer `.fit()` on full `X`
  before `train_test_split` leaks test data into the fit. Wrap
  preprocessing in `Pipeline` so fit only sees training folds. The
  `leakage-sentinel.sh` shared hook is the regex backstop; LeakageDetector
  2.0 (arXiv 2509.15971, Sep 2025) is the AST-level upgrade target.
- **Unlogged runs.** A training run with no `import mlflow` (or `wandb`)
  produces nothing the registry can compare against. The `mlflow` addon's
  `require-tracking.sh` hook enforces.
- **`.shift(-N)` look-ahead** on time-series features. Negative shift =
  future-data leak. The `leakage-sentinel.sh` hook rejects.

## Version-sensitive notes

- MLflow MCP extra ships in 3.5.1+.
- W&B `wandb/wandb-mcp-server`: 2026 official.
- UK AISI `inspect-ai`: Apache-2.0, May 2026.
- Databricks MCP: Public Preview May 7 2026.

## Cited links

- [MLflow MCP server docs](https://mlflow.org/docs/latest/genai/mcp/) — official.
- [Databricks MLflow MCP guide (Jan 28 2026)](https://docs.databricks.com/aws/en/mlflow3/genai/tracing/mlflow-mcp) — vendor-stewarded.
- [W&B official MCP — `wandb/wandb-mcp-server`](https://github.com/wandb/wandb-mcp-server) — Weave + Reports surface.
- [Inspect AI by UK AISI](https://inspect.aisi.org.uk/) — government-grade evals framework.
- [LeakageDetector 2.0 (arXiv 2509.15971, Sep 2025)](https://arxiv.org/html/2509.15971) — published static analyzer for leakage patterns.
- [scikit-learn — Common pitfalls and recommended practices](https://scikit-learn.org/stable/common_pitfalls.html) — fit-after-split, Pipeline rationale.
- [Databricks Managed MCP docs (Public Preview May 7 2026)](https://docs.databricks.com/aws/en/generative-ai/mcp/managed-mcp) — Unity Catalog + Genie + Vector Search.
