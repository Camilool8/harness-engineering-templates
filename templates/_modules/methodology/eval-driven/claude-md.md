## Eval-Driven Development

Evals are the unit test for LLM/ML output. Any change to a prompt, model,
retrieval config, or tool surface must be measured, not vibe-checked.

- **Evals live in `evals/`.** `golden.jsonl` is the dataset; `evals/run.sh` runs
  the harness. The `eval-gate.sh` Stop hook runs the fast subset before "done"
  is allowed and blocks if it regresses.
- **Three tiers, cheapest first** (Hamel Husain):
  1. **Assertions** — deterministic checks (format, schema, must/must-not
     contain). Fast, free, run on every change.
  2. **Model-graded** — an LLM judge scores against a rubric. Use for
     open-ended quality.
  3. **Human** — a person reviews a sample. The ground truth the other tiers
     are calibrated against.
- **HARD CONSTRAINT: the judge model must be a different model family than the
  generator.** A model judging its own family inflates scores and shares blind
  spots. If the generator is Claude, the judge is not Claude.
- **Error analysis first.** Do not invent evaluators up front. Look at real
  failures, then write evaluators for the failures you actually observed, and
  add the failing case to `golden.jsonl`.
- Optimize for user outcomes, not eval scores. A rising score that does not move
  the user metric is a measurement artifact.

See the `running-evals` skill and `evals/RUNBOOK.md`.
