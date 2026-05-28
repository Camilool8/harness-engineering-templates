---
name: sample-then-scale
description: Run LIMIT 1000 / TABLESAMPLE first, inspect dtypes and shape, then graduate to the full query. The block-unbounded-sql hook rejects the unscoped form.
---

## When to use

Every warehouse query. No exceptions.

## How

1. **Start scoped.** Append `LIMIT 1000` to any new `SELECT`. For warehouses
   that support it, prefer `TABLESAMPLE BERNOULLI(1)` over `LIMIT` — it
   surfaces row diversity that `LIMIT` may hide.
2. **Inspect.** Print shape + dtypes + head. Verify the join cardinality
   matches your mental model. Verify nullability where it matters.
3. **Estimate full-scale cost.** For warehouses with EXPLAIN, run it; for
   others, multiply: full-rows × cost-per-row-from-sample.
4. **Graduate.** Remove the `LIMIT` only after the inspection passes and
   the estimated cost is within budget.

## Anti-patterns this skill prevents

- The 200M-row `SELECT * FROM events` that doubles the warehouse bill.
- Joins whose cardinality blows up by 10× because a key wasn't unique.
- "It looked fine on 5 rows" — `LIMIT 5` hides distribution problems.

## Hook backing

The `block-unbounded-sql` shared hook (PreToolUse on Bash + warehouse-MCP)
will reject an unscoped `SELECT`. Do not try to bypass; fix the query.
