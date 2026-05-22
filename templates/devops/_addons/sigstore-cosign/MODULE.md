# Module: devops/addon/sigstore-cosign

> Config: `domain.addons` · Depends on: none (pairs with `github-actions`, `azure-devops`, `gitlab-ci`, `reusable-modules`)

**What it does.** Drops a CLAUDE.md section covering SLSA L3 keyless
signing via OIDC, Rekor inclusion verify, and the multi-arch
index-vs-manifest digest pitfall. The runtime enforcement
(`cosign-tlog-required.sh`) ships at the devops domain layer so it applies
to every devops sub-domain even without this addon.

## Adopt if
- You sign artifacts (images, modules, SBOMs).

## Skip if
- You do not publish artifacts (rare in 2026).

## Dependencies
- `cosign` (v2+) on PATH.
- An OIDC issuer (GitHub Actions, GitLab CI, Azure DevOps with WIF) for
  keyless signing.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `sigstore-cosign` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## Sigstore Cosign` section from `CLAUDE.md`.

## Files
- `claude-md.md` — keyless workflow, Rekor verify, multi-arch digest
  pitfall, SLSA L3 with `actions/attest-build-provenance@v2`.
