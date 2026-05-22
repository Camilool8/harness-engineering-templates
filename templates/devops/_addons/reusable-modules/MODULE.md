# Module: devops/addon/reusable-modules

> Config: `domain.addons` · Depends on: `terraform` or `pulumi` (pairs with `sigstore-cosign` for signed publishes)

**What it does.** Adds the `contract-tester` agent (writes and runs
`*.tftest.hcl` + Terratest), the `tftest-not-apply` PreToolUse hook that
refuses test files using `command = apply` against real providers, and a
CLAUDE.md section covering semver-publish gates and Cosign-signed module
artifacts (Trivy March 2026 lesson).

## Adopt if
- You publish IaC modules (Terraform Registry, Pulumi Registry, internal OCI).
- Breaking changes require a major version bump in your workflow.

## Skip if
- You only consume modules — `infrastructure` defaults are enough.

## Dependencies
- The `terraform` or `pulumi` addon for the module language.
- `jq` available on PATH for the hook to parse the PreToolUse event payload.

## Install (manual)
1. Copy `files/.claude/` into your project's `.claude/`.
2. Deep-merge `files/.claude/settings.fragment.json` into `.claude/settings.json`.
3. Append `claude-md.md` to your `CLAUDE.md`.
4. `chmod +x .claude/hooks/tftest-not-apply.sh`.

## Install (assemble.sh)
Add `reusable-modules` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `contract-tester` agent file from `.claude/agents/`.
- Remove the `tftest-not-apply.sh` hook from `.claude/hooks/`.
- Remove the matching `PreToolUse` entry from `.claude/settings.json`.
- Remove the `## Reusable modules` section from `CLAUDE.md`.

## Files
- `claude-md.md` — semver-publish + Cosign-sign rules.
- `files/.claude/agents/contract-tester.md` — contract-tester agent definition.
- `files/.claude/hooks/tftest-not-apply.sh` — PreToolUse hook on `Write|Edit` of `*.tftest.hcl`.
- `files/.claude/settings.fragment.json` — registers the hook on `Write|Edit|MultiEdit`.
