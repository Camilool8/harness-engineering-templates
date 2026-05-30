---
name: init
description: Select a Harness Data sub-domain and write the .claude/HARNESS.toml marker so the matching skills and hooks activate.
---
You are initializing the Harness Data pack for this project.
1. Ask which sub-domain fits, presenting these options (one line each from their SUBDOMAIN.md adopt-if):
   - **analytics-engineering** — your deliverable is dbt models (Core or Cloud) shipped with contracts, unit tests, a semantic layer, and lineage, publishing a paved path for downstream consumers.
   - **analyst-notebook** — ad-hoc and exploratory analysis where the deliverable is a reactive, reproducible notebook that reads from a warehouse and produces charts, tables, or memos with sample-then-scale on every query.
   - **llm-app** — LLM-powered products (RAG, agentic pipelines, prompt-driven apps) shipped behind a model-version pin, where the CI gate is a three-tier eval suite (assertion → judge → human) plus a prompt-regression check.
   - **ml-pipeline** — training, evaluation, packaging, and serving of supervised or self-supervised models, where the deliverable is a versioned model artifact plus the data-rooted eval suite that gates it, with tracking discipline and lockfile-frozen environments.
2. Write (creating if absent) to ${CLAUDE_PROJECT_DIR}/.claude/HARNESS.toml, MERGING (never overwrite other tables):

   [data]
   subdomain = "<choice>"
3. Confirm the selection and name the skills/hooks now armed. Do not edit the project's CLAUDE.md.
