# Data Domain Pack — Design

> Status: ⏳ Pending implementation.
> Date: 2026-05-22.
> Curates the `data` thin recipe into a three-layer **domain pack**, third
> after `web/` and `devops/`. Companion to `docs/HARNESS_ENGINEERING.md` §2,
> `docs/AGENT_ROLES.md`, the master design
> `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md` (pack
> mechanics, reused unchanged), and the meta-spec
> `docs/superpowers/specs/2026-05-22-thin-recipe-graduation-plan-design.md`
> (the graduation cycle this spec is the first execution of).

## 1. Context & motivation

The current `templates/data/` is a working v1 thin recipe — one
`harness.config.yml`, one `claude-md.md` snippet, two PreToolUse hooks
(`block-unbounded-sql.sh`, `leakage-sentinel.sh`) at
`templates/data/files/.claude/hooks/`, and one skill
(`ensuring-reproducibility/`) at `templates/data/files/.claude/skills/`. It
assembles, it stops the obvious anti-patterns (warehouse mutation, unbounded
`SELECT`, leakage, p-hacking, look-ahead bias), but it has no sub-domain
specificity, no curated agent team, no dated dossier, and no per-warehouse,
per-tracking-system, or per-eval-vendor specialization. The meta-spec
`docs/superpowers/specs/2026-05-22-thin-recipe-graduation-plan-design.md`
names `data` as cycle 1 of the nine remaining graduations.

Three 2026 forcing functions justify graduating now:

- **EU AI Act Article 99 / Annex III enforcement (Aug 2 2026)** — penalties
  reach €35M or 7% of global turnover; for high-risk systems Annex IV makes
  immutable audit logging of agent tool calls statutory, and the rebuttable
  compliance presumption attaches to NIST AI RMF / ISO 42001 implementations
  (state laws — Texas RAIGA, Colorado AI Act, California AI Transparency Act
  — extend the same shape into US jurisdictions). The flat recipe ships no
  query-audit hook, no dataset-card author, and no model-card linkage; a
  curated pack must.
- **ShinyHunters / Anodot supply-chain breach (April 2026)** — attackers
  pivoted through a third-party SaaS integration and exfiltrated 78.6M
  Rockstar Games and 119K Vimeo records via stolen Snowflake / BigQuery auth
  tokens cached on agent hosts. The lesson is that static warehouse
  credentials on the agent host are now the failure mode; managed-MCP /
  OAuth-only is the default. The flat recipe says nothing about credential
  posture.
- **Vendor MCP / agent-skill GA wave** — Snowflake Cortex Managed MCP went
  GA Nov 4 2025; dbt remote MCP went GA Oct 2025 and `dbt-labs/dbt-agent-skills`
  shipped Feb 9 2026; BigQuery MCP entered Google preview Jan 2026;
  Databricks MCP entered Public Preview May 7 2026; MotherDuck `duckdb-mcp`,
  W&B `wandb-mcp-server`, MLflow 3.5.1+ MCP extra, Langfuse, and Inspect AI
  (UK AISI, Apache-2.0, May 2026) all became first-class addon material in a
  single year. A flat recipe cannot encode "which warehouse, which tracker,
  which evaluator"; an addon catalog can.

Data as a domain spans wider orthogonal axes than even devops: deliverable
shape (notebook vs pipeline vs LLM app vs warehouse model) × warehouse
vendor × Python toolchain (uv / pixi) × DataFrame engine (Polars / DuckDB /
pandas) × notebook runtime (marimo / Jupyter) × experiment tracker (MLflow /
W&B) × eval system (assertion / LLM-judge / human) × observability vendor
(Langfuse / Braintrust / Phoenix). A flat recipe picks one default per axis
and pretends the others do not exist. **The existing field reference
`docs/HARNESS_ENGINEERING.md` §2 treats analytics-engineering (dbt) as a
sub-section of "data work" without splitting it from notebook analysis; this
spec disagrees** — per research brief A, dbt has its own vendor-stewarded
agent skill catalog, its own remote-MCP GA, and its own deliverable shape
(warehouse-modeled tables with contracts + unit tests + semantic layer +
lineage), so it earns its own sub-domain. HE §2 will be updated when this
pack ships. This design partitions the domain by **deliverable shape** at
the sub-domain level and pushes every other axis (warehouse, toolchain,
tracker, evaluator) into composable addons.

## 2. Decisions locked in brainstorming

Decisions inherit the meta-spec
(`docs/superpowers/specs/2026-05-22-thin-recipe-graduation-plan-design.md`)
§2 row-by-row; rows below either inherit verbatim or specialise it for `data`.

