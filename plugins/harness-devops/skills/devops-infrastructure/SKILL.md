---
name: devops-infrastructure
description: Conventions for cloud resources provisioned and operated via IaC (Terraform, OpenTofu, Pulumi) across one or more clouds. Use when .claude/HARNESS.toml selects devops/infrastructure, or when writing IaC where plan freshness, OIDC-only credentials, drift surfacing, per-env state isolation, cost control, and two-key prod gating are the primary concerns.
---

# DevOps — infrastructure

### Plan first, apply never
- The agent runs `terraform plan` / `tofu plan` / `pulumi preview` only.
  Apply is a human or CI action; the `plan-before-apply` hook enforces a
  ≤15-minute plan freshness window.
- A plan that touches a protected resource type (databases, stateful
  buckets, KMS keys) for destruction is blocked unconditionally.

### State layout
- One backend per environment; never share remote state across env tiers.
- State files contain secrets — backend access is OIDC-scoped, never with
  static cloud keys.
- Lock collisions abort the agent loop. Do not retry over an in-flight
  human-initiated operation.

### Variables and naming
- Required variables have no defaults — fail loud at plan time, not at
  apply time. Optional variables have explicit `default` values.
- Resource names are deterministic from inputs (no random suffixes in
  modules consumed by multiple environments).

### Drift
- Drift is surfaced and explained. It is NEVER autonomously remediated —
  drift may be intentional.

### Done criteria
- A change is not done until: plan reviewed, all policy checks pass
  (Checkov / OPA), Infracost delta within budget, supply-chain-auditor
  has verified any new module artifacts.
