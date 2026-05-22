# Module: devops/addon/terraform

> Config: `domain.addons` · Depends on: none (pairs with `aws`, `azure`, `gcp`, `multi-env-state`, `reusable-modules`)

**What it does.** Wires Terraform + OpenTofu defaults: native `*.tftest.hcl`
as the primary test framework, Terratest reserved for cloud-API e2e,
OpenTofu 1.11.4 init-break note, and the Terragrunt + provider-cache
pitfall. Drops a CLAUDE.md section so the agent picks the right test
tool and pins providers correctly.

## Adopt if
- You write Terraform or OpenTofu HCL (this addon covers both — they share surface).

## Skip if
- You use Pulumi → `pulumi` addon instead.
- You use only Bicep/ARM/CDK → no addon needed for v1; deferred to follow-up cycle.

## Dependencies
- Terraform ≥ 1.6 or OpenTofu ≥ 1.6 (for native `tofu test` / `terraform test`).

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `terraform` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## Terraform / OpenTofu` section from `CLAUDE.md`.

## Files
- `claude-md.md` — Terraform/OpenTofu rules: native test framework, OpenTofu
  1.11 init break, Terragrunt provider-cache pitfall, SHA-pinned module
  source refs.
