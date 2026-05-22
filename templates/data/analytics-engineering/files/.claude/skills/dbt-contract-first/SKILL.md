---
name: dbt-contract-first
description: Write the model contract (column types + constraints) before the model body. Every staging+ model declares contract.enforced true.
---

## When to use

When adding any new dbt model at the staging layer or above.

## How

### Step 1 — Author the contract

In `models/<layer>/<model>.yml`:

```yaml
version: 2

models:
  - name: stg_orders
    config:
      contract:
        enforced: true
    columns:
      - name: order_id
        data_type: bigint
        constraints:
          - type: not_null
          - type: unique
      - name: customer_id
        data_type: bigint
        constraints:
          - type: not_null
          - type: foreign_key
            expression: stg_customers (customer_id)
      - name: order_total_usd
        data_type: numeric(12, 2)
        constraints:
          - type: not_null
      - name: ordered_at
        data_type: timestamp
        constraints:
          - type: not_null
```

### Step 2 — Author the unit test

In `tests/unit/test_<model>.yml`:

```yaml
unit_tests:
  - name: test_stg_orders_normalizes_amount
    model: stg_orders
    given:
      - input: ref('raw_orders')
        rows:
          - { order_id: 1, customer_id: 10, raw_amount_cents: 12345, ordered_at: '2026-01-01' }
    expect:
      rows:
        - { order_id: 1, customer_id: 10, order_total_usd: 123.45, ordered_at: '2026-01-01' }
```

### Step 3 — Author the model body

Only after contract and unit test exist:

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

select
  order_id,
  customer_id,
  raw_amount_cents / 100.0 as order_total_usd,
  ordered_at
from {{ ref('raw_orders') }}
```

### Step 4 — Verify

```bash
dbt parse                       # contracts checked
dbt unit-test --select stg_orders   # unit test passes
dbt compile --select stg_orders     # model compiles
```

## Anti-patterns this skill prevents

- Contract drift via "let me fix this later" model edits.
- Unit tests written after the fact to match a broken model.
- Implicit type coercion that breaks downstream consumers silently.
