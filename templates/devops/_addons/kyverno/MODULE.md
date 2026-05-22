# Module: devops/addon/kyverno

> Config: `domain.addons` · Depends on: none (pairs with `argo-cd`)

**What it does.** Adds the `policy-author` agent (writes Kyverno
`ValidatingPolicy` (CEL) for new rules; tests against fixtures), the
`manifest-validate` PostToolUse hook (kubeconform → kube-linter → kyverno
apply on every YAML write under a K8s manifest path), and a CLAUDE.md
section explaining the Kyverno 1.13+ ValidatingPolicy → in-tree
`ValidatingAdmissionPolicy` compile path.

## Adopt if
- You enforce K8s-native YAML/CEL policies.

## Skip if
- You enforce cross-domain Rego policies (cloud + app + K8s) →
  `opa-gatekeeper` (deferred to follow-up cycle).

## Dependencies
- Kyverno 1.13+ installed in the target cluster.
- `kubeconform`, `kube-linter`, `kyverno` CLIs on PATH for the hook.

## Install (manual)
1. Copy `files/.claude/` into your project's `.claude/`.
2. Deep-merge `files/.claude/settings.fragment.json` into `.claude/settings.json`.
3. Append `claude-md.md` to your `CLAUDE.md`.
4. `chmod +x .claude/hooks/manifest-validate.sh`.

## Install (assemble.sh)
Add `kyverno` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove `policy-author.md` from `.claude/agents/`.
- Remove `manifest-validate.sh` from `.claude/hooks/`.
- Remove the matching `PostToolUse` entry from `.claude/settings.json`.
- Remove the `## Kyverno` section from `CLAUDE.md`.

## Files
- `claude-md.md` — Kyverno ValidatingPolicy notes; generate+pruning gotcha.
- `files/.claude/agents/policy-author.md` — policy author agent.
- `files/.claude/hooks/manifest-validate.sh` — PostToolUse on `Write|Edit` of
  YAML under K8s manifest paths.
- `files/.claude/settings.fragment.json` — registers the hook.
