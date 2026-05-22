# Thin Recipe Graduation — Game Plan Design

> Status: ⏳ Pending implementation.
> Date: 2026-05-22.
> Plans the graduation of the **9 remaining v1 thin recipes** into curated
> three-layer domain packs. Companion to
> `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md` (pack
> mechanics, reused unchanged) and
> `docs/superpowers/specs/2026-05-21-devops-domain-pack-design.md` (the proven
> per-domain template — its commit sequence is reproduced here).

## 1. Context & motivation

Two domains (`web/`, `devops/`) ship as curated three-layer packs. Nine
domains still ship as **v1 thin recipes** — a single `harness.config.yml`,
a `claude-md.md` snippet, and a flat `files/` tree. They assemble and gate the
obvious anti-patterns, but they have no sub-domain specificity, no curated
agent teams, no dated dossiers, and no composable addons.

The maintainer roadmap calls the remaining order:

> **data → mobile → finance → security → game → embedded → scientific → content → ops**

This document is the meta-plan that frames all nine cycles. Each cycle gets
its own short spec (one per domain, 9 specs total) that locks in research
deltas and the final sub-domain / addon list. This document defines:

- The repeatable per-domain cycle.
- Candidate sub-domain and addon decompositions (research starting points,
  not commitments).
- Cross-cutting policies (commit order, test gates, doc flips, retirement).
- The final cleanup pass once all nine ship.

> **Maintainer-only.** This spec and the per-domain specs are internal. No
> public how-to documents the graduation process itself. Only the *output*
> (the new pack, the updated `domains.md` row, the retired thin recipe)
> becomes public-facing.

## 2. Decisions locked in brainstorming

| Question | Decision |
|---|---|
| Order of cycles | **data → mobile → finance → security → game → embedded → scientific → content → ops** (user direction). |
| Number of specs | **One per domain** — 9 total — plus this meta-plan. Each domain spec is short (~devops spec, ~150 lines). |
| Sub-domain partition heuristic | **By deliverable shape** (what you ship), not by technology. Technology choice becomes an addon. Mirrors `web/` and `devops/`. |
| Sub-domain count per pack | **3–5**. Devops shipped 4; web shipped 5. Outside this range needs justification in the domain's spec. |
| Addon count per pack | **5–15**. Devops shipped 15; web shipped 9. |
| Research shape | **Three parallel agents per domain**: best practices / tools-MCP catalog / reference repos. Each returns a short brief (~500 words). |
| Cycle isolation | **Finish one domain before starting the next.** No half-graduated state in `domains.md` at any point. |
| Thin recipe retirement | **Final commit per cycle.** Delete `templates/<domain>/{claude-md.md,harness.config.yml,README.md}` and the flat `files/` tree (sub-domains now own the content). |
| Final cleanup commit | After all nine cycles: delete v1-thin language from public docs (`domains.md`, `HARNESS_ENGINEERING.md`, `pick-a-recipe.md`) and verify `git grep -i "v1 thin\|thin recipe\|pending curation"` returns zero outside historical commit messages. |
| Public docs touched per cycle | `docs/reference/domains.md` (status row flip), `docs/how-to/pick-a-recipe.md` (decision flow update), `docs/HARNESS_ENGINEERING.md` §N (status note strike). Nothing else. |
| AI attribution in commits | **Never.** Per standing memory. |

## 3. The per-domain cycle (reproducible template)

Each of the 9 domains follows the same 7-step cycle, scaled to its
complexity. The cycle was validated end-to-end by the `devops/` graduation
(commits `6af8e92` → `e8cffb5`, May 21–22 2026).

### Step 1 — Research fan-out (three parallel agents)

Three agents run in parallel, scoped narrowly so context stays useful:

| Agent | Subagent type | Scope |
|---|---|---|
| **2026 best-practices** | `research-synthesizer` | Domain-specific gates, anti-patterns, 2026 forcing functions (regulatory, security incidents, vendor shifts). Seed: `docs/HARNESS_ENGINEERING.md` §N. |
| **Tools + MCP catalog** | `research-synthesizer` | Official vs community MCPs as of 2026, auth model, blast radius. Identifies addon candidates. |
| **Reference repos + vendor harnesses** | `general-purpose` | Existing `AGENTS.md` / `CLAUDE.md` examples in the wild; vendor harnesses (Sentry, Vercel, Stripe, Databricks, Snowflake, Alpaca, PagerDuty, Datadog, Replit, Anthropic) for the domain. |

