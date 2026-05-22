---
name: dbt-build-model
description: Scaffold a new dbt model with contract, unit test, and model body in the right order. Seeded from dbt-labs/dbt-agent-skills (Feb 9 2026).
---

## When to use

When adding any new dbt model at the staging layer or above.

## How

Run the standard dbt build cycle for one model:

```bash
# 1. Author the contract first (see dbt-contract-first skill).
# 2. Author the unit test second (see dbt-unit-tests skill).
# 3. Author the model body third.
# 4. Build:
dbt parse                                  # contracts checked
dbt unit-test --select <model>             # unit tests pass
dbt build --select <model>+1               # model + immediate downstream rebuild
```

The model is "done" only when `dbt parse` is warning-free, `dbt unit-test`
passes, and `dbt build --select <model>+1` succeeds — the `+1` rebuilds
the immediate downstream, catching downstream contract breaks.

## Anti-patterns this skill prevents

- Model bodies written before contracts.
- Contracts that mismatch the SELECT (caught by `dbt parse`).
- Downstream contract breaks discovered in production (the `+1` rebuild
  surfaces them at PR time).
