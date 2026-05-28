---
name: devops-addon-aws
description: AWS conventions — 15-minute STS session ceiling, AFT-on-Control-Tower account bootstrap, EKS Pod Identity over IRSA, OIDC trust federated to STS with tight sub-claim scope, and env/blast-radius account tagging. Use when targeting AWS for IaC, CI/CD trust policies, or EKS.
---

## AWS

- STS session duration: 900 s (15 min) maximum. Refuse credentials older.
- Account bootstrap: AFT on Control Tower; never hand-roll AWS Organizations.
- EKS to a Pod: IRSA (existing) or EKS Pod Identity (preferred in 2026).
- OIDC trust: federate the CI's OIDC issuer to STS; trust policy uses
  `token.actions.githubusercontent.com:sub` (or equivalent) for tight scope.
- Tag every account `env:dev|staging|prod` and `blast-radius:low|med|high|nuclear`;
  PreToolUse hooks read these tags to choose deny rules.
- EKS standard support: track `aws-eks-version-EOL`; 1.32 reached EOL Feb 28 2026.
