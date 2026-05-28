---
name: running-evals
description: Builds and iterates evals for LLM/ML output. Use whenever changing a prompt, model, retrieval config, or tool surface, or when an output's correctness is judgmental rather than deterministic. Arm the Stop gate with eval = true in .claude/HARNESS.toml.
---

# Running Evals

Evals are the unit test for judgmental output. They are how you know a prompt or
model change improved rather than regressed behavior.

To arm the gate, add this to `.claude/HARNESS.toml` (create the file if needed):

```toml
[harness]
eval = true
```

While armed, the `eval-gate.sh` Stop hook runs the fast eval subset before "done"
is allowed and blocks on failure. It is a no-op until `evals/run.sh` exists, so
arming it early does not punish you.

## Error analysis first — do not skip

Do **not** invent evaluators up front. LLM failure modes are open-ended; you
cannot enumerate them in advance.

1. Run the system on real or representative inputs.
2. **Read the outputs.** Categorize what actually goes wrong.
3. For each failure category you observed, add a row to `evals/golden.jsonl`
   with `source: observed-failure:<ref>`, and write the cheapest evaluator that
   would have caught it.

## The three tiers — cheapest first

1. **Assertion** — deterministic code checks (schema, format,
   `must_contain` / `must_not_contain` / `regex`). Run on every change.
2. **Model-graded** — an LLM judge scores against the row's `rubric`. Use for
   open-ended quality assertions cannot express.
3. **Human** — a person reviews a sample; the ground truth the other tiers are
   calibrated against.

Escalate a check to the next tier only when the cheaper tier genuinely cannot
judge it.

## Hard constraint — judge family

The model-graded judge MUST be a **different model family** than the generator
under test. Same-family judging inflates scores and shares blind spots. If the
generator is Claude, the judge is GPT / Gemini / Llama / etc. Verify this before
trusting any model-graded number.

## Scaffolding the harness

The gate expects an `evals/run.sh` with this contract: exit 0 = pass, non-zero =
fail; honor `--fast` / `EVAL_FAST=1` to run a quick subset. The dataset is
`evals/golden.jsonl`, one JSON object per line:

```jsonl
{"input": "...", "expected": "...", "rubric": "...", "source": "observed-failure:#123"}
```

## Running

- Fast subset (assertion tier + a small model-graded sample):
  `EVAL_FAST=1 evals/run.sh --fast`. The `eval-gate.sh` Stop hook runs this
  automatically and blocks "done" on failure.
- Full suite: `evals/run.sh` — run in CI and before shipping a model/prompt
  change.

## When done

- Re-run evals after the change; confirm the score moved the right direction.
- Commit any new `golden.jsonl` rows — the dataset is the durable asset.
- Sanity-check that the eval gain corresponds to a real user-outcome gain. A
  score that rises while the user metric does not is a measurement artifact.
