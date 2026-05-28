---
name: eval-suite-isolated-package
description: Scaffold an out-of-tree eval/ package that imports the model but the model never imports it. The cross-cutting eval-curator shared agent enforces the separation.
---

## When to use

When starting a new ML project or adding the first eval suite to an
existing one.

## How

### Layout

```
my-ml-project/
  src/                       <- model code
    my_model/
      __init__.py
      train.py
      predict.py
  eval/                      <- eval code; SEPARATE package
    pyproject.toml           <- eval is its own package
    eval/
      __init__.py
      datasets.py
      assertions.py
      regression.py
      ts_cv.py
  pyproject.toml             <- root project; lists my_model only
  uv.lock
```

### Rules

1. `eval/pyproject.toml` declares `my-eval` as the package name; it
   depends on the root project (`my_model`) but the root project does
   not depend on it.
2. `src/my_model/*.py` MUST NOT contain `import eval` or `from eval ...`.
   The `eval-curator` shared agent's Default-FAIL contract rejects PR
   diffs that violate this.
3. The CI invocation runs evals as `uv run --package eval pytest eval/`
   so the eval package is loadable; in development, `uv pip install -e
   eval/` once at setup makes the package available.
4. New evals land in `eval/`; new training code lands in `src/`. A
   single PR may not touch both — split into two.

## Anti-patterns this skill prevents

- The agent "improving" eval scores by editing both the eval and the
  model in the same diff (the canonical p-hacking pattern under
  agent-driven development).
- Test data leaking into training via a shared utility module both
  packages import.
- "I'll just inline a quick eval next to the model" — once the inline
  eval ships, splitting it later is twice the work.
