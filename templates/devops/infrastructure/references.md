# DevOps — infrastructure reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **Default to native `*.tftest.hcl` for module unit tests; reserve Terratest for end-to-end** (OpenTofu/Terraform 1.6+, still the standard in 2026). Co-locate `*.tftest.hcl` next to `*.tf` files; reach for Terratest in Go only when you need real cloud-API assertions.
- **Static plan scanning before any API call.** Trivy IaC scanning is *not* the safe default after the March 2026 trivy-action tag-rewrite incident; standardise on **Checkov** for IaC plans.
- **Encrypt state at rest using OpenTofu 1.10+ External Key Providers** in production rather than passphrase-only PBKDF2. The 1.11.x branch is supported through Aug 2026 and includes JSON-state-encryption bug fixes.
- **Pulumi ESC with dynamic credentials (AWS/Azure/GCP/Doppler) is the GA pattern for module CI in 2026** — short-lived OIDC-issued creds via `esc run`. Static cloud keys in module CI are an EU AI Act Article 12 audit finding.
- **For multi-module orchestration, prefer Terragrunt 1.x or Terraform Stacks over hand-rolled wrapper scripts.** Terragrunt 1.0 (2026) ships `run`/`exec`/`find`/`list`, the `--filter` system, and a 1.x backwards-compatibility commitment, plus automatic provider caching with OpenTofu 1.10+.
- **Bootstrap multi-account AWS via Control Tower + AFT** (or LZA on AFT) — do not hand-roll AWS Organizations from scratch in 2026. AFT now supports CodeCommit, GitHub, Bitbucket, and GHES as the VCS for account-request repos.

## Common gotchas / failure modes

- **CDKTF migrations are now mandatory work** — repo archived Dec 10 2025; HCL synth via `cdktf synth` then `pulumi convert --from terraform cdktf.out/stacks/*/cdk.tf` is the documented path. Do not assume your coding agent knows it is deprecated.
- **AI agents driving `terraform apply` against shared state are a new failure class.** Concurrent agent runs collide on state lock and produce partial applies; lockless backends (S3 native locking, GCS) hide this longer than DynamoDB does.
- **`*.tftest.hcl` `command = apply` against real cloud bills quietly.** Engineers using AI to generate tests routinely omit `command = plan` and run up four-figure bills before noticing. The `tftest-not-apply` hook (from the `reusable-modules` addon) blocks it.
- **Provider caching with Terragrunt + OpenTofu 1.10 can silently use stale checksums** if `.terraform.lock.hcl` is not committed per unit.
- **AFT pipeline drift after manual console fixes** — engineers patch a control-plane misconfig in the console, then the next account-request run reverts it without warning. AFT's customizations layer is not a complete answer.
- **Workload Identity Federation `subject` claims are easy to over-scope.** `repo:org/*` patterns on GitHub or broad `sc://org/project/*` on Azure DevOps are common audit findings.

## Version-sensitive notes

- **OpenTofu 1.11.4 (2026) introduces a breaking change** rejecting `enabled` in local provider configs and tightens JSON state-encryption template interpolation. Modules with these patterns fail `init`.
- **CDKTF archived Dec 10 2025** — no further security patches. Migrate via `pulumi convert --from terraform`. `pulumi convert` quality jumped in early 2026 and handles `for_each` + dynamic blocks; still struggles with `provider` aliases inside modules.
- **Terraform Stacks (HashiCorp Cloud) is in preview** as a Terragrunt competitor — not yet at feature parity for hierarchical environment configuration as of mid-2026.
- **Azure DevOps WIF is GA + on by default for new service connections (2026).** Legacy SPN-with-secret connections still work but are being deprecated.
- **GCP Workload Identity Federation now supports GitLab as a first-class issuer** with org-id and project-path attribute mapping (2026).

## Cited links

- [OpenTofu 1.10.0 "Well-Seasoned Release" blog](https://opentofu.org/blog/opentofu-1-10-0/) — canonical reference for External Key Providers and the 1.10/1.11 state-encryption pivot.
- [OpenTofu `tofu test` command docs](https://opentofu.org/docs/cli/commands/test/) — authoritative HCL test-framework reference.
- [Pulumi: CDKTF is deprecated, what's next (Dec 2025)](https://www.pulumi.com/blog/cdktf-is-deprecated-whats-next-for-your-team/) — definitive primary source on the Dec 2025 archival + migration path.
- [Pulumi ESC dynamic-login docs](https://www.pulumi.com/docs/esc/integrations/dynamic-login-credentials/) — official OIDC dynamic-creds provider matrix (AWS / Azure / GCP / Doppler).
- [AWS Control Tower Account Factory for Terraform (AFT) overview](https://docs.aws.amazon.com/controltower/latest/userguide/aft-overview.html) — canonical for multi-account module distribution patterns.
- [Spacelift: Terragrunt vs Terraform (2026)](https://spacelift.io/blog/terragrunt-vs-terraform) — practical decision guide; covers 1.0 unit/stack terminology.
- [Azure DevOps WIF for Azure deployments GA blog](https://devblogs.microsoft.com/devops/workload-identity-federation-for-azure-deployments-is-now-generally-available/) — primary source on the GA pivot.
