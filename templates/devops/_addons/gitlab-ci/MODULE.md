# Module: devops/addon/gitlab-ci

> Config: `domain.addons` · Depends on: none (pairs with `sigstore-cosign`, `aws`, `azure`, `gcp`)

**What it does.** Adds three platform-prefixed PreToolUse hooks
(`gitlab-oidc-only`, `gitlab-sha-pin-includes`, `gitlab-agent-in-ci-guard`)
and a CLAUDE.md section covering GitLab ID-tokens (JWT) federation,
`include:project` SHA-pinning, `job-token:` scope discipline, and the
agent-in-CI rule.

## Adopt if
- The project targets GitLab CI/CD.

## Skip if
- The project does not run on GitLab CI/CD.

## Dependencies
- GitLab project with CI/CD enabled.
- `jq` available on PATH for the hooks.

## Install (manual)
1. Copy `files/.claude/` into your project's `.claude/`.
2. Deep-merge `files/.claude/settings.fragment.json` into `.claude/settings.json`.
3. Append `claude-md.md` to your `CLAUDE.md`.
4. `chmod +x .claude/hooks/gitlab-*.sh`.

## Install (assemble.sh)
Add `gitlab-ci` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the three `gitlab-*.sh` hooks from `.claude/hooks/`.
- Remove the matching `PreToolUse` entries from `.claude/settings.json`.
- Remove the `## GitLab CI/CD` section from `CLAUDE.md`.

## Files
- `claude-md.md` — ID-tokens, include SHA-pinning, job-token scope, agent-in-CI rule.
- `files/.claude/hooks/gitlab-oidc-only.sh` — refuses static cloud secrets in `variables:` / `secrets:`.
- `files/.claude/hooks/gitlab-sha-pin-includes.sh` — refuses `include:project` without 40-char SHA `ref:`.
- `files/.claude/hooks/gitlab-agent-in-ci-guard.sh` — refuses agent pipelines with write-scoped job tokens.
- `files/.claude/settings.fragment.json` — registers all three hooks on `Write|Edit|MultiEdit`.
