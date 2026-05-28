---
name: devops-addon-multi-env-state
description: Multi-environment state conventions — one backend and one STS session per env tier with no credential reuse, per-env cost budgets, drift surfaced never remediated via drift-surfacer, and the typed-token confirmation card for prod-touching applies. Use when operating dev/staging/prod from per-env IaC state.
---

## Multi-env state

- One backend per environment. Never share remote state across env tiers.
- Per-env state files have per-env STS sessions; never reuse credentials
  across env tiers.
- Cost budgets: default $100/month delta for non-prod, $500/month for prod
  (override via `policy/cost.rego`).
- Drift is surfaced, never remediated. The `drift-surfacer` agent reports;
  a human decides.
- Prod-touching applies require the typed-token confirmation card. A single
  "y" is insufficient — the token requirement defeats reflexive approval.
