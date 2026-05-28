---
name: data-analyst-notebook
description: Exploratory notebook discipline — marimo first and never raw NotebookEdit on .ipynb, Restart-and-Run-All as the only acceptance test, sample-then-scale on every warehouse query, Polars + DuckDB over pandas, and chart-critic review. Use when .claude/HARNESS.toml selects data/data-analyst-notebook, or when doing ad-hoc analysis, exploratory reporting, or building reactive reproducible notebooks.
---

# Data — data-analyst-notebook

## Notebook discipline
- New notebooks: **marimo first**, Jupyter only when forced. Edit marimo
  `.py` directly. Never raw `NotebookEdit` on `.ipynb` JSON — route through
  the `marimo pair` flow or a Jupyter MCP.
- **Restart-and-Run-All is the only acceptance test.** A notebook that runs
  cells out of order or relies on hidden state is not done. The
  `restart-run-all-checker` agent enforces.
- One cell, one idea. If a cell exceeds ~30 lines, split it.

## Querying data
- **Sample then scale** on every warehouse query: `LIMIT 1000` or
  `TABLESAMPLE` first, inspect dtypes + shape, then graduate. The
  `block-unbounded-sql` hook will reject the unscoped form.
- Prefer Polars + DuckDB / Ibis. pandas only as ecosystem glue for libraries
  that demand it.

## Charts
- Every chart goes through the `chart-critic` agent (PostToolUse on chart
  write). Banned by default: truncated y-axis, dual y-axes, missing CIs,
  rainbow palettes on sequential data, color-only encoding, 3D pie charts.

## Reporting
- **Every number in your output traces to a logged query + data hash.** The
  `query-provenance-auditor` shared agent will reject reports whose numbers
  lack the audit-log entry.
