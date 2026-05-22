# DevOps — cicd-platform reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **Pin every action and reusable workflow to a 40-char SHA, not a tag.** GitHub policy now lets enterprise/org admins *enforce* this (Aug 15 2025); the trivy-action March 2026 incident is exhibit A for why.
- **Default vulnerability scanning stack: Checkov (IaC), Grype (images), Syft (SBOM generation), Cosign (signing).** Aqua's Trivy ecosystem was compromised twice in March 2026; even with Aqua's clean-up, supply-chain risk-tolerance puts it behind alternatives for new pipelines.
- **Achieve SLSA Level 3 with `actions/attest-build-provenance@v2` + Cosign keyless signing via OIDC.** What was a multi-week project in 2024 is now an afternoon.
- **Generate CycloneDX 1.6+ or SPDX 3.0.1+ SBOMs as in-toto attestations** — both satisfy EU CRA Annex VII (vulnerability-reporting kicks in Sept 2026; manufacturer obligations Dec 2027). CycloneDX 1.7 (Mar 2026) adds TLP distribution constraints.
- **Reusable workflow OIDC: enforce `job_workflow_ref` claim** in the cloud trust policy so only approved central workflows can mint prod creds.
- **For container-build-heavy monorepos, Bazel + `rules_oci` 2.x is the modern path; `rules_docker` is deprecated.** `rules_oci` 2.3 ships `bzlmod` MODULE.bazel registration.

## Common gotchas / failure modes

- **AI agents called from inside CI hold elevated tokens and read untrusted PR/issue content.** The "Comment and Control" / PromptPwnd attack class (Apr 2026) showed Copilot Coding Agent, Gemini CLI, Claude Code, OpenAI Codex, and GitHub AI Inference all exfiltrating tokens via a single malicious issue comment. Read-only `GITHUB_TOKEN` is necessary but not sufficient.
- **Tag-rewrites are not detected by Dependabot** — the trivy-action attacker force-pushed 76/77 version tags; pin to a 40-char SHA or you would still be on a malicious commit even with up-to-date scanning.
- **Cosign keyless `verify` without Rekor transparency log check is meaningless** — `--insecure-ignore-tlog` defeats the entire keyless model; common in air-gapped policy templates.
- **Provenance attestations against multi-arch images break** if you sign the index but verify the manifest; verify both, or attach the attestation to the index digest specifically.
- **Reusable workflow `secrets: inherit` exposes every org secret** to the called workflow — SHA-pin it and review it as production code.

## Version-sensitive notes

- **GitHub Actions SHA-pinning policy enforcement is GA as of Aug 15 2025**; workflow-lockfile (`actions.lock`-style) is on the 2026 roadmap.
- **GitHub OIDC custom property claims GA Apr 2 2026** — lets you encode environment/owner in the OIDC token for finer-grained cloud trust policies.
- **`actions/attest-build-provenance@v2`** is the SLSA L3 path on GitHub; v1 lacked subject-digest verification on multi-arch.
- **Trivy safe versions** (post-incident): binary ≤ `v0.69.3`; `trivy-action@v0.35.0` (commit `57a97c7`); `setup-trivy@v0.2.6` (commit `3fb12ec`). Anything between v0.69.4 and the rollback is malicious.

## Cited links

- [Microsoft Security: Defending against the Trivy supply chain compromise (Mar 24 2026)](https://www.microsoft.com/en-us/security/blog/2026/03/24/detecting-investigating-defending-against-trivy-supply-chain-compromise/) — authoritative incident response.
- [CrowdStrike: From Scanner to Stealer — trivy-action compromise](https://www.crowdstrike.com/en-us/blog/from-scanner-to-stealer-inside-the-trivy-action-supply-chain-compromise/) — attack-chain technical detail.
- [Aqua security advisory GHSA-69fq-xp46-6x23](https://github.com/aquasecurity/trivy/security/advisories/GHSA-69fq-xp46-6x23) — vendor advisory + safe versions.
- [GitHub Changelog: SHA-pinning policy enforcement](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/) — primary source for policy GA.
- [GitHub secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use) — `job_workflow_ref` and OIDC claim hardening.
- [Sigstore Cosign keyless + GitHub Actions OIDC guide](https://www.qcecuring.com/blog/sigstore-cosign-keyless-github-actions) — end-to-end SLSA L3 walkthrough.
- [CycloneDX 1.7 release notes (Mar 25 2026)](https://docs.sbom.observer/release-notes/2026-03-25-cyclonedx-1.7) — TLP distribution constraints.
- [rules_oci on Bazel Central Registry](https://registry.bazel.build/modules/rules_oci) — version-of-truth for bzlmod consumers.
