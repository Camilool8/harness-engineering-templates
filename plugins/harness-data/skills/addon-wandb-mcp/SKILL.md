---
name: data-addon-wandb-mcp
description: Weights & Biases conventions — the official wandb-mcp-server with WANDB_API_KEY auth, Weave as the GenAI trace surface, Reports as the human-review surface the agent can author, refuse-to-delete-runs discipline, and pairing with MLflow. Use when wiring the W&B MCP, tracing LLM runs in Weave, or authoring W&B Reports.
---

# W&B (Weave + Reports + MCP)

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

## MCP setup (opt-in)

This addon's W&B MCP carries a secret API key, so it is **not** auto-started
by the plugin. Add it to your project's `.mcp.json` only when you want runs /
artifacts / reports access, then set `WANDB_API_KEY` in your environment:

```json
{
  "mcpServers": {
    "wandb": {
      "command": "uvx",
      "args": ["wandb-mcp@latest"],
      "env": { "WANDB_API_KEY": "${WANDB_API_KEY}" }
    }
  }
}
```
