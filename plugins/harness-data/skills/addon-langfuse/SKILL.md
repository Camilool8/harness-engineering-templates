---
name: data-addon-langfuse
description: Langfuse OSS LLM-observability conventions — production traces graduate to the next eval dataset, cross-family LLM judges, versioned reproducible datasets, the MCP at /api/public/mcp with public+secret keys, and PII masking in trace inputs. Use when instrumenting LLM tracing, wiring the Langfuse MCP, or triaging traces and regressions.
---

# Langfuse (OSS LLM observability + MCP)

- **Traces are the eval source.** Production traces graduate to the
  next release's eval dataset. The `trace-triager` agent surfaces
  regressions.
- **Cross-family LLM judge.** Langfuse Score / Eval features support
  custom judges; configure the judge model from a DIFFERENT family than
  the generator (the `judge-runner` agent in `llm-app` refuses
  same-family).
- **Datasets are versioned.** Every eval run is reproducible —
  fixed dataset version + fixed prompt + fixed model snapshot.
- **MCP at `/api/public/mcp`.** Auth via public + secret keys; refuse
  to log PII in trace inputs (mask in the SDK call).
- **Self-hosted is the default.** Langfuse Cloud is fine; on-prem with
  PHI / PII is the more common posture.

## MCP setup (opt-in)

This addon's Langfuse MCP carries a secret key (and a host), so it is **not**
auto-started by the plugin. Add it to your project's `.mcp.json` only when
you want trace access, then set `LANGFUSE_HOST`, `LANGFUSE_PUBLIC_KEY`, and
`LANGFUSE_SECRET_KEY` in your environment:

```json
{
  "mcpServers": {
    "langfuse": {
      "type": "http",
      "url": "${LANGFUSE_HOST}/api/public/mcp",
      "headers": {
        "X-Langfuse-Public-Key": "${LANGFUSE_PUBLIC_KEY}",
        "X-Langfuse-Secret-Key": "${LANGFUSE_SECRET_KEY}"
      }
    }
  }
}
```
