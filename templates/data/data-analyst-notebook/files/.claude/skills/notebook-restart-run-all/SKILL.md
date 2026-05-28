---
name: notebook-restart-run-all
description: Run the notebook top-to-bottom in a clean kernel before claiming it is done. The only acceptance test for notebooks.
---

## When to use

Before claiming any notebook task is complete. The
`restart-run-all-checker` agent will run this skill automatically; use it
yourself first.

## How

### marimo `.py`

```bash
marimo export script analysis.py > /tmp/analysis-export.py
python /tmp/analysis-export.py
```

A clean execution prints no traceback and produces every expected output.

### Jupyter `.ipynb`

```bash
jupyter nbconvert --to notebook --execute --inplace analysis.ipynb
```

After execution, verify:
- Cell execution counts are strictly monotonic starting at 1.
- No cell has `In [ ]:` (empty) or `In [*]:` (still running).
- The reported numbers match `.claude/expected-outputs.json` if present.

## Anti-patterns this skill prevents

- Hidden cell state: cells run out of order during exploration leave the
  kernel in a state that does not reproduce.
- Manual cell-by-cell completion claims that do not survive a fresh kernel.
- `print()` outputs that depend on a global mutated three cells ago.
