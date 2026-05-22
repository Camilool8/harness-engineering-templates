## DevOps — cicd-platform

### OIDC, always
- No static cloud credentials in any workflow file. Use `id-token: write`
  + `configure-aws-credentials` (or the cloud equivalent) for short-lived,
  role-assumed credentials.

### SHA pinning
- Every `uses:` / `include:` / `template:` reference pins a 40-char commit
  SHA. Tags can be force-pushed (the Trivy March 2026 compromise rewrote
  76/77 version tags; Dependabot did not catch it).

### Supply chain
- Generate SBOMs as in-toto attestations: CycloneDX 1.7+ or SPDX 3.0.1+.
- Sign with `cosign sign --keyless` + verify Rekor inclusion. The
  `cosign-tlog-required` hook refuses `--insecure-ignore-tlog`.
- Use `actions/attest-build-provenance@v2` for SLSA L3 (GitHub) or the
  cloud-specific equivalent.

### Agents in CI
- Any workflow that invokes a coding agent (claude-code, copilot-cli,
  gemini-cli, openai/codex) must use `permissions: { contents: read }`
  only and OIDC for any state-mutating step. Read-only `GITHUB_TOKEN` is
  necessary but not sufficient — the agent-in-CI guard hook enforces this.

### Reusable workflows
- `secrets: inherit` exposes every org secret to the called workflow; the
  called workflow must be SHA-pinned and reviewed as production code.

### Done criteria
- A workflow change is not done until: SHA-pin verified, OIDC trust
  policy reviewed, SLSA provenance produced + verifiable, supply-chain
  auditor PASS.
