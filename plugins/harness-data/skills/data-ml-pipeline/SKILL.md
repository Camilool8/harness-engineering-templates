---
name: data-ml-pipeline
description: ML-pipeline discipline — every training run logged, lockfile-frozen environments, every seed pinned, the eval suite as a separate package the model never imports, a data hash per dataset, and leakage guards. Use when .claude/HARNESS.toml selects data/ml-pipeline, or when training models, writing train.py, running evaluation suites, packaging or registering model artifacts.
---

# Data — ml-pipeline

## Training discipline
- **Every training run is logged.** Refuse `python train.py` invocations
  that lack `import (mlflow|wandb|aim)`. The `mlflow` addon's
  `require-tracking.sh` hook enforces.
- **Lockfile-frozen environments.** `uv lock --frozen` + `uv sync
  --frozen`; new packages go through a deps-update PR. The `uv` addon's
  `lockfile-frozen.sh` hook enforces.
- **Pin every seed** in `random` / `numpy` / `torch` / `jax` /
  `transformers.set_seed` / `PYTHONHASHSEED`. Use the
  `pin-seeds-and-lockfile` skill.

## Eval discipline
- **The eval suite is a separate Python package.** Models import nothing
  from evals; evals import the model. The `eval-curator` shared agent
  refuses any PR diff that touches both.
- **Every dataset gets a data hash.** Refuse model commits that change an
  artifact without a recorded data hash. The `data-versioner` agent emits
  and stores hashes per run.

## Reporting
- **Every reported number traces to a logged run + data hash.** The
  `query-provenance-auditor` shared agent will reject reports without
  provenance. Use the `run-comparator` agent (contributed by `mlflow`) to
  diff against prior runs.

## Anti-patterns blocked
- `.fit()` before `train_test_split`; scaler `.fit()` outside a `Pipeline`;
  loop of t-tests without `multipletests`; `.shift(-N)`. The
  `leakage-sentinel` shared hook enforces.
