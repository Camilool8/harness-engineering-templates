---
name: data-analytics-engineering
description: dbt analytics-engineering discipline — contracts before model bodies, mandatory unit tests, a semantic layer as the single metric source of truth, lineage docs, and read-only warehouse access via Managed-MCP/OAuth. Use when .claude/HARNESS.toml selects data/analytics-engineering, or when building dbt models, contracts, unit tests, semantic-layer metrics, or lineage.
---

# Data — analytics-engineering

## dbt discipline
- **Contracts first.** Every staging+ model declares
  `contract.enforced: true` with explicit column types and constraints.
  The `contract-author` agent (from `dbt-core` addon) writes contracts
  before models.
- **Unit tests are mandatory.** Every model has at least one unit test
  per dbt Labs Feb 2026 best practice. The `dbt-implementer` agent
  refuses to commit a model without one.
- **Semantic layer is the metric source of truth.** Every metric is
  defined exactly once, in the semantic layer manifest. The
  `semantic-modeler` agent (from `dbt-core` addon) enforces.

## Lineage
- **Every model documents upstream + downstream.** The `lineage-doc`
  skill scaffolds the comment block; the `lineage-auditor` agent rejects
  "done" claims if a new mart has no downstream consumer or a deprecated
  model still has live consumers.

## Warehouse posture
- **Read-only via Managed-MCP / OAuth.** The `block-static-warehouse-creds`
  shared hook refuses static credentials in env.
- **dbt remote MCP** wires governed access to project lineage; never
  embed warehouse creds in the dbt MCP config.

## Reporting
- **Every reported metric is computed via a semantic-layer metric, not
  ad-hoc SQL.** The `query-provenance-auditor` shared agent will reject
  numbers whose query is not in the audit log against a semantic-layer
  metric.
