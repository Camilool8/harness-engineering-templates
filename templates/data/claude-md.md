## Data / ML rules

### Stack lockdown

- **Polars + DuckDB by default**, not pandas. Use Ibis when you need one query
  to run locally (DuckDB) and in the warehouse (Snowflake/BigQuery) unchanged.
  pandas only as ecosystem glue where a library demands it.
- New notebooks: prefer marimo (pure-Python, git-diffable) over Jupyter.
  Never edit `.ipynb` JSON blind.

### Querying data

- **Sample then scale.** Run `LIMIT 1000` (or `TABLESAMPLE`) first, inspect the
  shape and dtypes, *then* run the full query. The `block-unbounded-sql` hook
  enforces this — a SELECT with no WHERE/LIMIT is rejected.
- The warehouse is read-only. Any DDL/DML goes through a reviewed migration PR,
  never an agent query.

### Reporting

- **Every reported metric is backed by a logged query.** A number without the
  query, dataframe shape, and data hash that produced it is a hallucination
  with extra steps. Use the `ensuring-reproducibility` skill before committing.
- Evals live in a package separate from model code — never edit both at once.

### Never do

- Never call `.fit()` before `train_test_split`, or fit a scaler on full X
  outside a Pipeline — the `leakage-sentinel` hook blocks both.
- Never run many t-tests without a multiple-comparison correction.
- Never use `.shift(-N)` — a negative shift is look-ahead bias.
