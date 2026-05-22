# DevOps — kubernetes-platform sub-domain

A Kubernetes cluster (or fleet) + GitOps engine + platform addons + a paved
path of reusable manifests for application teams.

## Adopt if

- You operate one or more K8s clusters as your primary deliverable.
- You use Argo CD or Flux as the reconciler.
- You ship a manifest pipeline (kubeconform → kube-linter → policy) and the
  agent never mutates the cluster directly.

## Skip if

- You consume a managed K8s service for one app and don't operate the
  platform → use `infrastructure` + the relevant cloud addon.
- Your deliverable is reusable CI workflows → use `cicd-platform`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `aws` / `azure` / `gcp` | The cloud the cluster runs on; brings cloud-specific gates (e.g. EKS version EOL). |
| `argo-cd` | Argo CD as the GitOps engine; adds the `gitops-promoter` agent. |
| `kyverno` | Policy enforcement via Kyverno 1.13+ ValidatingPolicy; adds the `policy-author` agent and the manifest-validate hook. |

## Agent team

| Agent | Role |
|---|---|
| `k8s-architect` | Read-only; plans cluster topology, namespace partition, addon set, RBAC, network policy, resource quotas, the paved-path manifest set. |
| `manifest-implementer` | Read-write bounded to a single namespace per invocation; writes/edits YAML; runs validate pipeline. |
| `incident-commander` | Shared. |
| `cost-auditor` | Shared. |
