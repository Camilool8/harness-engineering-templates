# DevOps — infrastructure sub-domain

Cloud resources provisioned and/or operated via IaC. The workflow shape —
publish reusable modules, operate dev/staging/prod environments, or both — is
selected by addon.

## Adopt if

- You provision cloud resources from code (Terraform, OpenTofu, Pulumi).
- You ship to one or more clouds (AWS, Azure, GCP); single-cloud and
  multi-cloud are both supported by addons.
- Your primary concerns are plan freshness, OIDC-only credentials, drift
  surfacing, and (if operating environments) cost control + two-key gating
  on prod.

## Skip if

- You operate a Kubernetes cluster as your primary deliverable → use
  `kubernetes-platform`.
- You ship reusable CI/CD workflows for many teams → use `cicd-platform`.
- You operate the observability stack → use `observability-sre`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `terraform` | You write Terraform or OpenTofu (one addon covers both). |
| `pulumi` | You write Pulumi (any language). |
| `aws` / `azure` / `gcp` | Add one per cloud you target. |
| `reusable-modules` | You publish modules consumed by ≥2 teams; semver-stable; adds the `contract-tester` agent and Cosign-sign-module workflow. |
| `multi-env-state` | You operate dev/staging/prod from per-env state; adds the `drift-surfacer` agent, cost-gate hook, and prod typed-token gate. |
| `sigstore-cosign` | You sign published module artifacts (typically with `reusable-modules`). |

## Agent team

| Agent | Role |
|---|---|
| `infra-architect` | Read-only; returns a typed plan: provider matrix, state layout, module decomposition, variable surface, OIDC trust policy, blast-radius tags. |
| `infra-implementer` | Read-write; implements the architect's plan bounded to files named in the plan; returns diff + summary. Never runs apply. |
| `supply-chain-auditor` | Shared; verifies module artifacts on publish. |
| `cost-auditor` | Shared; runs Infracost against plans (most relevant with `multi-env-state`). |
| `incident-commander` | Shared; orchestrates incident response when infra is the suspected cause. |
