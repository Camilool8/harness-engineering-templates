---
name: devops-addon-argo-cd
description: Argo CD 3.x conventions — ApplicationSet cluster-version label format, Source Hydrator + GitOps Promoter for tamper-evident staging→prod promotion as a PR, and the gitops-promoter agent that writes only to Git. Use when configuring Argo CD applications, ApplicationSets, or GitOps promotion.
---

## Argo CD

- Argo CD 3.x ApplicationSet cluster generators use the
  `argocd.argoproj.io/kubernetes-version` label in `vMajor.Minor.Patch`
  format (the post-3.0 break). Older `Major.Minor` labels are silent
  generator no-ops.
- Use Source Hydrator + GitOps Promoter for tamper-evident promotion
  staging-next → staging → prod. Promotion is a PR, never `kubectl argo
  rollouts promote`.
- `gitops-promoter` writes only to Git — never to the cluster.
