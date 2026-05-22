# Module: devops/addon/azure-devops

> Config: `domain.addons` · Depends on: none (pairs with `sigstore-cosign`, `aws`, `azure`, `gcp`)

**What it does.** Adds three platform-prefixed PreToolUse hooks
(`ado-oidc-only`, `ado-sha-pin-templates`, `ado-agent-in-ci-guard`) and a
CLAUDE.md section covering Workload Identity Federation GA + on-by-default
defaults (2026), template SHA-pinning, and the agent-in-CI rule.

## Adopt if
- The project targets Azure DevOps Pipelines.

## Skip if
- The project does not run on Azure DevOps.

## Dependencies
- Azure DevOps organization + project with WIF service connections.
- `jq` available on PATH for the hooks.

## Install (manual)
1. Copy `files/.claude/` into your project's `.claude/`.
2. Deep-merge `files/.claude/settings.fragment.json` into `.claude/settings.json`.
3. Append `claude-md.md` to your `CLAUDE.md`.
4. `chmod +x .claude/hooks/ado-*.sh`.

## Install (assemble.sh)
Add `azure-devops` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the three `ado-*.sh` hooks from `.claude/hooks/`.
- Remove the matching `PreToolUse` entries from `.claude/settings.json`.
- Remove the `## Azure DevOps Pipelines` section from `CLAUDE.md`.

## Files
- `claude-md.md` — WIF GA defaults, template SHA-pinning, agent-in-CI rule.
- `files/.claude/hooks/ado-oidc-only.sh` — refuses static SPN secret references.
- `files/.claude/hooks/ado-sha-pin-templates.sh` — refuses cross-repo `template:` without SHA `ref:`.
- `files/.claude/hooks/ado-agent-in-ci-guard.sh` — refuses agent pipelines with `persistCredentials: true`.
- `files/.claude/settings.fragment.json` — registers all three hooks on `Write|Edit|MultiEdit`.
