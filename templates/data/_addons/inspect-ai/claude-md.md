## Inspect AI (UK AISI, Apache-2.0)

- **Dataset → solver → scorer.** Three-piece eval shape. Datasets are
  versioned; solvers are the agent / model under test; scorers compute
  the metric.
- **Docker-sandboxed evals.** Each task runs in a fresh container;
  no shared state between tasks. Required for adversarial / agentic
  evals.
- **200+ pre-built evals** at `github.com/UKGovernmentBEIS/inspect_evals`.
  Use them as starter tasks; do not re-invent.
- **Can wrap Claude Code, Codex, Gemini CLI as the agent under test.**
  This is the agentic-eval surface — eval the full harness, not just
  the model.
- **Inspect AI version May 2026 release line** is the minimum target.
