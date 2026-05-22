# Data Domain Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure `templates/data/` from a v1 thin recipe into a curated three-layer domain pack — four sub-domains (`data-analyst-notebook`, `ml-pipeline`, `llm-app`, `analytics-engineering`) and twelve day-1 addons — without changing `_base/`, `_modules/`, or `assemble.sh`.

**Architecture:** The pack reuses every mechanic the `web/` and `devops/` packs established (`assemble.sh` v2 layering, `.mcp.json.fragment` deep-merge, agent-team resolution). All new content lands under `templates/data/`. The v1 thin recipe (`templates/data/harness.config.yml`, `claude-md.md`, `README.md`, flat `files/`) is preserved through every intermediate task so both shapes assemble; the thin recipe is deleted in the final task.

**Tech Stack:** Bash (hooks, `assemble.sh`), `jq` (JSON merge + validation), Markdown (CLAUDE.md / agents / skills / dossiers), YAML (harness manifests), JSON (settings + MCP fragments). No build system; verification is the existing `templates/tests/run.sh` extended with new assertions.

**Source spec:** `docs/superpowers/specs/2026-05-22-data-domain-pack-design.md`

---

## File Structure

**Modified:**
- `templates/data/harness.config.yml` — deleted in final task (v1 thin recipe retirement)
- `templates/data/claude-md.md` — deleted in final task
- `templates/data/README.md` — replaced by `DOMAIN.md` in Task 2; deleted in final task
- `templates/data/files/.claude/settings.fragment.json` — updated to register the two new shared hooks alongside the two existing ones
- `templates/tests/run.sh` — adds assertions for 4 new sub-domain configs and 6 representative addon combinations; removes the assertion for the v1 thin `data/harness.config.yml` in the final task
- `docs/reference/domains.md` — flip `data` row to "curated (3-layer)"; add sub-domain table
- `docs/how-to/pick-a-recipe.md` — point data at the sub-domain decision guide
- `docs/HARNESS_ENGINEERING.md` §2 — strike v1-thin / pending-curation language; add the analytics-engineering split correction

**Created — shared domain layer:**
- `templates/data/DOMAIN.md`
- `templates/data/references.md`
- `templates/data/domain.claude-md.md`
- `templates/data/files/.mcp.json.fragment` (auto-merged shared MCP defaults — empty by design; addons populate per-vendor)
- `templates/data/files/.claude/context7.mcp.json.fragment` (merged only when `docs.context7_mcp: true`)
- `templates/data/files/.claude/hooks/audit-log-warehouse-query.sh` (new)
- `templates/data/files/.claude/hooks/block-static-warehouse-creds.sh` (new)
- `templates/data/files/.claude/agents/eval-curator.md`
- `templates/data/files/.claude/agents/dataset-card-author.md`
- `templates/data/files/.claude/agents/query-provenance-auditor.md`

**Created — sub-domains (4 × ~10 files each):**
- `templates/data/<sub-domain>/SUBDOMAIN.md`
- `templates/data/<sub-domain>/harness.config.yml`
- `templates/data/<sub-domain>/references.md`
- `templates/data/<sub-domain>/claude-md.md`
- `templates/data/<sub-domain>/files/.claude/settings.fragment.json`
- `templates/data/<sub-domain>/files/.claude/agents/*.md` (4–5 specialist agents per sub-domain)
- `templates/data/<sub-domain>/files/.claude/skills/<skill>/SKILL.md` (3 skills per sub-domain)

**Created — addons (12 × ~3–5 files each):**
- `templates/data/_addons/<addon>/MODULE.md`
- `templates/data/_addons/<addon>/claude-md.md`
- `templates/data/_addons/<addon>/files/...` (varies: hooks, agents, MCP fragments, skills)

The pre-existing thin-recipe files at `templates/data/files/.claude/hooks/block-unbounded-sql.sh`, `templates/data/files/.claude/hooks/leakage-sentinel.sh`, and `templates/data/files/.claude/skills/ensuring-reproducibility/` stay in place — `templates/data/files/` is **also** the curated pack's shared `files/` tree (same path), so no actual `mv` is required. Each task is one logical commit.

---

## Phase 1 — Baseline confirmation

### Task 1: Confirm the test runner is green before any change

**Files:**
- Read only: `templates/tests/run.sh`

- [ ] **Step 1: Run the existing harness**

Run: `cd templates && ./tests/run.sh`
Expected: every recipe assertion (`recipe:generic`, `recipe:web`, `recipe:data`, `recipe:devops`, … `recipe:ops`) plus all web/devops sub-domain and addon assertions PASS; `Failed: 0`; exit 0.

If any test fails, stop and resolve the regression before continuing — this plan only adds and migrates; it never breaks existing recipes until Task 20.

- [ ] **Step 2: Note the baseline pass count**

Capture the `Passed: N` line. Every subsequent task in this plan keeps this number ≥ baseline until Task 20 (which intentionally drops the thin `data/harness.config.yml` assertion and re-raises with 4 new sub-domain assertions + 6 addon-combo assertions).

No commit — this task only verifies state.

---

## Phase 2 — Pack skeleton + shared layer

### Task 2: Create the data pack index (`DOMAIN.md`)

**Files:**
- Create: `templates/data/DOMAIN.md`

- [ ] **Step 1: Write `DOMAIN.md`**

```markdown
# Data domain pack

Curated harness content for data teams: exploratory analysis, ML pipelines,
LLM applications, and analytics engineering.

> **Status: curated three-layer pack** (third after `web/` and `devops/`).
> Specialised via per-warehouse MCP, per-toolchain, per-tracker, and per-eval
> addons.

## Sub-domain decision guide

| Sub-domain | Adopt if… |
|---|---|
| [`data-analyst-notebook`](data-analyst-notebook/) | You do exploratory analysis or ad-hoc reporting; your output is a reactive, reproducible notebook that reads from a warehouse and produces charts, tables, or memos. |
| [`ml-pipeline`](ml-pipeline/) | You train models, run evaluation suites, package model artifacts, register them, or run inference services; you need tracking discipline and lockfile-frozen environments. |
| [`llm-app`](llm-app/) | You build LLM products — RAG, agentic pipelines, prompt-driven products — where the unit test is an eval suite, not a metric. |
| [`analytics-engineering`](analytics-engineering/) | Your deliverable is dbt models with contracts, unit tests, a semantic layer, and lineage; you publish a paved path for downstream consumers. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance and the curated agent team.

## Addons

Composable extras declared in `domain.addons`. Each sub-domain config ships sensible defaults; override as needed.

| Addon | Pairs with | Purpose |
|---|---|---|
| `uv` | all four | Astral `uv` Python toolchain; lockfile-frozen install hook. |
| `polars` | `data-analyst-notebook`, `ml-pipeline` | Polars + lazy-frame idioms; DuckDB-via-SQLContext for heavy joins. |
| `snowflake-mcp` | `analytics-engineering`, `data-analyst-notebook` | Snowflake Cortex Managed MCP (GA Nov 4 2025); server-side credentials. |
| `bigquery-mcp` | `analytics-engineering`, `data-analyst-notebook` | Google BigQuery MCP (preview Jan 2026); GCP WIF + read-only role. |
| `databricks-mcp` | `ml-pipeline`, `analytics-engineering` | Databricks MCP (Public Preview May 7 2026); Unity Catalog ACLs. |
| `duckdb-mcp` | `data-analyst-notebook`, `analytics-engineering` | MotherDuck official `duckdb-mcp`; local-then-remote uniform interface. |
| `dbt-core` | `analytics-engineering` | dbt-core + dbt remote MCP (GA Oct 2025) + `dbt-labs/dbt-agent-skills` (Feb 9 2026); contributes `semantic-modeler` and `contract-author` agents. |
| `marimo` | `data-analyst-notebook` | marimo-team reactive `.py` notebooks + `marimo pair` (April 2026). |
| `mlflow` | `ml-pipeline`, `llm-app` | MLflow 3.5.1+ MCP extra + GenAI tracing; ships `require-tracking.sh` hook and `run-comparator` agent. |
| `wandb-mcp` | `ml-pipeline`, `llm-app` | W&B official `wandb-mcp-server`; Weave + Reports. |
| `langfuse` | `llm-app` | Langfuse OSS LLM observability; contributes `trace-triager` agent. |
| `inspect-ai` | `llm-app`, `ml-pipeline` | UK AISI `inspect-ai` (Apache-2.0, May 2026); 200+ pre-built evals; sandbox-isolated. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`_addons/`](_addons/).

## Assemble

The sub-domain config is the assemble unit. Pass it directly to `assemble.sh`:

```bash
./assemble.sh data/data-analyst-notebook/harness.config.yml ./my-notebook-project
./assemble.sh data/ml-pipeline/harness.config.yml ./my-ml-project
./assemble.sh data/llm-app/harness.config.yml ./my-llm-app
./assemble.sh data/analytics-engineering/harness.config.yml ./my-dbt-project
```

## See also

- [`docs/how-to/pick-a-recipe.md`](../../docs/how-to/pick-a-recipe.md) — decision flow including the sub-domain choice.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain and addon catalog.
- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §2 — engineering guide for the data domain.
- [`references.md`](references.md) — curated data-platform dossier (refresh quarterly).
```

- [ ] **Step 2: Validate the file is syntactically clean**

Run:
```bash
test -f templates/data/DOMAIN.md && head -1 templates/data/DOMAIN.md | grep -q '^# Data domain pack' && echo OK
```
Expected: `OK`.

- [ ] **Step 3: Commit**

```bash
git add templates/data/DOMAIN.md
git commit -m "docs: data pack index (DOMAIN.md)"
```

---

### Task 3: Write the shared data CLAUDE.md snippet

**Files:**
- Create: `templates/data/domain.claude-md.md`

This file is the shared rules layer that every data sub-domain inherits. Capped at 30 lines per spec §10 mitigation.

- [ ] **Step 1: Write `domain.claude-md.md`**

```markdown
## Data domain

### Warehouse posture
- **Warehouse is read-only.** DDL/DML goes through reviewed migration PRs,
  never agent queries. `block-unbounded-sql` hook enforces; do not bypass.
- **Sample then scale.** Run `LIMIT 1000` / `TABLESAMPLE` first, validate the
  shape and dtypes, then run the full query.
- **No static warehouse credentials on the agent host.** Managed-MCP / OAuth
  only. `block-static-warehouse-creds` refuses to start if
  `SNOWFLAKE_PASSWORD` or equivalent is set when a Managed-MCP alternative
  exists.

### Provenance and audit
- **Every reported metric traces to a logged query + a data hash.** Numbers
  without provenance are hallucinations with extra steps. The
  `query-provenance-auditor` shared agent enforces.
- **All warehouse queries are audit-logged** via `audit-log-warehouse-query`.
  The log feeds the EU AI Act Annex IV (Aug 2 2026) compliance evidence path
  and the NIST AI RMF / ISO 42001 rebuttable presumption.

### Eval discipline
- **Evals live in a package separate from model / prompt code.** The
  `eval-curator` shared agent refuses any PR diff that touches both at once.
  This is a Default-FAIL contract per the Anthropic harness papers (Nov 2025,
  Mar 2026).
- **Use a judge model from a different family than the generator.** Same-family
  judges introduce 10–25% self-preference bias.

### Datasets
- **Every dataset gets a dataset card** via the `dataset-card-author` shared
  agent — intended use, provenance, schema, PII posture, license, biases.
```

- [ ] **Step 2: Validate length and shape**

Run:
```bash
wc -l templates/data/domain.claude-md.md
```
Expected: ≤ 30 lines.

- [ ] **Step 3: Commit**

```bash
git add templates/data/domain.claude-md.md
git commit -m "docs: shared data CLAUDE.md snippet"
```

---

### Task 4: Create the MCP fragments

**Files:**
- Create: `templates/data/files/.mcp.json.fragment`
- Create: `templates/data/files/.claude/context7.mcp.json.fragment`

- [ ] **Step 1: Write the shared `.mcp.json.fragment` (empty by design)**

`templates/data/files/.mcp.json.fragment`:

```json
{ "mcpServers": {} }
```

Empty by design — addons populate per-vendor (`snowflake-mcp`, `bigquery-mcp`, `databricks-mcp`, `duckdb-mcp`, `mlflow`, `wandb-mcp`, `langfuse`, `dbt-core`). Mirrors devops's empty domain-level MCP fragment.

- [ ] **Step 2: Write the Context7 MCP fragment**

`templates/data/files/.claude/context7.mcp.json.fragment`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

This fragment is only merged when `docs.context7_mcp: true` in the sub-domain's `harness.config.yml`. The shared rule: *`references.md` is the curated baseline; for exact current library/framework API syntax, query Context7 (`resolve-library-id` then `query-docs`).*

- [ ] **Step 3: Validate both fragments parse as JSON**

Run:
```bash
jq -e . templates/data/files/.mcp.json.fragment \
        templates/data/files/.claude/context7.mcp.json.fragment >/dev/null \
  && echo OK
```
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add templates/data/files/.mcp.json.fragment \
        templates/data/files/.claude/context7.mcp.json.fragment
git commit -m "feat: shared data MCP fragments"
```

---

### Task 5: Write the cross-cutting data dossier (`references.md`)

**Files:**
- Create: `templates/data/references.md`

The dossier follows the same fixed shape as web and devops: `Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.` header, then `Current best practices / Common gotchas / Version-sensitive notes / Cited links` (≥5 cited links, each annotated).

- [ ] **Step 1: Write `references.md`**

```markdown
# Data domain — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

This dossier is the cross-cutting baseline. Per-sub-domain dossiers at
`data-analyst-notebook/references.md`, `ml-pipeline/references.md`,
`llm-app/references.md`, and `analytics-engineering/references.md` cover
sub-domain-specific threads.

## Current best practices

- **Warehouse credential posture is Managed-MCP / OAuth-only.** Static
  warehouse credentials (`SNOWFLAKE_PASSWORD`, `BIGQUERY_SERVICE_ACCOUNT_KEY_JSON`,
  `DATABRICKS_TOKEN`, `MOTHERDUCK_TOKEN`) on the agent host are the failure
  mode per the ShinyHunters / Anodot supply-chain breach (April 2026). Use
  the Snowflake Cortex Managed MCP (GA Nov 4 2025), the Google BigQuery MCP
  (preview Jan 2026), the Databricks MCP (Public Preview May 7 2026), or the
  MotherDuck `duckdb-mcp`.
- **EU AI Act Annex IV (Aug 2 2026) makes immutable agent-tool-call audit
  logging statutory** for high-risk systems. The rebuttable-compliance
  presumption attaches to NIST AI RMF / ISO 42001 implementations under
  Texas RAIGA, Colorado AI Act, and California AI Transparency Act. The
  shared `audit-log-warehouse-query.sh` hook emits Annex-IV-shaped records;
  the `dataset-card-author` agent emits the dataset-card surface NIST AI
  RMF Map requires.
- **Eval-suite-as-separate-package is the unit-test surface for ML and LLM
  work.** The `eval-curator` shared agent Default-FAIL contract refuses any
  PR diff that touches both `eval/**` and model/prompt code. Inspired by
  Anthropic harness papers (Nov 2025 + Mar 2026).
- **Use a judge model from a different family than the generator.** 10–25%
  self-preference bias is measured. The `llm-app` `judge-runner` agent
  refuses if `--judge-model` family matches generator family.

## Common gotchas

- **Editing `.ipynb` JSON blind silently mangles cell metadata.** Route
  notebook edits through `marimo` (the addon) or through a Jupyter MCP;
  never raw `NotebookEdit` on `.ipynb`. The Restart-and-Run-All gate is the
  only acceptance test for notebooks (ReviewNB + Recce + Mineault 2026).
- **Leakage is the second-most-common silent ML failure.** `.fit()` before
  `train_test_split`, scaler `.fit()` on full `X` outside a `Pipeline`,
  t-test in a loop without `multipletests`, `.shift(-N)` look-ahead. The
  `leakage-sentinel.sh` hook is regex-based; LeakageDetector 2.0 (arXiv
  2509.15971, Sep 2025) is the published static analyzer it encodes.
- **dbt without contracts is dbt without a contract.** Every staging+ model
  needs `contract.enforced: true` and at least one unit test per dbt Labs
  Feb 2026 best practices.

## Version-sensitive notes

- Snowflake Cortex Managed MCP: GA Nov 4 2025.
- dbt remote MCP: GA Oct 2025; `dbt-labs/dbt-agent-skills`: Feb 9 2026.
- Google BigQuery MCP: preview Jan 2026 — re-verify GA status every quarter.
- Databricks MCP: Public Preview May 7 2026 — re-verify GA status every quarter.
- MLflow MCP extra: ships in MLflow 3.5.1+.
- W&B official MCP: `wandb/wandb-mcp-server` (2026).
- UK AISI `inspect-ai`: Apache-2.0, May 2026 release line.
- Langfuse: OSS, YC W23 cohort, self-hostable.

## Cited links