| Question | Decision |
|---|---|
| Sub-domain count | **Four** — `data-analyst-notebook`, `ml-pipeline`, `llm-app`, `analytics-engineering`. (Within the meta-spec's 3–5 band; the four deliverable shapes are non-overlapping and each carries a distinct gate set.) |
| Partition heuristic | **By deliverable shape** — what you ship (a notebook, a trained model + serving stack, an LLM app, a warehouse-modeled table set). (Inherits meta-spec §2; mirrors `web/` and `devops/`.) |
| Should `analytics-engineering` be a sub-domain or an addon under another? | **Sub-domain** — explicitly disagrees with `docs/HARNESS_ENGINEERING.md` §2 lumping. (Brief A: dbt has its own GA remote MCP, its own vendor-stewarded agent-skills catalog, its own deliverable shape; collapsing it loses too much specificity.) |
| Should `data-analyst-notebook` and `ml-pipeline` be one sub-domain? | **No** — they share toolchain but diverge sharply on gates (notebook needs Restart-and-Run-All + marimo/Jupyter-MCP guard; ML pipeline needs tracking-required + lockfile + data-hash + eval-suite isolation). (User direction.) |
| Should `llm-app` collapse into `ml-pipeline`? | **No** — eval-as-code is the unit-test surface and is structurally different from training-loss tracking (three-tier assertion → judge → human; prompt-regression; model-version pinning). (Brief A — Husain LLM Evals FAQ Jan 15 2026.) |
| Warehouse vendor as sub-domain? | **No** — addon per warehouse (`snowflake-mcp`, `bigquery-mcp`, `databricks-mcp`, `duckdb-mcp`); warehouse cuts across `data-analyst-notebook`, `analytics-engineering`, and (for Databricks) `ml-pipeline`. (Mirrors devops cloud-as-addon decision.) |
| Python toolchain as sub-domain? | **No** — `uv` is the cross-domain default addon; `pixi` is deferred to contrib (only needed when conda/CUDA/MKL is mandatory). (Brief B.) |
| Experiment tracker as sub-domain? | **No** — `mlflow` and `wandb-mcp` are addons of `ml-pipeline` (and `llm-app` for GenAI tracing in MLflow 3.5.1+). |
| Eval/observability vendor as sub-domain? | **No** — `langfuse` and `inspect-ai` are addons of `llm-app` (and `inspect-ai` also of `ml-pipeline`). `braintrust` deferred to contrib. |
| Addons may contribute agents? | **Yes** — pattern is already mechanically supported and was formalised by the devops pack (`reusable-modules` ships `contract-tester`; `kyverno` ships `policy-author`); this spec uses it for `dbt-core` (`semantic-modeler`, `contract-author`), `mlflow` (`run-comparator`), and `langfuse` (`trace-triager`). (Inherits meta-spec §3 step 3.) |
| Addon count | **Twelve** — within the meta-spec's 5–15 band. Six categories: Python toolchain (2), warehouse-MCP (4), analytics-engineering (1), notebook runtime (1), ML tracking (2), LLM eval / observability (2). |
| Defer-to-contrib addons | `pixi`, `braintrust`, `deepeval`, `felt-mcp`, `jupyter-mcp`. (None is GA-stable in 2026 with the maturity bar the other twelve cleared; see §5 note.) |
| Shared agents | **Three** — `eval-curator`, `dataset-card-author`, `query-provenance-auditor`. (Anthropic harness papers Nov 2025 + Mar 2026 motivate `eval-curator`; EU AI Act Annex IV + NIST AI RMF motivate `dataset-card-author`; HE §2.9 anti-pattern #2 motivates `query-provenance-auditor`.) |
| Shared hooks | **Four** — `block-unbounded-sql.sh` and `leakage-sentinel.sh` (promoted from the thin recipe), plus `audit-log-warehouse-query.sh` and `block-static-warehouse-creds.sh` (both new for 2026). |
| Shared MCP fragment defaults | **Empty** — per-warehouse and per-tracker MCPs are addon-installed, mirroring devops's empty domain-level MCP fragment until the cloud / tracker addons populate it. |
| Thin recipe retirement timing | **Final commit of Phase B.** Both shapes assemble through every intermediate commit; the thin manifest, `claude-md.md`, `README.md`, and flat `files/` tree are removed in the cycle's last commit. (Inherits meta-spec §3 step 7; same approach `web/` and `devops/` took.) |
| AI attribution in commits | **Never.** (Inherits meta-spec §2.) |

## 3. Architecture — the data pack

The master design's three-layer shape and `assemble.sh` v2 mechanics are
reused unchanged. The data layout follows the devops template:

```
templates/data/                            DOMAIN PACK
  DOMAIN.md                index + sub-domain decision guide
  references.md            curated dossier — Verified: 2026-05, cited links
  domain.claude-md.md      shared data rules (warehouse read-only, eval-suite
                           isolation, every number traceable to a logged query)
  files/
    .mcp.json.fragment     (auto-merged — empty by default; addons populate)
    .claude/
      context7.mcp.json.fragment   (merged only if docs.context7_mcp: true)
      agents/              shared data agents (eval-curator,
                           dataset-card-author, query-provenance-auditor)
      hooks/               shared data hooks (block-unbounded-sql,
                           leakage-sentinel, audit-log-warehouse-query,
                           block-static-warehouse-creds)
      settings.fragment.json
  _addons/<addon>/         12 addons — each module-shaped
  <sub-domain>/                            THE ASSEMBLE UNIT
    SUBDOMAIN.md
    harness.config.yml
    references.md
    claude-md.md
    files/.claude/{agents,hooks,skills,settings.fragment.json}
```

No changes to `_base/`, `_modules/`, the `harness.config.yml` schema, or
`assemble.sh`. The pack reuses every mechanic the web and devops packs
already exercise.

The shared layer (`templates/data/DOMAIN.md`, `templates/data/references.md`,
`templates/data/domain.claude-md.md`, `templates/data/files/.claude/agents/`,
`templates/data/files/.claude/hooks/`, the shared MCP fragments) installs on
every data sub-domain. The per-sub-domain layer
(`templates/data/<sub-domain>/`) is the assemble unit and owns the curated
specialist agent team, the curated skill set, the sub-domain dossier, and
the default `domain.addons` list. The `_addons/<addon>/` layer is the
composable extras layer — twelve module-shaped addons grouped into six
categories.

## 4. Sub-domains — partitioned by deliverable shape

**Preview-tagged addons in default sets.** Where a sub-domain's natural
warehouse surface includes a vendor whose MCP is still in preview
(`bigquery-mcp`, `databricks-mcp`), this design **includes the preview-tagged
addon in `domain.addons`** rather than forcing it out. The `preview: true`
flag in the addon's `MODULE.md` carries the install-time warning regardless
of whether the addon lands via default set or explicit opt-in; pushing
preview MCPs out of defaults to chase a "GA-only defaults" purity would
misrepresent how `ml-pipeline` and `analytics-engineering` actually target
warehouses in 2026. `data-analyst-notebook`'s default set is the one
exception: notebook work has a primary-warehouse choice rather than a
multi-warehouse-by-default posture, so its defaults pick the GA pair
(`snowflake-mcp` + `duckdb-mcp`) and surface preview warehouses as per-project
opt-ins.

### 4.1 `data-analyst-notebook`

**Purpose:** ad-hoc and exploratory analysis where the deliverable is a
reactive, reproducible notebook that explains a data question end-to-end.

- **Adopt if:** you do exploratory analysis or ad-hoc reporting; your output
  is a notebook or a small set of cells; you read from a warehouse and
  produce charts, tables, or memos; you want sample-then-scale on every
  query.
- **Skip if:** your deliverable is a trained model + serving stack
  (→ `ml-pipeline`), an LLM app (→ `llm-app`), or warehouse-modeled tables
  (→ `analytics-engineering`).

**Curated agent team:**

- `notebook-architect` (opus) — frames the analysis question, picks the
  warehouse + sample size + DataFrame engine, drafts the cell outline.
- `notebook-implementer` (sonnet) — fills cells one at a time; for marimo
  edits the `.py` directly; for Jupyter routes through the marimo-pair or
  Jupyter-MCP path; never raw `NotebookEdit` on `.ipynb` JSON.
- `chart-critic` (sonnet, vision) — PostToolUse on `plt.savefig` /
  `fig.write_html`; scores against the canonical sins list (truncated
  y-axis, dual y-axes, missing CIs, rainbow palettes for sequential data,
  color-only encoding, 3D pie charts); different model family from the
  generator.
- `restart-run-all-checker` (haiku) — Default-FAIL contract: a notebook is
  not "done" until Restart-and-Run-All succeeds end-to-end in a clean
  kernel; verifies kernel-fresh state by checking timestamps and execution
  counts (ReviewNB + Recce + Mineault practice).

**Skills the sub-domain installs:**

- `ensuring-reproducibility` (promoted from the thin recipe).
- `sample-then-scale` — explicit "run `LIMIT 1000` / `TABLESAMPLE` first,
  inspect dtypes + shape, then graduate" recipe.
- `notebook-restart-run-all` — invoked by the `restart-run-all-checker`
  agent before any "complete" claim.

**Default `domain.addons`:** `uv`, `polars`, `marimo`, `duckdb-mcp`,
`snowflake-mcp`. Preview-tagged warehouses (`bigquery-mcp`,
`databricks-mcp`) are opted in per project for this sub-domain — notebook
analysis typically pins to one primary warehouse and `data-analyst-notebook`
keeps its default set to the GA pair. (Sub-domains with multi-warehouse-by-
default posture — `ml-pipeline`, `analytics-engineering` — include preview
MCPs in defaults per the §4 resolution above.)

### 4.2 `ml-pipeline`

**Purpose:** training, evaluation, packaging, and (where in-scope) serving
of supervised or self-supervised models; the deliverable is a versioned
model artifact plus the eval suite that gates it.

- **Adopt if:** you train models, run evaluation suites, package model
  artifacts, register them, or run inference services; you need tracking
  discipline (every run logged) and lockfile-frozen environments.
- **Skip if:** your deliverable is a chat-style LLM app, RAG pipeline, or
  agentic system whose unit test is an eval suite over prompts
  (→ `llm-app`); your deliverable is dbt models (→ `analytics-engineering`).

**Curated agent team:**

- `pipeline-architect` (opus) — drafts the training-loop / eval-suite split;
  enforces eval-suite-as-separate-package; picks tracker (MLflow vs W&B).
- `training-implementer` (sonnet) — writes `train.py`; refuses to run
  `python train.py` invocations without `import (mlflow|wandb|aim)`
  (PreToolUse on `Bash`).
- `eval-implementer` (sonnet) — writes evals in the **separate** eval
  package; the cross-cutting `eval-curator` shared agent refuses any PR
  that touches both `eval/*` and model code.
- `run-comparator` (haiku, contributed by `mlflow` addon when installed) —
  pulls last N runs from the tracker, summarises deltas, flags suspicious
  improvements (test accuracy > 0.99 on non-trivial data → human review).
- `data-versioner` (haiku) — emits a data hash for every input parquet /
  arrow / DuckDB snapshot used in a run; refuses a commit that has a model
  artifact change without a recorded data hash.

**Skills the sub-domain installs:**

- `ensuring-reproducibility` (promoted from the thin recipe).
- `pin-seeds-and-lockfile` — pins `random` / `numpy` / `torch` / `jax` /
  `transformers.set_seed` / `PYTHONHASHSEED`, refreshes `uv.lock`.
- `eval-suite-isolated-package` — scaffolds an out-of-tree eval package
  that imports the model but the model never imports it.

**Default `domain.addons`:** `uv`, `polars`, `mlflow`, `wandb-mcp`,
`inspect-ai`, `databricks-mcp` (preview-tagged; included in defaults per the
§4 resolution — Databricks is a primary ML-platform target and the
`preview: true` flag in `MODULE.md` carries the install-time warning).

### 4.3 `llm-app`

**Purpose:** LLM-powered applications — RAG, agentic pipelines, prompt-
driven products — where the unit test is an eval suite, not a metric.

- **Adopt if:** you build LLM products; you have prompts as the
  intervention surface; you ship behind a model-version pin; your CI gate is
  an eval suite (assertion + judge + human) and a prompt-regression check.
- **Skip if:** your deliverable is a trained model (→ `ml-pipeline`) or an
  exploratory notebook (→ `data-analyst-notebook`).

**Curated agent team:**

- `llm-app-architect` (opus) — picks the three-tier eval shape per Husain &
  Shankar LLM Evals FAQ (Jan 15 2026): assertion-first (incl. multi-test
  correction as Level-1), then judge with cross-family model, then human
  review on major changes; refuses to start higher tiers until lower tiers
  exist.
- `prompt-implementer` (sonnet) — edits prompts; refuses to bump a
  model-version pin and edit a prompt in the same diff.
- `eval-author` (sonnet) — writes new evals; routed through the shared
  `eval-curator` agent for the "PR may not touch eval + model in same diff"
  enforcement.
- `judge-runner` (haiku) — runs LLM-judge evals; refuses if `--judge-model`
  matches the family of the generator (self-preference bias is 10–25%
  measured; bake the constraint into the agent).
- `trace-triager` (haiku, contributed by `langfuse` addon when installed) —
  reads recent traces, flags regressions, summarises latency and cost
  deltas.

**Skills the sub-domain installs:**

- `three-tier-eval` — the assertion → judge → human ladder with the
  refuse-to-skip ordering.
- `prompt-regression-suite` — runs the pinned eval set on every prompt
  change.
- `model-version-pin` — every LLM call goes through a single pinned
  model-ID env var; pin changes require a typed-token confirmation.

**Default `domain.addons`:** `uv`, `langfuse`, `inspect-ai`, `mlflow` (for
GenAI tracing — MLflow 3.5.1+ ships the GenAI tracing surface), `wandb-mcp`.

### 4.4 `analytics-engineering`

**Purpose:** warehouse-modeled tables, contracts, unit tests, semantic
layer, and lineage — the dbt-centric deliverable. Explicitly broken out
from "data work" per brief A (HE §2 will be updated when this ships).

- **Adopt if:** your deliverable is dbt models (Core or Cloud), with
  contracts, unit tests, a semantic layer, and lineage; you publish a paved
  path for downstream consumers (BI, analysts, ML).
- **Skip if:** you do ad-hoc analysis with no dbt project
  (→ `data-analyst-notebook`); you train models (→ `ml-pipeline`).

**Curated agent team:**

- `analytics-architect` (opus) — designs the layer cake (staging → marts →
  semantic layer); drafts contracts and unit tests before models.
- `dbt-implementer` (sonnet) — writes dbt models, contracts, unit tests;
  auto-activated by prompts matching `dbt-labs/dbt-agent-skills` (10
  vendor-stewarded skills, Feb 9 2026).
- `semantic-modeler` (sonnet, contributed by `dbt-core` addon when
  installed) — owns the semantic-layer manifest; refuses to add a metric
  without a contract and a unit test.
- `contract-author` (sonnet, contributed by `dbt-core` addon when
  installed) — writes contracts before models; refuses model PRs that
  break an existing contract without a migration note.
- `lineage-auditor` (haiku) — refuses to mark "done" if a new mart is not
  referenced by at least one downstream consumer manifest, or if a
  deprecated model still has live consumers.

**Skills the sub-domain installs:**

- `dbt-contract-first` — contracts and unit tests before models.
- `semantic-layer-as-source-of-truth` — every metric defined exactly once,
  in the semantic layer.
- `lineage-doc` — every model has an upstream + downstream comment with
  the lineage edges enumerated.

**Default `domain.addons`:** `uv`, `dbt-core`, `snowflake-mcp`,
`bigquery-mcp` (preview), `databricks-mcp` (preview), `duckdb-mcp` (local
dev). Both preview-tagged warehouse MCPs are included in defaults per the
§4 resolution — analytics-engineering is the most multi-warehouse-by-default
sub-domain in the pack and the `preview: true` flag in each addon's
`MODULE.md` carries the install-time warning.

## 5. Addons — 12 in the initial set

Each addon is module-shaped (`_addons/<addon>/MODULE.md`, `claude-md.md`,
`files/`, optional `settings.fragment.json`, optional `.mcp.json.fragment`,
optional `files/.claude/agents/*.md` to contribute agents). Grouped by the
six categories locked in §2. Each entry ships **what it installs**, an
**Adopt if / Skip if** pair, **which sub-domain(s) it pairs with**, and
**the 2026 source from brief B** that justifies it.

### 5.1 Python toolchain (2)

**`uv`** ships `_addons/uv/MODULE.md`, `_addons/uv/claude-md.md` (a 15-line
snippet teaching `uv lock --frozen` + `uv sync --frozen` + the
`uv add --frozen`-or-block discipline), and
`_addons/uv/files/.claude/hooks/lockfile-frozen.sh` (PostToolUse on `Bash`
matching `pip install\|uv add\|uv pip`; refuses unfrozen installs outside an
explicit deps-update mode). **Adopt if:** you want fast, deterministic
pure-Python environments and a lockfile. **Skip if:** you must use conda
(CUDA / MKL / R); defer to a future `pixi` addon. **Pairs with:** all four
sub-domains. **Source:** Astral `uv` v0.7+ (May 2026) — the cross-domain
Python-toolchain default.

**`polars`** ships `_addons/polars/MODULE.md` and `_addons/polars/claude-md.md`
(a 15-line snippet on lazy-frames-first, `scan_parquet` over `read_parquet`,
`with_columns` over column assignment, and DuckDB-via-`pl.SQLContext` for
heavy joins). **Adopt if:** your DataFrame surface is non-trivial and pandas
would be the only constraint stopping you from going faster. **Skip if:**
your project is pandas-locked by an upstream library; keep pandas as
ecosystem glue. **Pairs with:** `data-analyst-notebook`, `ml-pipeline`.
**Source:** pola-rs v1.40 (April 2026) — the DataFrame default per brief B.

### 5.2 Warehouses / managed MCP (4)

**`snowflake-mcp`** ships `_addons/snowflake-mcp/MODULE.md`,
`_addons/snowflake-mcp/claude-md.md` (a 15-line snippet on managed-MCP,
OAuth-only auth, server-side credentials, and Cortex Agent Evaluations as
the eval surface), and `_addons/snowflake-mcp/.mcp.json.fragment` (wires
the Snowflake Cortex Managed MCP). **Adopt if:** your warehouse is
Snowflake and you have Cortex enabled. **Skip if:** you are not on
Snowflake, or your tenant has not provisioned Managed MCP. **Pairs with:**
`analytics-engineering`, `data-analyst-notebook`. **Source:** Snowflake
Cortex Managed MCP GA Nov 4 2025
(`docs.snowflake.com/en/release-notes/2025/other/2025-11-04-cortex-agents-mcp`).

**`bigquery-mcp`** ships `_addons/bigquery-mcp/MODULE.md`,
`_addons/bigquery-mcp/claude-md.md` (15 lines on GCP WIF for the MCP,
read-only role for the agent, partition-pruning expectations), and
`_addons/bigquery-mcp/.mcp.json.fragment`. **Adopt if:** your warehouse is
BigQuery. **Skip if:** you are not on BigQuery. **Pairs with:**
`analytics-engineering`, `data-analyst-notebook`. **Source:** Google
BigQuery MCP — **preview** (January 2026) — marked `preview: true` in the
`MODULE.md`.

**`databricks-mcp`** ships `_addons/databricks-mcp/MODULE.md`,
`_addons/databricks-mcp/claude-md.md` (15 lines on Unity Catalog ACLs as
the upstream gate, Databricks AI/BI Genie + Mosaic linkage), and
`_addons/databricks-mcp/.mcp.json.fragment`. **Adopt if:** your warehouse /
ML platform is Databricks. **Skip if:** you are not on Databricks.
**Pairs with:** `ml-pipeline`, `analytics-engineering`. **Source:**
Databricks MCP — **Public Preview** (May 7 2026) — marked `preview: true`
in the `MODULE.md`.

**`duckdb-mcp`** ships `_addons/duckdb-mcp/MODULE.md`,
`_addons/duckdb-mcp/claude-md.md` (15 lines on local DuckDB + MotherDuck,
sample-then-scale as the default local pattern), and
`_addons/duckdb-mcp/.mcp.json.fragment` (the MotherDuck official server).
**Adopt if:** you do local exploratory analysis or you want a uniform query
interface across local Parquet and a hosted MotherDuck warehouse.
**Skip if:** your work is exclusively against a remote warehouse and you
have no local exploration surface. **Pairs with:** `data-analyst-notebook`,
`analytics-engineering`. **Source:** MotherDuck official `duckdb-mcp`.

### 5.3 Analytics engineering (1)

**`dbt-core`** ships `_addons/dbt-core/MODULE.md`,
`_addons/dbt-core/claude-md.md` (15 lines on contract-first models, unit
tests before marts, semantic layer as the metric source of truth, and the
dbt remote MCP), `_addons/dbt-core/.mcp.json.fragment` (the dbt remote MCP),
`_addons/dbt-core/files/.claude/skills/*` (the 10 `dbt-labs/dbt-agent-skills`,
with auto-activation by prompt match), and
`_addons/dbt-core/files/.claude/agents/{semantic-modeler.md,contract-author.md}`
(the two specialist agents this addon contributes to the
`analytics-engineering` roster, per the formalised pattern in §2). **Adopt
if:** you use dbt Core or dbt Cloud. **Skip if:** you do not use dbt.
**Pairs with:** `analytics-engineering` (primary). **Source:** dbt-core +
dbt remote MCP GA October 2025; `dbt-labs/dbt-agent-skills` released
February 9 2026.

### 5.4 Notebooks (1)

**`marimo`** ships `_addons/marimo/MODULE.md`, `_addons/marimo/claude-md.md`
(15 lines on marimo-as-`.py`, reactive dependency graph, `marimo pair` for
working with the file in tandem with the agent, `marimo export script` as
the Restart-and-Run-All CI gate), and
`_addons/marimo/files/.claude/skills/marimo-pair-mode/` (recipe for the
agent + human pair-on-notebook workflow). **Adopt if:** you start any new
notebook in 2026 — marimo is the default per HE §2.1 (36% of sampled
Jupyter notebooks are non-reproducible) and brief C (ReviewNB + Recce +
Mineault). **Skip if:** you are locked into an existing Jupyter notebook
estate and the migration cost outweighs the gain. **Pairs with:**
`data-analyst-notebook` (primary). **Source:** marimo-team `marimo pair`
(April 2026); `marimo-team/skills`.

### 5.5 ML tracking (2)

**`mlflow`** ships `_addons/mlflow/MODULE.md`, `_addons/mlflow/claude-md.md`
(15 lines on MLflow 3.5.1+ MCP extra, every run logged, GenAI tracing for
LLM-app use), `_addons/mlflow/.mcp.json.fragment` (the MLflow MCP),
`_addons/mlflow/files/.claude/hooks/require-tracking.sh` (PreToolUse on
`Bash` matching `python\s+train`; refuses invocations that lack
`import mlflow`), and `_addons/mlflow/files/.claude/agents/run-comparator.md`
(the agent the `ml-pipeline` roster references). **Adopt if:** you train
models or run GenAI evals and want an OSS tracker. **Skip if:** you have
chosen W&B and have no need for a second tracker. **Pairs with:**
`ml-pipeline` (primary), `llm-app` (for GenAI tracing). **Source:** MLflow
(Linux Foundation + Databricks); 3.5.1+ ships the MCP extra and the GenAI
tracing surface.

**`wandb-mcp`** ships `_addons/wandb-mcp/MODULE.md`,
`_addons/wandb-mcp/claude-md.md` (15 lines on W&B Weave for GenAI traces,
W&B Reports as the human-review surface), and
`_addons/wandb-mcp/.mcp.json.fragment` (the official `wandb/wandb-mcp-server`).
**Adopt if:** your team is W&B-native. **Skip if:** you are MLflow-native
and adding W&B would duplicate state. **Pairs with:** `ml-pipeline`,
`llm-app`. **Source:** W&B official `wandb/wandb-mcp-server` (2026).

### 5.6 LLM eval & observability (2)

**`langfuse`** ships `_addons/langfuse/MODULE.md`,
`_addons/langfuse/claude-md.md` (15 lines on traces-as-eval-source,
LLM-judge with a cross-family model, dataset/score management as the
regression surface), `_addons/langfuse/.mcp.json.fragment` (Langfuse OSS
MCP), and `_addons/langfuse/files/.claude/agents/trace-triager.md` (the
agent the `llm-app` roster references). **Adopt if:** your LLM app needs
production-grade trace + eval + dataset management with an OSS stack.
**Skip if:** you have committed to a closed-source observability vendor
and Langfuse would duplicate state. **Pairs with:** `llm-app` (primary).
**Source:** Langfuse (OSS, YC W23) — the OSS eval/observability default per
brief B.

**`inspect-ai`** ships `_addons/inspect-ai/MODULE.md`,
`_addons/inspect-ai/claude-md.md` (15 lines on dataset → solver → scorer,
Docker-sandboxed evals, the 200+ pre-built evals in
`UKGovernmentBEIS/inspect_evals`, and the rule that Inspect AI can wrap
Claude Code, Codex, and Gemini CLI as the agent under test), and
`_addons/inspect-ai/files/.claude/skills/inspect-eval-author/` (recipe for
authoring a new task). **Adopt if:** you need rigorous, reproducible LLM
evals — especially for agentic systems. **Skip if:** your eval surface is
purely assertion-style and you do not need sandbox isolation. **Pairs
with:** `llm-app` (primary), `ml-pipeline`. **Source:** UK AISI
`inspect-ai` (Apache-2.0, May 2026).

### 5.7 Deferred to contrib (not first-party in this spec)

`pixi` (only when conda / CUDA / MKL is mandatory; defer until the conda
contingent surfaces it), `braintrust` (closed-source equivalent of
`langfuse`; users who want it can install via `addons-contribute-agents`
patterns), `deepeval` (overlaps `inspect-ai` and `langfuse`), `felt-mcp`
(single-MCP-across-warehouses; useful but not as a first-party addon),
`jupyter-mcp` (only adopted when an existing Jupyter estate cannot migrate
to marimo; defer to a follow-up cycle that scopes the migration path).

## 6. Shared hooks, agents, and MCP defaults

### 6.1 Shared hooks (`templates/data/files/.claude/hooks/`)

Installed with every data sub-domain. Two are promoted from the current
thin recipe; two are new for 2026.

- **`block-unbounded-sql.sh`** *(promoted from
  `templates/data/files/.claude/hooks/block-unbounded-sql.sh`)* — PreToolUse
  on `Bash` and warehouse-MCP query tools. Blocks `SELECT` without
  `WHERE` / `LIMIT` / `TABLESAMPLE`; blocks `DROP` / `TRUNCATE` /
  `DELETE` / `UPDATE` / `INSERT` / `MERGE` / `ALTER`. Exit 2 with reason on
  stderr.
- **`leakage-sentinel.sh`** *(promoted)* — PreToolUse on `Write|Edit`.
  Regex-checks Python edits for `.fit()` before `train_test_split`, scaler
  `.fit()` on full `X` outside a `Pipeline`, t-tests in a loop without
  `multipletests`, `.shift(-N)` look-ahead. (LeakageDetector 2.0,
  arXiv 2509.15971, Sep 2025, is the published static analyzer this hook
  encodes; the hook stays regex-based for speed; an AST upgrade is a
  follow-up cycle.)
- **`audit-log-warehouse-query.sh`** *(new)* — PostToolUse on every
  warehouse-MCP query tool and on `Bash` matching the warehouse CLI set
  (`snow sql`, `bq query`, `databricks sql`, `duckdb`). Appends
  `(timestamp, session_id, tool_name, query, row_count, byte_count, cost_estimate)`
  to `.claude/logs/agent_audit.jsonl`. Mirrors the Databricks Unity AI
  Gateway pattern. Required for EU AI Act Annex IV (Aug 2 2026); the
  rebuttable-compliance presumption for NIST AI RMF / ISO 42001 attaches to
  shops that produce this log.
- **`block-static-warehouse-creds.sh`** *(new)* — PreToolUse on `Bash` and
  on tool-start lifecycle. Refuses to start (exit 2) if any of
  `SNOWFLAKE_PASSWORD`, `BIGQUERY_SERVICE_ACCOUNT_KEY_JSON`,
  `DATABRICKS_TOKEN`, `DATABRICKS_PERSONAL_ACCESS_TOKEN`, or
  `MOTHERDUCK_TOKEN` is present in env when a Managed-MCP / OAuth
  alternative exists for that warehouse. Codifies the post-ShinyHunters
  (April 2026) credential-posture default: agent hosts do not hold
  long-lived warehouse creds.

All hooks use `bash -n`-clean exit-2 patterns so they survive
`--dangerously-skip-permissions` (HE §3.9 invariant).

### 6.2 Shared agents (`templates/data/files/.claude/agents/`)

Three cross-cutting agents installed with every data sub-domain. All obey
the four `AGENT_ROLES.md` invariants: least-privilege tools (auditors are
read-only; only implementers get `Edit/Write/Bash`, scope-bounded), model
routing, typed return contracts, and evaluators-in-a-different-family.

- **`eval-curator`** (sonnet, read-only + diff-vetoing return contract) —
  Default-FAIL contract per Anthropic harness papers (Nov 2025 + Mar 2026).
  Refuses any PR whose diff touches both `eval/**` and model code
  (`src/**`, `models/**`, `prompts/**`, dbt `models/**`). Returns
  `{verdict: PASS|CHANGES-REQUESTED, files_in_eval: [...], files_in_model:
  [...], reason: "..."}`. Bounded behaviour: never edits; only vetoes.
- **`dataset-card-author`** (sonnet) — Emits a dataset card structured for
  the NIST AI RMF Map function and EU AI Act Annex IV. For every new
  training / eval / source dataset, the agent produces a card with
  intended use, provenance + chain of custody, schema + dtypes,
  collection method, PII posture, license, and known biases. Required
  shape for the rebuttable-compliance presumption that NIST AI RMF /
  ISO 42001 implementations enjoy under Texas RAIGA, Colorado AI Act, and
  California AI Transparency Act.
- **`query-provenance-auditor`** (haiku, read-only) — For every metric in
  a report / notebook output, traces back to a logged query + a data hash
  in `.claude/logs/agent_audit.jsonl`. Refuses "done" if any reported
  number lacks a (query, data hash) pair. Encodes HE §2.9 anti-pattern #2
  ("'looks reasonable' outputs — numbers without provenance are
  hallucinations with extra steps") as a Default-FAIL hard constraint.

### 6.3 Shared MCP fragment defaults

`templates/data/files/.mcp.json.fragment` is **empty by default**, mirroring
the devops domain-level MCP fragment. Per-warehouse and per-tracker MCPs
are installed by addons (`snowflake-mcp`, `bigquery-mcp`, `databricks-mcp`,
`duckdb-mcp`, `mlflow`, `wandb-mcp`, `langfuse`, `dbt-core`). The
`templates/data/files/.claude/context7.mcp.json.fragment` follows the same
shared rule as web and devops: *`references.md` is the curated baseline;
for exact current library/framework API syntax, query Context7
(`resolve-library-id` then `query-docs`).*

### 6.4 Addon-shipped hooks

Two of the twelve addons currently ship their own hook; the rest contribute
agents, MCP fragments, skills, or claude-md snippets only. The shared
warehouse-credential and warehouse-query hooks in §6.1 cover the
cross-warehouse posture, so warehouse-MCP addons need no additional hook of
their own. Mirrors the devops §7.2 consolidation.

| Addon | Hook | Cadence | Behaviour |
|---|---|---|---|
| `uv` | `lockfile-frozen.sh` | PostToolUse on `Bash` matching `pip install\|uv add\|uv pip` | Refuses unfrozen installs outside an explicit deps-update mode; enforces `uv lock --frozen` + `uv sync --frozen` discipline. |
| `mlflow` | `require-tracking.sh` | PreToolUse on `Bash` matching `python\s+train` | Refuses `python train…` invocations whose target script lacks `import mlflow`. Pairs with `ml-pipeline`'s tracking-required posture. |

All addon hooks share the same `bash -n`-clean exit-2 contract as the
shared hooks so they survive `--dangerously-skip-permissions` (HE §3.9
invariant).

## 7. Dossier model

`references.md` files follow the same fixed shape as web and devops:
`Verified: 2026-05 · Refresh: re-verify version-sensitive notes each
quarter.` header, then `Current best practices / Common gotchas /
Version-sensitive notes / Cited links` (≥5 cited links, each annotated with
what it is good for). The research dossier produced during brainstorming
(briefs A/B/C, ~3500 words, 30+ cited links) distributes across the
domain-level dossier plus one per sub-domain.

- `templates/data/references.md` — cross-cutting threads: post-ShinyHunters
  warehouse-credential posture (Managed-MCP / OAuth-only), EU AI Act
  Annex IV audit-log obligations and NIST AI RMF / ISO 42001 rebuttable
  presumption, the vendor-MCP / agent-skill GA wave (Snowflake Cortex,
  dbt remote, BigQuery, Databricks, MotherDuck, MLflow, W&B, Langfuse,
  Inspect AI), data-leakage taxonomy (LeakageDetector 2.0, arXiv 2509.15971),
  Anthropic harness papers (Nov 2025 + Mar 2026) on `eval-curator`
  contracts.
- `templates/data/data-analyst-notebook/references.md` — marimo idioms
  (reactive graph, `marimo pair`, `marimo export script` as the
  Restart-and-Run-All CI gate), DuckDB-vs-Snowflake decision matrix for
  local-then-remote workflows, chart-critic canonical-sins reference
  (Mineault rules; ReviewNB + Recce sources), sample-then-scale guidance,
  the 36% non-reproducible-Jupyter statistic from HE §2.1.
- `templates/data/ml-pipeline/references.md` — MLflow 3.5.1+ vs W&B Weave
  comparison and tracking-required mechanics, leakage-detector references
  (arXiv 2509.15971 + the regex→AST upgrade follow-up), point-in-time
  correctness patterns and feature-store leakage guards, Databricks
  Mosaic / Unity Catalog ACL flow, eval-suite-isolated-package conventions.
- `templates/data/llm-app/references.md` — Husain & Shankar three-tier
  eval (LLM Evals FAQ, Jan 15 2026), evaluator-in-a-different-family rule
  (10–25% self-preference bias), Inspect AI vs Langfuse selection
  (sandbox-isolated agent eval vs trace-as-eval-source), Anthropic
  Default-FAIL contract for `eval-curator`, MLflow 3.5.1+ GenAI tracing
  surface, model-version-pin discipline.
- `templates/data/analytics-engineering/references.md` —
  `dbt-labs/dbt-agent-skills` (10 vendor-stewarded skills, Feb 9 2026), dbt
  remote MCP (GA Oct 2025), dbt MetricFlow + semantic-layer-as-source-of-
  truth, dbt contracts + unit tests (`.tftest`-style discipline), semantic-
  layer-vs-text-to-SQL benchmark, lineage-doc conventions.

## 8. Migration & retirement

Phase B follows the meta-spec §3 commit sequence (a 10-step cycle proven by
the devops graduation, May 21–22 2026). Each step is a separate commit;
the v1 thin recipe stays present through every intermediate commit so both
shapes assemble until the very last commit — same approach `web/` and
`devops/` took.

1. `docs: shared data CLAUDE.md snippet` — `templates/data/domain.claude-md.md`.
2. `feat: shared data MCP fragments` —
   `templates/data/files/.mcp.json.fragment` (empty default) +
   `templates/data/files/.claude/context7.mcp.json.fragment`.
3. `docs: data cross-cutting reference dossier` —
   `templates/data/references.md`, dated `Verified: 2026-05`, ≥5 cited
   links, fixed `Current best practices / Common gotchas / Version-sensitive
   notes / Cited links` shape.
4. `feat: data audit-log-warehouse-query.sh + block-static-warehouse-creds.sh
   guard hooks` — the two new shared hooks (the two promoted hooks move in
   step 6 with their sub-domain, since they live in `templates/data/files/`
   alongside the thin recipe until the last commit).
5. `feat: shared data agents (eval-curator, dataset-card-author,
   query-provenance-auditor)` — three cross-cutting agents at
   `templates/data/files/.claude/agents/`.
6. **Per sub-domain, one commit each** — four commits:
   `feat: data data-analyst-notebook sub-domain`,
   `feat: data ml-pipeline sub-domain`,
   `feat: data llm-app sub-domain`,
   `feat: data analytics-engineering sub-domain`. Each ships
   `SUBDOMAIN.md` + `harness.config.yml` + `claude-md.md` + `references.md`
   + curated specialist agents + curated skills +
   `files/.claude/settings.fragment.json`. The shared hooks (`block-unbounded-sql.sh`,
   `leakage-sentinel.sh`) move from the thin-recipe path to
   `templates/data/files/.claude/hooks/` in the first of these commits so
   they remain installed when assembling either shape.
7. **Per addon category, one commit each** — six commits:
   `feat: data python-toolchain addons (uv, polars)`,
   `feat: data warehouse-mcp addons (snowflake-mcp, bigquery-mcp,
   databricks-mcp, duckdb-mcp)`,
   `feat: data analytics-engineering addon (dbt-core)`,
   `feat: data notebook addon (marimo)`,
   `feat: data ml-tracking addons (mlflow, wandb-mcp)`,
   `feat: data llm-eval addons (langfuse, inspect-ai)`.
8. `test: extend assemble-coverage + structure-lint to discover data pack` —
   the test framework already globs `templates/*/`; this commit adds any
   explicit assertions the framework requires for the four new sub-domain
   configs and a representative addon combination per sub-domain.
9. `docs: flip data to curated 3-layer; update HE §2 analytics-engineering
   split` — flips the `data` row in `docs/reference/domains.md` to
   "curated (3-layer)", adds a `## The data/ pack (curated)` section,
   updates `docs/how-to/pick-a-recipe.md` to point data at the sub-domain
   decision guide, and strikes the v1-thin / pending-curation language in
   `docs/HARNESS_ENGINEERING.md` §2 plus the analytics-engineering-lumping
   correction.
10. **Final commit:** `feat: retire v1 thin data recipe in favor of curated
    pack` — `git rm templates/data/claude-md.md`,
    `git rm templates/data/harness.config.yml`,
    `git rm templates/data/README.md`, `git rm -r templates/data/files`
    (the shared hooks and the `ensuring-reproducibility` skill already
    moved to `templates/data/files/.claude/...` and the sub-domain skill
    paths in step 6; nothing is lost). Remove the corresponding
    `assert_assembles` line in `templates/tests/run.sh`. Backward
    compatibility ends here; the sub-domain configs are the assemble unit
    going forward — one of
    `./assemble.sh data/data-analyst-notebook/harness.config.yml .`,
    `./assemble.sh data/ml-pipeline/harness.config.yml .`,
    `./assemble.sh data/llm-app/harness.config.yml .`, or
    `./assemble.sh data/analytics-engineering/harness.config.yml .`.

## 9. Success criteria — representative addon combinations

`assemble.sh` must produce a valid harness for each of the 4 data sub-domains
on its own. Beyond the per-sub-domain baseline, the following representative
addon combinations must assemble cleanly without lost fragments, broken
agent frontmatter, or `bash -n` hook failures. The Phase B step 8 commit
(`test: extend assemble-coverage + structure-lint to discover data pack`)
encodes these as `assert_assembles` lines; this list **is** the test target.

```bash
./assemble.sh data/data-analyst-notebook/harness.config.yml /tmp/test-out
```
Sub-domain default set — exercises `uv + polars + marimo + duckdb-mcp +
snowflake-mcp` + 3 shared agents + 4 shared hooks + `notebook-architect` /
`notebook-implementer` / `chart-critic` / `restart-run-all-checker` rosters.
Covers the GA-only warehouse posture for `data-analyst-notebook`.

```bash
./assemble.sh data/ml-pipeline/harness.config.yml /tmp/test-out
```
Sub-domain default set — exercises `uv + polars + mlflow + wandb-mcp +
inspect-ai + databricks-mcp` (the last being preview-tagged) + the addon-
contributed `run-comparator` agent (from `mlflow`) + the `require-tracking.sh`
addon hook. Verifies the addons-contribute-agents pattern and the
preview-tagged-in-default resolution from §4.

```bash
./assemble.sh data/llm-app/harness.config.yml /tmp/test-out
```
Sub-domain default set — exercises `uv + langfuse + inspect-ai + mlflow +
wandb-mcp` + the addon-contributed `trace-triager` agent (from `langfuse`) +
the three-tier-eval / prompt-regression / model-version-pin skills.

```bash
./assemble.sh data/analytics-engineering/harness.config.yml /tmp/test-out
```
Sub-domain default set with **all four warehouses including both preview
ones** — exercises `uv + dbt-core + snowflake-mcp + bigquery-mcp +
databricks-mcp + duckdb-mcp` + the addon-contributed `semantic-modeler` /
`contract-author` agents (from `dbt-core`) + the 10 dbt-labs skills. This is
the **highest-coverage assemble test** in the pack: four warehouse MCP
fragments merging into a single `.mcp.json`, two addon-contributed agents,
ten addon-contributed skills, plus the four shared hooks. If this passes,
fragment-merge and file-name-collision behaviour is verified across the
warehouse-MCP family.

```bash
./assemble.sh data/ml-pipeline/harness.config.yml /tmp/test-out \
  --addons uv,polars
```
Cross-sub-domain Python-toolchain minimum — exercises the `uv + polars`
combination on `ml-pipeline` without warehouse or tracker addons. Verifies
the toolchain addons stand alone, and that `lockfile-frozen.sh` (the only
hook either toolchain addon ships) installs without conflict.

```bash
./assemble.sh data/data-analyst-notebook/harness.config.yml /tmp/test-out \
  --addons uv,polars,marimo,duckdb-mcp,snowflake-mcp,bigquery-mcp,databricks-mcp
```
Notebook-with-all-warehouses opt-in — exercises the same warehouse-MCP
fragment-merge as analytics-engineering but on `data-analyst-notebook`,
where preview warehouses are opt-in rather than default. Verifies the
preview-tagged addons assemble identically whether installed by default set
or by opt-in.

## 10. Risks & open questions

- **CLAUDE.md length stacking.** A loaded `data-analyst-notebook` install
  pulls base + modules + `data/domain.claude-md.md` +
  `data-analyst-notebook/claude-md.md` + 5 addon claude-md snippets (`uv`,
  `polars`, `marimo`, `duckdb-mcp`, `snowflake-mcp`); `analytics-engineering`
  is worse — same shared layer plus 6 addon snippets including `dbt-core`'s
  contract-first guidance. Stacked CLAUDE.md context bloat is real. Mitigation
  inherits devops's: cap every addon claude-md at 15 lines (already specified
  in §5 entries), cap domain.claude-md and sub-domain claude-md at 30 lines,
  and prune ruthlessly when the threshold is breached during Phase B.
- **Addon file-name collisions are unvalidated.** `mlflow`, `wandb-mcp`,
  `langfuse` are all `llm-app` defaults; if two ship an agent or hook file
  with the same name, `assemble.sh` silently overwrites the earlier copy.
  This design picks unique agent names by hand (`run-comparator` ←
  `mlflow`; `trace-triager` ← `langfuse`; `semantic-modeler` /
  `contract-author` ← `dbt-core`) and the only addon-shipped hooks are
  `uv/lockfile-frozen.sh` and `mlflow/require-tracking.sh` (no overlap).
  Accepted as a known limitation matching devops's stance; documented in
  `docs/AGENT_ROLES.md` when this design implements.
- **Vendor-MCP availability is the user's problem.** `snowflake-mcp`,
  `bigquery-mcp`, `databricks-mcp`, `duckdb-mcp`, `mlflow`, `wandb-mcp`,
  `langfuse`, and `dbt-core` all wire vendor MCPs that the user must
  provision (Cortex tenant for Snowflake, GCP project + WIF for BigQuery,
  Unity Catalog + workspace for Databricks, MotherDuck account or local
  install for DuckDB, tracker host + creds for MLflow / W&B, Langfuse
  deployment, dbt Cloud account or remote-MCP token). `assemble.sh` writes
  the MCP config but cannot validate the user has access; assemble succeeds,
  runtime fails the first time the agent calls the MCP. Mitigation: each
  addon's `MODULE.md` opens with a one-paragraph "Provision before install"
  block enumerating what the user must have ready.
- **Preview-status drift on BigQuery / Databricks MCPs.** `bigquery-mcp`
  is preview as of Jan 2026; `databricks-mcp` is Public Preview as of May 7
  2026. When either moves to GA, the §4 default-set resolution and the
  install-time warning posture both need re-validation — and if either is
  withdrawn / renamed (the cycle that nuked `arize-phoenix-mcp` early in 2026
  is the precedent), the addon shipping the now-stale MCP config breaks
  assemble for any sub-domain that includes it in defaults. Mitigation: the
  quarterly `Verified: 2026-MM` refresh on `references.md` is the formal
  catch-point; addon `MODULE.md` annotates `preview: true` explicitly so
  refresh sweeps know which addons need re-verification first.
- **Evaluator-model-family drift in `judge-runner`.** The `llm-app`
  `judge-runner` agent refuses if `--judge-model` matches the generator's
  family (10–25% self-preference bias). Family-membership is currently a
  hand-maintained allowlist embedded in the agent spec; new model releases
  (a new GPT family, a new Anthropic generation, a new Gemini SKU) require
  updating that allowlist or the rule degrades to false-negatives. Mitigation:
  the `llm-app/references.md` quarterly refresh names the allowlist as a
  refresh target; the rule is documented as policy-not-static-data so users
  know to update on model GAs.

## 11. Non-goals

- No changes to `_base/`, `_modules/`, `assemble.sh`, or the
  `harness.config.yml` schema. The mechanics are settled and reused
  unchanged.
- No new top-level domains. Twelve domains is the agreed catalog (`generic`
  is base-only and not slated for graduation).
- No retroactive change to the already-curated `web/` or `devops/` packs.
- No changes to the test framework (`templates/tests/`). The four new
  data sub-domains plug into the existing discovery.
- No public maintainer how-to about the graduation process itself. The
  cycle, the research-agent fan-out, the commit order — none of it lands
  in `docs/how-to/`, `CONTRIBUTING.md`, or `README.md`. The only public
  artifacts from this cycle are the new pack itself and the three doc
  files touched in step 9 (`domains.md`, `pick-a-recipe.md`,
  `HARNESS_ENGINEERING.md` §2).
