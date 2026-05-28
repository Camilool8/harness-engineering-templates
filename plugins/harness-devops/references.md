# DevOps — reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### Supply-chain posture
- **SLSA Level 3 is the realistic prod bar in 2026.** SLSA L4 remains aspirational because it requires two-person review on the build system itself; few CI vendors implement it. Achieve L3 with `actions/attest-build-provenance@v2` + Cosign keyless signing via OIDC — what was a multi-week project in 2024 is now an afternoon.
- **Default scanner stack: Checkov (IaC), Grype (images), Syft (SBOM generation), Cosign (signing).** Trivy is excluded by default after the March 2026 supply-chain compromises (two waves). Even with Aqua's clean-up, risk-tolerance puts Trivy behind alternatives for new pipelines.
- **SBOM as in-toto attestation.** Generate CycloneDX 1.6+ or SPDX 3.0.1+ — both satisfy EU CRA Annex VII. CycloneDX 1.7 (Mar 25 2026) adds TLP distribution constraints; SPDX 3.0.1 covers license depth. Use both formats only if a regulator forces it.
- **Always verify Rekor transparency-log inclusion** when verifying Cosign signatures. The `--insecure-ignore-tlog` flag defeats the entire keyless trust model and is common in copy-pasted air-gapped templates. The domain-shared `cosign-tlog-required` hook blocks it.

### Credentials — OIDC everywhere
- **GitHub Actions:** OIDC mature; SHA-pinning policy enforcement GA Aug 15 2025; custom property claims GA Apr 2 2026 (encode env/owner in the token for finer-grained cloud trust policies).
- **GitLab CI:** ID-tokens (JWT) GA against AWS/Azure/GCP/Vault, with conditionals on group/project/branch/tag.
- **Azure DevOps:** Workload Identity Federation GA + on-by-default for new service connections (2026); legacy SPN-with-secret is being deprecated.
- **Cross-platform pattern:** federate the CI's OIDC issuer to cloud STS, then assume a role scoped per env. Avoid long assume-role chains > 1 hour.
- Static cloud keys in CI variables are an audit finding under EU AI Act Article 12.

### Agents touch production via MCP, not via console
- **Datadog MCP** (GA Mar 9 2026) is remote-hosted (no local server) with 16+ core tools + APM/Errors/FeatureFlags/DBM/Security/LLM Obs toolsets. **Honeycomb MCP** GA + on AWS Marketplace Mar 11 2026. **New Relic AI MCP** Public Preview → GA mid-2026. **Sentry MCP** exposes Seer root-cause from the IDE. **PagerDuty MCP** exposes 60+ tools incl. `trigger_incident`.
- **Treat MCP servers as first-class IAM endpoints**: rate-limit, scope per-tenant, audit. No per-tenant cost guardrails exist in 2026 MCP implementations — rate-limit at the MCP-server proxy if cost matters.
- MCPs return raw fields by default — **scrub PII and API keys at the source** (the logging library), never at the agent.

### Two-key + typed-token confirmation for prod-touching automation
- **OWASP AI Agent Security Cheat Sheet (2026)** prescribes JIT ephemeral tokens scoped to exact resource+action plus HITL confirmation for state-mutating ops, plus structured decision-metadata logging.
- **Komodor war-room model** routes high-risk actions (DB rollback, traffic shift) through a Main Incident-Commander agent that surfaces a typed-token confirmation card — specialist sub-agents wait. Closest commercial implementation of the two-key pattern.
- Implementation hint: map the agent's MCP tool call → a short-lived signed action token → a Slack/PagerDuty confirmation card → cloud action. Token TTL < 5 min.

## Common gotchas / failure modes

