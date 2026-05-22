# Module: devops/addon/azure

> Config: `domain.addons` · Depends on: none (pairs with `terraform`, `pulumi`, `argo-cd`, `azure-devops`)

**What it does.** Wires Azure-specific defaults: Workload Identity Federation
GA + on-by-default for new service connections (2026), Bicep deployment
notes, AKS Workload Identity (Pod Identity deprecated), and the Azure MCP
Server. Drops a CLAUDE.md section so the agent does not introduce SPN
secrets or deprecated patterns.

## Adopt if
- The project targets Azure (any sub-domain).
- You want the Azure MCP Server wired automatically.

## Skip if
- The project does not touch Azure.

## Dependencies
- Azure tenant + subscription(s) with Workload Identity Federation enabled
  on the relevant service connections.
- The Node.js runtime (`npx`) to launch the Azure MCP Server.

## Install (manual)
1. Copy `files/.mcp.json.fragment` into your project root (deep-merge if a
   `.mcp.json` already exists).
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `azure` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `azure` server entry from `.mcp.json`.
- Remove the `## Azure` section from `CLAUDE.md`.

## Files
- `claude-md.md` — Azure rules (WIF GA defaults, Bicep, AKS Workload Identity,
  blast-radius tagging).
- `files/.mcp.json.fragment` — Azure MCP Server registration.
