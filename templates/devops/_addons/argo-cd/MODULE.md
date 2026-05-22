# Module: devops/addon/argo-cd

> Config: `domain.addons` · Depends on: none (pairs with `kyverno`, `aws`, `azure`, `gcp`)

**What it does.** Adds the `gitops-promoter` agent (writes only to Git;
never to the cluster) and a CLAUDE.md section covering Argo CD 3.x
defaults — the post-3.0 ApplicationSet cluster-version label format break,
Source Hydrator + GitOps Promoter PR-as-promotion-gate, and the cardinal
rule that promotion is a PR, never an agent-issued sync.

## Adopt if
- The cluster uses Argo CD for reconciliation.

## Skip if
- The cluster uses Flux → `flux` addon (deferred to follow-up cycle).

## Dependencies
- A GitOps repository the cluster's Argo CD `Application` watches.
- `argocd` CLI available on the implementer's PATH for `app diff`.

## Install (manual)
1. Copy `files/.claude/agents/gitops-promoter.md` into your project's
   `.claude/agents/`.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `argo-cd` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove `gitops-promoter.md` from `.claude/agents/`.
- Remove the `## Argo CD` section from `CLAUDE.md`.

## Files
- `claude-md.md` — Argo CD 3.x defaults, Source Hydrator pattern, GitOps
  cardinal rule.
- `files/.claude/agents/gitops-promoter.md` — promotion agent.
