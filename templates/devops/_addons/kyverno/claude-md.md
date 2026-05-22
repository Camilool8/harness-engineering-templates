## Kyverno

- Kyverno 1.13+ `ValidatingPolicy` compiles to in-tree
  `ValidatingAdmissionPolicy` — prefer for new rules.
- Kyverno `generate` rules + Argo CD pruning fight each other: generated
  child resources get pruned each reconcile unless explicitly excluded.
- The `manifest-validate` hook runs kubeconform → kube-linter → Kyverno
  on a 10s budget on every YAML write under a K8s manifest path.
