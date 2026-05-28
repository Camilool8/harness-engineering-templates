---
name: prompt-regression-suite
description: Run the pinned eval set on every prompt change. CI gate that catches regressions before they ship.
---

## When to use

On every prompt diff. The CI workflow runs this on every PR that
touches `prompts/**`.

## How

### Inputs

- Pinned eval data at `eval/data/<surface>/`.
- Frozen baseline scores at `eval/baselines/<surface>.json`.
- The new prompt under review.

### Run

```bash
uv run pytest eval/regression/test_<surface>.py \
  --baseline eval/baselines/<surface>.json \
  --tolerance 0.02
```

The test loads each input, runs the LLM with the new prompt, scores via
Tier 1 + Tier 2 evals, and compares to the baseline. A regression
beyond the tolerance fails the test.

### Update the baseline

When a prompt change is intentional and the new behavior is better:

```bash
uv run pytest eval/regression/test_<surface>.py --update-baseline
git add eval/baselines/<surface>.json
```

The baseline file change is a separate commit from the prompt change so
the audit log distinguishes "intentional regression" from "drift."

## Anti-patterns this skill prevents

- "Looks fine to me" merges that silently degrade a behavior surface.
- Baselines that are never refreshed and grow stale.
- Updating baseline + prompt in the same diff (the `eval-curator` shared
  agent refuses).
