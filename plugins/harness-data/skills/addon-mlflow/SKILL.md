---
name: data-addon-mlflow
description: MLflow tracking conventions — MLflow 3.5.1+ as the minimum, every training run logged, GenAI tracing for LLM apps, the run-comparator agent flagging suspicious improvements, and registry promotion to production gated to humans/CI. Use when wiring MLflow tracking, the MLflow MCP, comparing runs, or registering model artifacts.
---

# MLflow (tracking + MCP + GenAI tracing)

- **MLflow 3.5.1+** is the minimum version (MCP extra ships from 3.5.1).
- **Every training run is logged.** The `require-tracking.sh` hook
  (PreToolUse on Bash) refuses `python train…` invocations whose
  target script lacks `import mlflow`.
- **GenAI tracing** (MLflow 3.5.1+) is the LLM-app surface; traces
  graduate to evals.
- **`run-comparator` agent** (contributed by this addon, joins the
  `ml-pipeline` roster) pulls last N runs and flags suspicious
  improvements (test accuracy > 0.99 → human review).
- **Model registry:** `register_model(stage='staging')` only; promotion
  to `production` is a human / CI action.

## MCP setup (opt-in)

This addon's MLflow MCP carries a tracking-URI env var (which may embed
credentials or a private host), so it is **not** auto-started by the plugin.
Add it to your project's `.mcp.json` only when you want tracking access, then
set `MLFLOW_TRACKING_URI` in your environment:

```json
{
  "mcpServers": {
    "mlflow": {
      "command": "uvx",
      "args": ["mlflow-mcp@latest"],
      "env": { "MLFLOW_TRACKING_URI": "${MLFLOW_TRACKING_URI}" }
    }
  }
}
```
