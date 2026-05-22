# Module: devops/addon/pulumi

> Config: `domain.addons` · Depends on: none (pairs with `aws`, `azure`, `gcp`, `multi-env-state`, `reusable-modules`)

**What it does.** Wires Pulumi defaults: ESC dynamic credentials as the
GA OIDC pattern for module CI in 2026; `pulumi convert --from terraform`
as the canonical CDKTF migration path (CDKTF archived Dec 10 2025); the
provider-alias-in-modules caveat for converted code.

## Adopt if
- You write Pulumi programs in TypeScript/Python/Go/.NET/Java.

## Skip if
- You write Terraform/OpenTofu → `terraform` addon instead.

## Dependencies
- Pulumi CLI ≥ 3.100 (for `pulumi convert --from terraform` quality).
- A Pulumi ESC environment if you use dynamic credentials.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `pulumi` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## Pulumi` section from `CLAUDE.md`.

## Files
- `claude-md.md` — Pulumi rules: ESC dynamic creds, `pulumi convert` migration
  recipe, provider-alias caveat, preview-not-apply in CI.
