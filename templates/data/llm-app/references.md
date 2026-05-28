# Data / llm-app — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **Three-tier eval ladder (Husain & Shankar, Jan 15 2026):** assertion-first
  (cheap, deterministic, multi-test-corrected), then LLM-judge with a
  cross-family model, then human review on major changes. Higher tiers
  must not exist without lower tiers populated.
- **Evaluator-in-a-different-family rule.** 10–25% self-preference bias
  measured for same-family judges across 2025–2026 benchmarks.
- **Sandbox-isolated agentic evals (Inspect AI).** Docker-sandboxed
  solver / scorer pattern; deterministic seed pinning; the
  `UKGovernmentBEIS/inspect_evals` catalogue (200+) is the starter set.
- **Trace-as-eval-source (Langfuse).** Production traces become the next
  release's eval dataset. The `trace-triager` agent surfaces regressions.

## Common gotchas

- **Hard-coded model-ID strings sprinkled across the codebase.** Move
  the model-ID into one env var and pin it. The `model-version-pin`
  skill documents the surface.
- **Prompt + model bump in the same diff.** Eval signal becomes
  unreadable. `eval-curator` shared agent refuses.
- **Skipping assertion tier "because the judge is smarter."** The judge
  is more expensive AND more variable; the assertion tier is the cheap
  signal.

## Version-sensitive notes

- Inspect AI: Apache-2.0, May 2026 release line.
- Langfuse: OSS, YC W23 cohort; MCP endpoint at `/api/public/mcp`.
- MLflow 3.5.1+ GenAI tracing surface ships in the standard MLflow package.
- Husain & Shankar LLM Evals FAQ: Jan 15 2026 edition.

## Cited links

- [Husain & Shankar — LLM Evals FAQ PDF (Jan 15 2026)](https://hamel.dev/blog/posts/evals-faq/evals-faq.pdf) — three-tier eval ladder.
- [Inspect AI by UK AISI](https://inspect.aisi.org.uk/) — sandbox-isolated eval framework.
- [Langfuse — OSS LLM observability](https://langfuse.com/) — traces, datasets, scores.
- [MLflow GenAI tracing](https://mlflow.org/docs/latest/genai/) — GenAI surface in 3.5.1+.
- [Anthropic harness papers — Default-FAIL contract](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Nov 2025 + Mar 2026.
- [Snowflake — Cortex Agent Evaluations (GA Mar 13 2026)](https://www.snowflake.com/en/developers/guides/getting-started-with-cortex-agent-evaluations/) — YAML-defined custom metrics.
