---
name: init
description: Select a Harness DevOps sub-domain and write the .claude/HARNESS.toml marker so the matching skills and hooks activate.
---
You are initializing the Harness DevOps pack for this project.
1. Ask which sub-domain fits, presenting these options (one line each from their SUBDOMAIN.md adopt-if):
   - **cicd-platform** — reusable workflows, pipeline templates, and release engineering for many teams, where supply-chain attestation (SBOM + signature + Rekor + SLSA L3 provenance) and OIDC over static keys are first-class concerns.
   - **infrastructure** — cloud resources provisioned and/or operated via IaC (Terraform, OpenTofu, Pulumi) across one or more clouds, with plan freshness, OIDC-only credentials, drift surfacing, and prod two-key gating.
   - **kubernetes-platform** — a Kubernetes cluster or fleet plus a GitOps engine (Argo CD / Flux), platform addons, and a paved-path manifest set; the agent writes to Git, never to the live cluster.
   - **observability-sre** — telemetry collection, dashboards, alert rules, SLOs / error budgets, and on-call automation, where AI agents touch production observability via MCP, not via copy-pasted dashboards.
2. Write (creating if absent) to ${CLAUDE_PROJECT_DIR}/.claude/HARNESS.toml, MERGING (never overwrite other tables):

   [devops]
   subdomain = "<choice>"
3. Confirm the selection and name the skills/hooks now armed. Do not edit the project's CLAUDE.md.
