---
name: three-tier-eval
description: The assertion → judge → human eval ladder per Husain & Shankar (Jan 15 2026). No higher tier without the lower tier populated.
---

## When to use

When starting any LLM eval suite, or when adding a new behavior surface
to an existing one.

## The ladder

### Tier 1 — Assertion

Cheap, deterministic, multi-test-corrected. Examples:

- Output is valid JSON.
- Output matches a regex.
- Output's length is within a budget.
- Output contains / excludes specific tokens.
- Output's structured fields satisfy a Pydantic schema.

When a loop runs multiple p-value-style tests, apply
`statsmodels.stats.multitest.multipletests` with `method='bh'`
(Benjamini-Hochberg) or `method='bonferroni'`.

### Tier 2 — LLM judge

Cross-family judge. Examples:

- Judge model from family B scores generator-model-family-A outputs on
  rubric criteria.
- Pairwise A/B preference between two prompt variants.

The `judge-runner` agent refuses if `LLM_MODEL_ID` and
`JUDGE_MODEL_ID` families match.

### Tier 3 — Human review

Sampled. Examples:

- 1% of production traffic flagged for human label.
- All major prompt diffs get N (e.g. 50) human labels before merge.

## Order

1. Build Tier 1 first. It is cheap and catches most regressions.
2. Add Tier 2 only when Tier 1 cannot capture the behavior surface
   (semantic correctness, style adherence).
3. Add Tier 3 only when Tier 2 is unreliable (high judge variance) or
   the decision is high-stakes (production rollout).

The `llm-app-architect` agent refuses to design Tier N if Tier (N-1)
does not exist.

## Anti-patterns this skill prevents

- "I'll just use a judge" — judge variance dominates without an
  assertion floor.
- Same-family judge — 10–25% self-preference bias makes it useless.
- Unlabeled Tier 3 — humans label whatever they feel like, not the
  decision criteria.
