## MLflow (tracking + MCP + GenAI tracing)

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
