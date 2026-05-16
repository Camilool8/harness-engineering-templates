---
name: ensuring-reproducibility
description: Makes a data/ML run reproducible. Use before committing training, analysis, or eval code — pin every random seed, refresh the lockfile, record the environment, and keep the eval suite in a package separate from model code.
---

# Ensuring reproducibility

A result that cannot be reproduced is an anecdote. Run this checklist before
committing any code that trains a model, computes a metric, or runs an eval.

## Seed every source of randomness

Pin all of these — one unpinned source makes the run non-deterministic:

```python
import os, random, numpy as np
os.environ["PYTHONHASHSEED"] = "0"
random.seed(SEED)
np.random.seed(SEED)
# torch:  torch.manual_seed(SEED); torch.use_deterministic_algorithms(True)
# jax:    key = jax.random.PRNGKey(SEED)
# hf:     transformers.set_seed(SEED)
```

`SEED` is a named constant, logged with the run — never a literal scattered
through the code.

## Pin the environment

- Use **uv** for pure-Python projects (`uv lock`, `uv sync --frozen` in CI),
  **pixi** when conda packages are needed (CUDA, MKL, R, ffmpeg).
- The lockfile must be **fresh** — regenerated after any dependency change and
  committed in the same change. A stale lockfile is silent drift.
- Record CUDA / cuDNN versions and a content hash of the input data alongside
  the run.

## Keep evals separate from model code

The eval suite lives in its **own package** (or repo) from the model/training
code. This is structural, not stylistic: if evals and model live together, the
agent can "improve the numbers" by editing both in one motion. Separation makes
that impossible — the eval is an independent measurement.

- Never edit an eval and the model it scores in the same change.
- Never let an LLM-as-judge come from the same model family as the generator —
  self-preference bias inflates scores 10–25%.

## Rules

- No metric is reported without the logged query / dataframe shape / data hash
  that produced it.
- A run that does not pin seeds is not "done" — it is unverifiable.
