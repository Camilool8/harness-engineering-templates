---
name: dbt-unit-tests
description: Write dbt unit-test specs with given/when/expect shape. Seeded from dbt-labs/dbt-agent-skills (Feb 9 2026).
---

## When to use

For every model at staging+ level, before writing the model body.

## How

In `tests/unit/test_<model>.yml`:

```yaml
unit_tests:
  - name: test_<model>_handles_nulls
    model: <model>
    given:
      - input: ref('<upstream_model>')
        rows:
          - { col1: 1, col2: null, col3: 'x' }
          - { col1: 2, col2: 5,    col3: 'y' }
    expect:
      rows:
        - { col1: 1, col2_filled: 0, derived_col: 'x' }
        - { col1: 2, col2_filled: 5, derived_col: 'y' }

  - name: test_<model>_dedupes_on_natural_key
    model: <model>
    given:
      - input: ref('<upstream_model>')
        rows:
          - { id: 1, updated_at: '2026-01-01', val: 'old' }
          - { id: 1, updated_at: '2026-01-02', val: 'new' }
    expect:
      rows:
        - { id: 1, updated_at: '2026-01-02', val: 'new' }
```

Run:

```bash
dbt unit-test --select <model>
```

Each `name:` should describe the **invariant** the test protects
(handles nulls, dedupes on natural key, preserves currency-of-units).

## Anti-patterns this skill prevents

- Unit tests written after the model "to match" — tests that confirm
  what the model does, not what it should do.
- Tests that fixture so much data that the test reads like a small
  benchmark. Keep fixtures to 2–5 rows that exercise one invariant.
- "Happy path only" — every model has at least one null / boundary /
  duplicate adversarial case.
