---
name: data-domain
description: Shared rules for any data engineering work — warehouse is read-only via Managed-MCP/OAuth, sample-then-scale on every query, every reported metric traces to a logged query and data hash, evals live in a package separate from model/prompt code, cross-family LLM judges, and a dataset card for every dataset. Auto-loads for any analytics, ML, LLM, or notebook task.
---

# Data domain

## Warehouse posture
- **Warehouse is read-only.** DDL/DML goes through reviewed migration PRs,
  never agent queries. `block-unbounded-sql` hook enforces; do not bypass.
- **Sample then scale.** Run `LIMIT 1000` / `TABLESAMPLE` first, validate the
  shape and dtypes, then run the full query.
- **No static warehouse credentials on the agent host.** Managed-MCP / OAuth
  only. `block-static-warehouse-creds` refuses to start if
  `SNOWFLAKE_PASSWORD` or equivalent is set when a Managed-MCP alternative
  exists.

## Provenance and audit
- **Every reported metric traces to a logged query + a data hash.** Numbers
  without provenance are hallucinations with extra steps. The
  `query-provenance-auditor` shared agent enforces.
- **All warehouse queries are audit-logged** via `audit-log-warehouse-query`.
  The log feeds the EU AI Act Annex IV (Aug 2 2026) compliance evidence path
  and the NIST AI RMF / ISO 42001 rebuttable presumption.

## Eval discipline
- **Evals live in a package separate from model / prompt code.** The
  `eval-curator` shared agent refuses any PR diff that touches both at once.
  This is a Default-FAIL contract per the Anthropic harness papers (Nov 2025,
  Mar 2026).
- **Use a judge model from a different family than the generator.** Same-
  family judges introduce 10–25% self-preference bias.

## Datasets
- **Every dataset gets a dataset card** via the `dataset-card-author` shared
  agent — intended use, provenance, schema, PII posture, license, biases.