Output of each: short brief (~500 words), source list with dates, explicit
recommendations. We synthesize the three briefs into the domain spec; we do
not paste them.

### Step 2 — Lock sub-domain split

Apply the **deliverable-shape heuristic**. Candidate sub-domains for each
domain are seeded in §5 below; research from Step 1 refines (adds, drops,
renames). Each sub-domain gets a one-line "Adopt if…" sentence in the
domain's `DOMAIN.md`.

### Step 3 — Lock addon catalog

Group by category (cloud, tool, observability, CI, etc.). Each addon ships:

- `_addons/<addon>/MODULE.md` — adopt-if / skip-if / install / remove.
- `_addons/<addon>/claude-md.md` — optional CLAUDE.md snippet if it teaches
  the agent something.
- `_addons/<addon>/files/` — skills, hooks, agents, or settings the addon
  installs.

Addons **may contribute agents** (devops `argo-cd` ships `gitops-promoter`;
`kyverno` ships `policy-author`). This pattern is already mechanically
supported by `assemble.sh` and `_addons/<addon>/files/.claude/agents/`.

### Step 4 — Build commits (the devops order)

The devops graduation established this commit sequence. Reproduce it per
domain:

1. `docs: shared <domain> CLAUDE.md snippet` — `templates/<domain>/domain.claude-md.md`.
2. `feat: shared <domain> MCP fragments` — `templates/<domain>/files/.mcp.json.fragment` and `context7.mcp.json.fragment`.
3. `docs: <domain> cross-cutting reference dossier` — `templates/<domain>/references.md`.
4. `feat: <domain> <hook>.sh guard hook` — any new shared hook surfaced by research (e.g. devops `cosign --insecure-ignore-tlog` guard).
5. `feat: shared <domain> agents (...)` — the cross-cutting agents (e.g. devops `incident-commander`, `supply-chain-auditor`, `cost-auditor`).
6. **Per sub-domain, one commit each**:
   `feat: <domain> <sub-domain> sub-domain` — ships
   `SUBDOMAIN.md` + `harness.config.yml` + `claude-md.md` + `references.md` +
   curated agents + curated skills + `files/.claude/settings.fragment.json`.
7. **Per addon category, one commit each**:
   `feat: <domain> <category> addons (<addon-a>, <addon-b>, ...)`.
8. `test: extend assemble-coverage + structure-lint to discover <domain> pack`.
9. `docs: flip <domain> to curated 3-layer; document any cross-cutting patterns` — updates `docs/reference/domains.md`, `docs/how-to/pick-a-recipe.md`, and `docs/HARNESS_ENGINEERING.md` §N status.
10. `feat: retire v1 thin <domain> recipe in favor of curated pack` — deletes the flat thin-recipe files.

Each commit is independently green: assemble-coverage and structure-lint
pass at every step. No commit lands a broken intermediate state.

### Step 5 — Test coverage

`templates/tests/assemble-coverage` and `structure-lint` must discover the
new sub-domains automatically. The devops graduation's commit `15a5179` is
the reference change — both tests already glob `templates/*/`; ensure new
sub-domain configs at `templates/<domain>/<sub>/harness.config.yml` are picked
up. Add explicit assertions if the test framework requires them.

### Step 6 — Flip public docs

