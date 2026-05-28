---
name: devops-addon-github-actions
description: GitHub Actions conventions — job_workflow_ref-pinned OIDC trust, 40-char SHA-pinning of every uses (enforced client-side by gha-sha-pin-actions), SLSA L3 via attest-build-provenance v2, secrets-inherit hardening, and the gha-agent-in-ci-guard rule. Use when authoring GitHub Actions workflows.
---

## GitHub Actions

- OIDC trust: cloud trust policies pin `job_workflow_ref` to the exact
  workflow path so only approved central workflows can mint prod creds.
  Avoid `repo:org/*` patterns — they are an audit finding.
- SHA-pin every `uses:` reference to a 40-char hex SHA. The Aug 15 2025
  enforcement policy lets enterprise/org admins enforce this; the
  `gha-sha-pin-actions` hook also enforces it client-side.
- Use `actions/attest-build-provenance@v2` for SLSA L3 provenance.
- Reusable workflows with `secrets: inherit` expose every org secret to
  the called workflow — SHA-pin it and review it as production code.
- If a workflow invokes a coding agent (claude-code, copilot-cli,
  gemini-cli, openai/codex), it must declare `permissions: { contents: read }`
  only; any state-mutating step uses OIDC. The `gha-agent-in-ci-guard` hook
  enforces this.
