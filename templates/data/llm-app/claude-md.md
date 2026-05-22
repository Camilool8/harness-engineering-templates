## Data — llm-app

### Three-tier eval discipline
- **Assertion → judge → human, in that order.** No higher tier without the
  lower tier. The `llm-app-architect` refuses; the `three-tier-eval` skill
  documents the shape.
- **Multi-test correction is a Level-1 assertion.** A loop of judge calls
  applies Bonferroni or Benjamini-Hochberg.
- **The judge is in a different model family from the generator.** Same-
  family judges introduce 10–25% self-preference bias. The `judge-runner`
  agent refuses if families match.

### Prompt + model-version discipline
- **Every LLM call goes through a single pinned model-ID env var.** Use
  the `model-version-pin` skill. Pin bumps require typed-token
  confirmation (two-key on).
- **Never bump a model-version pin and edit a prompt in the same diff.**
  The `prompt-implementer` agent refuses; the `eval-curator` shared agent
  enforces at PR boundary.
- **Prompt-regression suite runs on every prompt change** via
  `prompt-regression-suite` skill. Hits the pinned eval set.

### Observability
- **Every production call is traced.** The `langfuse` addon wires the MCP
  fragment; the `trace-triager` agent (contributed by `langfuse`) reads
  recent traces and flags regressions.

### Reporting
- **Eval numbers trace to logged runs.** `query-provenance-auditor` shared
  agent enforces; do not report bare accuracy without the run-id.
