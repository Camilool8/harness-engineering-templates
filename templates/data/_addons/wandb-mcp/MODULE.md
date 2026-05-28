# Addon — wandb-mcp

W&B official `wandb/wandb-mcp-server`. Weave (GenAI traces) + Reports
(human-review surface).

## Adopt if

- Your team is W&B-native.

## Skip if

- You are MLflow-native and adding W&B would duplicate state.

## What it contributes

- CLAUDE.md section: W&B Weave for GenAI traces, W&B Reports as the
  human-review surface.
- MCP fragment: W&B official MCP server.

## Provision before install

- W&B account with team + project.
- `WANDB_API_KEY` (env). The `block-static-warehouse-creds.sh` shared
  hook does NOT currently flag `WANDB_API_KEY` because W&B's auth model
  is API-key-by-design (no OAuth alternative as of May 2026); revisit
  if W&B ships OAuth.

## Pairs with

`ml-pipeline`, `llm-app`.