| File | Change |
|---|---|
| `docs/reference/domains.md` | `v1 thin` → `curated (3-layer)` in the catalog table; add a `## The <domain>/ pack (curated)` section mirroring the `## The web/ pack` and `## The devops/ pack` sections; update the `## The v1 thin recipes` bullet list (drop the graduated domain). |
| `docs/how-to/pick-a-recipe.md` | Replace the v1-thin decision branch with a sub-domain decision branch. |
| `docs/HARNESS_ENGINEERING.md` | Strike any "v1 thin" or "pending curation" language in §N (the domain's section). |
| `CONTRIBUTING.md` | If it mentions the v1-thin shape generically, no change yet (final cleanup pass handles this). |

### Step 7 — Retire the thin recipe

Final commit per cycle:

```
git rm templates/<domain>/claude-md.md
git rm templates/<domain>/harness.config.yml
git rm templates/<domain>/README.md
git rm -r templates/<domain>/files            # if sub-domains absorb all content
```

The sub-domain configs are now the assemble unit:
`./assemble.sh <domain>/<sub-domain>/harness.config.yml .`

## 4. Cross-cutting policies

- **Commits never use AI attribution.** No `Co-Authored-By: Claude`, no
  `Generated with Claude Code`. Human attribution only.
- **No public maintainer how-to.** The cycle, the research-agent fan-out,
  the commit order — none of it lands in `docs/how-to/`, `CONTRIBUTING.md`,
  or `README.md`. The only public artifacts are the new pack itself and the
  three doc files in Step 6.
- **One domain at a time.** Finish a cycle (research → build → tests →
  public-doc flip → thin retirement) before starting the next. This keeps
  `domains.md` consistent at every commit boundary.
- **Tests stay green per commit.** Never commit a structure-lint failure
  "to be fixed in the next commit."
- **Brainstorming/spec/plan are internal.** Each domain spec lives at
  `docs/superpowers/specs/YYYY-MM-DD-<domain>-domain-pack-design.md`. Each
  plan lives at `docs/superpowers/plans/...`. Neither is referenced from
  public docs.

## 5. Candidate sub-domain + addon decompositions

These are **research starting points**, not commitments. Each domain's
Step 1 research cycle refines (adds, drops, renames) the list before the
domain spec is written. The list is seeded from
`docs/HARNESS_ENGINEERING.md` §2–§11 plus the current thin-recipe gates.

### 5.1 `data`

**Candidate sub-domains:**
- `data-analyst-notebook` — exploratory analysis, BI, ad-hoc reporting.
- `ml-pipeline` — training, eval, model packaging, deployment.
- `llm-app` — RAG, agentic pipelines, prompt eval as the unit test.
- `analytics-engineering` — dbt, warehouse modeling, semantic layer.

**Candidate addons:** `snowflake-mcp`, `bigquery-mcp`, `dbt-core`, `polars`,
`marimo`, `jupyter`, `langfuse-evals`, `braintrust-evals`.

**Existing gates to preserve:** `block-unbounded-sql.sh`,
`leakage-sentinel.sh`, `ensuring-reproducibility` skill.

### 5.2 `mobile`

**Candidate sub-domains:**
- `ios-app` — SwiftUI/UIKit, Xcode 26.3, App Intents.
- `android-app` — Jetpack Compose, Gradle, ADB.
- `react-native-expo` — Expo Agent + Skills, EAS.
- `flutter-app` — Dart toolchain.

**Candidate addons:** `xcodebuildmcp`, `expo-agent`, `gradle-mcp`,
`sentry-mobile`, `app-intents-schema`.

**Existing gates to preserve:** simulator-in-the-loop pattern, structured
build logs.

### 5.3 `finance`

**Candidate sub-domains:**
- `quant-research` — backtest, paper-broker default, t+1 walk-forward.
- `trading-execution` — broker integration, position-size guard.
- `accounting-bookkeeping` — double-entry, immutable audit log.
- `regulatory-compliance` — SOX/MAR/MiFID II/EU AI Act audit.

**Candidate addons:** `alpaca`, `paper-broker-default`, `ibkr`,
`double-entry-guard`, `audit-log-append-only`, `defi-readonly`.

**Existing gates to preserve:** paper-by-default, two-key on real money,
immutable audit, double-entry.

### 5.4 `security`

**Candidate sub-domains:**
- `red-team-engagement` — scope authorization gate, RedAmon-style allow/deny.
- `blue-team-defensive` — SAST (semgrep, CodeQL), dependency-track.
- `appsec-sast` — code-review-as-skill, owasp-top-10 patterns.

**Candidate addons:** `semgrep`, `codeql`, `dependency-track`,
`redamon-gates`, `owasp-llm-ctf`, `spiffe-spire`.

**Existing gates to preserve:** engagement-scope authorization, red/blue
separation.

### 5.5 `game`

**Candidate sub-domains:**
- `unity-game` — Bezi/Coplay/Aura, Rider 2026.1.
- `godot-game` — GDScript text-scenes, Godot MCP.
- `unreal-game` — Blueprint scaffolding MCP.
- `bevy-ecs-game` — Rust ECS, code-only.

**Candidate addons:** `bezi-coplay`, `hot-reload-screenshot`,
`asset-guid-guard`, `rider-unity`, `godot-mcp`.

**Existing gates to preserve:** hot-reload + screenshot loop, asset-GUID
awareness.

### 5.6 `embedded`

**Candidate sub-domains:**
- `esp-idf-firmware` — ESP32 family, idf.py MCP.
- `zephyr-firmware` — Twister HIL CI.
- `bare-metal-rtos` — STM32, nRF52/91, RISC-V.

**Candidate addons:** `hil-runner`, `ota-dual-bank`, `embedder-mcp`,
`bootloop`, `never-flash-without-dry-run`.

**Existing gates to preserve:** never-flash-without-dry-run, HIL gate.

### 5.7 `scientific`

**Candidate sub-domains:**
- `quarto-paper` — manuscript-as-output, LaTeX/Typst.
- `snakemake-pipeline` — workflow engine, Singularity/Apptainer.
- `julia-experiment` — `Project.toml` + `Manifest.toml` reproducibility.

**Candidate addons:** `nix-repro`, `latex-typst`, `r-rmarkdown`, `matlab`,
`nextflow`.

**Existing gates to preserve:** pinned-env reproducibility, manuscript
pipeline.

### 5.8 `content`

**Candidate sub-domains:**
- `brand-content` — brand-voice guard, banned-clichés list.
- `seo-publisher` — schema.org validation, AI Overviews readiness.
- `technical-writer` — Diátaxis structure, docs-as-code.

**Candidate addons:** `brand-voice-guard`, `schema-org-validator`,
`copyleaks`, `sanity-mcp`, `notion-mcp`.

**Existing gates to preserve:** brand-voice guard, schema.org validation.

### 5.9 `ops`

**Candidate sub-domains:**
- `customer-support` — Linear/Intercom/Zendesk, drafter ≠ publisher.
- `ops-automation` — Procedures, refund-threshold gate.

**Candidate addons:** `linear-mcp`, `intercom-procedures`, `zendesk-mcp`,
`slack-escalation`, `notion-mcp`, `refund-threshold-gate`.

**Existing gates to preserve:** refund threshold gate, drafter ≠ publisher.

## 6. Final cleanup pass

After all nine cycles land, one closing commit (or short series) scrubs the
"v1 thin" shape from the repository entirely:

1. `docs/reference/domains.md` — delete the **"Two shapes today"** preamble
   (only one shape remains); delete the **"## The v1 thin recipes"** section;
   collapse the `Status` column in the catalog table (or drop it).
2. `docs/HARNESS_ENGINEERING.md` — strike all remaining "v1 thin", "pending
   curation", "maintainer roadmap" mentions.
3. `docs/how-to/pick-a-recipe.md` — confirm the decision flow no longer
   references the thin shape.
4. `CONTRIBUTING.md` — strike any references to the v1-thin layout.
5. Grep verification:

   ```bash
   git grep -i "v1 thin"
   git grep -i "thin recipe"
   git grep -i "pending curation"
   ```

   Must return zero hits outside historical commit messages (use
   `git log --all --grep` separately to inspect history).
6. Final commit: `docs: complete graduation — retire v1 thin recipe shape`.

## 7. Order rationale (and one risk note)

The user-set order is preserved:
`data → mobile → finance → security → game → embedded → scientific → content → ops`.

`data` first is a low-risk dress rehearsal for the cycle itself — strong
existing gates (`leakage-sentinel`, `block-unbounded-sql`), mid-complexity,
clear sub-domain candidates from `HARNESS_ENGINEERING.md` §2.

`finance` and `security` are the highest-blast-radius cycles — money and
prod-credential / attack-tooling surfaces respectively. Their Step 1
research must be front-loaded and more thorough; their spec sign-off should
get an explicit pause for review. No change to ordering needed, just an
attention budget note.

`ops` last is appropriate — it's the most MCP-heavy and least
implementation-novel domain; the cycle template will be well-rehearsed by
the time it lands.

## 8. Open questions (deferred to per-domain specs)

These are deliberately not decided here; each domain's Step 1 research and
Step 2 lock-in resolve them:

- Exact sub-domain count per domain (within the 3–5 band).
- Exact addon list per domain (within the 5–15 band).
- Which addons contribute agents vs only skills/hooks.
- Whether any domain needs a new shared hook beyond what the thin recipe
  ships today.
- Whether any domain needs a new shared agent beyond what the thin recipe
  ships today.

## 9. Non-goals

- This plan does not propose changing `_base/`, `_modules/`, `assemble.sh`,
  or the `harness.config.yml` schema. The mechanics are settled and reused
  unchanged.
- This plan does not propose adding new top-level domains. Twelve domains
  is the agreed catalog (`generic` is base-only and not slated for
  graduation).
- This plan does not propose changing the test framework
  (`templates/tests/`). New sub-domains plug into the existing discovery.
- This plan does not propose any retroactive change to the already-curated
  `web/` or `devops/` packs.
