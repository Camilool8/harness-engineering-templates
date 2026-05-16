---
name: validating-strategies
description: Validates a quantitative strategy or model before any human sign-off. Use when backtesting or evaluating a strategy — enforce point-in-time data, combinatorial purged CV, the Deflated Sharpe Ratio for multi-trial work, and survivorship-aware universes.
---

# Validating strategies

The highest observed Sharpe across many random strategies is positive even when
every true Sharpe is zero (the False Strategy Theorem). A backtest is evidence
only if it survives this checklist. The agent drafts the validation; a human
signs off on the result.

## Point-in-time data

- Every dataset must carry an `as_of_date` / `knowledge_date`. If the schema
  has no such column, refuse the dataset — you cannot prove the feature was
  knowable at decision time.
- Restatements, late-arriving fundamentals, and index reconstitutions must be
  applied as of when they were *known*, not when they were *true*.

## Cross-validation — CPCV, not just walk-forward

- Walk-forward alone gives a single high-variance path. Use **Combinatorial
  Purged Cross-Validation**: it embargoes overlapping samples and yields a
  distribution of out-of-sample paths.
- Never `train_test_split(shuffle=True)` or `KFold(shuffle=True)` on
  time-indexed data — the `lookahead-bias-guard` hook blocks these.

## Multi-trial correction — Deflated Sharpe Ratio

- A single strategy reports a **Probabilistic Sharpe Ratio**.
- The moment more than one configuration was tried, report the **Deflated
  Sharpe Ratio** and the **number of trials**. An uncorrected Sharpe from a
  parameter sweep is not a result.
- Prefer CVaR over VaR for tail-sensitive portfolios.

## Survivorship-aware universes

- Construct the universe against a delisting database; defunct tickers must be
  present for the periods they traded. A survivorship-biased universe
  overstates returns by roughly 1–4% per annum.

## Rules

- No strategy is "validated" without: PIT data, a CPCV path distribution, a
  Deflated Sharpe (if multi-trial) with trial count, and a survivorship-aware
  universe.
- The agent never approves its own strategy — it assembles the evidence; a
  human signs off.
