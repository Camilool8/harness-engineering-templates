---
name: dbt-metricflow
description: Define semantic-layer entities, measures, dimensions, and metrics in the MetricFlow shape. Seeded from dbt-labs/dbt-agent-skills (Feb 9 2026).
---

## When to use

When defining a new metric (always via the semantic-modeler agent), or
when adding a new semantic model to surface a previously un-modeled
table.

## How

In `models/semantic/<entity>.yml`:

```yaml
semantic_models:
  - name: orders
    description: One row per customer order, post-deduplication.
    model: ref('fct_orders')
    entities:
      - name: order_id
        type: primary
        expr: order_id
      - name: customer_id
        type: foreign
        expr: customer_id
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
      - name: status
        type: categorical

metrics:
  - name: gross_revenue
    type: simple
    label: Gross revenue (USD)
    description: Sum of order_total_usd across orders. Gross of returns.
    type_params:
      measure:
        name: gross_revenue_usd

  - name: orders_per_customer
    type: ratio
    label: Orders per customer
    description: order_count divided by distinct customer count.
    type_params:
      numerator: order_count
      denominator: customer_count
```

## Anti-patterns this skill prevents

- Metrics defined twice — once in MetricFlow, once inline in a mart.
- Missing `description:` — text-to-SQL via the dbt MCP needs the
  description to pick the right metric.
- Time-grain implicit — every time dimension declares its
  `time_granularity`.
