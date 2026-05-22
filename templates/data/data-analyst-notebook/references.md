# Data / data-analyst-notebook — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **marimo is the 2026 notebook default.** Pure-Python `.py` files, reactive
  dependency graph, git-diffable. `marimo pair` (April 2026) is the agent
  pair-on-notebook surface. `marimo export script` is the Restart-and-Run-All
  CI gate.
- **Sample then scale on every warehouse query.** `LIMIT 1000` or
  `TABLESAMPLE` first, validate shape + dtypes, then run the full query.
  The `block-unbounded-sql.sh` shared hook enforces.
- **DuckDB-then-Snowflake / BigQuery / Databricks** is the local-then-remote
  default. Same SQL, same DataFrame surface (via Ibis or `pl.SQLContext`).

## Common gotchas

- **`.ipynb` JSON edits silently mangle cell metadata.** Never raw
  `NotebookEdit`. Route through marimo or a Jupyter MCP.
- **Charts hallucinate readability.** Truncated y-axes, dual axes, rainbow
  palettes on sequential data are the canonical sins (Mineault 2026,
  ReviewNB + Recce). The `chart-critic` agent runs PostToolUse on chart-write.
- **Hidden notebook state.** ~36% of sampled Jupyter notebooks are
  non-reproducible (HE §2.1). Restart-and-Run-All is the only acceptance test.

## Version-sensitive notes

- marimo `marimo pair`: April 2026.
- Polars: v1.40 (April 2026) — first-class scikit-learn / XGBoost integration.
- DuckDB / MotherDuck `duckdb-mcp`: 2026 official server.

## Cited links

- [marimo — `marimo pair` launch (April 2026)](https://marimo.io/blog/marimo-pair) — agent pair-on-notebook surface.
- [marimo vs Jupyter (marimo.io)](https://marimo.io/features/vs-jupyter-alternative) — why reactive `.py` notebooks beat `.ipynb`.
- [Patrick Mineault — Claude Code for Scientists (Jan 29 2026)](https://www.neuroai.science/p/claude-code-for-scientists) — minimal-version-first, diagnostic plots, journal-keeping.
- [ReviewNB — Claude Code + Jupyter Notebooks Finally Work Well](https://www.reviewnb.com/claude-code-with-jupyter-notebooks) — Restart-and-Run-All as the only acceptance test.
- [Recce — I let Claude Code build my dbt models (Feb 25 2026)](https://blog.reccehq.com/i-let-claude-code-build-my-dbt-models.-the-interesting-part-wasnt-the-code) — silent-data-quality-flag catalogue.
- [MotherDuck — `duckdb-mcp` server](https://motherduck.com/product/mcp-server/) — local-first SQL via official MCP.
