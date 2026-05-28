# Addon — dbt-core

dbt-core + dbt remote MCP + a curated subset of `dbt-labs/dbt-agent-skills`
(Feb 9 2026). Contributes `semantic-modeler` and `contract-author` agents.

## Adopt if

- You use dbt Core or dbt Cloud.

## Skip if

- You do not use dbt.

## What it contributes

- CLAUDE.md section: contract-first models, unit tests before marts,
  semantic-layer as metric source of truth, dbt remote MCP.
- MCP fragment: dbt remote MCP wiring.
- Agents: `semantic-modeler` (sonnet) and `contract-author` (sonnet) for
  the `analytics-engineering` roster.
- Skills: `dbt-build-model`, `dbt-unit-tests`, `dbt-metricflow` (3 of
  the 10 vendor-stewarded skills; the remaining 7 are available
  upstream at `github.com/dbt-labs/dbt-agent-skills`).

## Provision before install

- dbt Core ≥ 1.8 (`uv tool install dbt-core`) or dbt Cloud account.
- dbt project initialized (`dbt init`).
- For the remote MCP: a dbt Cloud PAT (env: `DBT_CLOUD_TOKEN`).

## Pairs with

`analytics-engineering` (primary).
