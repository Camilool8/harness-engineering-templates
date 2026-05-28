---
name: devops-addon-reusable-modules
description: Reusable IaC module conventions — semver with major bumps for breaking changes, Cosign-signed + Rekor-proofed release artifacts, the tftest-not-apply hook blocking real-cloud test applies, and published SBOMs as in-toto attestations. Use when authoring or publishing modules consumed by multiple teams.
---

## Reusable modules

- Module versioning is semver. Breaking changes (removed input, renamed
  output, changed type) require a major version bump.
- Every release ships a Cosign-signed artifact + Rekor inclusion proof —
  the Trivy March 2026 attack proved that tags can be force-pushed.
- `*.tftest.hcl` defaults to `command = plan`. The `tftest-not-apply` hook
  blocks `command = apply` against non-mock providers (real-cloud bills
  from AI-generated test files).
- Public modules also publish an SBOM (CycloneDX 1.7+ or SPDX 3.0.1+) as
  an in-toto attestation.
