# Data domain — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

This dossier is the cross-cutting baseline. Per-sub-domain dossiers at
`data-analyst-notebook/references.md`, `ml-pipeline/references.md`,
`llm-app/references.md`, and `analytics-engineering/references.md` cover
sub-domain-specific threads.

## Current best practices

- **Warehouse credential posture is Managed-MCP / OAuth-only.** Static
  warehouse credentials (`SNOWFLAKE_PASSWORD`, `BIGQUERY_SERVICE_ACCOUNT_KEY_JSON`,
  `DATABRICKS_TOKEN`, `MOTHERDUCK_TOKEN`) on the agent host are the failure
  mode per the ShinyHunters / Anodot supply-chain breach (April 2026). Use
  the Snowflake Cortex Managed MCP (GA Nov 4 2025), the Google BigQuery MCP
  (preview Jan 2026), the Databricks MCP (Public Preview May 7 2026), or the
  MotherDuck `duckdb-mcp`.
- **EU AI Act Annex IV (Aug 2 2026) makes immutable agent-tool-call audit
  logging statutory** for high-risk systems. The rebuttable-compliance
  presumption attaches to NIST AI RMF / ISO 42001 implementations under
  Texas RAIGA, Colorado AI Act, and California AI Transparency Act. The
  shared `audit-log-warehouse-query.sh` hook emits Annex-IV-shaped records;
  the `dataset-card-author` agent emits the dataset-card surface NIST AI
  RMF Map requires.
- **Eval-suite-as-separate-package is the unit-test surface for ML and LLM
  work.** The `eval-curator` shared agent Default-FAIL contract refuses any
  PR diff that touches both `eval/**` and model/prompt code. Inspired by
  Anthropic harness papers (Nov 2025 + Mar 2026).
- **Use a judge model from a different family than the generator.** 10–25%
  self-preference bias is measured. The `llm-app` `judge-runner` agent
  refuses if `--judge-model` family matches generator family.

## Common gotchas

- **Editing `.ipynb` JSON blind silently mangles cell metadata.** Route
  notebook edits through `marimo` (the addon) or through a Jupyter MCP;
  never raw `NotebookEdit` on `.ipynb`. The Restart-and-Run-All gate is the
  only acceptance test for notebooks (ReviewNB + Recce + Mineault 2026).
- **Leakage is the second-most-common silent ML failure.** `.fit()` before
  `train_test_split`, scaler `.fit()` on full `X` outside a `Pipeline`,
  t-test in a loop without `multipletests`, `.shift(-N)` look-ahead. The
  `leakage-sentinel.sh` hook is regex-based; LeakageDetector 2.0 (arXiv
  2509.15971, Sep 2025) is the published static analyzer it encodes.
- **dbt without contracts is dbt without a contract.** Every staging+ model
  needs `contract.enforced: true` and at least one unit test per dbt Labs
  Feb 2026 best practices.

## Version-sensitive notes

- Snowflake Cortex Managed MCP: GA Nov 4 2025.
- dbt remote MCP: GA Oct 2025; `dbt-labs/dbt-agent-skills`: Feb 9 2026.
- Google BigQuery MCP: preview Jan 2026 — re-verify GA status every quarter.
- Databricks MCP: Public Preview May 7 2026 — re-verify GA status every quarter.
- MLflow MCP extra: ships in MLflow 3.5.1+.
- W&B official MCP: `wandb/wandb-mcp-server` (2026).
- UK AISI `inspect-ai`: Apache-2.0, May 2026 release line.
- Langfuse: OSS, YC W23 cohort, self-hostable.

## Cited links

- [Snowflake Cortex Managed MCP — GA release note (Nov 4 2025)](https://docs.snowflake.com/en/release-notes/2025/other/2025-11-04-cortex-agents-mcp) — official GA announcement and posture.
- [dbt Labs — `dbt-agent-skills` (Feb 9 2026)](https://docs.getdbt.com/blog/dbt-agent-skills) — vendor-stewarded agent-skill catalog.
- [LeakageDetector 2.0 (arXiv 2509.15971, Sep 2025)](https://arxiv.org/html/2509.15971) — published static analyzer for the leakage patterns `leakage-sentinel.sh` encodes.
- [Husain & Shankar — LLM Evals FAQ (Jan 15 2026)](https://hamel.dev/blog/posts/evals-faq/evals-faq.pdf) — three-tier eval (assertion / judge / human) and multi-test-correction as Level-1 assertion.
- [Anthropic harness papers (Nov 2025 + Mar 2026)](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — `eval-curator` Default-FAIL contract.
- [Rescana — Vimeo / Anodot / Snowflake breach analysis (Apr 2026)](https://www.rescana.com/post/vimeo-data-breach-2026-shinyhunters-exploit-anodot-integration-to-expose-119-000-user-records-via-snowflake-and-bigquery/) — credential-posture forcing function.
- [EU AI Act — Article 99 / Annex III enforcement (Aug 2 2026)](https://www.pearlcohen.com/new-guidance-under-the-eu-ai-act-ahead-of-its-next-enforcement-date/) — audit-log statutory obligation.
