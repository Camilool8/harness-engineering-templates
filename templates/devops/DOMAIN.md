# DevOps domain pack

Curated harness content for DevOps, SRE, and platform engineering teams operating
cloud infrastructure, Kubernetes platforms, CI/CD pipelines, and the observability
stack that supports them.

> **Status: curated three-layer pack** (second after `web/`). Specialised via
> per-cloud, per-IaC, per-CI, per-K8s, and per-observability addons.

## Sub-domain decision guide

| Sub-domain | Adopt if… |
|---|---|
| [`infrastructure`](infrastructure/) | You provision and/or operate cloud resources via IaC — reusable modules, environment state, or both. Workflow shape (publish-modules vs operate-envs) is selected by addon. |
| [`kubernetes-platform`](kubernetes-platform/) | You operate one or more Kubernetes clusters with a GitOps engine and platform addons; you ship a paved path for app teams. |
| [`cicd-platform`](cicd-platform/) | You build reusable workflows, pipeline templates, and release engineering for many teams; supply-chain attestation is a first-class concern. |
| [`observability-sre`](observability-sre/) | You operate the telemetry stack — collection, dashboards, SLOs, alerting, on-call automation; AI agents reach production via MCP. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance and the curated agent team.

## Addons

Composable extras declared in `domain.addons`. Each sub-domain config ships sensible defaults; override as needed.

| Addon | Pairs with | Purpose |
|---|---|---|
| `aws` | `infrastructure`, `kubernetes-platform`, `cicd-platform` | AWS-specific defaults (STS ≤15 min, AFT bootstrap, IRSA), AWS MCP wiring. |
| `azure` | same | Azure-specific defaults (WIF GA, Bicep notes), Azure MCP Server wiring. |
| `gcp` | same | GCP-specific defaults (WIF, GitLab issuer support), Cloud Build OIDC. |
| `terraform` | `infrastructure` | Terraform + OpenTofu; native `.tftest.hcl` first, Terratest for cloud e2e. |
| `pulumi` | `infrastructure` | Pulumi ESC dynamic creds; `pulumi convert --from terraform` (CDKTF EoL). |
| `reusable-modules` | `infrastructure` | Semver-publish workflow; Cosign-sign module artifacts; `contract-tester` agent. |
| `multi-env-state` | `infrastructure` | Per-env state; two-key on prod; cost gates; `drift-surfacer` agent. |
| `github-actions` | `cicd-platform`, any | OIDC-only, 40-char SHA-pinning, agent-in-CI guard. |
| `azure-devops` | `cicd-platform`, any | WIF GA defaults; template SHA-pinning; agent-in-CI guard. |
| `gitlab-ci` | `cicd-platform`, any | ID-tokens (JWT); `include:project` SHA-pinning; agent-in-CI guard. |
| `argo-cd` | `kubernetes-platform` | Argo CD 3.x defaults; `gitops-promoter` agent. |
| `kyverno` | `kubernetes-platform` | Kyverno 1.13+ `ValidatingPolicy`; `policy-author` agent; manifest-validate hook. |
| `opentelemetry` | `observability-sre`, any | OTel Collector pipeline validation; SemConv 1.41. |
| `datadog` | `observability-sre` | Datadog MCP (GA Mar 9 2026) wiring. |
| `sigstore-cosign` | `cicd-platform`, `infrastructure` (via `reusable-modules`) | SLSA L3 keyless via OIDC; Rekor inclusion verify. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`_addons/`](_addons/).

## Assemble

The sub-domain config is the assemble unit. Pass it directly to `assemble.sh`:

```bash
./assemble.sh devops/infrastructure/harness.config.yml ./my-platform
./assemble.sh devops/kubernetes-platform/harness.config.yml ./my-cluster
./assemble.sh devops/cicd-platform/harness.config.yml ./my-pipelines
./assemble.sh devops/observability-sre/harness.config.yml ./my-observability
```

## See also

- [`docs/how-to/pick-a-recipe.md`](../../docs/how-to/pick-a-recipe.md) — decision flow including the sub-domain choice.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain and addon catalog.
- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §3 — engineering guide for the DevOps / SRE / Platform domain.
- [`references.md`](references.md) — curated devops dossier (refresh quarterly).