- **Agent-in-CI prompt injection (2026 attack class).** The "Comment and Control" / PromptPwnd attack (Aikido Apr 2026; CSA research note May 3 2026) showed Copilot Coding Agent, Gemini CLI, Claude Code, OpenAI Codex, and GitHub AI Inference all exfiltrating tokens via a single malicious PR/issue comment. Read-only `GITHUB_TOKEN` is necessary but not sufficient — the leaked token need not be the workflow's own, it can be any cloud creds the agent has access to via OIDC. Sandbox the agent process; tool-allowlist at the MCP-server layer; treat untrusted content as data, never as instructions.
- **Tag-rewrites are not detected by Dependabot.** The trivy-action attacker force-pushed 76/77 version tags; pin to a 40-char SHA or you would still be on a malicious commit even with up-to-date scanning. The CI addons enforce SHA-pinning client-side.
- **`cosign verify --insecure-ignore-tlog` defeats the keyless model entirely.** Common in air-gapped policy templates. The domain-shared hook refuses it; if you genuinely need an offline path, configure a custom Sigstore trusted root.
- **Reusable-workflow `secrets: inherit` exposes every org secret** to the called workflow. The called workflow must be SHA-pinned and reviewed as production code.
- **Sub-agent credential inheritance defeats attribution.** Each sub-agent must request its own scoped credentials; sharing the parent's IAM principal collapses CloudTrail/EU AI Act auditability.
- **Autonomous drift remediation is itself an anti-pattern.** Drift may be intentional (emergency manual fix pending a PR). The `drift-surfacer` agent surfaces and explains; it never heals.
- **PagerDuty MCP `trigger_incident` has no built-in confirmation flow.** Wrap with a typed-token gate (OWASP cheat-sheet pattern) or a war-room HITL.

## Version-sensitive notes

- **GitHub Actions SHA-pinning policy enforcement: GA Aug 15 2025.** Enterprise/org admins can enforce SHA pins on every `uses:`. Custom property claims for OIDC GA Apr 2 2026.
- **Trivy safe versions (post-compromise):** binary ≤ `v0.69.3`; `trivy-action@v0.35.0` only if pinned to commit `57a97c7`; `setup-trivy@v0.2.6` only if pinned to commit `3fb12ec`. Anything between `v0.69.4` and the rollback is malicious. Better: switch to Checkov (IaC) + Grype (images).
- **CycloneDX 1.7 released Mar 25 2026** — adds TLP distribution constraints. Both CycloneDX 1.6+ and SPDX 3.0.1+ qualify under BSI TR-03183-2 / EU CRA Annex VII.
- **AWS Agent Toolkit MCP GA May 2026.** IAM-gated, CloudWatch + CloudTrail auditable.
- **EU AI Act enforcement begins Aug 2 2026.** Article 12 makes audit-logging of agent-issued commands a regulatory obligation; penalties up to €15M or 3% of worldwide turnover. The harness must default to attributable agent identity, time-bound credentials, and structured logs.
- **`actions/attest-build-provenance@v2`** is the SLSA L3 path on GitHub; v1 lacked subject-digest verification on multi-arch images.

## Cited links

- [Microsoft Security: Defending against the Trivy supply chain compromise (Mar 24 2026)](https://www.microsoft.com/en-us/security/blog/2026/03/24/detecting-investigating-defending-against-trivy-supply-chain-compromise/) — authoritative incident-response narrative + IOC list.
- [Aqua security advisory GHSA-69fq-xp46-6x23](https://github.com/aquasecurity/trivy/security/advisories/GHSA-69fq-xp46-6x23) — vendor advisory + canonical safe-version list.
- [GitHub Changelog: SHA-pinning policy enforcement (Aug 15 2025)](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/) — primary source for the policy GA.
- [GitHub secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use) — `job_workflow_ref` claim hardening + OIDC claim allowlist patterns.
- [Sigstore Cosign keyless + GitHub Actions OIDC end-to-end](https://www.qcecuring.com/blog/sigstore-cosign-keyless-github-actions) — concrete SLSA L3 walkthrough including Rekor verify.
- [CycloneDX 1.7 release notes (Mar 25 2026)](https://docs.sbom.observer/release-notes/2026-03-25-cyclonedx-1.7) — what changed for TLP distribution and crypto fields.
- [OWASP AI Agent Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/AI_Agent_Security_Cheat_Sheet.html) — typed-token / HITL patterns for state-mutating agent actions.
- [Datadog MCP Server GA press release (Mar 9 2026)](https://www.datadoghq.com/about/latest-news/press-releases/datadog-launches-mcp-server/) — feature list, tool counts, official remote endpoint.
- [Cloud Security Alliance: AI in GitHub Actions research note (May 3 2026)](https://cloudsecurityalliance.org/research/) — the "Comment and Control" attack-class write-up affecting Copilot Coding Agent, Gemini CLI, Claude Code, Codex, and GitHub AI Inference.
- [EU AI Act Article 12 — record-keeping requirements](https://artificialintelligenceact.eu/article/12/) — what the Aug 2 2026 enforcement makes mandatory for agent-issued automation.
