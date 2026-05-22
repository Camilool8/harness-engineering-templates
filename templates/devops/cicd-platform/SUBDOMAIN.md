# DevOps — cicd-platform sub-domain

Reusable workflows, pipeline templates, and release engineering for many
teams. Supply-chain attestation (SBOM + signature + Rekor + SLSA L3
provenance) is a first-class concern.

## Adopt if

- You build reusable workflows / pipeline templates consumed by other teams.
- You own release engineering: artifact signing, SBOM generation, SLSA
  provenance, version bumping, changelog automation.
- You enforce OIDC over static cloud keys across all CI runs.

## Skip if

- You only consume reusable workflows — you are an app team, not a platform
  team → no devops harness needed.
- Your deliverable is the K8s platform — use `kubernetes-platform`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `github-actions` | Day-1 default for any GitHub-hosted repo. |
| `azure-devops` | Add when targets include Azure Pipelines. |
| `gitlab-ci` | Add when targets include GitLab CI/CD. |
| `sigstore-cosign` | Day-1 for SLSA L3 keyless signing. |
| `aws` / `azure` / `gcp` | The cloud(s) the pipeline deploys to (OIDC trust policies). |

## Agent team

| Agent | Role |
|---|---|
| `pipeline-architect` | Read-only; plans workflow decomposition, OIDC trust mapping, supply-chain attestation chain, version-bump strategy. |
| `workflow-implementer` | Read-write bounded to workflow files; implements the plan. |
| `release-engineer` | Read-write bounded to release configs; never promotes across env boundaries without typed-token. |
| `supply-chain-auditor` | Shared. |
| `incident-commander` | Shared. |
