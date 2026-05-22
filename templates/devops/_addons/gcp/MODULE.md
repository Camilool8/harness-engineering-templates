# Module: devops/addon/gcp

> Config: `domain.addons` · Depends on: none (pairs with `terraform`, `pulumi`, `argo-cd`, `gitlab-ci`)

**What it does.** Wires GCP-specific defaults: Workload Identity Federation
patterns (with GitLab issuer support GA in 2026), Cloud Build OIDC, GKE
Workload Identity. No MCP server in v1 — Google MCP equivalents are
pending stable releases as of 2026-05.

## Adopt if
- The project targets Google Cloud (any sub-domain).

## Skip if
- The project does not touch GCP.

## Dependencies
- GCP project(s) with Workload Identity Pools configured for your CI
  issuer.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `gcp` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## GCP` section from `CLAUDE.md`.

## Files
- `claude-md.md` — GCP rules (Workload Identity Federation, GitLab issuer
  support, GKE Workload Identity, blast-radius tagging).
