---
name: marimo-pair-mode
description: Use `marimo pair` to work on a marimo notebook in tandem with the agent. The agent edits cells in the .py file; the human observes in the browser.
---

## When to use

Whenever the deliverable is a notebook and you want the agent to drive
cell construction while a human observes / steers in real time.

## How

### Start a marimo pair session

```bash
marimo edit --pair analysis.py
```

This opens the marimo browser UI AND streams cell-level diffs to a
local socket the agent reads.

### Agent rules in pair mode

1. **One cell at a time.** Do not batch-edit; the human is observing
   each change as it lands.
2. **Print the cell's shape + dtypes after every data transformation.**
   The marimo table widget renders it inline.
3. **No `display()` shenanigans.** marimo auto-renders the last
   expression; rely on that.
4. **Restart-and-Run-All is the gate.** Before claiming "done", run:

```bash
marimo export script analysis.py > /tmp/analysis-export.py
python /tmp/analysis-export.py
```

A clean execution prints no traceback and produces every expected
output. The `restart-run-all-checker` agent (in `data-analyst-notebook`)
enforces.

## Anti-patterns this skill prevents

- "I'll fix it in the next cell" — pair mode forces every cell to be
  consistent before moving on.
- Hidden state from out-of-order edits (the reactive graph re-runs
  downstream cells automatically, but the human must see the new
  state).
- Bulk diffs that lose the cell-level intent.
