## dbt-core (contracts + semantic layer + agent skills)

- **Contract-first.** Every staging+ model declares
  `contract.enforced: true` with explicit column types. The
  `contract-author` agent writes the contract before the model body.
- **Unit tests are mandatory** per dbt Labs Feb 2026 best practice. The
  `dbt-build-model` skill scaffolds them.
- **Semantic layer is the metric source of truth.** The
  `semantic-modeler` agent owns the manifest; no metric defined twice.
- **dbt remote MCP (GA Oct 2025)** is the governed agent surface for
  project lineage / models / tests. Token via env, not embedded.
- **dbt-agent-skills (Feb 9 2026)** auto-activate by prompt match; this
  addon ships the 3 highest-leverage.
