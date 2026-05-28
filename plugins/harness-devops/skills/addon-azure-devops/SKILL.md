---
name: devops-addon-azure-devops
description: Azure DevOps Pipelines conventions — Workload Identity Federation over SPN-with-secret, 40-char SHA-pinned cross-repo template refs, and the ado-agent-in-ci-guard rule forbidding write-scoped tokens in agent-invoking pipelines. Use when authoring Azure Pipelines YAML.
---

## Azure DevOps Pipelines

- Workload Identity Federation is GA and on by default for new service
  connections in 2026. Do not introduce SPN-with-secret connections.
- Template references (`template:`) that resolve to another repository must
  pin `ref:` to a 40-char commit SHA.
- The `ado-agent-in-ci-guard` hook enforces the same agent-in-CI rule as
  the GitHub variant: workflows invoking coding agents may not introduce
  write-scoped tokens (e.g. `persistCredentials: true`).
