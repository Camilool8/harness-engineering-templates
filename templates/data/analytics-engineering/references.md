# Data / analytics-engineering — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **Contracts + unit tests before models.** Per dbt Labs Feb 2026 best
  practices, every staging+ model declares `contract.enforced: true`
  with explicit column types; every model has at least one unit test.
- **Semantic layer is the LLM-facing interface.** Per dbt Labs 2026
  "Semantic Layer vs. Text-to-SQL benchmark," the semantic layer is the
  governed surface that prevents hallucinated SQL.
- **`dbt-labs/dbt-agent-skills` (Feb 9 2026)** is the canonical agent
  skill pack — 10 vendor-stewarded skills (model build, unit tests,
  MetricFlow, Mesh, MCP setup, two migration skills).
- **dbt remote MCP (GA Oct 2025)** provides governed agent access to
  project lineage, models, and tests without warehouse creds passing
  through the agent host.

## Common gotchas

- **Contract drift without migration notes.** A breaking contract change
  with no migration note silently breaks downstream consumers. The
  `contract-author` agent refuses contract-breaking PRs without a
  migration note.
- **Inline metrics in marts.** A metric defined in a mart and re-defined
  in a downstream report is two truths. The `semantic-modeler` agent
  refuses; metrics live exactly once in the semantic layer.
- **Deprecated models with live consumers.** Removing a model whose
  downstream consumers still reference it breaks production. The
  `lineage-auditor` agent rejects.

## Version-sensitive notes

- dbt remote MCP: GA Oct 2025.
- `dbt-labs/dbt-agent-skills`: Feb 9 2026 release.
- dbt MetricFlow: shipped with dbt 1.6+; semantic-layer manifest is
  the 2026 canonical surface.

## Cited links

- [dbt-labs/dbt-agent-skills](https://github.com/dbt-labs/dbt-agent-skills) — vendor-stewarded skill catalogue.
- [dbt Developer Blog — Make your AI better at data work (Feb 9 2026)](https://docs.getdbt.com/blog/dbt-agent-skills) — release announcement.
- [dbt remote MCP — GA announcement (Oct 2025)](https://www.getdbt.com/blog/dbt-agents-remote-dbt-mcp-server-trusted-ai-for-analytics) — vendor-stewarded.
- [dbt Developer Blog — Semantic Layer vs. Text-to-SQL: 2026 Benchmark](https://docs.getdbt.com/blog/semantic-layer-vs-text-to-sql-2026) — why semantic layer beats raw SQL for LLMs.
- [Recce — I let Claude Code build my dbt models (Feb 25 2026)](https://blog.reccehq.com/i-let-claude-code-build-my-dbt-models.-the-interesting-part-wasnt-the-code) — silent data-quality flag catalogue.
- [Snowflake Builders Blog — dbt for Cortex AI (Apr 2026)](https://medium.com/snowflake/dbt-for-cortex-ai-harvesting-patterns-as-snowflake-cortex-code-skills-e4388fa2f1b1) — Cortex × dbt patterns.
