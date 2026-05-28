---
name: semantic-layer-as-source-of-truth
description: Every metric defined exactly once, in the semantic layer manifest. The semantic-modeler agent (from dbt-core addon) enforces.
---

## When to use

When defining a new metric, or when you see a metric being computed
ad-hoc in a mart or report.

## How

### Define in the semantic-layer manifest

In `models/semantic/<entity>.yml`:

```yaml
semantic_models:
  - name: orders
    model: ref('fct_orders')
    entities:
      - name: order_id
        type: primary
      - name: customer_id
        type: foreign
    measures:
      - name: order_count
        expr: 1
        agg: sum
      - name: gross_revenue_usd
        expr: order_total_usd
        agg: sum
    dimensions:
      - name: ordered_at
        type: time
        type_params:
          time_granularity: day

metrics:
  - name: gross_revenue
    type: simple
    label: Gross revenue (USD)
    description: Sum of order_total_usd, gross of returns and refunds.
    type_params:
      measure: gross_revenue_usd
```

### Consume from BI / LLM / ad-hoc

- BI tools query via the dbt Semantic Layer (`mf query` or vendor
  integrations) — never raw SQL over the marts.
- LLM apps query via the semantic-layer surface; the dbt remote MCP
  exposes it.
- Ad-hoc analysts query via `dbt semantic-layer` or `mf query`; never
  re-derive a metric in a notebook.

## Anti-patterns this skill prevents

- "Revenue" defined three different ways across BI / report / notebook.
- LLM text-to-SQL hallucinating column names because there is no
  governed metric surface.
- New metrics added in marts instead of the semantic layer — the
  `semantic-modeler` agent (from `dbt-core` addon) refuses these PRs.
