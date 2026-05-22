# Module: devops/addon/aws

> Config: `domain.addons` · Depends on: none (pairs with `terraform`, `pulumi`, `argo-cd`, `github-actions`)

**What it does.** Wires AWS-specific defaults into a devops sub-domain harness:
STS session duration ≤ 15 min, AFT/Control Tower bootstrap pattern,
IRSA / EKS Pod Identity for in-cluster IAM, blast-radius tags, and the AWS
Agent Toolkit MCP server (GA May 2026). Drops a CLAUDE.md section so the
agent learns these defaults verbatim instead of guessing.

## Adopt if
- The project targets AWS (any sub-domain: `infrastructure`,
  `kubernetes-platform`, `cicd-platform`, or `observability-sre`).
- You want the AWS Agent Toolkit MCP wired automatically.

## Skip if
- The project does not touch AWS.

## Dependencies
- AWS account(s) with Control Tower or organizations bootstrapped.
- The Node.js runtime (`npx`) to launch the AWS Agent Toolkit MCP.

## Install (manual)
1. Copy `files/.mcp.json.fragment` into your project root (deep-merge if a
   `.mcp.json` already exists).
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `aws` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `aws` server entry from `.mcp.json`.
- Remove the `## AWS` section from `CLAUDE.md`.

## Files
- `claude-md.md` — AWS rules (STS duration, AFT bootstrap, IRSA / Pod
  Identity, blast-radius tagging, EKS version-EOL note).
- `files/.mcp.json.fragment` — AWS Agent Toolkit MCP server registration.
