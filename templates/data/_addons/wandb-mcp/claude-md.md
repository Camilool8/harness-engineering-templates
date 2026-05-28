## W&B (Weave + Reports + MCP)

- **W&B `wandb/wandb-mcp-server`** is the official 2026 MCP. Auth via
  `WANDB_API_KEY` (API-key model; no OAuth alternative as of May 2026).
- **Weave** is the GenAI trace surface for `llm-app` work; runs land in
  Weave automatically when `wandb.init(...)` is followed by the LLM
  call.
- **Reports** are the human-review surface — markdown + embedded
  charts + queryable run tables. The agent can author Reports; humans
  comment.
- **Refuse to delete runs.** The agent reads / queries; deletion is a
  human action via the W&B UI.
- **Pairs with MLflow** when a team uses both (MLflow for classical ML
  tracking, W&B Weave for LLM-app tracing).
