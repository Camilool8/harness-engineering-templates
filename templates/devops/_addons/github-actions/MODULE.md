# Module: devops/addon/github-actions

> Config: `domain.addons` · Depends on: none (pairs with `sigstore-cosign`, `aws`, `azure`, `gcp`)

**What it does.** Adds three platform-prefixed PreToolUse hooks
(`gha-oidc-only`, `gha-sha-pin-actions`, `gha-agent-in-ci-guard`) and a
CLAUDE.md section covering OIDC trust with `job_workflow_ref`, the Aug 15
2025 SHA-pinning policy enforcement, `actions/attest-build-provenance@v2`
for SLSA L3, and the agent-in-CI rule that addresses the May 2026 CSA
"Comment and Control" attack class.

## Adopt if
- The project targets GitHub Actions.

## Skip if
- The project does not run on GitHub Actions.

## Dependencies
- GitHub repository with Actions enabled.
- `jq` available on PATH for the hooks to parse PreToolUse event payloads.

## Install (manual)
1. Copy `files/.claude/` into your project's `.claude/`.
2. Deep-merge `files/.claude/settings.fragment.json` into `.claude/settings.json`.
3. Append `claude-md.md` to your `CLAUDE.md`.
4. `chmod +x .claude/hooks/gha-*.sh`.

## Install (assemble.sh)
Add `github-actions` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the three `gha-*.sh` hooks from `.claude/hooks/`.
- Remove the matching `PreToolUse` entries from `.claude/settings.json`.
- Remove the `## GitHub Actions` section from `CLAUDE.md`.

## Files
- `claude-md.md` — OIDC trust, SHA-pinning, attest-build-provenance, agent-in-CI rules.
- `files/.claude/hooks/gha-oidc-only.sh` — refuses static cloud credential references.
- `files/.claude/hooks/gha-sha-pin-actions.sh` — refuses `uses:` without 40-char SHA.
- `files/.claude/hooks/gha-agent-in-ci-guard.sh` — refuses agent workflows with non-read-only token scope.
- `files/.claude/settings.fragment.json` — registers all three hooks on `Write|Edit|MultiEdit`.
