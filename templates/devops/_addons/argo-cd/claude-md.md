## Argo CD

- Argo CD 3.x ApplicationSet cluster generators use the
  `argocd.argoproj.io/kubernetes-version` label in `vMajor.Minor.Patch`
  format (the post-3.0 break). Older `Major.Minor` labels are silent
  generator no-ops.
- Use Source Hydrator + GitOps Promoter for tamper-evident promotion
  staging-next → staging → prod. Promotion is a PR, never `kubectl argo
  rollouts promote`.
- `gitops-promoter` writes only to Git — never to the cluster.
