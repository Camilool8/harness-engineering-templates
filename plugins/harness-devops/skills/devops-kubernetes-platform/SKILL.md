---
name: devops-kubernetes-platform
description: Conventions for operating a Kubernetes cluster or fleet with a GitOps engine, platform addons, and a paved-path manifest set for application teams. Use when .claude/HARNESS.toml selects devops/kubernetes-platform, or when working on K8s manifests where the agent writes to Git not the cluster, runs a kubeconform → kube-linter → policy pipeline, and respects production context guards.
---

# DevOps — kubernetes-platform

### GitOps cardinal rule
- The agent writes to Git, never to the cluster. `kubectl apply` against a
  cluster reconciled by Argo CD / Flux is denied by the
  `kubectl-context-guard` hook.
- Promotion happens via Argo Rollouts `AnalysisRun`, NEVER via agent-issued
  `kubectl argo rollouts promote`.

### Manifest pipeline
- Every YAML write runs kubeconform → kube-linter → Kyverno
  ValidatingPolicy. A failure blocks "done".

### Cluster context discipline
- Production contexts (`*prod*`, `*prd*`, `*production*`) block delete,
  drain, cordon, scale-to-zero, and any apply/replace/create without
  `--dry-run=server`.
- Nuclear patterns — `delete namespace/pvc/pv/crd`, `--all`,
  `--all-namespaces` — are blocked unconditionally on prod.

### Addons
- Argo CD 3.x ApplicationSet cluster-version label uses `vMajor.Minor.Patch`
  (post-3.0 break); see the `argo-cd` addon for details.
- Kyverno 1.13+ `ValidatingPolicy` compiles to in-tree
  `ValidatingAdmissionPolicy`; prefer it over older `ClusterPolicy` for
  new rules.

### Done criteria
- A change is not done until: PR opened against the GitOps repo, manifest
  pipeline passes, Argo `AnalysisRun` (if applicable) passes, the cluster
  has reconciled.
