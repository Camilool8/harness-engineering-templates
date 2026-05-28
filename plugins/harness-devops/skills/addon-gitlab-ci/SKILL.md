---
name: devops-addon-gitlab-ci
description: GitLab CI/CD conventions — cloud auth via GitLab ID tokens (JWT) with project/group/branch/tag conditional trust, 40-char SHA-pinned include refs, minimal job-token scope, and the gitlab-agent-in-ci-guard rule. Use when authoring .gitlab-ci.yml pipelines.
---

## GitLab CI/CD

- Authenticate to clouds via GitLab ID tokens (JWT). Conditional trust on
  project/group/branch/tag.
- Every `include:project` / `include:remote` reference pins `ref:` to a
  40-char commit SHA.
- `job-token:` scope: only required projects; never broadcast.
- The `gitlab-agent-in-ci-guard` hook enforces the agent-in-CI rule:
  pipelines invoking coding agents must not grant write-scoped tokens.
