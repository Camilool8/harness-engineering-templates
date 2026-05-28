---
name: devops-addon-gcp
description: GCP conventions — Workload Identity Federation via a Workload Identity Pool with attribute conditions, GitLab as a GA WIF issuer, GKE Workload Identity over node-service-account keys, and env/blast-radius project tagging. Use when targeting GCP for IaC, CI/CD trust, or GKE.
---

## GCP

- Workload Identity Federation: federate the CI's OIDC issuer to a
  Workload Identity Pool; attribute conditions scope by repo/branch.
- GitLab as a WIF issuer is GA in 2026; attribute mapping supports org-id
  and project-path.
- GKE: prefer Workload Identity (GA) over node-service-account keys.
- Tag every project: `env:dev|staging|prod` and
  `blast-radius:low|med|high|nuclear`.
