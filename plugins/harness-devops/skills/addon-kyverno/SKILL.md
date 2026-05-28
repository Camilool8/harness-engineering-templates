---
name: devops-addon-kyverno
description: Kyverno conventions — 1.13+ ValidatingPolicy compiling to in-tree ValidatingAdmissionPolicy for new rules, the generate-rule vs Argo CD pruning conflict, and the manifest-validate hook running kubeconform → kube-linter → Kyverno on YAML writes. Use when authoring Kyverno policies.
---

## Kyverno

- Kyverno 1.13+ `ValidatingPolicy` compiles to in-tree
  `ValidatingAdmissionPolicy` — prefer for new rules.
- Kyverno `generate` rules + Argo CD pruning fight each other: generated
  child resources get pruned each reconcile unless explicitly excluded.
- The `manifest-validate` hook runs kubeconform → kube-linter → Kyverno
  on a 10s budget on every YAML write under a K8s manifest path.
