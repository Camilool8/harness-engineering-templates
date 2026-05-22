## Langfuse (OSS LLM observability + MCP)

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
