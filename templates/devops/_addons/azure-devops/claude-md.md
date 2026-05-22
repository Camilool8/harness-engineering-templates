## Azure DevOps Pipelines

- Workload Identity Federation is GA and on by default for new service
  connections in 2026. Do not introduce SPN-with-secret connections.
- Template references (`template:`) that resolve to another repository must
  pin `ref:` to a 40-char commit SHA.
- The `ado-agent-in-ci-guard` hook enforces the same agent-in-CI rule as
  the GitHub variant: workflows invoking coding agents may not introduce
  write-scoped tokens (e.g. `persistCredentials: true`).
