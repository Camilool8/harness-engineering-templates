# Evals Runbook

Evals are to LLM/ML systems what tests are to deterministic code. Without them
you cannot tell whether a prompt, model, or retrieval change improved or
regressed behavior.

## Layout

```
evals/
  golden.jsonl   the dataset — one input→expected row per line
  run.sh         YOU write this — runs the harness against golden.jsonl
  RUNBOOK.md     this file
```

## Row schema

`golden.jsonl` is strict JSONL — one JSON object per line, no comments. Fields:

| Field | Meaning |
|---|---|
| `id` | Stable unique identifier; never reuse after deletion. |
| `input` | The input passed to the system under test. |
| `expected` | The reference answer / expected behavior. |
| `checks` | Assertion-tier checks: `must_contain` / `must_not_contain` / `regex`. |
| `tier` | `assertion` \| `model_graded` \| `human` — how this row is scored. |
| `rubric` | (model_graded / human only) the grading criteria. |
| `source` | Where this case came from; prefer `observed-failure:<ref>`. |

## The `run.sh` contract

`evals/run.sh` is stack-specific, so this module does not ship it — you write
it. It must:

- Read `golden.jsonl` (one JSON object per line), run each row through the
  system under test, and score it per its `tier`.
- Print a human-readable pass/fail summary.
- Exit `0` if the run meets the pass bar, non-zero otherwise.
- Support a fast subset: honor a `--fast` flag **or** `EVAL_FAST=1` env var to
  run only assertion-tier rows (and a small model-graded sample). The
  `eval-gate.sh` Stop hook calls the fast path; the full suite runs in CI.

## The three tiers (Hamel Husain)

Run them cheapest-first; escalate only what the cheaper tier cannot judge.

1. **Assertion tier.** Deterministic, code-only checks — schema/format
   validity, `must_contain` / `must_not_contain` / `regex` from each row's
   `checks`. Fast, free, deterministic. Run on every change.
2. **Model-graded tier.** An LLM judge scores the output against the row's
   `rubric`. Use for open-ended quality (tone, faithfulness, helpfulness) that
   assertions cannot capture.
3. **Human tier.** A person reviews a sample. This is the ground truth the
   other two tiers are calibrated against — periodically check that the
   model-graded scores still agree with human judgment.

## HARD CONSTRAINT — judge family

> The judge model in the model-graded tier MUST belong to a **different model
> family** than the generator under test.

A model grading its own family inflates scores and shares the generator's blind
spots — it cannot see errors it would make itself. If the generator is Claude,
the judge must be GPT / Gemini / Llama / etc., and vice versa. `run.sh` must
fail loudly if the configured judge family equals the generator family.

## Workflow — error analysis first

Do **not** write evaluators up front. LLM failure modes are open-ended and
unknowable in advance.

1. Run the system on real or representative inputs and **look at the outputs**.
2. Categorize the failures you actually observe.
3. For each failure category, add a row to `golden.jsonl` (`source:
   observed-failure:<ref>`) and write the cheapest evaluator that catches it.
4. Make the change, re-run evals, confirm the score moved the right way.
5. Keep the dataset versioned in git — it is the asset.

## Anti-patterns

- Writing evaluators before observing failures.
- Treating the LLM judge as ground truth without ever checking it against humans.
- Optimizing the eval score instead of the user outcome.
- Same-family judging (see the hard constraint above).
