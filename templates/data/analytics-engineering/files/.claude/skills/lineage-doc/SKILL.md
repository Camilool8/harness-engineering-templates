---
name: lineage-doc
description: Every model has an upstream + downstream comment block enumerating the lineage edges. The lineage-auditor agent verifies.
---

## When to use

Every dbt model. Top of the model file, before any SQL.

## How

Put a doc-block at the top:

```sql
-- ============================================================================
-- fct_orders — order facts at one row per order, USD-denominated.
--
-- Upstream:
--   - stg_orders (current_session)
--   - stg_customers (current_session)
--   - dim_currency_rates (current_session)
--
-- Downstream consumers:
--   - dashboard/sales_overview.lkml (Looker)
--   - exposures.yml::sales_weekly_report
--   - downstream-project::int_orders_enriched (dbt Mesh)
--
-- Refresh: daily at 04:00 UTC after stg_orders lands.
-- Owner: revenue-analytics@example.com
-- ============================================================================

{{ config(materialized='table') }}
...
```

For the semantic-layer manifest at `models/semantic/<entity>.yml`, put
the same doc-block in YAML comments at the top.

## Anti-patterns this skill prevents

- Removing a model whose downstream consumers still reference it (the
  `lineage-auditor` agent rejects, but the doc-block makes it obvious
  before the agent even runs).
- "Why is this here?" questions six months later when no one remembers
  the upstream.
- Hidden dbt-Mesh references that span projects without doc-block
  acknowledgement.