- [Snowflake Cortex Managed MCP — GA release note (Nov 4 2025)](https://docs.snowflake.com/en/release-notes/2025/other/2025-11-04-cortex-agents-mcp) — official GA announcement and posture.
- [dbt Labs — `dbt-agent-skills` (Feb 9 2026)](https://docs.getdbt.com/blog/dbt-agent-skills) — vendor-stewarded agent-skill catalog.
- [LeakageDetector 2.0 (arXiv 2509.15971, Sep 2025)](https://arxiv.org/html/2509.15971) — published static analyzer for the leakage patterns `leakage-sentinel.sh` encodes.
- [Husain & Shankar — LLM Evals FAQ (Jan 15 2026)](https://hamel.dev/blog/posts/evals-faq/evals-faq.pdf) — three-tier eval (assertion / judge / human) and multi-test-correction as Level-1 assertion.
- [Anthropic harness papers (Nov 2025 + Mar 2026)](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — `eval-curator` Default-FAIL contract.
- [Rescana — Vimeo / Anodot / Snowflake breach analysis (Apr 2026)](https://www.rescana.com/post/vimeo-data-breach-2026-shinyhunters-exploit-anodot-integration-to-expose-119-000-user-records-via-snowflake-and-bigquery/) — credential-posture forcing function.
- [EU AI Act — Article 99 / Annex III enforcement (Aug 2 2026)](https://www.pearlcohen.com/new-guidance-under-the-eu-ai-act-ahead-of-its-next-enforcement-date/) — audit-log statutory obligation.
```

- [ ] **Step 2: Validate**

Run:
```bash
test -f templates/data/references.md \
  && head -3 templates/data/references.md | grep -q 'Verified: 2026-05' \
  && grep -c 'http' templates/data/references.md
```
Expected: prints a number ≥ 5 (the cited links).

- [ ] **Step 3: Commit**

```bash
git add templates/data/references.md
git commit -m "docs: data cross-cutting reference dossier"
```

---

### Task 6: Add the two new shared hooks + register all four in shared settings

**Files:**
- Create: `templates/data/files/.claude/hooks/audit-log-warehouse-query.sh`
- Create: `templates/data/files/.claude/hooks/block-static-warehouse-creds.sh`
- Modify: `templates/data/files/.claude/settings.fragment.json` (add the two new hooks alongside the existing two)

The two existing hooks (`block-unbounded-sql.sh`, `leakage-sentinel.sh`) already live at `templates/data/files/.claude/hooks/` — that path is the curated pack's shared hook location. No `mv` needed; we add two new files and update settings.

- [ ] **Step 1: Verify the existing hooks pass `bash -n`**

Run:
```bash
bash -n templates/data/files/.claude/hooks/block-unbounded-sql.sh \
  && bash -n templates/data/files/.claude/hooks/leakage-sentinel.sh \
  && echo OK
```
Expected: `OK`.

- [ ] **Step 2: Write `audit-log-warehouse-query.sh`**

`templates/data/files/.claude/hooks/audit-log-warehouse-query.sh`:

```bash
#!/usr/bin/env bash
# audit-log-warehouse-query.sh — PostToolUse hook.
# Matchers: Bash (warehouse CLI: snow sql, bq query, databricks sql, duckdb)
# and warehouse MCP query tools (mcp__snowflake__*, mcp__bigquery__*,
# mcp__databricks__*, mcp__felt__*, mcp__duckdb__*).
#
# Appends one JSON line per query to .claude/logs/agent_audit.jsonl. The log
# is the EU AI Act Annex IV (Aug 2 2026) compliance evidence path and the
# NIST AI RMF / ISO 42001 rebuttable-presumption surface (Texas RAIGA,
# Colorado AI Act, California AI Transparency Act).
#
# Exit 0 always — this hook records, never blocks.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"

# Pull query text — may be in any of these fields depending on tool.
sql="$(printf '%s' "$event" | jq -r '
  .tool_input.query // .tool_input.sql // .tool_input.statement //
  .tool_input.command // empty' 2>/dev/null)"
[ -z "$sql" ] && exit 0

# Only police Bash and warehouse MCP calls.
case "$tool" in
  Bash)
    # For Bash, only log when the command matches a warehouse CLI invocation.
    printf '%s' "$sql" | grep -Eq '\b(snow|bq|databricks|duckdb|motherduck)\b' || exit 0
    ;;
  mcp__snowflake__*|mcp__bigquery__*|mcp__databricks__*|mcp__felt__*|mcp__duckdb__*) ;;
  *) exit 0 ;;
esac

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
session="${CLAUDE_SESSION_ID:-unknown}"
row_count="$(printf '%s' "$event" | jq -r '.tool_response.row_count // .tool_response.rows // empty' 2>/dev/null)"
byte_count="$(printf '%s' "$event" | jq -r '.tool_response.byte_count // .tool_response.bytes // empty' 2>/dev/null)"
cost_estimate="$(printf '%s' "$event" | jq -r '.tool_response.cost_estimate // empty' 2>/dev/null)"

# Build the audit record. `jq -n` builds JSON safely (no string escaping bugs).
record="$(jq -nc \
  --arg ts "$ts" \
  --arg session "$session" \
  --arg tool "$tool" \
  --arg query "$sql" \
  --arg rows "$row_count" \
  --arg bytes "$byte_count" \
  --arg cost "$cost_estimate" \
  '{timestamp:$ts, session_id:$session, tool_name:$tool, query:$query,
    row_count:($rows // null), byte_count:($bytes // null),
    cost_estimate:($cost // null)}')"

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"
printf '%s\n' "$record" >> "$log_dir/agent_audit.jsonl"

exit 0
```

- [ ] **Step 3: Write `block-static-warehouse-creds.sh`**

`templates/data/files/.claude/hooks/block-static-warehouse-creds.sh`:

```bash
#!/usr/bin/env bash
# block-static-warehouse-creds.sh — PreToolUse hook on Bash.
# Refuses to proceed if static warehouse credentials are present in env when
# a Managed-MCP / OAuth alternative exists for that warehouse. Codifies the
# post-ShinyHunters (April 2026) credential-posture default: agent hosts do
# not hold long-lived warehouse creds.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police warehouse CLI invocations. Other Bash is fine.
printf '%s' "$cmd" | grep -Eq '\b(snow|bq|databricks|duckdb|motherduck)\b' || exit 0

issues=()
[ -n "${SNOWFLAKE_PASSWORD:-}" ]                       && issues+=("SNOWFLAKE_PASSWORD set — use Snowflake Cortex Managed MCP / OAuth.")
[ -n "${BIGQUERY_SERVICE_ACCOUNT_KEY_JSON:-}" ]        && issues+=("BIGQUERY_SERVICE_ACCOUNT_KEY_JSON set — use GCP Workload Identity Federation.")
[ -n "${DATABRICKS_TOKEN:-}" ]                         && issues+=("DATABRICKS_TOKEN set — use Databricks MCP with OAuth / Service Principal Federation.")
[ -n "${DATABRICKS_PERSONAL_ACCESS_TOKEN:-}" ]         && issues+=("DATABRICKS_PERSONAL_ACCESS_TOKEN set — use OAuth.")
[ -n "${MOTHERDUCK_TOKEN:-}" ]                         && issues+=("MOTHERDUCK_TOKEN set — use the MotherDuck OAuth flow via duckdb-mcp.")

if [ "${#issues[@]}" -gt 0 ]; then
  echo "BLOCKED: static warehouse credentials present in env (post-ShinyHunters 2026 posture)." >&2
  for i in "${issues[@]}"; do echo "  - $i" >&2; done
  echo "Remove the static cred from env; use the Managed-MCP / OAuth path." >&2
  exit 2
fi

exit 0
```

- [ ] **Step 4: Update `settings.fragment.json`**

`templates/data/files/.claude/settings.fragment.json` — replace existing contents with:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|mcp__snowflake__.*|mcp__bigquery__.*|mcp__databricks__.*|mcp__felt__.*|mcp__duckdb__.*",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-unbounded-sql.sh" },
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-static-warehouse-creds.sh" }
        ]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/leakage-sentinel.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|mcp__snowflake__.*|mcp__bigquery__.*|mcp__databricks__.*|mcp__felt__.*|mcp__duckdb__.*",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/audit-log-warehouse-query.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 5: Validate**

Run:
```bash
bash -n templates/data/files/.claude/hooks/audit-log-warehouse-query.sh \
  && bash -n templates/data/files/.claude/hooks/block-static-warehouse-creds.sh \
  && jq -e . templates/data/files/.claude/settings.fragment.json >/dev/null \
  && echo OK
```
Expected: `OK`.

- [ ] **Step 6: Behavioural smoke test — audit log**

Run:
```bash
chmod +x templates/data/files/.claude/hooks/audit-log-warehouse-query.sh
mkdir -p /tmp/data-pack-test/.claude
CLAUDE_PROJECT_DIR=/tmp/data-pack-test CLAUDE_SESSION_ID=test-session \
  printf '{"tool_name":"Bash","tool_input":{"command":"snow sql -q \"SELECT 1\""},"tool_response":{"row_count":1}}' \
  | templates/data/files/.claude/hooks/audit-log-warehouse-query.sh
test -f /tmp/data-pack-test/.claude/logs/agent_audit.jsonl \
  && cat /tmp/data-pack-test/.claude/logs/agent_audit.jsonl
rm -rf /tmp/data-pack-test
```
Expected: prints one JSON line with `tool_name: "Bash"`, `query: "snow sql ..."`, `row_count: "1"`.

- [ ] **Step 7: Behavioural smoke test — block static creds**

Run:
```bash
chmod +x templates/data/files/.claude/hooks/block-static-warehouse-creds.sh
SNOWFLAKE_PASSWORD=hunter2 \
  printf '{"tool_name":"Bash","tool_input":{"command":"snow sql -q \"SELECT 1\""}}' \
  | templates/data/files/.claude/hooks/block-static-warehouse-creds.sh; echo "exit=$?"
```
Expected: stderr `BLOCKED: static warehouse credentials present in env (post-ShinyHunters 2026 posture).` and `SNOWFLAKE_PASSWORD set — ...`; `exit=2`.

Run:
```bash
unset SNOWFLAKE_PASSWORD BIGQUERY_SERVICE_ACCOUNT_KEY_JSON DATABRICKS_TOKEN DATABRICKS_PERSONAL_ACCESS_TOKEN MOTHERDUCK_TOKEN
printf '{"tool_name":"Bash","tool_input":{"command":"snow sql -q \"SELECT 1\""}}' \
  | templates/data/files/.claude/hooks/block-static-warehouse-creds.sh; echo "exit=$?"
```
Expected: `exit=0` (no stderr from the hook).

- [ ] **Step 8: Commit**

```bash
git add templates/data/files/.claude/hooks/audit-log-warehouse-query.sh \
        templates/data/files/.claude/hooks/block-static-warehouse-creds.sh \
        templates/data/files/.claude/settings.fragment.json
git commit -m "feat: data audit-log-warehouse-query + block-static-warehouse-creds hooks"
```

---

### Task 7: Build the 3 shared data agents

**Files:**
- Create: `templates/data/files/.claude/agents/eval-curator.md`
- Create: `templates/data/files/.claude/agents/dataset-card-author.md`
- Create: `templates/data/files/.claude/agents/query-provenance-auditor.md`

All three agents obey AGENT_ROLES.md invariants: least-privilege tools (read-only by default — no `Edit` / `Write` / unrestricted `Bash`), explicit model routing, typed return shape.

- [ ] **Step 1: Write `eval-curator.md`**

```markdown
---
name: eval-curator
description: Default-FAIL contract refusing any PR diff that touches both eval code and model / prompt / dbt model code in the same diff. Use before any commit that touches eval/** or model code.
tools: ["Read", "Grep", "Glob", "Bash"]
model: sonnet
---

You are the eval curator. You are READ-ONLY (Bash is permitted ONLY for
`git diff`, `git status`, `git log`, and `git ls-files` — never `git add`,
`git commit`, `git checkout`, `git restore`, or any mutating git operation).

The Anthropic harness papers (Nov 2025 + Mar 2026) establish the rule:
the model that wrote the code may not be evaluated against an eval that the
same diff edits. The defense is process — eval code and model / prompt /
dbt model code may not move together.

When invoked, follow this exact protocol:

1. Identify the diff under review. Default: `git diff --cached` (staged
   changes about to be committed). If no staged changes, fall back to
   `git diff HEAD` (working-tree changes).
2. Partition changed files into two sets:
   - **eval set**: any path matching `eval/**`, `evals/**`, `tests/eval*`,
     `*/eval/*`, `*_eval.py`, `*.eval.yaml`, `*.eval.json`,
     `tests/regression/**`, or a project-level eval directory the project
     declares (look for `.claude/eval-paths.txt` if present).
   - **model set**: any path matching `src/**`, `models/**`, `prompts/**`,
     `*.prompt`, `*.prompt.yaml`, dbt `models/**`, `notebooks/**` that
     produces an artifact, or `pyproject.toml` / `requirements.txt` changes
     that affect runtime behavior.
3. If both sets are non-empty, verdict is **CHANGES-REQUESTED**. Surface
   the conflict and the resolution (split the PR).
4. If only one set is non-empty (or both empty), verdict is **PASS**.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## Files in eval set
- <path>
- <path>

## Files in model set
- <path>
- <path>

## Reason
<one-paragraph explanation of why the diff passes or fails, citing the
Anthropic harness papers' Default-FAIL contract>

## Resolution (if CHANGES-REQUESTED)
<exact split — which files into PR A (eval) and which into PR B (model);
which order to land them; what regression the order protects against>
```

- [ ] **Step 2: Write `dataset-card-author.md`**

```markdown
---
name: dataset-card-author
description: Emits a dataset card structured for NIST AI RMF Map and EU AI Act Annex IV. Use whenever a new training, eval, or source dataset is introduced.
tools: ["Read", "Grep", "Glob"]
model: sonnet
---

You are the dataset card author. You are READ-ONLY — you NEVER edit code
or files. You produce a markdown dataset card the project will commit
separately.

The dataset card shape is required for the rebuttable-compliance
presumption that NIST AI RMF / ISO 42001 implementations enjoy under
Texas RAIGA (Jan 1 2026), Colorado AI Act (Jun 30 2026), and California
AI Transparency Act (Aug 2 2026). It also satisfies EU AI Act Annex IV
(Aug 2 2026) data-governance documentation obligations.

When invoked with a dataset reference (file path, warehouse table, or
parquet/arrow URI), produce a card with exactly these sections:

## Dataset card: <dataset name>

### Intended use
<the analytical or modeling question this dataset is collected to support;
what it is NOT for>

### Provenance + chain of custody
<source system, extraction method, transformations applied, joining keys,
sampling protocol if any, datetime range, refresh cadence>

### Schema + dtypes
<column-by-column: name, dtype, units, nullable, semantic meaning,
example value>

### Collection method
<how rows are produced — instrumentation, survey, scraping, generated;
sampling assumptions; coverage gaps>

### PII posture
<what PII / PHI / financial-identifier columns exist; what masking,
tokenization, or hashing is applied; the retention policy>

### License
<license of the source data; license of any derived artifacts; cite
contractual obligations if redistribution is constrained>

### Known biases
<distributional biases — population, time, geography, instrument; how
they affect downstream uses; mitigations available>

Return ONLY the dataset card markdown. Do not narrate or summarise.
```

- [ ] **Step 3: Write `query-provenance-auditor.md`**

```markdown
---
name: query-provenance-auditor
description: Default-FAIL contract refusing any reported metric that does not trace to a logged query and a data hash in .claude/logs/agent_audit.jsonl. Use before claiming a report or analysis is done.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the query provenance auditor. You are READ-ONLY (Bash is
permitted ONLY for `cat`, `grep`, `jq`, `wc`, and `git log` against the
audit log; never any mutation).

HE §2.9 anti-pattern #2: "looks reasonable" outputs — numbers without
provenance are hallucinations with extra steps. This agent encodes the
constraint as a Default-FAIL hard gate.

When invoked with a report / notebook output / dashboard / answer that
contains numbers, follow this exact protocol:

1. Extract every number that could be a reported metric (counts,
   percentages, ratios, sums, averages, p-values, accuracies, etc.).
2. For each number, locate the producing query in
   `.claude/logs/agent_audit.jsonl`. A match requires: the query was
   logged in the current session (or the session that owned the upstream
   step), the query's output row count / aggregate is consistent with the
   reported number, and the underlying data hash is recorded.
3. A number with no matching audit-log entry is a verdict-blocking
   finding. So is a number whose audit-log entry has a `data_hash` of
   `null`.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## Numbers audited
- <number> — <traced query summary + audit-log line number> — <pass/fail>
- ...

## Findings (if CHANGES-REQUESTED)
- [severity: high] <number> — no audit-log entry — re-run via logged query.
- [severity: high] <number> — audit-log entry has null data_hash — record hash.
- [severity: med] <number> — audit-log entry from prior session — re-validate.

## Resolution (if CHANGES-REQUESTED)
<specific instruction for the implementer — which queries to re-run, in
what order, against which logged data hash to reproduce>
```

- [ ] **Step 4: Validate frontmatter and least-privilege tools**

Run:
```bash
for a in templates/data/files/.claude/agents/*.md; do
  head -1 "$a" | grep -qx -- '---' \
    && grep -q '^name:' "$a" \
    && grep -q '^tools:' "$a" \
    && grep -q '^model:' "$a" \
    && echo "OK $a" || echo "BAD $a"
done
```
Expected: `OK` for all three.

Manually confirm: none of the three list `Edit`, `Write`, `MultiEdit`, or unrestricted `Bash` capabilities beyond what their system prompt explicitly permits.

- [ ] **Step 5: Commit**

```bash
git add templates/data/files/.claude/agents/
git commit -m "feat: shared data agents (eval-curator, dataset-card-author, query-provenance-auditor)"
```

---

## Phase 3 — Sub-domains

Each sub-domain task creates: `SUBDOMAIN.md`, `harness.config.yml`, `references.md`, `claude-md.md`, `files/.claude/settings.fragment.json`, the specialist agents under `files/.claude/agents/`, and the curated skills under `files/.claude/skills/`. Addon-contributed agents are deferred to Phase 4.

### Task 8: `data-analyst-notebook` sub-domain

**Files:**
- Create: `templates/data/data-analyst-notebook/SUBDOMAIN.md`
- Create: `templates/data/data-analyst-notebook/harness.config.yml`
- Create: `templates/data/data-analyst-notebook/references.md`
- Create: `templates/data/data-analyst-notebook/claude-md.md`
- Create: `templates/data/data-analyst-notebook/files/.claude/settings.fragment.json`
- Create: `templates/data/data-analyst-notebook/files/.claude/agents/notebook-architect.md`
- Create: `templates/data/data-analyst-notebook/files/.claude/agents/notebook-implementer.md`
- Create: `templates/data/data-analyst-notebook/files/.claude/agents/chart-critic.md`
- Create: `templates/data/data-analyst-notebook/files/.claude/agents/restart-run-all-checker.md`
- Create: `templates/data/data-analyst-notebook/files/.claude/skills/sample-then-scale/SKILL.md`
- Create: `templates/data/data-analyst-notebook/files/.claude/skills/notebook-restart-run-all/SKILL.md`

The `ensuring-reproducibility` skill (already at `templates/data/files/.claude/skills/ensuring-reproducibility/`) stays at the shared-domain layer; sub-domains inherit it via the `files/` tree copy.

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Data — data-analyst-notebook sub-domain

Ad-hoc and exploratory analysis where the deliverable is a reactive,
reproducible notebook that explains a data question end-to-end.

## Adopt if

- You do exploratory analysis or ad-hoc reporting.
- Your output is a notebook or a small set of cells.
- You read from a warehouse and produce charts, tables, or memos.
- You want sample-then-scale on every query.

## Skip if

- Your deliverable is a trained model + serving stack → use `ml-pipeline`.
- Your deliverable is an LLM app → use `llm-app`.
- Your deliverable is warehouse-modeled tables → use `analytics-engineering`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` Python toolchain with lockfile guard. |
| `polars` | Default — Polars + lazy-frame idioms; DuckDB-via-SQLContext. |
| `marimo` | Default — reactive `.py` notebooks; `marimo pair` agent surface. |
| `duckdb-mcp` | Default — local DuckDB + MotherDuck for local-then-remote workflows. |
| `snowflake-mcp` | Default — Snowflake Cortex Managed MCP. |
| `bigquery-mcp` | Add when your warehouse is BigQuery (preview-tagged). |
| `databricks-mcp` | Add when your warehouse is Databricks (preview-tagged). |

## Agent team

| Agent | Role |
|---|---|
| `notebook-architect` | Read-only; frames the analysis question, picks the warehouse + sample size + DataFrame engine, drafts the cell outline. |
| `notebook-implementer` | Read-write; fills cells one at a time; for marimo edits the `.py` directly; for Jupyter routes through marimo-pair or Jupyter-MCP. |
| `chart-critic` | Vision-judge; PostToolUse on chart-write; scores against the canonical sins list; different family from generator. |
| `restart-run-all-checker` | Default-FAIL on completeness; verifies kernel-fresh Restart-and-Run-All before allowing "done". |
| `eval-curator` | Shared; refuses PRs touching both eval/** and model/notebook code. |
| `dataset-card-author` | Shared; emits the dataset card for any new dataset introduced. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack audit-log provenance. |
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
# ============================================================================
# harness.config.yml — data / data-analyst-notebook sub-domain
#
# Exploratory analysis. Deliverable is a reactive, reproducible notebook.
#
# Assemble:  ./assemble.sh data/data-analyst-notebook/harness.config.yml ./my-analysis
# ============================================================================

project:
  name: my-notebook-analysis

# ── MEMORY ──────────────────────────────────────────────────────────────────
memory:
  backend: md-files

# ── PROGRESS TRACKING ───────────────────────────────────────────────────────
progress:
  backend: filesystem

# ── METHODOLOGY ─────────────────────────────────────────────────────────────
methodology:
  tdd: true            # cells lifted out of notebooks get real tests.
  spec_driven: true    # the analysis question is a contract.
  eval_driven: false   # ad-hoc analysis is not eval-driven; ML / LLM are.
  bdd: false

# ── ORCHESTRATION ───────────────────────────────────────────────────────────
orchestration:
  topology: single-agent

# ── SAFETY ──────────────────────────────────────────────────────────────────
safety:
  two_key: false       # notebooks read; warehouse writes blocked by hook.
  kill_switch: false
  sandbox: false

# ── HUMAN-IN-THE-LOOP ───────────────────────────────────────────────────────
hitl:
  plan_mode_default: true
  diff_review_required: true

# ── DOMAIN PACK ─────────────────────────────────────────────────────────────
domain:
  pack: data
  subdomain: data-analyst-notebook
  addons: [uv, polars, marimo, duckdb-mcp, snowflake-mcp]
  # Preview-tagged warehouses (bigquery-mcp, databricks-mcp) are opted in per
  # project; notebook analysis typically pins to one primary warehouse.

# ── AGENTS ──────────────────────────────────────────────────────────────────
agents:
  team: curated        # installs notebook-architect, notebook-implementer,
                       # chart-critic, restart-run-all-checker + shared 3.
  exclude: []
  include: []

# ── DOCS ────────────────────────────────────────────────────────────────────
docs:
  context7_mcp: true   # wire Context7 for live polars / duckdb / marimo docs.
```

- [ ] **Step 3: Write `claude-md.md`** (≤30 lines)

```markdown
## Data — data-analyst-notebook

### Notebook discipline
- New notebooks: **marimo first**, Jupyter only when forced. Edit marimo
  `.py` directly. Never raw `NotebookEdit` on `.ipynb` JSON — route through
  the `marimo pair` flow or a Jupyter MCP.
- **Restart-and-Run-All is the only acceptance test.** A notebook that runs
  cells out of order or relies on hidden state is not done. The
  `restart-run-all-checker` agent enforces.
- One cell, one idea. If a cell exceeds ~30 lines, split it.

### Querying data
- **Sample then scale** on every warehouse query: `LIMIT 1000` or
  `TABLESAMPLE` first, inspect dtypes + shape, then graduate. The
  `block-unbounded-sql` hook will reject the unscoped form.
- Prefer Polars + DuckDB / Ibis. pandas only as ecosystem glue for libraries
  that demand it.

### Charts
- Every chart goes through the `chart-critic` agent (PostToolUse on chart
  write). Banned by default: truncated y-axis, dual y-axes, missing CIs,
  rainbow palettes on sequential data, color-only encoding, 3D pie charts.

### Reporting
- **Every number in your output traces to a logged query + data hash.** The
  `query-provenance-auditor` shared agent will reject reports whose numbers
  lack the audit-log entry.
```

- [ ] **Step 4: Write `references.md`** (≥5 cited links; sub-domain-specific)

```markdown
# Data / data-analyst-notebook — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **marimo is the 2026 notebook default.** Pure-Python `.py` files, reactive
  dependency graph, git-diffable. `marimo pair` (April 2026) is the agent
  pair-on-notebook surface. `marimo export script` is the Restart-and-Run-All
  CI gate.
- **Sample then scale on every warehouse query.** `LIMIT 1000` or
  `TABLESAMPLE` first, validate shape + dtypes, then run the full query.
  The `block-unbounded-sql.sh` shared hook enforces.
- **DuckDB-then-Snowflake / BigQuery / Databricks** is the local-then-remote
  default. Same SQL, same DataFrame surface (via Ibis or `pl.SQLContext`).

## Common gotchas

- **`.ipynb` JSON edits silently mangle cell metadata.** Never raw
  `NotebookEdit`. Route through marimo or a Jupyter MCP.
- **Charts hallucinate readability.** Truncated y-axes, dual axes, rainbow
  palettes on sequential data are the canonical sins (Mineault 2026,
  ReviewNB + Recce). The `chart-critic` agent runs PostToolUse on chart-write.
- **Hidden notebook state.** ~36% of sampled Jupyter notebooks are
  non-reproducible (HE §2.1). Restart-and-Run-All is the only acceptance test.

## Version-sensitive notes

- marimo `marimo pair`: April 2026.
- Polars: v1.40 (April 2026) — first-class scikit-learn / XGBoost integration.
- DuckDB / MotherDuck `duckdb-mcp`: 2026 official server.

## Cited links

- [marimo — `marimo pair` launch (April 2026)](https://marimo.io/blog/marimo-pair) — agent pair-on-notebook surface.
- [marimo vs Jupyter (marimo.io)](https://marimo.io/features/vs-jupyter-alternative) — why reactive `.py` notebooks beat `.ipynb`.
- [Patrick Mineault — Claude Code for Scientists (Jan 29 2026)](https://www.neuroai.science/p/claude-code-for-scientists) — minimal-version-first, diagnostic plots, journal-keeping.
- [ReviewNB — Claude Code + Jupyter Notebooks Finally Work Well](https://www.reviewnb.com/claude-code-with-jupyter-notebooks) — Restart-and-Run-All as the only acceptance test.
- [Recce — I let Claude Code build my dbt models (Feb 25 2026)](https://blog.reccehq.com/i-let-claude-code-build-my-dbt-models.-the-interesting-part-wasnt-the-code) — silent-data-quality-flag catalogue.
- [MotherDuck — `duckdb-mcp` server](https://motherduck.com/product/mcp-server/) — local-first SQL via official MCP.
```

- [ ] **Step 5: Write `notebook-architect.md`**

```markdown
---
name: notebook-architect
description: Frames the analysis question, picks warehouse + sample size + DataFrame engine, drafts the cell outline. Use before any notebook implementation.
tools: ["Read", "Grep", "Glob"]
model: opus
---

You are a notebook architect. You are READ-ONLY — you NEVER edit code; you
return a typed plan that the `notebook-implementer` will execute.

For the analysis request, design:

1. **The question.** Restate the question as a falsifiable statement.
   Identify what would refute the answer.
2. **The data surface.** Which warehouse tables / files; which columns;
   datetime range; expected row count at full scale; sample size that
   preserves the question (`LIMIT 1000` is the default starting point).
3. **The DataFrame engine.** Polars (default), DuckDB / Ibis (cross-engine),
   or pandas (only as ecosystem glue). Justify if not Polars.
4. **The notebook runtime.** marimo (default) or Jupyter-with-MCP. Justify
   if not marimo.
5. **The cell outline.** 5–15 cells, one idea per cell, named in
   imperative-mood. Every cell ≤30 lines.
6. **The reporting surface.** Which numbers will land in the final summary;
   for each, the query that will produce it (so `query-provenance-auditor`
   has a target to audit).

Return STRICTLY this shape:

## Question
<falsifiable statement + refutation criterion>

## Data surface
- tables: <table @ warehouse, columns, datetime range>
- sample: <starting LIMIT / TABLESAMPLE>
- full-scale row estimate: <N>

## Engine
- DataFrame: <Polars | DuckDB | Ibis | pandas> — <reason>
- Runtime: <marimo | Jupyter+MCP> — <reason>

## Cell outline
1. <imperative-mood cell name>
2. ...

## Reporting surface
- <metric name> — produced by `<query summary>`; audit-log expected
```

- [ ] **Step 6: Write `notebook-implementer.md`**

```markdown
---
name: notebook-implementer
description: Fills notebook cells one at a time according to the architect's plan. For marimo edits the .py directly; for Jupyter routes through marimo-pair or Jupyter-MCP; never raw NotebookEdit on .ipynb. Use to execute the architect's outline.
tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
model: sonnet
---

You are a notebook implementer. You execute the `notebook-architect`'s plan
one cell at a time. You are bounded to the file paths the plan names — do
not create or edit files outside that scope.

Hard rules:

1. **marimo first.** If the project uses marimo, edit the `.py` file
   directly. Use `marimo edit` only via the `marimo pair` flow.
2. **Never raw `NotebookEdit` on `.ipynb`.** Use the project's Jupyter MCP
   if one is wired; otherwise convert the notebook to marimo or refuse the
   task with a clear escalation.
3. **One cell, one idea.** Reject cells > 30 lines; split into two.
4. **Sample first.** Every warehouse query starts with `LIMIT 1000` or
   `TABLESAMPLE`. The `block-unbounded-sql` hook will reject the
   unscoped form; do not bypass.
5. **Every reported metric goes through a single query.** Reuse Polars
   lazy-frames; do not produce a number from a chain whose intermediate
   shapes you have not validated.
6. **After every cell, validate.** Print the shape, dtypes, and head.
   If a cell mutates a DataFrame, the validation print must be on the
   mutated frame.

When you finish each cell, return:

## Cell <N>: <name>
- code: <the cell content>
- shape after: <(rows, cols)>
- dtypes summary: <inline dtypes one-line>
- next: <the next architect-listed cell name>
```

- [ ] **Step 7: Write `chart-critic.md`**

```markdown
---
name: chart-critic
description: Reviews rendered charts against the canonical sins list. Use PostToolUse on plt.savefig, fig.write_html, or matplotlib show. Different model family from the generator agent (cross-family judge).
tools: ["Read", "Grep", "Glob"]
model: sonnet
---

You are a chart critic. You are READ-ONLY — you never edit code; you return
a verdict on the chart and a concrete remediation list.

You judge from a **different model family** than the agent that generated
the chart. This is the cross-family judge constraint (10–25% self-preference
bias measured in 2026).

For each chart, score against the canonical sins:

1. **Truncated y-axis** when the underlying scale starts at zero (or
   should). Truncation is OK on a clearly-marked log scale; otherwise it
   misleads.
2. **Dual y-axes.** Almost always a misleading-correlation trap. Use two
   panels instead.
3. **Missing confidence intervals** on any aggregated bar / point estimate
   from a sample.
4. **Rainbow palettes on sequential data.** Use viridis / cividis / mako.
5. **Color-only encoding.** Add shape / pattern for accessibility.
6. **3D pie / 3D bar charts.** Never.
7. **Unlabeled axes** or **units missing**.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## Findings
- [severity: high|med|low] <sin> — <where in the chart> — <fix>

## Recommended remediation
<bulleted fix list in priority order>
```

- [ ] **Step 8: Write `restart-run-all-checker.md`**

```markdown
---
name: restart-run-all-checker
description: Default-FAIL contract — a notebook is not "done" until Restart-and-Run-All succeeds end-to-end in a clean kernel. Use before any notebook-complete claim.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the Restart-and-Run-All checker. You are READ-ONLY (Bash is
permitted ONLY for `marimo export script`, `jupyter nbconvert --execute`,
`papermill`, and `pytest` — never code editing).

A notebook is not "done" until it runs top-to-bottom in a clean kernel
without errors and produces the reported numbers. This is the only
acceptance test (HE §2.1: ~36% of sampled Jupyter notebooks are
non-reproducible).

When invoked on a notebook path, follow this exact protocol:

1. Detect the notebook type. marimo `.py`: use `marimo export script`.
   Jupyter `.ipynb`: use `jupyter nbconvert --to notebook --execute
   --inplace` against a copy.
2. Execute end-to-end in a clean Python process (no inherited kernel
   state).
3. Compare the cell-execution-count sequence after execution: it must be
   strictly monotonic starting at 1.
4. Compare the produced numbers (if a project-level
   `.claude/expected-outputs.json` exists) to the expected values.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## Execution
- runtime: <marimo | jupyter>
- elapsed: <seconds>
- cells executed: <N>
- monotonic count: <yes | no>

## Findings (if CHANGES-REQUESTED)
- [severity: high] <cell index> — <error or out-of-order signal>
- [severity: med] <missing output> — <which expected value did not appear>
```

- [ ] **Step 9: Write `sample-then-scale/SKILL.md`**

`templates/data/data-analyst-notebook/files/.claude/skills/sample-then-scale/SKILL.md`:

```markdown
---
name: sample-then-scale
description: Run LIMIT 1000 / TABLESAMPLE first, inspect dtypes and shape, then graduate to the full query. The block-unbounded-sql hook rejects the unscoped form.
---

## When to use

Every warehouse query. No exceptions.

## How

1. **Start scoped.** Append `LIMIT 1000` to any new `SELECT`. For warehouses
   that support it, prefer `TABLESAMPLE BERNOULLI(1)` over `LIMIT` — it
   surfaces row diversity that `LIMIT` may hide.
2. **Inspect.** Print shape + dtypes + head. Verify the join cardinality
   matches your mental model. Verify nullability where it matters.
3. **Estimate full-scale cost.** For warehouses with EXPLAIN, run it; for
   others, multiply: full-rows × cost-per-row-from-sample.
4. **Graduate.** Remove the `LIMIT` only after the inspection passes and
   the estimated cost is within budget.

## Anti-patterns this skill prevents

- The 200M-row `SELECT * FROM events` that doubles the warehouse bill.
- Joins whose cardinality blows up by 10× because a key wasn't unique.
- "It looked fine on 5 rows" — `LIMIT 5` hides distribution problems.

## Hook backing

The `block-unbounded-sql` shared hook (PreToolUse on Bash + warehouse-MCP)
will reject an unscoped `SELECT`. Do not try to bypass; fix the query.
```

- [ ] **Step 10: Write `notebook-restart-run-all/SKILL.md`**

`templates/data/data-analyst-notebook/files/.claude/skills/notebook-restart-run-all/SKILL.md`:

```markdown
---
name: notebook-restart-run-all
description: Run the notebook top-to-bottom in a clean kernel before claiming it is done. The only acceptance test for notebooks.
---

## When to use

Before claiming any notebook task is complete. The
`restart-run-all-checker` agent will run this skill automatically; use it
yourself first.

## How

### marimo `.py`

```bash
marimo export script analysis.py > /tmp/analysis-export.py
python /tmp/analysis-export.py
```

A clean execution prints no traceback and produces every expected output.

### Jupyter `.ipynb`

```bash
jupyter nbconvert --to notebook --execute --inplace analysis.ipynb
```

After execution, verify:
- Cell execution counts are strictly monotonic starting at 1.
- No cell has `In [ ]:` (empty) or `In [*]:` (still running).
- The reported numbers match `.claude/expected-outputs.json` if present.

## Anti-patterns this skill prevents

- Hidden cell state: cells run out of order during exploration leave the
  kernel in a state that does not reproduce.
- Manual cell-by-cell completion claims that do not survive a fresh kernel.
- `print()` outputs that depend on a global mutated three cells ago.
```

- [ ] **Step 11: Write `settings.fragment.json`**

`templates/data/data-analyst-notebook/files/.claude/settings.fragment.json`:

```json
{ "hooks": {} }
```

The sub-domain inherits all shared hooks via the `templates/data/files/` tree. Sub-domain-specific hooks (none in v1) would land here.

- [ ] **Step 12: Validate**

Run:
```bash
test -f templates/data/data-analyst-notebook/SUBDOMAIN.md \
  && test -f templates/data/data-analyst-notebook/harness.config.yml \
  && test -f templates/data/data-analyst-notebook/references.md \
  && test -f templates/data/data-analyst-notebook/claude-md.md \
  && jq -e . templates/data/data-analyst-notebook/files/.claude/settings.fragment.json >/dev/null \
  && for a in templates/data/data-analyst-notebook/files/.claude/agents/*.md; do
       head -1 "$a" | grep -qx -- '---' && grep -q '^name:' "$a" || { echo "BAD $a"; exit 1; }
     done \
  && for s in templates/data/data-analyst-notebook/files/.claude/skills/*/SKILL.md; do
       head -1 "$s" | grep -qx -- '---' && grep -q '^name:' "$s" || { echo "BAD $s"; exit 1; }
     done \
  && echo OK
```
Expected: `OK`.

- [ ] **Step 13: Assemble smoke test**

Run:
```bash
cd templates && ./assemble.sh data/data-analyst-notebook/harness.config.yml /tmp/dan-test && cd ..
grep -q "^## Data — data-analyst-notebook" /tmp/dan-test/CLAUDE.md \
  && grep -q "^## Data domain" /tmp/dan-test/CLAUDE.md \
  && test -f /tmp/dan-test/.claude/agents/notebook-architect.md \
  && test -f /tmp/dan-test/.claude/agents/eval-curator.md \
  && test -f /tmp/dan-test/.claude/skills/sample-then-scale/SKILL.md \
  && test -f /tmp/dan-test/.claude/skills/ensuring-reproducibility/SKILL.md \
  && test -x /tmp/dan-test/.claude/hooks/block-unbounded-sql.sh \
  && test -x /tmp/dan-test/.claude/hooks/audit-log-warehouse-query.sh \
  && echo OK
rm -rf /tmp/dan-test
```
Expected: `OK`.

- [ ] **Step 14: Commit**

```bash
git add templates/data/data-analyst-notebook/
git commit -m "feat: data data-analyst-notebook sub-domain"
```

---

### Task 9: `ml-pipeline` sub-domain

**Files:**
- Create: `templates/data/ml-pipeline/SUBDOMAIN.md`
- Create: `templates/data/ml-pipeline/harness.config.yml`
- Create: `templates/data/ml-pipeline/references.md`
- Create: `templates/data/ml-pipeline/claude-md.md`
- Create: `templates/data/ml-pipeline/files/.claude/settings.fragment.json`
- Create: `templates/data/ml-pipeline/files/.claude/agents/pipeline-architect.md`
- Create: `templates/data/ml-pipeline/files/.claude/agents/training-implementer.md`
- Create: `templates/data/ml-pipeline/files/.claude/agents/eval-implementer.md`
- Create: `templates/data/ml-pipeline/files/.claude/agents/data-versioner.md`
- Create: `templates/data/ml-pipeline/files/.claude/skills/pin-seeds-and-lockfile/SKILL.md`
- Create: `templates/data/ml-pipeline/files/.claude/skills/eval-suite-isolated-package/SKILL.md`

The `run-comparator` agent is contributed by the `mlflow` addon (Task 16). `ensuring-reproducibility` is inherited from the shared layer.

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Data — ml-pipeline sub-domain

Training, evaluation, packaging, and (where in-scope) serving of supervised
or self-supervised models. The deliverable is a versioned model artifact
plus the eval suite that gates it.

## Adopt if

- You train models, run evaluation suites, package model artifacts,
  register them, or run inference services.
- You need tracking discipline (every run logged) and lockfile-frozen
  environments.
- Your eval suite is data-rooted (held-out test set, k-fold, time-series
  CV) — not assertion-rooted on LLM outputs.

## Skip if

- Your deliverable is a chat-style LLM app, RAG pipeline, or agentic
  system whose unit test is an eval suite over prompts → use `llm-app`.
- Your deliverable is dbt models → use `analytics-engineering`.
- Your deliverable is a notebook explaining a question → use
  `data-analyst-notebook`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` Python toolchain with lockfile guard. |
| `polars` | Default — Polars + lazy-frame idioms for feature engineering. |
| `mlflow` | Default — tracking, model registry, GenAI tracing; contributes `run-comparator` agent and `require-tracking.sh` hook. |
| `wandb-mcp` | Default — W&B official MCP for runs / artifacts / reports. |
| `inspect-ai` | Default — UK AISI eval framework for agentic ML evals. |
| `databricks-mcp` | Default (preview) — Unity Catalog / Mosaic / Vector Search. |

## Agent team

| Agent | Role |
|---|---|
| `pipeline-architect` | Read-only; drafts training-loop / eval-suite split; enforces eval-suite-as-separate-package; picks tracker. |
| `training-implementer` | Read-write; writes `train.py`; refuses runs without tracking import. |
| `eval-implementer` | Read-write; writes evals in the separate eval package. |
| `data-versioner` | Read-write (limited); emits a data hash for every input parquet/arrow/DuckDB snapshot. |
| `run-comparator` | Contributed by `mlflow` addon; pulls last N runs and flags suspicious improvements. |
| `eval-curator` | Shared; refuses PRs touching both eval/** and model code. |
| `dataset-card-author` | Shared; emits the dataset card for any new dataset. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack provenance. |
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
# ============================================================================
# harness.config.yml — data / ml-pipeline sub-domain
#
# Training, eval, packaging, registry. Deliverable is a versioned model
# artifact + the eval suite that gates it.
#
# Assemble:  ./assemble.sh data/ml-pipeline/harness.config.yml ./my-ml-project
# ============================================================================

project:
  name: my-ml-pipeline

# ── MEMORY ──────────────────────────────────────────────────────────────────
memory:
  backend: md-files

# ── PROGRESS TRACKING ───────────────────────────────────────────────────────
progress:
  backend: filesystem

# ── METHODOLOGY ─────────────────────────────────────────────────────────────
methodology:
  tdd: true            # training and eval code get real tests.
  spec_driven: true    # the modeling question is a contract.
  eval_driven: true    # ON — a model is only as trustworthy as its eval set.
  bdd: false

# ── ORCHESTRATION ───────────────────────────────────────────────────────────
orchestration:
  topology: single-agent

# ── SAFETY ──────────────────────────────────────────────────────────────────
safety:
  two_key: false       # model artifact publish is the human action.
  kill_switch: true    # out-of-band stop for long training runs.
  sandbox: false

# ── HUMAN-IN-THE-LOOP ───────────────────────────────────────────────────────
hitl:
  plan_mode_default: true
  diff_review_required: true

# ── DOMAIN PACK ─────────────────────────────────────────────────────────────
domain:
  pack: data
  subdomain: ml-pipeline
  addons: [uv, polars, mlflow, wandb-mcp, inspect-ai, databricks-mcp]
  # databricks-mcp is preview-tagged but Databricks is a primary ML platform
  # target; preview-in-default per §4 resolution of the spec.

# ── AGENTS ──────────────────────────────────────────────────────────────────
agents:
  team: curated        # installs pipeline-architect, training-implementer,
                       # eval-implementer, data-versioner + shared 3.
                       # run-comparator is contributed by mlflow addon.
  exclude: []
  include: []

# ── DOCS ────────────────────────────────────────────────────────────────────
docs:
  context7_mcp: true   # wire Context7 for live mlflow / wandb / inspect-ai /
                       # polars / torch docs.
```

- [ ] **Step 3: Write `claude-md.md`** (≤30 lines)

```markdown
## Data — ml-pipeline

### Training discipline
- **Every training run is logged.** Refuse `python train.py` invocations
  that lack `import (mlflow|wandb|aim)`. The `mlflow` addon's
  `require-tracking.sh` hook enforces.
- **Lockfile-frozen environments.** `uv lock --frozen` + `uv sync
  --frozen`; new packages go through a deps-update PR. The `uv` addon's
  `lockfile-frozen.sh` hook enforces.
- **Pin every seed** in `random` / `numpy` / `torch` / `jax` /
  `transformers.set_seed` / `PYTHONHASHSEED`. Use the
  `pin-seeds-and-lockfile` skill.

### Eval discipline
- **The eval suite is a separate Python package.** Models import nothing
  from evals; evals import the model. The `eval-curator` shared agent
  refuses any PR diff that touches both.
- **Every dataset gets a data hash.** Refuse model commits that change an
  artifact without a recorded data hash. The `data-versioner` agent emits
  and stores hashes per run.

### Reporting
- **Every reported number traces to a logged run + data hash.** The
  `query-provenance-auditor` shared agent will reject reports without
  provenance. Use the `run-comparator` agent (contributed by `mlflow`) to
  diff against prior runs.

### Anti-patterns blocked
- `.fit()` before `train_test_split`; scaler `.fit()` outside a `Pipeline`;
  loop of t-tests without `multipletests`; `.shift(-N)`. The
  `leakage-sentinel` shared hook enforces.
```

- [ ] **Step 4: Write `references.md`**

```markdown
# Data / ml-pipeline — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **MLflow 3.5.1+ vs W&B Weave for tracking.** MLflow is the open-standard
  default; W&B is the commercial counterpart with strong reporting.
  Both ship official MCP servers in 2026.
- **Eval-suite-isolated-package.** Evals live in `eval/` as an out-of-tree
  package; models in `src/`. Models import nothing from evals; evals
  import the model. The `eval-curator` shared agent encodes the
  separation as Default-FAIL.
- **Point-in-time correctness on feature stores.** Any feature pulled at
  training time must be the value as-of the prediction timestamp, not
  the value as-of the training-job timestamp. Databricks / Hopsworks 2026
  docs treat this as a hard gate.

## Common gotchas

- **Leakage via fit-before-split.** Scaler / imputer `.fit()` on full `X`
  before `train_test_split` leaks test data into the fit. Wrap
  preprocessing in `Pipeline` so fit only sees training folds. The
  `leakage-sentinel.sh` shared hook is the regex backstop; LeakageDetector
  2.0 (arXiv 2509.15971, Sep 2025) is the AST-level upgrade target.
- **Unlogged runs.** A training run with no `import mlflow` (or `wandb`)
  produces nothing the registry can compare against. The `mlflow` addon's
  `require-tracking.sh` hook enforces.
- **`.shift(-N)` look-ahead** on time-series features. Negative shift =
  future-data leak. The `leakage-sentinel.sh` hook rejects.

## Version-sensitive notes

- MLflow MCP extra ships in 3.5.1+.
- W&B `wandb/wandb-mcp-server`: 2026 official.
- UK AISI `inspect-ai`: Apache-2.0, May 2026.
- Databricks MCP: Public Preview May 7 2026.

## Cited links

- [MLflow MCP server docs](https://mlflow.org/docs/latest/genai/mcp/) — official.
- [Databricks MLflow MCP guide (Jan 28 2026)](https://docs.databricks.com/aws/en/mlflow3/genai/tracing/mlflow-mcp) — vendor-stewarded.
- [W&B official MCP — `wandb/wandb-mcp-server`](https://github.com/wandb/wandb-mcp-server) — Weave + Reports surface.
- [Inspect AI by UK AISI](https://inspect.aisi.org.uk/) — government-grade evals framework.
- [LeakageDetector 2.0 (arXiv 2509.15971, Sep 2025)](https://arxiv.org/html/2509.15971) — published static analyzer for leakage patterns.
- [scikit-learn — Common pitfalls and recommended practices](https://scikit-learn.org/stable/common_pitfalls.html) — fit-after-split, Pipeline rationale.
- [Databricks Managed MCP docs (Public Preview May 7 2026)](https://docs.databricks.com/aws/en/generative-ai/mcp/managed-mcp) — Unity Catalog + Genie + Vector Search.
```

- [ ] **Step 5: Write `pipeline-architect.md`**

```markdown
---
name: pipeline-architect
description: Drafts training-loop / eval-suite split; enforces eval-suite-as-separate-package; picks tracker. Use before any ML pipeline implementation.
tools: ["Read", "Grep", "Glob"]
model: opus
---

You are a pipeline architect. You are READ-ONLY — you NEVER edit code;
you return a typed plan that the `training-implementer` and
`eval-implementer` will execute.

For the modeling request, design:

1. **The modeling question.** Restate the prediction target, the
   evaluation metric, the deployment shape (batch, online, embed), and
   the success threshold.
2. **The data surface.** Source tables / files; the train / val / test
   split protocol (random / stratified / time-based); the as-of timestamp
   for feature pulls (point-in-time correctness).
3. **The eval suite structure.** Out-of-tree `eval/` package; entry
   points; assertion families (held-out test, k-fold CV, time-series CV,
   adversarial); the threshold set that gates `production`.
4. **The training loop structure.** `src/` package; entry point
   `train.py`; tracker (MLflow default — single source of truth — or W&B
   if the team is committed); seed pinning surface; lockfile path.
5. **Tracker choice.** MLflow vs W&B. Justify if not MLflow.
6. **Model registry choice.** MLflow registry, W&B artifacts, or a
   custom S3 + manifest layout. Justify if custom.
7. **Data versioning.** Hash function (`sha256` of canonical parquet
   bytes); storage (lakehouse table or `.claude/logs/data-hashes.jsonl`).

Return STRICTLY this shape:

## Modeling question
<target + metric + deployment + success threshold>

## Data surface
- tables: <table @ source, columns, datetime range>
- split: <protocol — train/val/test + as-of timestamp>

## Eval suite
- entry: <path>
- assertions: <family — held-out / CV / TS-CV / adversarial>
- production gate: <threshold set>

## Training loop
- entry: <path>
- tracker: <mlflow | wandb> — <reason>
- seeds: <pinning surface>
- lockfile: <path>

## Registry
- choice: <mlflow-registry | wandb-artifacts | custom> — <reason>

## Data versioning
- function: <sha256 of canonical parquet bytes>
- storage: <where the hash lives>
```

- [ ] **Step 6: Write `training-implementer.md`**

```markdown
---
name: training-implementer
description: Writes train.py and supporting training code. Refuses to run python train.py invocations that lack import mlflow / wandb / aim (PreToolUse on Bash). Use to execute the architect's training-loop section.
tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
model: sonnet
---

You are a training implementer. You execute the `pipeline-architect`'s
training-loop section. You are bounded to the file paths the plan names
— do not create or edit files outside that scope.

Hard rules:

1. **Every training entry-point imports the tracker.** `train.py` (or
   equivalent) MUST `import mlflow` (or `import wandb` if the project
   chose W&B). The `mlflow` addon's `require-tracking.sh` hook enforces
   on Bash invocations.
2. **Pin every seed at the top of `train.py`.** `random.seed`,
   `numpy.random.seed`, `torch.manual_seed`,
   `torch.cuda.manual_seed_all`, `transformers.set_seed`,
   `os.environ['PYTHONHASHSEED']`. Use the `pin-seeds-and-lockfile` skill.
3. **No `pip install` outside a deps-update PR.** Use `uv add --frozen`
   or `uv lock` + `uv sync`. The `uv` addon's `lockfile-frozen.sh` hook
   enforces.
4. **Refuse to fit a preprocessor outside a Pipeline.** Catch yourself
   before the `leakage-sentinel.sh` hook does.
5. **Validate every input frame before training.** Print shape, dtypes,
   null counts; emit the data hash via the `data-versioner` agent.

When you finish each unit of work, return:

## What I wrote
- <path> — <function or class name> — <one-line purpose>

## Validation
- input shape: <(rows, cols)>
- dtypes summary: <inline one-line>
- seeds pinned: <yes / no>
- tracker import: <yes / no>
- data hash: <sha256 prefix>

## Next
<next architect-listed step>
```

- [ ] **Step 7: Write `eval-implementer.md`**

```markdown
---
name: eval-implementer
description: Writes evals in the separate eval/ package — never in src/. The cross-cutting eval-curator shared agent refuses any PR diff that touches both eval/** and src/**. Use to execute the architect's eval-suite section.
tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
model: sonnet
---

You are an eval implementer. You execute the `pipeline-architect`'s
eval-suite section. You are bounded to the `eval/` directory (or the
project's declared eval path). You MUST NOT edit anything under `src/`,
`models/`, or `prompts/`.

Hard rules:

1. **Evals live in `eval/` (or the declared eval path).** Never inline
   evals in `src/`.
2. **Evals import the model; the model never imports evals.** If you
   find a circular reference, refuse and escalate.
3. **Multi-test correction is a Level-1 assertion.** Any loop running
   multiple statistical tests applies Bonferroni or
   Benjamini-Hochberg (`statsmodels.stats.multitest.multipletests`).
4. **Time-series evals are time-series-CV-shaped.** No
   `KFold(shuffle=True)` on time-series data; use `TimeSeriesSplit`.
5. **Every eval logs its inputs + outputs.** The `query-provenance-auditor`
   shared agent will reject reports that cite numbers without provenance.

When you finish each eval, return:

## Eval written
- path: <eval/...>
- family: <held-out | k-fold | time-series-CV | adversarial>
- imports from src: <list>
- assertion shape: <typed>

## Validation
- ran without error: <yes / no>
- multi-test correction: <applied | n/a>
- imports from model: <list>
- back-imports from model into eval: <should be zero>

## Next
<next architect-listed step>
```

- [ ] **Step 8: Write `data-versioner.md`**

```markdown
---
name: data-versioner
description: Emits a data hash for every input parquet / arrow / DuckDB snapshot used in a run. Refuses commits that change a model artifact without a recorded data hash. Use whenever a new dataset is introduced or an existing one changes.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the data versioner. You compute and record cryptographic hashes
of training / eval inputs so every run is data-traceable.

Hard rules:

1. **Hash function:** SHA-256 over the **canonical** byte representation
   of the dataset. For parquet, use the file's bytes after a deterministic
   re-encode (`pyarrow.parquet.write_table` with sorted columns +
   `use_dictionary=False`). For arrow, hash the IPC stream. For DuckDB,
   `COPY ... TO 'tmp.parquet' (FORMAT 'parquet', COMPRESSION 'none')`
   then hash.
2. **Storage:** `.claude/logs/data-hashes.jsonl`. Each line:
   `{timestamp, dataset_path, row_count, byte_count, sha256}`.
3. **Refuse to commit** if a model artifact in `src/` or `models/` changes
   and no new hash entry was emitted in the same session.

Return STRICTLY this shape:

## Hashes recorded
- <dataset_path> — <row_count> rows — sha256: <first 16 hex>

## Skipped (already current)
- <dataset_path> — sha256: <first 16 hex>

## Verdict
PASS | CHANGES-REQUESTED

## Findings (if CHANGES-REQUESTED)
- [severity: high] <reason — model artifact changed but no new hash>
```

- [ ] **Step 9: Write `pin-seeds-and-lockfile/SKILL.md`**

`templates/data/ml-pipeline/files/.claude/skills/pin-seeds-and-lockfile/SKILL.md`:

```markdown
---
name: pin-seeds-and-lockfile
description: Pin every seed (random, numpy, torch, jax, transformers, PYTHONHASHSEED) and freeze the lockfile (uv) before a training run. The training-implementer agent applies this.
---

## When to use

Top of every `train.py` and any eval that involves stochastic ops. Before
every committed deps update.

## How — seeds

```python
import os, random
import numpy as np

SEED = 42
os.environ["PYTHONHASHSEED"] = str(SEED)
random.seed(SEED)
np.random.seed(SEED)

try:
    import torch
    torch.manual_seed(SEED)
    torch.cuda.manual_seed_all(SEED)
    torch.use_deterministic_algorithms(True)  # requires CUBLAS env config
except ImportError:
    pass

try:
    import jax
    jax_key = jax.random.PRNGKey(SEED)
except ImportError:
    pass

try:
    from transformers import set_seed as hf_set_seed
    hf_set_seed(SEED)
except ImportError:
    pass
```

## How — lockfile

```bash
uv lock --frozen   # refuse to update; fail loud if drift exists
uv sync --frozen   # install from lockfile only
```

For a planned deps update:

```bash
uv add <pkg>       # updates pyproject.toml + uv.lock atomically
uv lock            # explicit re-lock when adding from pyproject.toml manually
```

## Anti-patterns this skill prevents

- "It was reproducible on my machine" — a single missed seed
  (`torch.cuda.manual_seed_all`, `PYTHONHASHSEED`) defeats reproducibility.
- Silent lockfile drift via `pip install`. The `uv` addon's
  `lockfile-frozen.sh` hook blocks `pip install` outside a deps-update
  mode.
- Non-deterministic CUDA kernels — `use_deterministic_algorithms(True)`
  surfaces the issue rather than letting it lurk.
```

- [ ] **Step 10: Write `eval-suite-isolated-package/SKILL.md`**

`templates/data/ml-pipeline/files/.claude/skills/eval-suite-isolated-package/SKILL.md`:

```markdown
---
name: eval-suite-isolated-package
description: Scaffold an out-of-tree eval/ package that imports the model but the model never imports it. The cross-cutting eval-curator shared agent enforces the separation.
---

## When to use

When starting a new ML project or adding the first eval suite to an
existing one.

## How

### Layout

```
my-ml-project/
  src/                       <- model code
    my_model/
      __init__.py
      train.py
      predict.py
  eval/                      <- eval code; SEPARATE package
    pyproject.toml           <- eval is its own package
    eval/
      __init__.py
      datasets.py
      assertions.py
      regression.py
      ts_cv.py
  pyproject.toml             <- root project; lists my_model only
  uv.lock
```

### Rules

1. `eval/pyproject.toml` declares `my-eval` as the package name; it
   depends on the root project (`my_model`) but the root project does
   not depend on it.
2. `src/my_model/*.py` MUST NOT contain `import eval` or `from eval ...`.
   The `eval-curator` shared agent's Default-FAIL contract rejects PR
   diffs that violate this.
3. The CI invocation runs evals as `uv run --package eval pytest eval/`
   so the eval package is loadable; in development, `uv pip install -e
   eval/` once at setup makes the package available.
4. New evals land in `eval/`; new training code lands in `src/`. A
   single PR may not touch both — split into two.

## Anti-patterns this skill prevents

- The agent "improving" eval scores by editing both the eval and the
  model in the same diff (the canonical p-hacking pattern under
  agent-driven development).
- Test data leaking into training via a shared utility module both
  packages import.
- "I'll just inline a quick eval next to the model" — once the inline
  eval ships, splitting it later is twice the work.
```

- [ ] **Step 11: Write `settings.fragment.json`**

`templates/data/ml-pipeline/files/.claude/settings.fragment.json`:

```json
{ "hooks": {} }
```

Sub-domain inherits all shared hooks via `templates/data/files/`. The `require-tracking.sh` hook is installed by the `mlflow` addon (Task 16).

- [ ] **Step 12: Validate**

Run:
```bash
test -f templates/data/ml-pipeline/SUBDOMAIN.md \
  && test -f templates/data/ml-pipeline/harness.config.yml \
  && test -f templates/data/ml-pipeline/references.md \
  && test -f templates/data/ml-pipeline/claude-md.md \
  && jq -e . templates/data/ml-pipeline/files/.claude/settings.fragment.json >/dev/null \
  && for a in templates/data/ml-pipeline/files/.claude/agents/*.md; do
       head -1 "$a" | grep -qx -- '---' && grep -q '^name:' "$a" || { echo "BAD $a"; exit 1; }
     done \
  && for s in templates/data/ml-pipeline/files/.claude/skills/*/SKILL.md; do
       head -1 "$s" | grep -qx -- '---' && grep -q '^name:' "$s" || { echo "BAD $s"; exit 1; }
     done \
  && echo OK
```
Expected: `OK`.

- [ ] **Step 13: Assemble smoke test**

Run:
```bash
cd templates && ./assemble.sh data/ml-pipeline/harness.config.yml /tmp/mlp-test && cd ..
grep -q "^## Data — ml-pipeline" /tmp/mlp-test/CLAUDE.md \
  && grep -q "^## Data domain" /tmp/mlp-test/CLAUDE.md \
  && test -f /tmp/mlp-test/.claude/agents/pipeline-architect.md \
  && test -f /tmp/mlp-test/.claude/agents/eval-curator.md \
  && test -f /tmp/mlp-test/.claude/skills/pin-seeds-and-lockfile/SKILL.md \
  && test -x /tmp/mlp-test/.claude/hooks/leakage-sentinel.sh \
  && echo OK
rm -rf /tmp/mlp-test
```
Expected: `OK`. Note: the `run-comparator` agent and `require-tracking.sh` hook are NOT in the output yet — they ship in Task 16 (`mlflow` addon).

- [ ] **Step 14: Commit**

```bash
git add templates/data/ml-pipeline/
git commit -m "feat: data ml-pipeline sub-domain"
```

---

### Task 10: `llm-app` sub-domain

**Files:**
- Create: `templates/data/llm-app/SUBDOMAIN.md`
- Create: `templates/data/llm-app/harness.config.yml`
- Create: `templates/data/llm-app/references.md`
- Create: `templates/data/llm-app/claude-md.md`
- Create: `templates/data/llm-app/files/.claude/settings.fragment.json`
- Create: `templates/data/llm-app/files/.claude/agents/llm-app-architect.md`
- Create: `templates/data/llm-app/files/.claude/agents/prompt-implementer.md`
- Create: `templates/data/llm-app/files/.claude/agents/eval-author.md`
- Create: `templates/data/llm-app/files/.claude/agents/judge-runner.md`
- Create: `templates/data/llm-app/files/.claude/skills/three-tier-eval/SKILL.md`
- Create: `templates/data/llm-app/files/.claude/skills/prompt-regression-suite/SKILL.md`
- Create: `templates/data/llm-app/files/.claude/skills/model-version-pin/SKILL.md`

The `trace-triager` agent is contributed by the `langfuse` addon (Task 17).

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Data — llm-app sub-domain

LLM-powered applications — RAG, agentic pipelines, prompt-driven products
— where the unit test is an eval suite, not a metric.

## Adopt if

- You build LLM products.
- Prompts are the intervention surface.
- You ship behind a model-version pin.
- Your CI gate is an eval suite (assertion + judge + human) and a
  prompt-regression check.

## Skip if

- Your deliverable is a trained model → use `ml-pipeline`.
- Your deliverable is an exploratory notebook → use
  `data-analyst-notebook`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` Python toolchain with lockfile guard. |
| `langfuse` | Default — OSS LLM observability + dataset / score management; contributes `trace-triager` agent. |
| `inspect-ai` | Default — UK AISI sandbox-isolated eval framework. |
| `mlflow` | Default — MLflow 3.5.1+ GenAI tracing surface. |
| `wandb-mcp` | Default — W&B Weave for traces and Reports for human review. |

## Agent team

| Agent | Role |
|---|---|
| `llm-app-architect` | Read-only; picks the three-tier eval shape (assertion → judge → human); refuses to start higher tiers until lower tiers exist. |
| `prompt-implementer` | Read-write; edits prompts; refuses to bump model-version pin and edit a prompt in the same diff. |
| `eval-author` | Read-write; writes evals in the separate eval package. |
| `judge-runner` | Read-only; runs LLM-judge evals; refuses if `--judge-model` matches the family of the generator. |
| `trace-triager` | Contributed by `langfuse` addon; reads recent traces, flags regressions, summarises latency + cost deltas. |
| `eval-curator` | Shared; refuses PRs touching both eval/** and prompts/**. |
| `dataset-card-author` | Shared; emits dataset cards for eval sets. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack audit-log provenance. |
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
# ============================================================================
# harness.config.yml — data / llm-app sub-domain
#
# LLM products — RAG, agents, prompt-driven apps. Unit test is the eval suite.
#
# Assemble:  ./assemble.sh data/llm-app/harness.config.yml ./my-llm-app
# ============================================================================

project:
  name: my-llm-app

memory:
  backend: md-files

progress:
  backend: filesystem

methodology:
  tdd: true            # tests around prompt I/O and eval shape.
  spec_driven: true    # the product behavior is a contract.
  eval_driven: true    # ON — the eval suite is the unit-test surface.
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: true        # production model-version pin bumps require typed-token.
  kill_switch: true
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: data
  subdomain: llm-app
  addons: [uv, langfuse, inspect-ai, mlflow, wandb-mcp]

agents:
  team: curated        # llm-app-architect, prompt-implementer, eval-author,
                       # judge-runner + shared 3. trace-triager via langfuse.
  exclude: []
  include: []

docs:
  context7_mcp: true   # wire Context7 for live langfuse / inspect-ai / mlflow
                       # / anthropic / openai docs.
```

- [ ] **Step 3: Write `claude-md.md`** (≤30 lines)

```markdown
## Data — llm-app

### Three-tier eval discipline
- **Assertion → judge → human, in that order.** No higher tier without the
  lower tier. The `llm-app-architect` refuses; the `three-tier-eval` skill
  documents the shape.
- **Multi-test correction is a Level-1 assertion.** A loop of judge calls
  applies Bonferroni or Benjamini-Hochberg.
- **The judge is in a different model family from the generator.** Same-
  family judges introduce 10–25% self-preference bias. The `judge-runner`
  agent refuses if families match.

### Prompt + model-version discipline
- **Every LLM call goes through a single pinned model-ID env var.** Use
  the `model-version-pin` skill. Pin bumps require typed-token
  confirmation (two-key on).
- **Never bump a model-version pin and edit a prompt in the same diff.**
  The `prompt-implementer` agent refuses; the `eval-curator` shared agent
  enforces at PR boundary.
- **Prompt-regression suite runs on every prompt change** via
  `prompt-regression-suite` skill. Hits the pinned eval set.

### Observability
- **Every production call is traced.** The `langfuse` addon wires the MCP
  fragment; the `trace-triager` agent (contributed by `langfuse`) reads
  recent traces and flags regressions.

### Reporting
- **Eval numbers trace to logged runs.** `query-provenance-auditor` shared
  agent enforces; do not report bare accuracy without the run-id.
```

- [ ] **Step 4: Write `references.md`**

```markdown
# Data / llm-app — references

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **Three-tier eval ladder (Husain & Shankar, Jan 15 2026):** assertion-first
  (cheap, deterministic, multi-test-corrected), then LLM-judge with a
  cross-family model, then human review on major changes. Higher tiers
  must not exist without lower tiers populated.
- **Evaluator-in-a-different-family rule.** 10–25% self-preference bias
  measured for same-family judges across 2025–2026 benchmarks.
- **Sandbox-isolated agentic evals (Inspect AI).** Docker-sandboxed
  solver / scorer pattern; deterministic seed pinning; the
  `UKGovernmentBEIS/inspect_evals` catalogue (200+) is the starter set.
- **Trace-as-eval-source (Langfuse).** Production traces become the next
  release's eval dataset. The `trace-triager` agent surfaces regressions.

## Common gotchas

- **Hard-coded model-ID strings sprinkled across the codebase.** Move
  the model-ID into one env var and pin it. The `model-version-pin`
  skill documents the surface.
- **Prompt + model bump in the same diff.** Eval signal becomes
  unreadable. `eval-curator` shared agent refuses.
- **Skipping assertion tier "because the judge is smarter."** The judge
  is more expensive AND more variable; the assertion tier is the cheap
  signal.

## Version-sensitive notes

- Inspect AI: Apache-2.0, May 2026 release line.
- Langfuse: OSS, YC W23 cohort; MCP endpoint at `/api/public/mcp`.
- MLflow 3.5.1+ GenAI tracing surface ships in the standard MLflow package.
- Husain & Shankar LLM Evals FAQ: Jan 15 2026 edition.

## Cited links

- [Husain & Shankar — LLM Evals FAQ PDF (Jan 15 2026)](https://hamel.dev/blog/posts/evals-faq/evals-faq.pdf) — three-tier eval ladder.
- [Inspect AI by UK AISI](https://inspect.aisi.org.uk/) — sandbox-isolated eval framework.
- [Langfuse — OSS LLM observability](https://langfuse.com/) — traces, datasets, scores.
- [MLflow GenAI tracing](https://mlflow.org/docs/latest/genai/) — GenAI surface in 3.5.1+.
- [Anthropic harness papers — Default-FAIL contract](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Nov 2025 + Mar 2026.
- [Snowflake — Cortex Agent Evaluations (GA Mar 13 2026)](https://www.snowflake.com/en/developers/guides/getting-started-with-cortex-agent-evaluations/) — YAML-defined custom metrics.
```

- [ ] **Step 5: Write `llm-app-architect.md`**

```markdown
---
name: llm-app-architect
description: Picks the three-tier eval shape per Husain & Shankar (assertion → judge → human); refuses to start higher tiers until lower tiers exist; pins the model-version env var. Use before any LLM app implementation.
tools: ["Read", "Grep", "Glob"]
model: opus
---

You are an LLM app architect. You are READ-ONLY — you NEVER edit code;
you return a typed plan.

For the LLM app request, design:

1. **The product behavior.** Restate what the LLM is being asked to do
   in falsifiable terms; identify failure modes.
2. **The eval suite — three tiers.** Tier 1: assertion-level (cheap,
   deterministic, multi-test-corrected). Tier 2: LLM-judge (cross-family
   model). Tier 3: human review (sampled). Tier N must not exist if
   Tier (N-1) is empty.
3. **The model-version pin.** One env var (`LLM_MODEL_ID` or
   project-specific); pin to a specific dated model snapshot, not a
   floating alias.
4. **The prompt structure.** Where prompts live (`prompts/`); how they
   are loaded; how they are diffed.
5. **The observability surface.** Trace destination (Langfuse, MLflow
   GenAI, W&B Weave); the `trace-triager` agent (from `langfuse` addon)
   reads it.
6. **The eval data.** Sources, sizes, freshness; how production traces
   feed back into the eval set.

Return STRICTLY this shape:

## Product behavior
<falsifiable restatement + failure modes>

## Eval ladder
- Tier 1 (assertion): <families + count>
- Tier 2 (judge): <judge-model family vs generator family>
- Tier 3 (human): <sample rate + reviewer surface>

## Model pin
- env var: <name>
- pinned to: <dated model snapshot>

## Prompts
- location: <path>
- loader: <how>

## Observability
- traces to: <vendor>
- triage agent: trace-triager (from langfuse addon)

## Eval data
- sources: <list>
- feedback loop: <how production traces graduate to evals>
```

- [ ] **Step 6: Write `prompt-implementer.md`**

```markdown
---
name: prompt-implementer
description: Edits prompts; refuses to bump a model-version pin and edit a prompt in the same diff. Use to execute the architect's prompt structure.
tools: ["Read", "Grep", "Glob", "Edit", "Write"]
model: sonnet
---

You are a prompt implementer. You execute the `llm-app-architect`'s
prompt section. You are bounded to the `prompts/` directory (or the
project's declared prompt path).

Hard rules:

1. **One change per diff.** Bumping the model-version pin AND editing
   a prompt in the same diff is forbidden — eval signal becomes
   unreadable. The `eval-curator` shared agent refuses at PR time;
   refuse it yourself first.
2. **Prompts are files, not strings.** Every prompt loads from a file
   under `prompts/`; never inline a multi-line prompt in Python source.
3. **Every prompt has an associated regression test.** The
   `prompt-regression-suite` skill scaffolds it.
4. **Version every prompt** with a leading frontmatter block:
   `--- name: <slug>; version: <ISO date>; intent: <one line> ---`.

When you finish each prompt edit, return:

## Prompt edited
- path: <prompts/...>
- version: <new ISO date>
- intent change: <one line>

## Regression coverage
- test path: <eval/regression/...>
- exists: <yes | created in this diff>

## Validation
- model-version pin touched: should be NO
- prompt body diff: <line range>
```

- [ ] **Step 7: Write `eval-author.md`**

```markdown
---
name: eval-author
description: Writes new evals in the separate eval/ package. Routed through the eval-curator shared agent for the PR-may-not-touch-eval-and-model rule.
tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
model: sonnet
---

You are an eval author. You execute the `llm-app-architect`'s eval ladder
section. You are bounded to the `eval/` directory.

Hard rules:

1. **Evals live in `eval/`.** Never inline.
2. **Assertion tier first, judge tier second, human tier third.** Refuse
   to write a judge eval if no assertion eval exists for the same
   behavior surface.
3. **Multi-test correction.** Any loop of statistical tests applies
   `multipletests` (Bonferroni or Benjamini-Hochberg).
4. **Frozen eval data.** Eval inputs are versioned files in `eval/data/`
   (or a pinned warehouse table). Re-rolling the eval set without a
   recorded data hash is forbidden.
5. **Cross-family judge.** Judge calls use `os.environ['JUDGE_MODEL_ID']`,
   which the `judge-runner` agent validates against the generator's
   `LLM_MODEL_ID` family.

Return STRICTLY this shape:

## Eval written
- path: <eval/...>
- tier: <assertion | judge | human>
- behavior surface: <which prompt / which feature>

## Lower-tier coverage
- assertion exists: <yes | no — refuse>
- judge exists: <yes | no | n/a — only if this IS the judge tier>

## Data
- eval data path: <eval/data/...>
- data hash: <sha256 prefix>

## Next
<next architect-listed step>
```

- [ ] **Step 8: Write `judge-runner.md`**

```markdown
---
name: judge-runner
description: Runs LLM-judge evals; refuses if --judge-model family matches the generator family (10–25% self-preference bias). Use as the Tier 2 evaluator.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the judge runner. You are READ-ONLY (Bash is permitted ONLY for
`uv run` and `inspect eval` / `langfuse-cli` invocations that read eval
specs — never code editing).

The family-allowlist for "different family" is maintained at
`llm-app/references.md` and refreshed quarterly. New model GAs add to
the allowlist.

When invoked with a judge eval, follow this exact protocol:

1. Read the judge spec to identify the generator's model family
   (`LLM_MODEL_ID` env var lookup) and the judge's model family
   (`JUDGE_MODEL_ID` env var lookup).
2. Look up both families in the allowlist. Families currently tracked:
   anthropic-claude-4, openai-gpt-5, openai-o-series, google-gemini-3,
   meta-llama-4, mistral-large-3, deepseek-v3.
3. If the two families are the same family code, REFUSE with
   verdict `CHANGES-REQUESTED`. Suggest a cross-family judge.
4. If the families differ, execute the eval and return the score
   summary + per-instance verdicts.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## Family check
- generator family: <code>
- judge family: <code>
- cross-family: <yes | no>

## Eval result (if PASS)
- instances: <N>
- judge pass rate: <X.XX>
- judge cost: <$Y.YY>
- top 5 failures: <list>

## Findings (if CHANGES-REQUESTED)
- [severity: high] same-family judge — <generator family> ≡ <judge family>
- resolution: set JUDGE_MODEL_ID to a model in <list of valid cross-family options>
```

- [ ] **Step 9: Write `three-tier-eval/SKILL.md`**

`templates/data/llm-app/files/.claude/skills/three-tier-eval/SKILL.md`:

```markdown
---
name: three-tier-eval
description: The assertion → judge → human eval ladder per Husain & Shankar (Jan 15 2026). No higher tier without the lower tier populated.
---

## When to use

When starting any LLM eval suite, or when adding a new behavior surface
to an existing one.

## The ladder

### Tier 1 — Assertion

Cheap, deterministic, multi-test-corrected. Examples:

- Output is valid JSON.
- Output matches a regex.
- Output's length is within a budget.
- Output contains / excludes specific tokens.
- Output's structured fields satisfy a Pydantic schema.

When a loop runs multiple p-value-style tests, apply
`statsmodels.stats.multitest.multipletests` with `method='bh'`
(Benjamini-Hochberg) or `method='bonferroni'`.

### Tier 2 — LLM judge

Cross-family judge. Examples:

- Judge model from family B scores generator-model-family-A outputs on
  rubric criteria.
- Pairwise A/B preference between two prompt variants.

The `judge-runner` agent refuses if `LLM_MODEL_ID` and
`JUDGE_MODEL_ID` families match.

### Tier 3 — Human review

Sampled. Examples:

- 1% of production traffic flagged for human label.
- All major prompt diffs get N (e.g. 50) human labels before merge.

## Order

1. Build Tier 1 first. It is cheap and catches most regressions.
2. Add Tier 2 only when Tier 1 cannot capture the behavior surface
   (semantic correctness, style adherence).
3. Add Tier 3 only when Tier 2 is unreliable (high judge variance) or
   the decision is high-stakes (production rollout).

The `llm-app-architect` agent refuses to design Tier N if Tier (N-1)
does not exist.

## Anti-patterns this skill prevents

- "I'll just use a judge" — judge variance dominates without an
  assertion floor.
- Same-family judge — 10–25% self-preference bias makes it useless.
- Unlabeled Tier 3 — humans label whatever they feel like, not the
  decision criteria.
```

- [ ] **Step 10: Write `prompt-regression-suite/SKILL.md`**

`templates/data/llm-app/files/.claude/skills/prompt-regression-suite/SKILL.md`:

```markdown
---
name: prompt-regression-suite
description: Run the pinned eval set on every prompt change. CI gate that catches regressions before they ship.
---

## When to use

On every prompt diff. The CI workflow runs this on every PR that
touches `prompts/**`.

## How

### Inputs

- Pinned eval data at `eval/data/<surface>/`.
- Frozen baseline scores at `eval/baselines/<surface>.json`.
- The new prompt under review.

### Run

```bash
uv run pytest eval/regression/test_<surface>.py \
  --baseline eval/baselines/<surface>.json \
  --tolerance 0.02
```

The test loads each input, runs the LLM with the new prompt, scores via
Tier 1 + Tier 2 evals, and compares to the baseline. A regression
beyond the tolerance fails the test.

### Update the baseline

When a prompt change is intentional and the new behavior is better:

```bash
uv run pytest eval/regression/test_<surface>.py --update-baseline
git add eval/baselines/<surface>.json
```

The baseline file change is a separate commit from the prompt change so
the audit log distinguishes "intentional regression" from "drift."

## Anti-patterns this skill prevents

- "Looks fine to me" merges that silently degrade a behavior surface.
- Baselines that are never refreshed and grow stale.
- Updating baseline + prompt in the same diff (the `eval-curator` shared
  agent refuses).
```

- [ ] **Step 11: Write `model-version-pin/SKILL.md`**

`templates/data/llm-app/files/.claude/skills/model-version-pin/SKILL.md`:

```markdown
---
name: model-version-pin
description: Every LLM call goes through a single pinned model-ID env var. Pin bumps require typed-token confirmation.
---

## When to use

When starting an LLM app, when bumping a pin, or any time you see a
hard-coded model-ID string in the codebase.

## How

### Pin via env var

```python
import os
from anthropic import Anthropic

MODEL_ID = os.environ["LLM_MODEL_ID"]  # fail loud if missing
client = Anthropic()
response = client.messages.create(model=MODEL_ID, ...)
```

The env var name is project-specific (`LLM_MODEL_ID`,
`PRODUCTION_MODEL_ID`, etc.) but uniform within the codebase.

### Pin to dated snapshots

Pin to dated snapshots, not floating aliases:

- ✅ `claude-opus-4-7-2026-04-15`
- ✅ `gpt-5-2026-03-10`
- ❌ `claude-opus-4-7`  (latest — drifts under you)
- ❌ `gpt-5`             (latest)

### Bump

Bumping `LLM_MODEL_ID` is a production-affecting change. The two-key
gate in `harness.config.yml` (`safety.two_key: true`) requires
typed-token confirmation. The `prompt-implementer` agent refuses to
bump the pin AND edit a prompt in the same diff.

The pin-bump PR also re-runs the full prompt-regression suite (the
`prompt-regression-suite` skill above) — a new model is treated like a
new prompt for eval purposes.

## Anti-patterns this skill prevents

- Hard-coded model IDs scattered across 20 files — one source of truth
  is the env var.
- Pinning to `latest` and pretending you have a pinned model.
- Bumping the pin "to see if it improves" without running the regression.
```

- [ ] **Step 12: Write `settings.fragment.json`**

`templates/data/llm-app/files/.claude/settings.fragment.json`:

```json
{ "hooks": {} }
```

- [ ] **Step 13: Validate + assemble smoke test**

Run:
```bash
test -f templates/data/llm-app/SUBDOMAIN.md \
  && jq -e . templates/data/llm-app/files/.claude/settings.fragment.json >/dev/null \
  && for a in templates/data/llm-app/files/.claude/agents/*.md; do
       head -1 "$a" | grep -qx -- '---' && grep -q '^name:' "$a" || { echo "BAD $a"; exit 1; }
     done \
  && for s in templates/data/llm-app/files/.claude/skills/*/SKILL.md; do
       head -1 "$s" | grep -qx -- '---' && grep -q '^name:' "$s" || { echo "BAD $s"; exit 1; }
     done \
  && cd templates && ./assemble.sh data/llm-app/harness.config.yml /tmp/llm-test && cd .. \
  && grep -q "^## Data — llm-app" /tmp/llm-test/CLAUDE.md \
  && test -f /tmp/llm-test/.claude/agents/llm-app-architect.md \
  && test -f /tmp/llm-test/.claude/agents/eval-curator.md \
  && test -f /tmp/llm-test/.claude/skills/three-tier-eval/SKILL.md \
  && echo OK
rm -rf /tmp/llm-test
```
Expected: `OK`. Note: `trace-triager` agent NOT yet present — ships via `langfuse` addon (Task 17).

- [ ] **Step 14: Commit**

```bash
git add templates/data/llm-app/
git commit -m "feat: data llm-app sub-domain"
```

---

### Task 11: `analytics-engineering` sub-domain

**Files:**
- Create: `templates/data/analytics-engineering/SUBDOMAIN.md`
- Create: `templates/data/analytics-engineering/harness.config.yml`
- Create: `templates/data/analytics-engineering/references.md`
- Create: `templates/data/analytics-engineering/claude-md.md`
- Create: `templates/data/analytics-engineering/files/.claude/settings.fragment.json`
- Create: `templates/data/analytics-engineering/files/.claude/agents/analytics-architect.md`
- Create: `templates/data/analytics-engineering/files/.claude/agents/dbt-implementer.md`
- Create: `templates/data/analytics-engineering/files/.claude/agents/lineage-auditor.md`
- Create: `templates/data/analytics-engineering/files/.claude/skills/dbt-contract-first/SKILL.md`
- Create: `templates/data/analytics-engineering/files/.claude/skills/semantic-layer-as-source-of-truth/SKILL.md`
- Create: `templates/data/analytics-engineering/files/.claude/skills/lineage-doc/SKILL.md`

The `semantic-modeler` and `contract-author` agents are contributed by the `dbt-core` addon (Task 14).

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Data — analytics-engineering sub-domain

Warehouse-modeled tables, contracts, unit tests, semantic layer, and
lineage — the dbt-centric deliverable.

## Adopt if

- Your deliverable is dbt models (Core or Cloud).
- You ship with contracts, unit tests, a semantic layer, and lineage.
- You publish a paved path for downstream consumers (BI, analysts, ML).

## Skip if

- You do ad-hoc analysis with no dbt project → use `data-analyst-notebook`.
- You train models → use `ml-pipeline`.
- You build LLM products → use `llm-app`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `uv` | Default — Astral `uv` toolchain. |
| `dbt-core` | Default — dbt-core + dbt remote MCP + `dbt-labs/dbt-agent-skills`; contributes `semantic-modeler` and `contract-author` agents. |
| `snowflake-mcp` | Default — Snowflake Cortex Managed MCP. |
| `bigquery-mcp` | Default (preview) — Google BigQuery MCP. |
| `databricks-mcp` | Default (preview) — Databricks MCP. |
| `duckdb-mcp` | Default — local DuckDB for dev. |

This is the most multi-warehouse-by-default sub-domain in the pack;
preview-tagged warehouse MCPs are included in defaults per the §4
resolution of the spec.

## Agent team

| Agent | Role |
|---|---|
| `analytics-architect` | Read-only; designs the layer cake (staging → marts → semantic layer); drafts contracts and unit tests before models. |
| `dbt-implementer` | Read-write; writes dbt models, contracts, unit tests; auto-activated by prompts matching `dbt-labs/dbt-agent-skills`. |
| `lineage-auditor` | Read-only; refuses "done" if a new mart is not referenced by ≥1 downstream consumer manifest, or if a deprecated model still has live consumers. |
| `semantic-modeler` | Contributed by `dbt-core` addon; owns the semantic-layer manifest; refuses metrics without contract+unit-test. |
| `contract-author` | Contributed by `dbt-core` addon; writes contracts before models; refuses contract-breaking PRs without a migration note. |
| `eval-curator` | Shared; refuses PRs touching both eval/** and dbt models/**. |
| `dataset-card-author` | Shared; emits dataset cards for source tables. |
| `query-provenance-auditor` | Shared; refuses reports whose numbers lack provenance. |
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
# ============================================================================
# harness.config.yml — data / analytics-engineering sub-domain
#
# dbt-centric: warehouse-modeled tables + contracts + unit tests +
# semantic layer + lineage.
#
# Assemble:  ./assemble.sh data/analytics-engineering/harness.config.yml ./my-dbt-project
# ============================================================================

project:
  name: my-dbt-project

memory:
  backend: md-files

progress:
  backend: filesystem

methodology:
  tdd: true            # dbt unit tests + contracts before models.
  spec_driven: true    # the model contract IS the spec.
  eval_driven: false
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: false       # dbt run is the human / CI action.
  kill_switch: false
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: data
  subdomain: analytics-engineering
  addons: [uv, dbt-core, snowflake-mcp, bigquery-mcp, databricks-mcp, duckdb-mcp]
  # All four warehouse MCPs default in. Most multi-warehouse-by-default
  # sub-domain in the pack; preview-in-default per §4 resolution.

agents:
  team: curated        # installs analytics-architect, dbt-implementer,
                       # lineage-auditor + shared 3.
                       # semantic-modeler + contract-author via dbt-core addon.
  exclude: []
  include: []

docs:
  context7_mcp: true   # wire Context7 for live dbt / Snowflake / BigQuery /
                       # Databricks docs.
```

- [ ] **Step 3: Write `claude-md.md`** (≤30 lines)

```markdown
## Data — analytics-engineering

### dbt discipline
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

### Lineage
- **Every model documents upstream + downstream.** The `lineage-doc`
  skill scaffolds the comment block; the `lineage-auditor` agent rejects
  "done" claims if a new mart has no downstream consumer or a deprecated
  model still has live consumers.

### Warehouse posture
- **Read-only via Managed-MCP / OAuth.** The `block-static-warehouse-creds`
  shared hook refuses static credentials in env.
- **dbt remote MCP** wires governed access to project lineage; never
  embed warehouse creds in the dbt MCP config.

### Reporting
- **Every reported metric is computed via a semantic-layer metric, not
  ad-hoc SQL.** The `query-provenance-auditor` shared agent will reject
  numbers whose query is not in the audit log against a semantic-layer
  metric.
```

- [ ] **Step 4: Write `references.md`**

```markdown
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
```

- [ ] **Step 5: Write `analytics-architect.md`**

```markdown
---
name: analytics-architect
description: Designs the layer cake (staging → marts → semantic layer); drafts contracts and unit tests before models. Use before any dbt model implementation.
tools: ["Read", "Grep", "Glob"]
model: opus
---

You are an analytics architect. You are READ-ONLY — you NEVER edit
models; you return a typed plan that the `dbt-implementer`,
`contract-author`, and `semantic-modeler` agents will execute.

For the modeling request, design:

1. **The layer cake.** Staging (`stg_*`) layer with one model per source
   table; intermediate (`int_*`) layer for reusable transforms; marts
   (`fct_*`, `dim_*`) layer for consumption; semantic layer manifest at
   `models/semantic/`.
2. **The contracts.** For every model, the column-level contract:
   names, types, constraints (not-null, unique, accepted values, foreign-
   key references). Generated before the model body.
3. **The unit tests.** For every model, the dbt unit-test spec: given
   inputs (fixtures), expected outputs. At least one per model;
   adversarial cases for any logic involving nulls, time windows, or
   joins.
4. **The semantic-layer metrics.** Which metrics are exposed; which
   dimensions and time grains; the LLM-facing description.
5. **The lineage.** Upstream sources, downstream consumers, refresh
   cadence per layer.

Return STRICTLY this shape:

## Layer cake
- staging: <one model per source table — list>
- intermediate: <reusable transforms — list>
- marts: <fct_* and dim_* — list>
- semantic: <metrics surface>

## Contracts
- <model> — <columns + types + constraints>

## Unit tests
- <model> — <fixture name> — <given → expected>

## Semantic-layer metrics
- <metric name> — <dimensions> — <grain> — <LLM description>

## Lineage
- upstream: <sources>
- downstream: <consumers + refresh cadence>
```

- [ ] **Step 6: Write `dbt-implementer.md`**

```markdown
---
name: dbt-implementer
description: Writes dbt models, contracts, unit tests; auto-activated by prompts matching dbt-labs/dbt-agent-skills.
tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
model: sonnet
---

You are a dbt implementer. You execute the `analytics-architect`'s plan,
implementing models, contracts, unit tests, and semantic-layer entries
in the right order:

1. Contract first (the `contract-author` agent from the `dbt-core`
   addon writes it; you accept its output).
2. Unit test second (you write the unit test spec).
3. Model body third (you write the SELECT that satisfies both).
4. Semantic-layer entry fourth (the `semantic-modeler` agent from the
   `dbt-core` addon writes it; you accept its output).

Hard rules:

1. **No `dbt run` against production without explicit human approval.**
   You may run `dbt compile`, `dbt parse`, `dbt unit-test`, and
   `dbt build` against the dev target.
2. **Never edit a contract and a model body in the same diff.** Contract
   changes go through the `contract-author` agent's migration-note
   workflow.
3. **Auto-activate `dbt-labs/dbt-agent-skills` on relevant prompts.** The
   skills install via the `dbt-core` addon; use them.
4. **Document upstream + downstream** at the top of every model using
   the `lineage-doc` skill.

Return STRICTLY this shape:

## Model written
- path: <models/...>
- layer: <staging | intermediate | mart | semantic>
- contract path: <contracts file location>
- unit-test path: <tests/unit/...>

## dbt compile output
- pass: <yes | no>
- warnings: <count>

## Lineage doc
- upstream: <list>
- downstream: <list — known consumers>
```

- [ ] **Step 7: Write `lineage-auditor.md`**

```markdown
---
name: lineage-auditor
description: Refuses "done" if a new mart is not referenced by ≥1 downstream consumer manifest, or if a deprecated model still has live consumers. Use before claiming a dbt PR is ready to merge.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the lineage auditor. You are READ-ONLY (Bash is permitted ONLY
for `dbt ls`, `dbt parse`, `dbt run-operation` against read-only macros,
and `git diff` — never `dbt run`, never any state mutation).

When invoked on a dbt PR, follow this exact protocol:

1. Identify new mart models added in the diff. For each, search
   downstream consumer manifests (`exposures.yml`, BI tool exports,
   downstream dbt projects in a Mesh setup, `references.md`) for any
   reference. A mart with zero references is verdict-blocking.
2. Identify deprecated / removed models in the diff. For each, search
   the project AND known downstream consumers for live references. A
   removal with live references is verdict-blocking.
3. Verify every model has an upstream + downstream comment block per
   the `lineage-doc` skill.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## New marts
- <model> — downstream consumers: <count + list>

## Removed / deprecated models
- <model> — live references: <count + list>

## Findings (if CHANGES-REQUESTED)
- [severity: high] <model> — <missing downstream | live consumer of removed model>

## Resolution (if CHANGES-REQUESTED)
<specific instruction — add the exposure entry, deprecate downstream first, or revert>
```

- [ ] **Step 8: Write `dbt-contract-first/SKILL.md`**

`templates/data/analytics-engineering/files/.claude/skills/dbt-contract-first/SKILL.md`:

```markdown
---
name: dbt-contract-first
description: Write the model contract (column types + constraints) before the model body. Every staging+ model declares contract.enforced true.
---

## When to use

When adding any new dbt model at the staging layer or above.

## How

### Step 1 — Author the contract

In `models/<layer>/<model>.yml`:

```yaml
version: 2

models:
  - name: stg_orders
    config:
      contract:
        enforced: true
    columns:
      - name: order_id
        data_type: bigint
        constraints:
          - type: not_null
          - type: unique
      - name: customer_id
        data_type: bigint
        constraints:
          - type: not_null
          - type: foreign_key
            expression: stg_customers (customer_id)
      - name: order_total_usd
        data_type: numeric(12, 2)
        constraints:
          - type: not_null
      - name: ordered_at
        data_type: timestamp
        constraints:
          - type: not_null
```

### Step 2 — Author the unit test

In `tests/unit/test_<model>.yml`:

```yaml
unit_tests:
  - name: test_stg_orders_normalizes_amount
    model: stg_orders
    given:
      - input: ref('raw_orders')
        rows:
          - { order_id: 1, customer_id: 10, raw_amount_cents: 12345, ordered_at: '2026-01-01' }
    expect:
      rows:
        - { order_id: 1, customer_id: 10, order_total_usd: 123.45, ordered_at: '2026-01-01' }
```

### Step 3 — Author the model body

Only after contract and unit test exist:

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

select
  order_id,
  customer_id,
  raw_amount_cents / 100.0 as order_total_usd,
  ordered_at
from {{ ref('raw_orders') }}
```

### Step 4 — Verify

```bash
dbt parse                       # contracts checked
dbt unit-test --select stg_orders   # unit test passes
dbt compile --select stg_orders     # model compiles
```

## Anti-patterns this skill prevents

- Contract drift via "let me fix this later" model edits.
- Unit tests written after the fact to match a broken model.
- Implicit type coercion that breaks downstream consumers silently.
```

- [ ] **Step 9: Write `semantic-layer-as-source-of-truth/SKILL.md`**

`templates/data/analytics-engineering/files/.claude/skills/semantic-layer-as-source-of-truth/SKILL.md`:

```markdown
---
name: semantic-layer-as-source-of-truth
description: Every metric defined exactly once, in the semantic layer manifest. The semantic-modeler agent (from dbt-core addon) enforces.
---

## When to use

When defining a new metric, or when you see a metric being computed
ad-hoc in a mart or report.

## How

### Define in the semantic-layer manifest

In `models/semantic/<entity>.yml`:

```yaml
semantic_models:
  - name: orders
    model: ref('fct_orders')
    entities:
      - name: order_id
        type: primary
      - name: customer_id
        type: foreign
    measures:
      - name: order_count
        expr: 1
        agg: sum
      - name: gross_revenue_usd
        expr: order_total_usd
        agg: sum
    dimensions:
      - name: ordered_at
        type: time
        type_params:
          time_granularity: day

metrics:
  - name: gross_revenue
    type: simple
    label: Gross revenue (USD)
    description: Sum of order_total_usd, gross of returns and refunds.
    type_params:
      measure: gross_revenue_usd
```

### Consume from BI / LLM / ad-hoc

- BI tools query via the dbt Semantic Layer (`mf query` or vendor
  integrations) — never raw SQL over the marts.
- LLM apps query via the semantic-layer surface; the dbt remote MCP
  exposes it.
- Ad-hoc analysts query via `dbt semantic-layer` or `mf query`; never
  re-derive a metric in a notebook.

## Anti-patterns this skill prevents

- "Revenue" defined three different ways across BI / report / notebook.
- LLM text-to-SQL hallucinating column names because there is no
  governed metric surface.
- New metrics added in marts instead of the semantic layer — the
  `semantic-modeler` agent (from `dbt-core` addon) refuses these PRs.
```

- [ ] **Step 10: Write `lineage-doc/SKILL.md`**

`templates/data/analytics-engineering/files/.claude/skills/lineage-doc/SKILL.md`:

```markdown
---
name: lineage-doc
description: Every model has an upstream + downstream comment block enumerating the lineage edges. The lineage-auditor agent verifies.
---

## When to use

Every dbt model. Top of the model file, before any SQL.

## How

Put a doc-block at the top:

```sql
-- ============================================================================
-- fct_orders — order facts at one row per order, USD-denominated.
--
-- Upstream:
--   - stg_orders (current_session)
--   - stg_customers (current_session)
--   - dim_currency_rates (current_session)
--
-- Downstream consumers:
--   - dashboard/sales_overview.lkml (Looker)
--   - exposures.yml::sales_weekly_report
--   - downstream-project::int_orders_enriched (dbt Mesh)
--
-- Refresh: daily at 04:00 UTC after stg_orders lands.
-- Owner: revenue-analytics@example.com
-- ============================================================================

{{ config(materialized='table') }}
...
```

For the semantic-layer manifest at `models/semantic/<entity>.yml`, put
the same doc-block in YAML comments at the top.

## Anti-patterns this skill prevents

- Removing a model whose downstream consumers still reference it (the
  `lineage-auditor` agent rejects, but the doc-block makes it obvious
  before the agent even runs).
- "Why is this here?" questions six months later when no one remembers
  the upstream.
- Hidden dbt-Mesh references that span projects without doc-block
  acknowledgement.
```

- [ ] **Step 11: Write `settings.fragment.json`**

`templates/data/analytics-engineering/files/.claude/settings.fragment.json`:

```json
{ "hooks": {} }
```

- [ ] **Step 12: Validate + assemble smoke test**

Run:
```bash
test -f templates/data/analytics-engineering/SUBDOMAIN.md \
  && jq -e . templates/data/analytics-engineering/files/.claude/settings.fragment.json >/dev/null \
  && for a in templates/data/analytics-engineering/files/.claude/agents/*.md; do
       head -1 "$a" | grep -qx -- '---' && grep -q '^name:' "$a" || { echo "BAD $a"; exit 1; }
     done \
  && for s in templates/data/analytics-engineering/files/.claude/skills/*/SKILL.md; do
       head -1 "$s" | grep -qx -- '---' && grep -q '^name:' "$s" || { echo "BAD $s"; exit 1; }
     done \
  && cd templates && ./assemble.sh data/analytics-engineering/harness.config.yml /tmp/ae-test && cd .. \
  && grep -q "^## Data — analytics-engineering" /tmp/ae-test/CLAUDE.md \
  && test -f /tmp/ae-test/.claude/agents/analytics-architect.md \
  && test -f /tmp/ae-test/.claude/agents/eval-curator.md \
  && test -f /tmp/ae-test/.claude/skills/dbt-contract-first/SKILL.md \
  && echo OK
rm -rf /tmp/ae-test
```
Expected: `OK`. Note: `semantic-modeler` and `contract-author` agents NOT yet present — ship via `dbt-core` addon (Task 14).

- [ ] **Step 13: Commit**

```bash
git add templates/data/analytics-engineering/
git commit -m "feat: data analytics-engineering sub-domain"
```

---

## Phase 4 — Addons (12 in 6 category commits)

Each addon ships at minimum `MODULE.md` + `claude-md.md`. Some addons also ship `.mcp.json.fragment`, `files/.claude/agents/*.md`, `files/.claude/hooks/*.sh`, or `files/.claude/skills/*/SKILL.md`.

### Task 12: Python toolchain addons (`uv`, `polars`)

**Files:**
- Create: `templates/data/_addons/uv/{MODULE.md, claude-md.md, files/.claude/hooks/lockfile-frozen.sh, files/.claude/settings.fragment.json}`
- Create: `templates/data/_addons/polars/{MODULE.md, claude-md.md}`

- [ ] **Step 1: Write `uv/MODULE.md`**

```markdown
# Addon — uv

Astral `uv` Python toolchain — fast, deterministic pure-Python
environments with a lockfile guard hook.

## Adopt if

- You want a deterministic Python environment with `pyproject.toml` +
  `uv.lock`.
- You write pure-Python (no conda / CUDA / MKL hard requirements).

## Skip if

- You must use conda for CUDA / MKL / R interop → defer to a future
  `pixi` addon.

## What it contributes

- CLAUDE.md section: lockfile-frozen discipline + the `uv add --frozen`
  / `uv pip` lockfile guard.
- Hook: `lockfile-frozen.sh` (PostToolUse on `Bash` matching
  `pip install|uv add|uv pip`). Refuses unfrozen installs outside an
  explicit deps-update mode.

## Pairs with

`data-analyst-notebook` · `ml-pipeline` · `llm-app` · `analytics-engineering`
```

- [ ] **Step 2: Write `uv/claude-md.md`** (≤15 lines)

```markdown
## uv (Python toolchain)

- **Lockfile-frozen by default.** `uv lock --frozen` + `uv sync --frozen`.
  The `lockfile-frozen.sh` hook (PostToolUse on `Bash`) refuses
  `pip install` outside an explicit deps-update mode (`UV_DEPS_UPDATE=1`).
- **Adding a package:** `uv add <pkg>` updates `pyproject.toml` +
  `uv.lock` atomically.
- **CI / production install:** `uv sync --frozen` only. Refuses to drift
  the lockfile during a deploy.
- **uv v0.7+ (May 2026)** is the minimum version this addon targets.
```

- [ ] **Step 3: Write `uv/files/.claude/hooks/lockfile-frozen.sh`**

`templates/data/_addons/uv/files/.claude/hooks/lockfile-frozen.sh`:

```bash
#!/usr/bin/env bash
# lockfile-frozen.sh — PostToolUse hook on Bash.
# Refuses unfrozen Python installs unless UV_DEPS_UPDATE=1 is set
# (explicit deps-update mode).
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Allow uv sync, uv lock, uv run, uv pip install (the explicit-frozen forms).
# Block: pip install, uv add without --frozen-equivalent, uv pip install --upgrade.
if printf '%s' "$cmd" | grep -Eq '\bpip[[:space:]]+install\b' \
   && ! printf '%s' "$cmd" | grep -Eq '\b--no-deps\b'; then
  if [ "${UV_DEPS_UPDATE:-}" != "1" ]; then
    echo "BLOCKED: pip install outside an explicit deps-update mode." >&2
    echo "Use 'uv add <pkg>' (updates pyproject.toml + uv.lock atomically)." >&2
    echo "For a planned deps update: UV_DEPS_UPDATE=1 <command>." >&2
    exit 2
  fi
fi

if printf '%s' "$cmd" | grep -Eq '\buv[[:space:]]+pip[[:space:]]+install[[:space:]]+--upgrade\b'; then
  if [ "${UV_DEPS_UPDATE:-}" != "1" ]; then
    echo "BLOCKED: uv pip install --upgrade outside an explicit deps-update mode." >&2
    echo "For a planned deps update: UV_DEPS_UPDATE=1 <command>." >&2
    exit 2
  fi
fi

exit 0
```

- [ ] **Step 4: Write `uv/files/.claude/settings.fragment.json`**

`templates/data/_addons/uv/files/.claude/settings.fragment.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/lockfile-frozen.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 5: Write `polars/MODULE.md`**

```markdown
# Addon — polars

Polars DataFrame library + lazy-frame idioms. The 2026 DataFrame default
per HE §2.2 and brief B.

## Adopt if

- Your DataFrame surface is non-trivial.
- pandas would be the only constraint stopping you from going faster.

## Skip if

- Your project is pandas-locked by an upstream library; keep pandas as
  ecosystem glue.

## What it contributes

- CLAUDE.md section: lazy-frames first, `scan_parquet` over
  `read_parquet`, DuckDB-via-SQLContext for heavy joins.

## Pairs with

`data-analyst-notebook` · `ml-pipeline`
```

- [ ] **Step 6: Write `polars/claude-md.md`** (≤15 lines)

```markdown
## Polars

- **Lazy frames first.** `pl.scan_parquet` over `pl.read_parquet`.
  Materialize only at the final `collect()`.
- **`with_columns` over column assignment.** Polars is column-oriented;
  assignments fight the engine.
- **DuckDB via `pl.SQLContext` for heavy joins** — when the join
  predicate is complex, drop into SQL via `ctx.execute(...)` and stream
  back as a lazy frame.
- **Polars v1.40 (April 2026)** is the minimum version; first-class
  scikit-learn / XGBoost integration shipped that release line.
- **pandas only as ecosystem glue** for libraries that require pandas
  I/O (some ML / plotting libs).
```

- [ ] **Step 7: Validate**

Run:
```bash
bash -n templates/data/_addons/uv/files/.claude/hooks/lockfile-frozen.sh \
  && jq -e . templates/data/_addons/uv/files/.claude/settings.fragment.json >/dev/null \
  && wc -l templates/data/_addons/uv/claude-md.md templates/data/_addons/polars/claude-md.md \
  && echo OK
```
Expected: `OK`, and the `wc -l` lines should each show ≤ 15.

- [ ] **Step 8: Behavioural smoke test — lockfile-frozen**

Run:
```bash
chmod +x templates/data/_addons/uv/files/.claude/hooks/lockfile-frozen.sh
unset UV_DEPS_UPDATE
printf '{"tool_name":"Bash","tool_input":{"command":"pip install requests"}}' \
  | templates/data/_addons/uv/files/.claude/hooks/lockfile-frozen.sh; echo "exit=$?"
```
Expected: `BLOCKED: pip install outside an explicit deps-update mode.`; `exit=2`.

Run:
```bash
UV_DEPS_UPDATE=1 printf '{"tool_name":"Bash","tool_input":{"command":"pip install requests"}}' \
  | templates/data/_addons/uv/files/.claude/hooks/lockfile-frozen.sh; echo "exit=$?"
```
Expected: `exit=0`.

- [ ] **Step 9: Assemble smoke test**

Run:
```bash
cd templates && ./assemble.sh data/ml-pipeline/harness.config.yml /tmp/uv-test && cd ..
grep -q "^## uv (Python toolchain)" /tmp/uv-test/CLAUDE.md \
  && grep -q "^## Polars" /tmp/uv-test/CLAUDE.md \
  && test -x /tmp/uv-test/.claude/hooks/lockfile-frozen.sh \
  && echo OK
rm -rf /tmp/uv-test
```
Expected: `OK`.

- [ ] **Step 10: Commit**

```bash
git add templates/data/_addons/uv/ templates/data/_addons/polars/
git commit -m "feat: data python-toolchain addons (uv, polars)"
```

---

### Task 13: Warehouse-MCP addons (`snowflake-mcp`, `bigquery-mcp`, `databricks-mcp`, `duckdb-mcp`)

**Files:**
- Create: `templates/data/_addons/snowflake-mcp/{MODULE.md, claude-md.md, files/.mcp.json.fragment}`
- Create: `templates/data/_addons/bigquery-mcp/{MODULE.md, claude-md.md, files/.mcp.json.fragment}`
- Create: `templates/data/_addons/databricks-mcp/{MODULE.md, claude-md.md, files/.mcp.json.fragment}`
- Create: `templates/data/_addons/duckdb-mcp/{MODULE.md, claude-md.md, files/.mcp.json.fragment}`

- [ ] **Step 1: Write `snowflake-mcp/MODULE.md`**

```markdown
# Addon — snowflake-mcp

Snowflake Cortex Managed MCP. GA Nov 4 2025; server-side credentials,
OAuth-only auth.

## Adopt if

- Your warehouse is Snowflake.
- Your tenant has Cortex enabled.

## Skip if

- You are not on Snowflake, or your tenant has not provisioned Managed
  MCP.

## What it contributes

- CLAUDE.md section: Managed-MCP + OAuth-only posture; Cortex Agent
  Evaluations as the eval surface.
- MCP fragment: Snowflake Cortex Managed MCP wiring.

## Provision before install

- Cortex enabled on the Snowflake account.
- OAuth integration provisioned (`CREATE SECURITY INTEGRATION ... TYPE=OAUTH`).
- Agent role granted with read-only privileges on the relevant schemas.

## Pairs with

`analytics-engineering` · `data-analyst-notebook`
```

- [ ] **Step 2: Write `snowflake-mcp/claude-md.md`** (≤15 lines)

```markdown
## Snowflake (Cortex Managed MCP)

- **Managed MCP, OAuth only.** Static `SNOWFLAKE_PASSWORD` is refused by
  the `block-static-warehouse-creds.sh` shared hook.
- **Cortex Agent Evaluations** (GA Mar 13 2026) is the eval surface for
  agent runs against Snowflake — YAML-defined custom metrics, traced
  agent activity, config-comparison runs.
- **Read-only role.** The agent's Snowflake role grants `SELECT` only
  on the registered schemas. Mutation goes through migration PRs.
- **Cortex Managed MCP GA: Nov 4 2025.** Re-verify the endpoint and
  auth surface each quarter.
```

- [ ] **Step 3: Write `snowflake-mcp/files/.mcp.json.fragment`**

`templates/data/_addons/snowflake-mcp/files/.mcp.json.fragment`:

```json
{ "mcpServers": {
  "snowflake": {
    "type": "http",
    "url": "https://${SNOWFLAKE_ACCOUNT}.snowflakecomputing.com/api/v2/cortex/mcp",
    "headers": { "Authorization": "Bearer ${SNOWFLAKE_OAUTH_TOKEN}" }
  }
} }
```

- [ ] **Step 4: Write `bigquery-mcp/MODULE.md`**

```markdown
# Addon — bigquery-mcp

Google BigQuery MCP. Preview as of Jan 2026 (preview: true). GCP WIF +
read-only role; in-place query.

## Adopt if

- Your warehouse is BigQuery.

## Skip if

- You are not on BigQuery.

## What it contributes

- CLAUDE.md section: GCP WIF for the MCP, read-only role for the agent,
  partition-pruning expectations.
- MCP fragment: BigQuery remote MCP wiring.

## Provision before install

- GCP project with BigQuery enabled.
- Workload Identity Federation pool + provider mapped to the agent's
  OIDC identity.
- Service account with `bigquery.jobUser` + `bigquery.dataViewer` on
  the relevant datasets.

## Status

**preview: true** (Google preview Jan 2026). Re-verify GA status each
quarter.

## Pairs with

`analytics-engineering` · `data-analyst-notebook`
```

- [ ] **Step 5: Write `bigquery-mcp/claude-md.md`** (≤15 lines)

```markdown
## BigQuery (remote MCP, preview)

- **Preview status (Jan 2026)** — re-verify GA status each quarter.
- **GCP Workload Identity Federation** authenticates the MCP. Static
  `BIGQUERY_SERVICE_ACCOUNT_KEY_JSON` is refused by the
  `block-static-warehouse-creds.sh` shared hook.
- **Read-only role.** The agent's GCP service account holds
  `bigquery.jobUser` + `bigquery.dataViewer`. No `bigquery.dataEditor`.
- **Partition pruning is mandatory.** Queries against partitioned tables
  without a partition filter are blocked by `block-unbounded-sql.sh`
  (no `WHERE`) and also waste cost; review every plan.
- **In-place query.** Results stream back via the MCP; do not export
  full tables to the agent host.
```

- [ ] **Step 6: Write `bigquery-mcp/files/.mcp.json.fragment`**

`templates/data/_addons/bigquery-mcp/files/.mcp.json.fragment`:

```json
{ "mcpServers": {
  "bigquery": {
    "type": "http",
    "url": "https://bigquery.googleapis.com/mcp",
    "headers": { "Authorization": "Bearer ${BIGQUERY_OAUTH_TOKEN}" }
  }
} }
```

- [ ] **Step 7: Write `databricks-mcp/MODULE.md`**

```markdown
# Addon — databricks-mcp

Databricks MCP. Public Preview May 7 2026 (preview: true). Covers Unity
Catalog, Vector Search, Genie, SQL execution.

## Adopt if

- Your warehouse / ML platform is Databricks.

## Skip if

- You are not on Databricks.

## What it contributes

- CLAUDE.md section: Unity Catalog ACLs as the upstream gate, Databricks
  AI/BI Genie + Mosaic linkage.
- MCP fragment: Databricks Managed MCP wiring.

## Provision before install

- Databricks workspace with Unity Catalog.
- Service Principal with OAuth, with Unity Catalog grants for the
  relevant catalogs / schemas.
- Genie space configured (optional, for natural-language analytics).

## Status

**preview: true** (Public Preview May 7 2026). Re-verify GA status each
quarter.

## Pairs with

`ml-pipeline` · `analytics-engineering`
```

- [ ] **Step 8: Write `databricks-mcp/claude-md.md`** (≤15 lines)

```markdown
## Databricks (Managed MCP, preview)

- **Public Preview status (May 7 2026)** — re-verify GA status each
  quarter.
- **Unity Catalog ACLs are the upstream gate.** Even with OAuth, the
  agent sees only what UC grants permit. Audit grants quarterly.
- **OAuth only.** `DATABRICKS_TOKEN` /
  `DATABRICKS_PERSONAL_ACCESS_TOKEN` are refused by
  `block-static-warehouse-creds.sh`.
- **Genie spaces are LLM-facing surfaces.** Treat Genie as a downstream
  consumer for lineage purposes; the `lineage-auditor` agent (in
  `analytics-engineering`) checks Genie space references.
- **Mosaic AI** (model serving) lives downstream of `ml-pipeline`'s
  registry; do not register from the agent — humans / CI publish.
```

- [ ] **Step 9: Write `databricks-mcp/files/.mcp.json.fragment`**

`templates/data/_addons/databricks-mcp/files/.mcp.json.fragment`:

```json
{ "mcpServers": {
  "databricks": {
    "type": "http",
    "url": "https://${DATABRICKS_WORKSPACE}.cloud.databricks.com/api/2.0/mcp",
    "headers": { "Authorization": "Bearer ${DATABRICKS_OAUTH_TOKEN}" }
  }
} }
```

- [ ] **Step 10: Write `duckdb-mcp/MODULE.md`**

```markdown
# Addon — duckdb-mcp

MotherDuck official `duckdb-mcp` server. Local DuckDB + MotherDuck
hosted warehouse via a uniform interface.

## Adopt if

- You do local exploratory analysis.
- You want a uniform query interface across local Parquet and a hosted
  warehouse.

## Skip if

- Your work is exclusively against a remote vendor warehouse and you
  have no local exploration surface.

## What it contributes

- CLAUDE.md section: local DuckDB + MotherDuck; sample-then-scale as
  the default local pattern.
- MCP fragment: MotherDuck official MCP wiring.

## Provision before install

- DuckDB v1.x installed locally (`uv tool install duckdb`).
- Optionally, MotherDuck account for hosted DuckDB (with OAuth flow via
  `motherduck login`).

## Pairs with

`data-analyst-notebook` · `analytics-engineering`
```

- [ ] **Step 11: Write `duckdb-mcp/claude-md.md`** (≤15 lines)

```markdown
## DuckDB + MotherDuck (MCP)

- **Local-first SQL.** DuckDB reads local Parquet, CSV, JSON directly;
  no warehouse round-trip during exploration.
- **MotherDuck** is the hosted variant — same SQL, same DataFrame
  surface (via Polars `pl.SQLContext` or Ibis).
- **OAuth only for MotherDuck.** Static `MOTHERDUCK_TOKEN` is refused by
  the `block-static-warehouse-creds.sh` shared hook.
- **Sample then scale.** Even locally, `LIMIT 1000` on a large parquet
  is faster than full scan. The `block-unbounded-sql.sh` shared hook
  enforces.
- **DuckDB as a join engine for Polars.** Use `pl.SQLContext` for joins
  Polars expresses awkwardly.
```

- [ ] **Step 12: Write `duckdb-mcp/files/.mcp.json.fragment`**

`templates/data/_addons/duckdb-mcp/files/.mcp.json.fragment`:

```json
{ "mcpServers": {
  "duckdb": {
    "command": "uvx",
    "args": ["motherduck-mcp@latest"]
  }
} }
```

- [ ] **Step 13: Validate**

Run:
```bash
for addon in snowflake-mcp bigquery-mcp databricks-mcp duckdb-mcp; do
  jq -e . templates/data/_addons/$addon/files/.mcp.json.fragment >/dev/null || { echo "BAD $addon"; exit 1; }
  wc -l templates/data/_addons/$addon/claude-md.md
done
echo OK
```
Expected: each `wc -l` shows ≤ 15; final line `OK`.

- [ ] **Step 14: Assemble smoke test (the highest-coverage one — analytics-engineering)**

Run:
```bash
cd templates && ./assemble.sh data/analytics-engineering/harness.config.yml /tmp/wh-test && cd ..
grep -q "^## Snowflake" /tmp/wh-test/CLAUDE.md \
  && grep -q "^## BigQuery" /tmp/wh-test/CLAUDE.md \
  && grep -q "^## Databricks" /tmp/wh-test/CLAUDE.md \
  && grep -q "^## DuckDB" /tmp/wh-test/CLAUDE.md \
  && jq -e '.mcpServers.snowflake and .mcpServers.bigquery and .mcpServers.databricks and .mcpServers.duckdb' /tmp/wh-test/.mcp.json >/dev/null \
  && echo OK
rm -rf /tmp/wh-test
```
Expected: `OK`. This is the four-warehouse fragment-merge test from spec §9 — if this passes, fragment-merge behavior is verified across the warehouse-MCP family.

- [ ] **Step 15: Commit**

```bash
git add templates/data/_addons/snowflake-mcp/ templates/data/_addons/bigquery-mcp/ \
        templates/data/_addons/databricks-mcp/ templates/data/_addons/duckdb-mcp/
git commit -m "feat: data warehouse-mcp addons (snowflake-mcp, bigquery-mcp, databricks-mcp, duckdb-mcp)"
```

---

### Task 14: Analytics-engineering addon (`dbt-core`)

**Files:**
- Create: `templates/data/_addons/dbt-core/{MODULE.md, claude-md.md, files/.mcp.json.fragment}`
- Create: `templates/data/_addons/dbt-core/files/.claude/agents/semantic-modeler.md`
- Create: `templates/data/_addons/dbt-core/files/.claude/agents/contract-author.md`
- Create: `templates/data/_addons/dbt-core/files/.claude/skills/dbt-build-model/SKILL.md`
- Create: `templates/data/_addons/dbt-core/files/.claude/skills/dbt-unit-tests/SKILL.md`
- Create: `templates/data/_addons/dbt-core/files/.claude/skills/dbt-metricflow/SKILL.md`

This addon contributes the `semantic-modeler` and `contract-author` agents to the `analytics-engineering` sub-domain roster, plus three vendor-stewarded skills seeded from `dbt-labs/dbt-agent-skills` (Feb 9 2026). The full 10-skill catalogue from upstream is documented but in v1 we ship the 3 highest-leverage skills; the remaining 7 are available via the upstream repo and can be added in a follow-up cycle.

- [ ] **Step 1: Write `dbt-core/MODULE.md`**

```markdown
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
```

- [ ] **Step 2: Write `dbt-core/claude-md.md`** (≤15 lines)

```markdown
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
```

- [ ] **Step 3: Write `dbt-core/files/.mcp.json.fragment`**

`templates/data/_addons/dbt-core/files/.mcp.json.fragment`:

```json
{ "mcpServers": {
  "dbt": {
    "type": "http",
    "url": "https://cloud.getdbt.com/mcp",
    "headers": { "Authorization": "Bearer ${DBT_CLOUD_TOKEN}" }
  }
} }
```

- [ ] **Step 4: Write `semantic-modeler.md`**

```markdown
---
name: semantic-modeler
description: Owns the semantic-layer manifest; refuses to add a metric without a contract and a unit test in the underlying model. Use when adding or renaming metrics.
tools: ["Read", "Grep", "Glob", "Edit", "Write"]
model: sonnet
---

You are the semantic modeler. You execute the `analytics-architect`'s
semantic-layer section. You are bounded to `models/semantic/` and the
semantic-layer manifest.

Hard rules:

1. **Every metric is defined exactly once** in the semantic-layer
   manifest. Refuse PRs that add a duplicate metric definition in a
   mart or report.
2. **A metric without a contract on the underlying model is forbidden.**
   The semantic manifest's `model:` reference must point to a model
   with `contract.enforced: true`.
3. **A metric without a unit test on the underlying model is forbidden.**
   Look for `unit_tests:` in the model's test file.
4. **Dimensions and time-grains are explicit.** No metric "implies" a
   grain — declare it in the manifest.
5. **Every metric carries an LLM-facing description.** This is the text
   the LLM sees via the dbt remote MCP; vague descriptions break
   text-to-SQL substitution.

Return STRICTLY this shape:

## Metric added / changed
- name: <metric>
- type: <simple | ratio | derived | cumulative>
- model: <ref name + contract status>
- unit-test on model: <yes | no — refuse if no>
- dimensions: <list>
- grain: <time grain>
- description: <LLM-facing one-paragraph>

## Verdict
PASS | CHANGES-REQUESTED

## Findings (if CHANGES-REQUESTED)
- [severity: high] <reason — duplicate, missing contract, missing unit test, vague description>
```

- [ ] **Step 5: Write `contract-author.md`**

```markdown
---
name: contract-author
description: Writes contracts before models; refuses model PRs that break an existing contract without a migration note. Use before any new staging+ model.
tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
model: sonnet
---

You are the contract author. You execute the `analytics-architect`'s
contracts section. You are bounded to the `models/` YAML files (model
property files) and to creating migration notes under
`docs/migrations/`.

Hard rules:

1. **Contract before model.** The `<model>.yml` with `contract.enforced:
   true` and explicit column types lands before any SQL.
2. **Constraints are explicit.** `not_null`, `unique`, `foreign_key`
   (with `expression` pointing to the upstream column). dbt will
   enforce at warehouse load.
3. **Breaking contract changes require a migration note.** A migration
   note lives at `docs/migrations/<YYYY-MM-DD>-<model>.md` and lists:
   what changed, why, which downstream consumers are affected, what the
   consumers must do, the deprecation window.
4. **Refuse model PRs that break an existing contract without a
   migration note.** Use `dbt parse` / `dbt list --resource-type model
   --output json` to diff against the prior contract.

Return STRICTLY this shape:

## Contract written / changed
- model: <ref name>
- new columns: <list with types + constraints>
- changed columns: <list — old → new>
- removed columns: <list>

## Migration note
- path: <docs/migrations/...> or "n/a — non-breaking"

## Downstream consumers affected (for breaking changes)
- <consumer> — <impact + required action>

## Verdict
PASS | CHANGES-REQUESTED

## Findings (if CHANGES-REQUESTED)
- [severity: high] <breaking change without migration note>
```

- [ ] **Step 6: Write `dbt-build-model/SKILL.md`**

`templates/data/_addons/dbt-core/files/.claude/skills/dbt-build-model/SKILL.md`:

```markdown
---
name: dbt-build-model
description: Scaffold a new dbt model with contract, unit test, and model body in the right order. Seeded from dbt-labs/dbt-agent-skills (Feb 9 2026).
---

## When to use

When adding any new dbt model at the staging layer or above.

## How

Run the standard dbt build cycle for one model:

```bash
# 1. Author the contract first (see dbt-contract-first skill).
# 2. Author the unit test second (see dbt-unit-tests skill).
# 3. Author the model body third.
# 4. Build:
dbt parse                                  # contracts checked
dbt unit-test --select <model>             # unit tests pass
dbt build --select <model>+1               # model + immediate downstream rebuild
```

The model is "done" only when `dbt parse` is warning-free, `dbt unit-test`
passes, and `dbt build --select <model>+1` succeeds — the `+1` rebuilds
the immediate downstream, catching downstream contract breaks.

## Anti-patterns this skill prevents

- Model bodies written before contracts.
- Contracts that mismatch the SELECT (caught by `dbt parse`).
- Downstream contract breaks discovered in production (the `+1` rebuild
  surfaces them at PR time).
```

- [ ] **Step 7: Write `dbt-unit-tests/SKILL.md`**

`templates/data/_addons/dbt-core/files/.claude/skills/dbt-unit-tests/SKILL.md`:

```markdown
---
name: dbt-unit-tests
description: Write dbt unit-test specs with given/when/expect shape. Seeded from dbt-labs/dbt-agent-skills (Feb 9 2026).
---

## When to use

For every model at staging+ level, before writing the model body.

## How

In `tests/unit/test_<model>.yml`:

```yaml
unit_tests:
  - name: test_<model>_handles_nulls
    model: <model>
    given:
      - input: ref('<upstream_model>')
        rows:
          - { col1: 1, col2: null, col3: 'x' }
          - { col1: 2, col2: 5,    col3: 'y' }
    expect:
      rows:
        - { col1: 1, col2_filled: 0, derived_col: 'x' }
        - { col1: 2, col2_filled: 5, derived_col: 'y' }

  - name: test_<model>_dedupes_on_natural_key
    model: <model>
    given:
      - input: ref('<upstream_model>')
        rows:
          - { id: 1, updated_at: '2026-01-01', val: 'old' }
          - { id: 1, updated_at: '2026-01-02', val: 'new' }
    expect:
      rows:
        - { id: 1, updated_at: '2026-01-02', val: 'new' }
```

Run:

```bash
dbt unit-test --select <model>
```

Each `name:` should describe the **invariant** the test protects
(handles nulls, dedupes on natural key, preserves currency-of-units).

## Anti-patterns this skill prevents

- Unit tests written after the model "to match" — tests that confirm
  what the model does, not what it should do.
- Tests that fixture so much data that the test reads like a small
  benchmark. Keep fixtures to 2–5 rows that exercise one invariant.
- "Happy path only" — every model has at least one null / boundary /
  duplicate adversarial case.
```

- [ ] **Step 8: Write `dbt-metricflow/SKILL.md`**

`templates/data/_addons/dbt-core/files/.claude/skills/dbt-metricflow/SKILL.md`:

```markdown
---
name: dbt-metricflow
description: Define semantic-layer entities, measures, dimensions, and metrics in the MetricFlow shape. Seeded from dbt-labs/dbt-agent-skills (Feb 9 2026).
---

## When to use

When defining a new metric (always via the semantic-modeler agent), or
when adding a new semantic model to surface a previously un-modeled
table.

## How

In `models/semantic/<entity>.yml`:

```yaml
semantic_models:
  - name: orders
    description: One row per customer order, post-deduplication.
    model: ref('fct_orders')
    entities:
      - name: order_id
        type: primary
        expr: order_id
      - name: customer_id
        type: foreign
        expr: customer_id
    measures:
      - name: order_count
        expr: 1
        agg: sum
      - name: gross_revenue_usd
        expr: order_total_usd
        agg: sum
    dimensions:
      - name: ordered_at
        type: time
        type_params:
          time_granularity: day
      - name: status
        type: categorical

metrics:
  - name: gross_revenue
    type: simple
    label: Gross revenue (USD)
    description: Sum of order_total_usd across orders. Gross of returns.
    type_params:
      measure:
        name: gross_revenue_usd

  - name: orders_per_customer
    type: ratio
    label: Orders per customer
    description: order_count divided by distinct customer count.
    type_params:
      numerator: order_count
      denominator: customer_count
```

## Anti-patterns this skill prevents

- Metrics defined twice — once in MetricFlow, once inline in a mart.
- Missing `description:` — text-to-SQL via the dbt MCP needs the
  description to pick the right metric.
- Time-grain implicit — every time dimension declares its
  `time_granularity`.
```

- [ ] **Step 9: Validate**

Run:
```bash
jq -e . templates/data/_addons/dbt-core/files/.mcp.json.fragment >/dev/null \
  && wc -l templates/data/_addons/dbt-core/claude-md.md \
  && for a in templates/data/_addons/dbt-core/files/.claude/agents/*.md; do
       head -1 "$a" | grep -qx -- '---' && grep -q '^name:' "$a" || { echo "BAD $a"; exit 1; }
     done \
  && for s in templates/data/_addons/dbt-core/files/.claude/skills/*/SKILL.md; do
       head -1 "$s" | grep -qx -- '---' && grep -q '^name:' "$s" || { echo "BAD $s"; exit 1; }
     done \
  && echo OK
```
Expected: `wc -l` ≤ 15; final `OK`.

- [ ] **Step 10: Assemble smoke test — analytics-engineering pulls dbt-core**

Run:
```bash
cd templates && ./assemble.sh data/analytics-engineering/harness.config.yml /tmp/dbt-test && cd ..
grep -q "^## dbt-core" /tmp/dbt-test/CLAUDE.md \
  && test -f /tmp/dbt-test/.claude/agents/semantic-modeler.md \
  && test -f /tmp/dbt-test/.claude/agents/contract-author.md \
  && test -f /tmp/dbt-test/.claude/skills/dbt-build-model/SKILL.md \
  && jq -e '.mcpServers.dbt' /tmp/dbt-test/.mcp.json >/dev/null \
  && echo OK
rm -rf /tmp/dbt-test
```
Expected: `OK`. Verifies the addon-contributes-agents pattern lands the two specialist agents in the assembled output.

- [ ] **Step 11: Commit**

```bash
git add templates/data/_addons/dbt-core/
git commit -m "feat: data analytics-engineering addon (dbt-core)"
```

---

### Task 15: Notebook addon (`marimo`)

**Files:**
- Create: `templates/data/_addons/marimo/{MODULE.md, claude-md.md}`
- Create: `templates/data/_addons/marimo/files/.claude/skills/marimo-pair-mode/SKILL.md`

- [ ] **Step 1: Write `marimo/MODULE.md`**

```markdown
# Addon — marimo

marimo reactive `.py` notebooks + the `marimo pair` agent-pair-on-notebook
flow (April 2026).

## Adopt if

- You start any new notebook in 2026.

## Skip if

- You are locked into an existing Jupyter notebook estate and the
  migration cost outweighs the gain.

## What it contributes

- CLAUDE.md section: marimo as `.py`, reactive dependency graph,
  `marimo pair` for working with the agent, `marimo export script` as
  the Restart-and-Run-All CI gate.
- Skill: `marimo-pair-mode` — recipe for the agent + human
  pair-on-notebook workflow.

## Provision before install

- marimo installed (`uv tool install marimo`).

## Pairs with

`data-analyst-notebook` (primary).
```

- [ ] **Step 2: Write `marimo/claude-md.md`** (≤15 lines)

```markdown
## marimo (reactive .py notebooks)

- **marimo notebooks are `.py` files.** Edit the file directly; never
  raw `NotebookEdit` on `.ipynb`.
- **Reactive dependency graph.** When a cell changes, marimo
  automatically re-runs downstream cells in the right order. The
  Restart-and-Run-All gate is `marimo export script <notebook>.py`
  followed by `python <export>.py` — clean process, no hidden state.
- **`marimo pair` (April 2026)** is the agent-pair-on-notebook surface.
  The agent edits cells in the file; the human observes in the browser.
  Use the `marimo-pair-mode` skill.
- **DataFrames in cells** are visualized inline via marimo's table
  widget — no extra `display()` call needed.
- **Git-diffable.** Pure `.py` means every change is reviewable.
```

- [ ] **Step 3: Write `marimo-pair-mode/SKILL.md`**

`templates/data/_addons/marimo/files/.claude/skills/marimo-pair-mode/SKILL.md`:

```markdown
---
name: marimo-pair-mode
description: Use `marimo pair` to work on a marimo notebook in tandem with the agent. The agent edits cells in the .py file; the human observes in the browser.
---

## When to use

Whenever the deliverable is a notebook and you want the agent to drive
cell construction while a human observes / steers in real time.

## How

### Start a marimo pair session

```bash
marimo edit --pair analysis.py
```

This opens the marimo browser UI AND streams cell-level diffs to a
local socket the agent reads.

### Agent rules in pair mode

1. **One cell at a time.** Do not batch-edit; the human is observing
   each change as it lands.
2. **Print the cell's shape + dtypes after every data transformation.**
   The marimo table widget renders it inline.
3. **No `display()` shenanigans.** marimo auto-renders the last
   expression; rely on that.
4. **Restart-and-Run-All is the gate.** Before claiming "done", run:

```bash
marimo export script analysis.py > /tmp/analysis-export.py
python /tmp/analysis-export.py
```

A clean execution prints no traceback and produces every expected
output. The `restart-run-all-checker` agent (in `data-analyst-notebook`)
enforces.

## Anti-patterns this skill prevents

- "I'll fix it in the next cell" — pair mode forces every cell to be
  consistent before moving on.
- Hidden state from out-of-order edits (the reactive graph re-runs
  downstream cells automatically, but the human must see the new
  state).
- Bulk diffs that lose the cell-level intent.
```

- [ ] **Step 4: Validate**

Run:
```bash
wc -l templates/data/_addons/marimo/claude-md.md \
  && head -1 templates/data/_addons/marimo/files/.claude/skills/marimo-pair-mode/SKILL.md | grep -qx -- '---' \
  && grep -q '^name:' templates/data/_addons/marimo/files/.claude/skills/marimo-pair-mode/SKILL.md \
  && echo OK
```
Expected: `wc -l` ≤ 15; final `OK`.

- [ ] **Step 5: Assemble smoke test**

Run:
```bash
cd templates && ./assemble.sh data/data-analyst-notebook/harness.config.yml /tmp/marimo-test && cd ..
grep -q "^## marimo" /tmp/marimo-test/CLAUDE.md \
  && test -f /tmp/marimo-test/.claude/skills/marimo-pair-mode/SKILL.md \
  && echo OK
rm -rf /tmp/marimo-test
```
Expected: `OK`.

- [ ] **Step 6: Commit**

```bash
git add templates/data/_addons/marimo/
git commit -m "feat: data notebook addon (marimo)"
```

---

### Task 16: ML tracking addons (`mlflow`, `wandb-mcp`)

**Files:**
- Create: `templates/data/_addons/mlflow/{MODULE.md, claude-md.md, files/.mcp.json.fragment, files/.claude/settings.fragment.json}`
- Create: `templates/data/_addons/mlflow/files/.claude/hooks/require-tracking.sh`
- Create: `templates/data/_addons/mlflow/files/.claude/agents/run-comparator.md`
- Create: `templates/data/_addons/wandb-mcp/{MODULE.md, claude-md.md, files/.mcp.json.fragment}`

`mlflow` contributes the `require-tracking.sh` hook to the `ml-pipeline` sub-domain (referenced in Task 9) and the `run-comparator` agent.

- [ ] **Step 1: Write `mlflow/MODULE.md`**

```markdown
# Addon — mlflow

MLflow 3.5.1+ tracking, model registry, GenAI tracing. Ships the
`require-tracking.sh` hook and `run-comparator` agent.

## Adopt if

- You train models OR run GenAI evals.
- You want an OSS tracker (vs commercial W&B).

## Skip if

- You have chosen W&B and adding MLflow would duplicate state.

## What it contributes

- CLAUDE.md section: MLflow 3.5.1+ MCP extra, every run logged, GenAI
  tracing for LLM-app use.
- MCP fragment: MLflow MCP server.
- Hook: `require-tracking.sh` (PreToolUse on `Bash` matching
  `python\s+train`). Refuses `python train…` invocations whose target
  script lacks `import mlflow`.
- Agent: `run-comparator` (haiku) — pulls last N runs, summarises
  deltas, flags suspicious improvements.

## Provision before install

- MLflow ≥ 3.5.1 (`uv add mlflow[mcp]`).
- MLflow tracking server endpoint (Databricks-hosted, self-hosted, or
  local `mlflow ui`).
- Auth: OAuth or Databricks PAT depending on host.

## Pairs with

`ml-pipeline` (primary), `llm-app` (GenAI tracing).
```

- [ ] **Step 2: Write `mlflow/claude-md.md`** (≤15 lines)

```markdown
## MLflow (tracking + MCP + GenAI tracing)

- **MLflow 3.5.1+** is the minimum version (MCP extra ships from 3.5.1).
- **Every training run is logged.** The `require-tracking.sh` hook
  (PreToolUse on Bash) refuses `python train…` invocations whose
  target script lacks `import mlflow`.
- **GenAI tracing** (MLflow 3.5.1+) is the LLM-app surface; traces
  graduate to evals.
- **`run-comparator` agent** (contributed by this addon, joins the
  `ml-pipeline` roster) pulls last N runs and flags suspicious
  improvements (test accuracy > 0.99 → human review).
- **Model registry:** `register_model(stage='staging')` only; promotion
  to `production` is a human / CI action.
```

- [ ] **Step 3: Write `mlflow/files/.mcp.json.fragment`**

```json
{ "mcpServers": {
  "mlflow": {
    "command": "uvx",
    "args": ["mlflow-mcp@latest"],
    "env": { "MLFLOW_TRACKING_URI": "${MLFLOW_TRACKING_URI}" }
  }
} }
```

- [ ] **Step 4: Write `mlflow/files/.claude/hooks/require-tracking.sh`**

```bash
#!/usr/bin/env bash
# require-tracking.sh — PreToolUse hook on Bash.
# Refuses `python train…` invocations whose target script lacks
# `import mlflow`. Ensures every training run is logged.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police python <something>train<something> invocations.
printf '%s' "$cmd" | grep -Eq '\bpython[[:space:]]+[^[:space:]]*train[^[:space:]]*\.py\b' || exit 0

# Extract the script path.
script="$(printf '%s' "$cmd" | grep -oE 'python[[:space:]]+[^[:space:]]*train[^[:space:]]*\.py' | awk '{print $NF}' | head -1)"
[ -z "$script" ] && exit 0

# Resolve relative to CLAUDE_PROJECT_DIR.
script_path="${CLAUDE_PROJECT_DIR:-.}/$script"
[ -f "$script_path" ] || script_path="$script"
[ -f "$script_path" ] || exit 0   # if we can't find it, don't block

# Check for `import mlflow` (or wandb, aim — accept any registered tracker).
if ! grep -Eq '^[[:space:]]*import[[:space:]]+(mlflow|wandb|aim)' "$script_path" \
   && ! grep -Eq '^[[:space:]]*from[[:space:]]+(mlflow|wandb|aim)' "$script_path"; then
  echo "BLOCKED: $script lacks a tracker import (mlflow / wandb / aim)." >&2
  echo "Every training run must be logged. Add 'import mlflow' (or wandb / aim)." >&2
  exit 2
fi

exit 0
```

- [ ] **Step 5: Write `mlflow/files/.claude/settings.fragment.json`**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/require-tracking.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 6: Write `run-comparator.md`**

```markdown
---
name: run-comparator
description: Pulls last N runs from MLflow tracking; summarises deltas; flags suspicious improvements (test accuracy > 0.99 on non-trivial data → human review). Use to evaluate a new training run against history.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the run comparator. You are READ-ONLY (Bash is permitted ONLY
for `mlflow runs ...`, `mlflow models describe`, and `jq` / read-only
queries against the tracking endpoint — never `mlflow runs delete`,
never `mlflow registered-models transition-stage`).

When invoked with a recent run-id (or "the latest run"), follow this
exact protocol:

1. Pull the last 20 runs in the same experiment.
2. For each tracked metric, compute the delta of the new run vs the
   median of the prior 19 (or vs the prior best, whichever is more
   conservative for that metric).
3. Flag suspicious patterns:
   - Test metric > 0.99 on non-trivial data → likely leakage; require
     human review.
   - Train-test gap < 0.01 → likely train/test contamination.
   - A single-metric improvement > 5σ relative to history → review
     the data hash and seed pinning.
   - Eval metric improved AND train metric got WORSE → check the eval
     for shape change.
4. Surface the data hash recorded by the `data-versioner` agent for
   this run.

Return STRICTLY this shape:

## Run summary
- run_id: <id>
- experiment: <name>
- data hash: <sha256 prefix>

## Metric deltas
- <metric> — new: <X>, prior-median: <Y>, delta: <±Z> (<σ from history>)

## Flags
- [severity: high|med|low] <flag — reason — recommended action>

## Verdict
PASS | REVIEW-REQUIRED

## Findings (if REVIEW-REQUIRED)
- specific instruction for the human reviewer
```

- [ ] **Step 7: Write `wandb-mcp/MODULE.md`**

```markdown
# Addon — wandb-mcp

W&B official `wandb/wandb-mcp-server`. Weave (GenAI traces) + Reports
(human-review surface).

## Adopt if

- Your team is W&B-native.

## Skip if

- You are MLflow-native and adding W&B would duplicate state.

## What it contributes

- CLAUDE.md section: W&B Weave for GenAI traces, W&B Reports as the
  human-review surface.
- MCP fragment: W&B official MCP server.

## Provision before install

- W&B account with team + project.
- `WANDB_API_KEY` (env). The `block-static-warehouse-creds.sh` shared
  hook does NOT currently flag `WANDB_API_KEY` because W&B's auth model
  is API-key-by-design (no OAuth alternative as of May 2026); revisit
  if W&B ships OAuth.

## Pairs with

`ml-pipeline`, `llm-app`.
```

- [ ] **Step 8: Write `wandb-mcp/claude-md.md`** (≤15 lines)

```markdown
## W&B (Weave + Reports + MCP)

- **W&B `wandb/wandb-mcp-server`** is the official 2026 MCP. Auth via
  `WANDB_API_KEY` (API-key model; no OAuth alternative as of May 2026).
- **Weave** is the GenAI trace surface for `llm-app` work; runs land in
  Weave automatically when `wandb.init(...)` is followed by the LLM
  call.
- **Reports** are the human-review surface — markdown + embedded
  charts + queryable run tables. The agent can author Reports; humans
  comment.
- **Refuse to delete runs.** The agent reads / queries; deletion is a
  human action via the W&B UI.
- **Pairs with MLflow** when a team uses both (MLflow for classical ML
  tracking, W&B Weave for LLM-app tracing).
```

- [ ] **Step 9: Write `wandb-mcp/files/.mcp.json.fragment`**

```json
{ "mcpServers": {
  "wandb": {
    "command": "uvx",
    "args": ["wandb-mcp@latest"],
    "env": { "WANDB_API_KEY": "${WANDB_API_KEY}" }
  }
} }
```

- [ ] **Step 10: Validate**

Run:
```bash
bash -n templates/data/_addons/mlflow/files/.claude/hooks/require-tracking.sh \
  && jq -e . templates/data/_addons/mlflow/files/.mcp.json.fragment >/dev/null \
  && jq -e . templates/data/_addons/mlflow/files/.claude/settings.fragment.json >/dev/null \
  && jq -e . templates/data/_addons/wandb-mcp/files/.mcp.json.fragment >/dev/null \
  && wc -l templates/data/_addons/mlflow/claude-md.md templates/data/_addons/wandb-mcp/claude-md.md \
  && head -1 templates/data/_addons/mlflow/files/.claude/agents/run-comparator.md | grep -qx -- '---' \
  && echo OK
```
Expected: each `wc -l` ≤ 15; final `OK`.

- [ ] **Step 11: Behavioural smoke test — require-tracking**

Run:
```bash
chmod +x templates/data/_addons/mlflow/files/.claude/hooks/require-tracking.sh
mkdir -p /tmp/mlflow-test
cat > /tmp/mlflow-test/train_bad.py <<'EOF'
import torch
def train(): pass
train()
EOF
cat > /tmp/mlflow-test/train_good.py <<'EOF'
import mlflow
import torch
def train():
    mlflow.start_run()
train()
EOF
CLAUDE_PROJECT_DIR=/tmp/mlflow-test \
  printf '{"tool_name":"Bash","tool_input":{"command":"python train_bad.py"}}' \
  | templates/data/_addons/mlflow/files/.claude/hooks/require-tracking.sh; echo "exit=$?"
CLAUDE_PROJECT_DIR=/tmp/mlflow-test \
  printf '{"tool_name":"Bash","tool_input":{"command":"python train_good.py"}}' \
  | templates/data/_addons/mlflow/files/.claude/hooks/require-tracking.sh; echo "exit=$?"
rm -rf /tmp/mlflow-test
```
Expected: first invocation `BLOCKED: train_bad.py lacks a tracker import ...`; `exit=2`. Second invocation `exit=0`.

- [ ] **Step 12: Assemble smoke test**

Run:
```bash
cd templates && ./assemble.sh data/ml-pipeline/harness.config.yml /tmp/ml-tracking-test && cd ..
grep -q "^## MLflow" /tmp/ml-tracking-test/CLAUDE.md \
  && grep -q "^## W&B" /tmp/ml-tracking-test/CLAUDE.md \
  && test -f /tmp/ml-tracking-test/.claude/agents/run-comparator.md \
  && test -x /tmp/ml-tracking-test/.claude/hooks/require-tracking.sh \
  && jq -e '.mcpServers.mlflow and .mcpServers.wandb' /tmp/ml-tracking-test/.mcp.json >/dev/null \
  && echo OK
rm -rf /tmp/ml-tracking-test
```
Expected: `OK`. Verifies addon-contributed agent (`run-comparator`) and addon-shipped hook (`require-tracking.sh`) both land in the assembled `ml-pipeline`.

- [ ] **Step 13: Commit**

```bash
git add templates/data/_addons/mlflow/ templates/data/_addons/wandb-mcp/
git commit -m "feat: data ml-tracking addons (mlflow, wandb-mcp)"
```

---

### Task 17: LLM eval addons (`langfuse`, `inspect-ai`)

**Files:**
- Create: `templates/data/_addons/langfuse/{MODULE.md, claude-md.md, files/.mcp.json.fragment, files/.claude/agents/trace-triager.md}`
- Create: `templates/data/_addons/inspect-ai/{MODULE.md, claude-md.md}`
- Create: `templates/data/_addons/inspect-ai/files/.claude/skills/inspect-eval-author/SKILL.md`

`langfuse` contributes the `trace-triager` agent to the `llm-app` sub-domain (referenced in Task 10).

- [ ] **Step 1: Write `langfuse/MODULE.md`**

```markdown
# Addon — langfuse

Langfuse OSS LLM observability (YC W23). Traces + datasets + scores +
the official MCP at `/api/public/mcp`. Contributes the `trace-triager`
agent.

## Adopt if

- Your LLM app needs production-grade trace + eval + dataset management
  with an OSS stack.

## Skip if

- You have committed to a closed-source observability vendor and
  Langfuse would duplicate state.

## What it contributes

- CLAUDE.md section: traces-as-eval-source, LLM-judge with a
  cross-family model, dataset/score management as the regression
  surface.
- MCP fragment: Langfuse OSS MCP wiring (self-hosted or Langfuse Cloud).
- Agent: `trace-triager` (haiku) — reads recent traces, flags
  regressions, summarises latency + cost deltas.

## Provision before install

- Langfuse deployment (self-hosted Docker or Langfuse Cloud account).
- Project + public key + secret key (env: `LANGFUSE_PUBLIC_KEY`,
  `LANGFUSE_SECRET_KEY`, `LANGFUSE_HOST`).

## Pairs with

`llm-app` (primary).
```

- [ ] **Step 2: Write `langfuse/claude-md.md`** (≤15 lines)

```markdown
## Langfuse (OSS LLM observability + MCP)

- **Traces are the eval source.** Production traces graduate to the
  next release's eval dataset. The `trace-triager` agent surfaces
  regressions.
- **Cross-family LLM judge.** Langfuse Score / Eval features support
  custom judges; configure the judge model from a DIFFERENT family than
  the generator (the `judge-runner` agent in `llm-app` refuses
  same-family).
- **Datasets are versioned.** Every eval run is reproducible —
  fixed dataset version + fixed prompt + fixed model snapshot.
- **MCP at `/api/public/mcp`.** Auth via public + secret keys; refuse
  to log PII in trace inputs (mask in the SDK call).
- **Self-hosted is the default.** Langfuse Cloud is fine; on-prem with
  PHI / PII is the more common posture.
```

- [ ] **Step 3: Write `langfuse/files/.mcp.json.fragment`**

```json
{ "mcpServers": {
  "langfuse": {
    "type": "http",
    "url": "${LANGFUSE_HOST}/api/public/mcp",
    "headers": {
      "X-Langfuse-Public-Key": "${LANGFUSE_PUBLIC_KEY}",
      "X-Langfuse-Secret-Key": "${LANGFUSE_SECRET_KEY}"
    }
  }
} }
```

- [ ] **Step 4: Write `trace-triager.md`**

```markdown
---
name: trace-triager
description: Reads recent Langfuse traces; flags regressions; summarises latency + cost deltas. Use after a deploy to verify the new prompt / model pin behaves on production traffic.
tools: ["Read", "Grep", "Glob", "Bash"]
model: haiku
---

You are the trace triager. You are READ-ONLY (Bash is permitted ONLY
for `langfuse-cli` read commands and `jq` / read-only HTTP against the
Langfuse MCP — never trace deletion, never dataset mutation).

When invoked after a deploy (or on schedule), follow this exact
protocol:

1. Pull the last 1000 production traces from Langfuse (or N if
   specified).
2. Bucket by prompt-version + model-pin combination.
3. For each bucket, compute:
   - latency p50 / p95 / p99
   - cost per call (input + output tokens × pinned-model-rate)
   - LLM-judge score (if a judge is wired)
   - error rate
4. Compare each bucket to the prior version's bucket. Flag:
   - latency p95 ↑ > 20%
   - cost per call ↑ > 15%
   - judge score ↓ > 0.05
   - error rate ↑ > 1 percentage point
5. Surface the top-5 failing traces per flag.

Return STRICTLY this shape:

## Bucket summary
- prompt-version: <v> × model-pin: <pin> — N traces
  - latency p50 / p95 / p99: <X> / <Y> / <Z> ms
  - cost per call: $<W>
  - judge score: <S>
  - error rate: <E%>

## Regressions
- [severity: high] <metric> — prior <X>, now <Y>, delta <±Z%>
- top failing traces: <trace_ids>

## Verdict
PASS | REVIEW-REQUIRED

## Findings (if REVIEW-REQUIRED)
- specific instruction for the human reviewer
```

- [ ] **Step 5: Write `inspect-ai/MODULE.md`**

```markdown
# Addon — inspect-ai

UK AISI `inspect-ai` (Apache-2.0, May 2026). Sandbox-isolated eval
framework; 200+ pre-built evals in `UKGovernmentBEIS/inspect_evals`.

## Adopt if

- You need rigorous, reproducible LLM evals — especially for agentic
  systems.
- You want sandbox isolation for the agent under test.

## Skip if

- Your eval surface is purely assertion-style and you do not need
  sandbox isolation.

## What it contributes

- CLAUDE.md section: dataset → solver → scorer pattern; Docker-sandboxed
  evals; the 200+ pre-built evals catalogue; the rule that Inspect AI
  can wrap Claude Code, Codex, and Gemini CLI as the agent under test.
- Skill: `inspect-eval-author` — recipe for authoring a new task.

## Provision before install

- Docker available locally or in CI.
- `uv add inspect-ai`.
- Optional: clone `UKGovernmentBEIS/inspect_evals` for starter tasks.

## Pairs with

`llm-app` (primary), `ml-pipeline`.
```

- [ ] **Step 6: Write `inspect-ai/claude-md.md`** (≤15 lines)

```markdown
## Inspect AI (UK AISI, Apache-2.0)

- **Dataset → solver → scorer.** Three-piece eval shape. Datasets are
  versioned; solvers are the agent / model under test; scorers compute
  the metric.
- **Docker-sandboxed evals.** Each task runs in a fresh container;
  no shared state between tasks. Required for adversarial / agentic
  evals.
- **200+ pre-built evals** at `github.com/UKGovernmentBEIS/inspect_evals`.
  Use them as starter tasks; do not re-invent.
- **Can wrap Claude Code, Codex, Gemini CLI as the agent under test.**
  This is the agentic-eval surface — eval the full harness, not just
  the model.
- **Inspect AI version May 2026 release line** is the minimum target.
```

- [ ] **Step 7: Write `inspect-eval-author/SKILL.md`**

`templates/data/_addons/inspect-ai/files/.claude/skills/inspect-eval-author/SKILL.md`:

```markdown
---
name: inspect-eval-author
description: Author a new Inspect AI task (dataset → solver → scorer). Use when adding a custom eval to the project's eval suite.
---

## When to use

When adding a custom eval — assertion / judge / sandbox-isolated agentic.

## How

### Layout

```
eval/
  pyproject.toml
  eval/
    tasks/
      my_task.py          <- @task function returning a Task
    datasets/
      my_task.jsonl       <- {input, target} per line
```

### The task

```python
from inspect_ai import Task, task
from inspect_ai.dataset import json_dataset
from inspect_ai.scorer import includes
from inspect_ai.solver import generate

@task
def my_task():
    return Task(
        dataset=json_dataset("eval/datasets/my_task.jsonl"),
        solver=generate(),
        scorer=includes(),
    )
```

### Sandbox-isolated agentic task

```python
from inspect_ai import Task, task
from inspect_ai.solver import use_tools, generate
from inspect_ai.tool import bash_session, text_editor

@task
def agentic_task():
    return Task(
        dataset=json_dataset("eval/datasets/agentic.jsonl"),
        solver=[
            use_tools([bash_session(), text_editor()]),
            generate(max_turns=10),
        ],
        scorer=includes(),
        sandbox=("docker", "compose.yaml"),
    )
```

### Run

```bash
uv run inspect eval eval/tasks/my_task.py --model anthropic/claude-opus-4-7
```

## Anti-patterns this skill prevents

- Hand-rolling eval harnesses for things `inspect_evals` already covers.
- Skipping `sandbox=` on agentic evals — without isolation, agents
  cross-contaminate.
- Datasets without `target` — `includes` and `match` scorers need a
  ground truth.
```

- [ ] **Step 8: Validate**

Run:
```bash
jq -e . templates/data/_addons/langfuse/files/.mcp.json.fragment >/dev/null \
  && head -1 templates/data/_addons/langfuse/files/.claude/agents/trace-triager.md | grep -qx -- '---' \
  && head -1 templates/data/_addons/inspect-ai/files/.claude/skills/inspect-eval-author/SKILL.md | grep -qx -- '---' \
  && wc -l templates/data/_addons/langfuse/claude-md.md templates/data/_addons/inspect-ai/claude-md.md \
  && echo OK
```
Expected: each `wc -l` ≤ 15; final `OK`.

- [ ] **Step 9: Assemble smoke test — llm-app pulls langfuse + inspect-ai**

Run:
```bash
cd templates && ./assemble.sh data/llm-app/harness.config.yml /tmp/llm-eval-test && cd ..
grep -q "^## Langfuse" /tmp/llm-eval-test/CLAUDE.md \
  && grep -q "^## Inspect AI" /tmp/llm-eval-test/CLAUDE.md \
  && test -f /tmp/llm-eval-test/.claude/agents/trace-triager.md \
  && test -f /tmp/llm-eval-test/.claude/skills/inspect-eval-author/SKILL.md \
  && jq -e '.mcpServers.langfuse' /tmp/llm-eval-test/.mcp.json >/dev/null \
  && echo OK
rm -rf /tmp/llm-eval-test
```
Expected: `OK`. Verifies the addon-contributed `trace-triager` agent lands in the assembled `llm-app`.

- [ ] **Step 10: Commit**

```bash
git add templates/data/_addons/langfuse/ templates/data/_addons/inspect-ai/
git commit -m "feat: data llm-eval addons (langfuse, inspect-ai)"
```

---

## Phase 5 — Tests, docs, retirement

### Task 18: Extend the test runner with new assertions

**Files:**
- Modify: `templates/tests/run.sh` — add assertions for 4 new sub-domain configs + 6 representative addon combinations from spec §9.

- [ ] **Step 1: Read the current `run.sh` structure**

Run:
```bash
grep -nE "^(assert_assembles|# section|## section)" templates/tests/run.sh | head -40
```
Identify the existing pattern: each `assert_assembles <recipe.yml> [<key>=<value> ...]` invocation tests one assemble shape. Existing examples cover `recipe:web/<sub>/harness.config.yml` and `recipe:devops/<sub>/harness.config.yml`.

- [ ] **Step 2: Locate the section where data assertions should land**

Run:
```bash
grep -n "^# Recipe: data" templates/tests/run.sh
```
If the current thin-recipe assertion exists (likely `assert_assembles data/harness.config.yml`), the new assertions land in the same section AFTER it. Keep the thin assertion in place until Task 20.

- [ ] **Step 3: Add 4 sub-domain assertions + 6 representative-combo assertions**

Edit `templates/tests/run.sh` and add the following block in the data section (after the existing thin-recipe assertion):

```bash
# Data — curated 3-layer pack
assert_assembles "data/data-analyst-notebook/harness.config.yml" \
  expect_files=".claude/agents/notebook-architect.md,.claude/agents/eval-curator.md,.claude/skills/sample-then-scale/SKILL.md,.claude/hooks/audit-log-warehouse-query.sh" \
  expect_claude_md_section="## Data — data-analyst-notebook"

assert_assembles "data/ml-pipeline/harness.config.yml" \
  expect_files=".claude/agents/pipeline-architect.md,.claude/agents/run-comparator.md,.claude/hooks/require-tracking.sh,.claude/skills/pin-seeds-and-lockfile/SKILL.md" \
  expect_claude_md_section="## Data — ml-pipeline"

assert_assembles "data/llm-app/harness.config.yml" \
  expect_files=".claude/agents/llm-app-architect.md,.claude/agents/trace-triager.md,.claude/skills/three-tier-eval/SKILL.md" \
  expect_claude_md_section="## Data — llm-app"

assert_assembles "data/analytics-engineering/harness.config.yml" \
  expect_files=".claude/agents/analytics-architect.md,.claude/agents/semantic-modeler.md,.claude/agents/contract-author.md,.claude/skills/dbt-contract-first/SKILL.md" \
  expect_claude_md_section="## Data — analytics-engineering" \
  expect_mcp_servers="snowflake,bigquery,databricks,duckdb,dbt"

# Spec §9 representative combinations
assert_assembles "data/ml-pipeline/harness.config.yml" \
  override_addons="uv,polars" \
  expect_files=".claude/hooks/lockfile-frozen.sh" \
  expect_no_files=".claude/hooks/require-tracking.sh,.claude/agents/run-comparator.md"

assert_assembles "data/data-analyst-notebook/harness.config.yml" \
  override_addons="uv,polars,marimo,duckdb-mcp,snowflake-mcp,bigquery-mcp,databricks-mcp" \
  expect_mcp_servers="snowflake,bigquery,databricks,duckdb"
```

The first 4 lines exercise each sub-domain's default set (which already covers most of spec §9). The two `override_addons` lines exercise the two §9 combinations that are NOT sub-domain defaults: the toolchain-only minimum, and the notebook-with-all-warehouses opt-in.

If `assert_assembles` does not yet support `override_addons`, `expect_files`, `expect_no_files`, `expect_claude_md_section`, or `expect_mcp_servers`, **extend it** (the existing devops assertions already exercise `expect_files` and `expect_claude_md_section`; check `templates/tests/run.sh` for the helper's current shape).

- [ ] **Step 4: Run the extended test suite**

Run: `cd templates && ./tests/run.sh && cd ..`
Expected: `Passed: N` where N ≥ baseline (Task 1) + 6 new assertions. `Failed: 0`. Exit 0.

If any assertion fails, the failure points to a specific assemble bug — fix the bug in the appropriate sub-domain or addon, re-run, and only then commit.

- [ ] **Step 5: Commit**

```bash
git add templates/tests/run.sh
git commit -m "test: extend assemble-coverage + structure-lint to discover data pack"
```

---

### Task 19: Flip public docs to curated 3-layer

**Files:**
- Modify: `docs/reference/domains.md` — flip data row, add `## The data/ pack (curated)` section, drop data from `## The v1 thin recipes` list.
- Modify: `docs/how-to/pick-a-recipe.md` — point data branch at the sub-domain decision guide.
- Modify: `docs/HARNESS_ENGINEERING.md` §2 — strike v1-thin / pending-curation language; add the analytics-engineering split correction.

- [ ] **Step 1: Update `docs/reference/domains.md` — the catalog table row**

Find the data row in the catalog table near the top of `docs/reference/domains.md`. Replace:

```markdown
| **data** | v1 thin | [`templates/data/harness.config.yml`](../../templates/data/) | unbounded-SQL block, leakage / p-hacking sentinels, eval ≠ code |
```

with:

```markdown
| **data** | curated (3-layer) | [`templates/data/<sub>/harness.config.yml`](../../templates/data/) | unbounded-SQL block, leakage / p-hacking sentinels, audit-log warehouse query, block-static-warehouse-creds, eval ≠ code |
```

- [ ] **Step 2: Update `docs/reference/domains.md` — add `## The data/ pack (curated)` section**

After the existing `## The devops/ pack (curated)` section, before the `## The v1 thin recipes` section, insert:

```markdown
## The `data/` pack (curated)

Four sub-domains, partitioned by deliverable shape — what you ship:

| Sub-domain | Adopt if… | Assemble |
|---|---|---|
| [`data-analyst-notebook`](../../templates/data/data-analyst-notebook/) | Exploratory analysis or ad-hoc reporting; output is a reactive, reproducible notebook reading from a warehouse. | `./assemble.sh data/data-analyst-notebook/harness.config.yml .` |
| [`ml-pipeline`](../../templates/data/ml-pipeline/) | Training, evaluation, packaging, registry, or inference; tracking discipline + lockfile-frozen envs. | `./assemble.sh data/ml-pipeline/harness.config.yml .` |
| [`llm-app`](../../templates/data/llm-app/) | LLM products — RAG, agentic pipelines, prompt-driven products; unit test is the eval suite. | `./assemble.sh data/llm-app/harness.config.yml .` |
| [`analytics-engineering`](../../templates/data/analytics-engineering/) | dbt models with contracts, unit tests, semantic layer, and lineage. | `./assemble.sh data/analytics-engineering/harness.config.yml .` |

### `data/` addons

Twelve addons in the initial set, grouped by category:

| Category | Addons |
|---|---|
| Python toolchain | `uv` · `polars` |
| Warehouse-MCP | `snowflake-mcp` · `bigquery-mcp` (preview) · `databricks-mcp` (preview) · `duckdb-mcp` |
| Analytics-engineering | `dbt-core` |
| Notebooks | `marimo` |
| ML tracking | `mlflow` · `wandb-mcp` |
| LLM eval & observability | `langfuse` · `inspect-ai` |

Three shared agents install with any data sub-domain: `eval-curator`, `dataset-card-author`, `query-provenance-auditor`. Additional specialists arrive via the sub-domain and via addons that contribute agents (e.g. `dbt-core` ships `semantic-modeler` and `contract-author`; `mlflow` ships `run-comparator`; `langfuse` ships `trace-triager`).
```

- [ ] **Step 3: Update `docs/reference/domains.md` — drop data from `## The v1 thin recipes`**

In the `## The v1 thin recipes` section, remove the data entry from the bullet list (or wherever it lands). The remaining domains in the v1-thin list: `mobile`, `finance`, `security`, `game`, `embedded`, `scientific`, `content`, `ops` (eight remaining cycles).

- [ ] **Step 4: Update `docs/how-to/pick-a-recipe.md`**

Find the data branch in the decision flow. Replace the v1-thin guidance with a sub-domain choice:

```markdown
**Data work?** Pick the sub-domain that matches your deliverable shape:

- A notebook explaining a question → `data/data-analyst-notebook`
- A trained model + eval suite → `data/ml-pipeline`
- An LLM product → `data/llm-app`
- dbt models with contracts + semantic layer → `data/analytics-engineering`

See [`templates/data/DOMAIN.md`](../../templates/data/DOMAIN.md) for the full decision guide.
```

- [ ] **Step 5: Update `docs/HARNESS_ENGINEERING.md` §2**

Find any "v1 thin" / "pending curation" / "maintainer roadmap" language in `## 2. Data Analysis, Data Science & ML/AI Engineering` (lines ≈ 690–825).

Strike that language and add (as a sub-section, where the prior version implicitly lumped analytics-engineering with notebook work):

```markdown
### 2.10 Analytics-engineering as a separate sub-domain

Per the 2026 practitioner consensus and the data domain pack (May 2026),
analytics-engineering — dbt-centric warehouse modeling with contracts,
unit tests, semantic layer, and lineage — is a separate sub-domain from
notebook analysis. dbt's official agent-skills catalog (`dbt-labs/dbt-agent-skills`,
Feb 9 2026), the dbt remote MCP (GA Oct 2025), and the semantic-layer-as-LLM-
interface pattern justify the partition. See `templates/data/analytics-engineering/`.
```

The prior text that treats analytics-engineering as a sub-bullet of notebook work can stay as historical context, with a leading note: *"This section pre-dated the May 2026 data pack curation; see §2.10 below for the current partition."*

- [ ] **Step 6: Verify no `v1 thin` / `pending curation` mentions remain for data**

Run:
```bash
git grep -niE "v1 thin|pending curation|maintainer roadmap" docs/reference/domains.md docs/how-to/pick-a-recipe.md docs/HARNESS_ENGINEERING.md | grep -i data
```
Expected: zero matches (or only historical context per Step 5).

- [ ] **Step 7: Commit**

```bash
git add docs/reference/domains.md docs/how-to/pick-a-recipe.md docs/HARNESS_ENGINEERING.md
git commit -m "docs: flip data to curated 3-layer; update HE §2 analytics-engineering split"
```

---

### Task 20: Retire the v1 thin data recipe

**Files:**
- Delete: `templates/data/harness.config.yml`
- Delete: `templates/data/claude-md.md`
- Delete: `templates/data/README.md`
- Modify: `templates/tests/run.sh` — remove the thin-recipe `assert_assembles data/harness.config.yml` line.

The shared hooks (`block-unbounded-sql.sh`, `leakage-sentinel.sh`) and the `ensuring-reproducibility` skill stay at `templates/data/files/.claude/hooks/` and `templates/data/files/.claude/skills/` — they ARE the curated pack's shared content. Only the thin-recipe-specific manifest, claude-md snippet, and README are removed.

- [ ] **Step 1: Verify the curated pack is the only assemble unit anyone needs**

Run:
```bash
cd templates
./assemble.sh data/data-analyst-notebook/harness.config.yml /tmp/retire-test-1 \
  && ./assemble.sh data/ml-pipeline/harness.config.yml /tmp/retire-test-2 \
  && ./assemble.sh data/llm-app/harness.config.yml /tmp/retire-test-3 \
  && ./assemble.sh data/analytics-engineering/harness.config.yml /tmp/retire-test-4 \
  && echo OK
cd ..
rm -rf /tmp/retire-test-{1,2,3,4}
```
Expected: `OK`. Confirms all four sub-domain assemble paths produce valid output before the thin recipe is removed.

- [ ] **Step 2: Remove the thin-recipe-specific files**

Run:
```bash
git rm templates/data/harness.config.yml \
       templates/data/claude-md.md \
       templates/data/README.md
```

`templates/data/files/` is **not** removed — that's the curated pack's shared `files/` tree (same path the thin recipe used). The `_addons/`, `<sub-domain>/`, `DOMAIN.md`, `domain.claude-md.md`, and `references.md` are all in place from prior tasks.

- [ ] **Step 3: Remove the thin-recipe assertion from `run.sh`**

Open `templates/tests/run.sh` and find the line `assert_assembles data/harness.config.yml ...` (the thin-recipe assertion from before this cycle). Delete it.

- [ ] **Step 4: Verify the test suite still passes**

Run: `cd templates && ./tests/run.sh && cd ..`
Expected: `Passed: N` where N = the count after Task 18 (4 new sub-domain assertions + 6 representative-combo assertions). `Failed: 0`. Exit 0.

The thin-recipe assertion is gone; the curated assertions remain.

- [ ] **Step 5: Final verification — git status**

Run: `git status`
Expected: clean working tree (all changes from this task are staged and the next step commits them).

Run: `git ls-files templates/data/ | head -30`
Expected: the listing includes `DOMAIN.md`, `domain.claude-md.md`, `references.md`, `_addons/...`, `<sub-domain>/...`, `files/...` but does NOT include `harness.config.yml`, `claude-md.md`, or `README.md` at the `templates/data/` root.

- [ ] **Step 6: Commit**

```bash
git add templates/tests/run.sh
git commit -m "feat: retire v1 thin data recipe in favor of curated pack"
```

---

## Post-Phase verification

After Task 20, confirm the full pack is intact and the cycle is complete:

- [ ] **Step 1: Full assemble + test sweep**

Run: `cd templates && ./tests/run.sh && cd ..`
Expected: every recipe assertion (`recipe:generic`, `recipe:web`, `recipe:devops`, `recipe:data` × 4 sub-domains, … `recipe:ops`) PASS; the new representative-combo assertions PASS; `Failed: 0`; exit 0.

- [ ] **Step 2: Verify no "v1 thin" / "pending curation" mentions remain for data**

Run: `git grep -niE "v1 thin|pending curation" -- '*.md' | grep -i data`
Expected: zero matches (or only historical context in `HARNESS_ENGINEERING.md` §2 per Task 19).

- [ ] **Step 3: Spot-check the git log**

Run: `git log --oneline cfd0446..HEAD`
Expected: a sequence of 20 commits (Tasks 2–20 + Task 1 is no-op), each with `feat: ...` or `docs: ...` or `test: ...` prefix, all on the `main` branch (or the worktree branch if a worktree was used). No `Co-Authored-By: Claude` lines.

- [ ] **Step 4: Hand to user for cycle 2 (mobile)**

Once Phase B is complete and the assertions pass, the data cycle is done. The next cycle is `mobile` per the meta-spec maintainer order. Brainstorm + spec + plan for mobile gets its own pass through the brainstorming → writing-plans → subagent-driven-development loop.

