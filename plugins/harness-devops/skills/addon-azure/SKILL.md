---
name: devops-addon-azure
description: Azure conventions — Workload Identity Federation over legacy SPN-with-secret connections, Bicep over legacy ARM JSON, AKS Workload Identity over deprecated Pod Identity, and env/blast-radius Resource Group tagging. Use when targeting Azure for IaC, deployment templates, or AKS.
---

## Azure

- Workload Identity Federation is GA and on by default for new Azure DevOps
  service connections (2026). Legacy SPN-with-secret connections work but
  are being deprecated; do not introduce new ones.
- Bicep is the recommended deployment template language; ARM JSON is legacy.
- AKS: prefer Workload Identity (GA) over Pod Identity (deprecated 2024).
- Tag every Resource Group `env:dev|staging|prod` and
  `blast-radius:low|med|high|nuclear`.
