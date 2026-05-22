# Module: devops/addon/multi-env-state

> Config: `domain.addons` · Depends on: `terraform` or `pulumi` (pairs with `aws`, `azure`, `gcp`)

**What it does.** Adds per-env state-isolation rules, the `drift-surfacer`
agent (read-only refresh-only plans; never remediates), the `cost-gate`
PostToolUse hook (Infracost + OPA), and the `prod-typed-token` PreToolUse
hook that requires a typed `CONFIRM <last-4>` token for any apply against
a prod-tagged or nuclear-tier account.

## Adopt if
- You manage ≥2 environments (dev, staging, prod) from one IaC codebase.
- You enforce per-env state isolation and cost budgets.
- You want drift surfacing without autonomous remediation.

## Skip if
- You only publish modules and do not operate environments → use
  `reusable-modules`.
- You operate a single env — `infrastructure` defaults are enough.

## Dependencies
- The `terraform` or `pulumi` addon for the IaC language.
- `infracost` and `opa` on PATH (the cost-gate hook is a no-op when missing).
- A cloud CLI (`aws`, `az`, `gcloud`) on PATH so the prod-typed-token hook
  can resolve the current account tag.

## Install (manual)
1. Copy `files/.claude/` into your project's `.claude/`.
2. Deep-merge `files/.claude/settings.fragment.json` into `.claude/settings.json`.
3. Append `claude-md.md` to your `CLAUDE.md`.
4. `chmod +x .claude/hooks/cost-gate.sh .claude/hooks/prod-typed-token.sh`.

## Install (assemble.sh)
Add `multi-env-state` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `drift-surfacer` agent from `.claude/agents/`.
- Remove `cost-gate.sh` and `prod-typed-token.sh` from `.claude/hooks/`.
- Remove the matching `PreToolUse` + `PostToolUse` entries from `.claude/settings.json`.
- Remove the `## Multi-env state` section from `CLAUDE.md`.

## Files
- `claude-md.md` — per-env isolation + cost budget + two-key gate rules.
- `files/.claude/agents/drift-surfacer.md` — drift-surfacer agent (read-only).
- `files/.claude/hooks/cost-gate.sh` — PostToolUse on `Bash` for `terraform|tofu plan`.
- `files/.claude/hooks/prod-typed-token.sh` — PreToolUse on `Bash` for apply-class commands.
- `files/.claude/settings.fragment.json` — registers both hooks.
