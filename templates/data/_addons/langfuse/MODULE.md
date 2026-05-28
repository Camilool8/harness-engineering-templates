# Addon — langfuse

Langfuse OSS LLM observability (YC W23). Traces + datasets + scores +
the official MCP at `/api/public/mcp`. Contributes the `trace-triager`
agent.

## Adopt if

- Your LLM app needs production-grade trace + eval + dataset management
  with an OSS stack.

## Skip if

- You have committed to a closed-source observability vendor and
  Langfuse would duplicate state.

## What it contributes

- CLAUDE.md section: traces-as-eval-source, LLM-judge with a
  cross-family model, dataset/score management as the regression
  surface.
- MCP fragment: Langfuse OSS MCP wiring (self-hosted or Langfuse Cloud).
- Agent: `trace-triager` (haiku) — reads recent traces, flags
  regressions, summarises latency + cost deltas.

## Provision before install

- Langfuse deployment (self-hosted Docker or Langfuse Cloud account).
- Project + public key + secret key (env: `LANGFUSE_PUBLIC_KEY`,
  `LANGFUSE_SECRET_KEY`, `LANGFUSE_HOST`).

## Pairs with

`llm-app` (primary).
