# Data Cycle — Research & Spec Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Phase A of cycle 1 (data) — run the three parallel research agents defined by the meta-spec, synthesize their briefs, write the `data` domain pack design spec at `docs/superpowers/specs/2026-05-22-data-domain-pack-design.md`, self-review, commit, and hand to the user for approval. Phase B (build commits + retirement of the v1 thin recipe) gets its own plan once this spec is approved.

**Architecture:** Three `Agent` tool invocations dispatched in a single message, fanning out to two `research-synthesizer` agents (2026 best-practices; tools/MCP catalog) and one `general-purpose` agent (reference repos + vendor harnesses). Each returns a brief (~500 words, dated sources, explicit recommendations). The synthesis happens inline in the main session — briefs are read, decisions are locked, then the spec is written using the devops spec (`2026-05-21-devops-domain-pack-design.md`) as the structural template. No code changes; the artifact is one markdown file plus one commit.

**Tech Stack:** Markdown (the spec), Bash (`git`), `Agent` tool (parallel research dispatch). No build, no tests — the deliverable is a reviewable document.

**Source spec:** `docs/superpowers/specs/2026-05-22-thin-recipe-graduation-plan-design.md` (meta-plan §3 Step 1 defines the research fan-out shape; §5.1 lists the candidate sub-domains and addons that seed the research; §2 locks the policies).

---

## File Structure

**Created:**
- `docs/superpowers/specs/2026-05-22-data-domain-pack-design.md` — the data domain pack design spec; ~150 lines, modeled on `docs/superpowers/specs/2026-05-21-devops-domain-pack-design.md`.

**Not modified:**
- No code, no templates, no public docs. Phase B handles all of that.

**Not committed to disk (intermediate state):**
- The three research briefs return as Agent tool results. They live in the conversation transcript, not in the repo. Quotes and citations from them land in the spec's "Context & motivation" and "Decisions locked in brainstorming" sections.

---

## Tasks

### Task 1: Dispatch the three research agents in parallel

**Files:** None on disk; the work product is three Agent tool results in the transcript.

- [ ] **Step 1: Send a single message with three Agent tool calls**

Run all three in parallel by issuing one message containing three `Agent` tool blocks. Each prompt is self-contained — the agents have no prior context for this conversation.

**Agent A — 2026 best-practices brief**

```
subagent_type: research-synthesizer
description: Data domain 2026 best-practices brief
prompt: |
  Research 2026 best practices for AI-coding-agent harnesses in the data domain
  (data analysis, data science, ML engineering, LLM application development,
  analytics engineering). I'm building a curated harness pack for Claude Code
  that will be used by everyday practitioners. Specifically:

  1. What forcing functions in 2025-2026 changed how harnesses should be built
     in this domain? (regulations, security incidents, vendor shifts, model
     capabilities). Cite primary sources with dates.
  2. What gates / hooks / sentinels are now considered baseline for data work
     done by AI coding agents? (e.g. leakage detection, p-hacking guards,
     warehouse mutation blocks, lockfile hierarchy). Be specific about which
     are widely adopted vs experimental.
  3. What deliverable shapes does the data domain decompose into in practice?
     (notebook analysis vs ML pipeline vs LLM app vs analytics engineering).
     I'm trying to decide on 3-5 sub-domains for the pack — what does the
     2026 practitioner consensus suggest?
  4. What are the canonical anti-patterns this pack must mechanically prevent?

  Seed reading: docs/HARNESS_ENGINEERING.md §2 in
  /Users/cjoga/web-development/harness-engineering-templates (the existing
  field reference). Treat it as a 2026 snapshot to build on, not as the
  final word.

  Output: ~500 words, dated sources, explicit recommendations. Don't paste
  long quotes — synthesize.
```

**Agent B — tools + MCP catalog brief**

```
subagent_type: research-synthesizer
description: Data domain tools and MCP catalog brief
prompt: |
  Research the 2026 tool and MCP-server catalog for the data domain (data
  analysis, data science, ML, LLM-app, analytics engineering). I'm building
  a curated harness pack for Claude Code and need an addon list of 5-15
  items. For each candidate addon, report:

  1. Name and what it ships (skill, hook, agent, MCP fragment, or combo).
  2. Whether the underlying tool/MCP server is official (vendor-shipped) or
     community-maintained, with a citation and a release date if available.
  3. Auth model — where credentials live, what the agent can touch.
  4. Blast radius — what's the worst thing this addon enables if misused?
  5. Which sub-domain(s) it pairs with naturally:
     data-analyst-notebook, ml-pipeline, llm-app, analytics-engineering.

  Specifically investigate (these are starting candidates, refine the list):
  Snowflake Managed MCP, BigQuery MCP, Felt MCP, dbt, Polars, Marimo, Jupyter,
  Langfuse, Braintrust, DeepEval, Inspect AI, Weights & Biases, MLflow,
  uv, pixi. Add or drop based on 2026 adoption.

  Output: ~500 words, dated sources. Recommend a 5-15-addon shortlist with
  rationale for each pick.
```

**Agent C — reference repos + vendor harnesses brief**

```
subagent_type: general-purpose
description: Data domain reference harnesses brief
prompt: |
  Find concrete reference harnesses for data-domain AI coding agents as of
  2026. I'm building a curated Claude Code pack and want to learn from
  what's shipping in the wild. Report:

  1. Public repos with strong AGENTS.md / CLAUDE.md examples for data work
     (notebooks, ML pipelines, LLM apps). Note what they get right and what
     gaps they leave.
  2. Vendor harnesses worth studying: Databricks Assistant, Snowflake
     Cortex, Hex Magic, Anthropic's own LLM-eval harness patterns,
     Sentry's evals, OpenAI Evals integration patterns, Modal, Replicate,
     Hugging Face. For each, identify the gate or pattern that's worth
     adopting.
  3. The "everyday practitioner" use case — when a data scientist, ML
     engineer, or analytics engineer uses Claude Code on a real project,
     what does the inner loop look like? Cite blog posts, conference talks,
     or postmortems from 2025-2026.

  Output: ~500 words, dated sources. Identify 3-5 patterns that should
  inform our sub-domain split or addon list.
```

- [ ] **Step 2: Wait for all three Agents to return**

The Agent tool blocks. When all three return, their summaries arrive as tool results in the transcript.

- [ ] **Step 3: Confirm coverage before synthesis**

For each brief, confirm it answered every numbered question. If a brief skipped a question or returned generic content, dispatch a follow-up to that single agent (one Agent call, focused on the gap). Do not proceed to Task 2 with incomplete briefs.

### Task 2: Lock the data sub-domain split and addon catalog

**Files:** None on disk; the decisions are scratchpad-only until Task 3.

- [ ] **Step 1: Re-read the candidate list in the meta-spec**

Open `docs/superpowers/specs/2026-05-22-thin-recipe-graduation-plan-design.md` §5.1. Candidate sub-domains: `data-analyst-notebook`, `ml-pipeline`, `llm-app`, `analytics-engineering`. Candidate addons: `snowflake-mcp`, `bigquery-mcp`, `dbt-core`, `polars`, `marimo`, `jupyter`, `langfuse-evals`, `braintrust-evals`.

- [ ] **Step 2: Apply research deltas**

Cross-reference the briefs from Task 1. For each candidate:
- **Keep** if all three briefs corroborate it as 2026-current and load-bearing.
- **Drop** if research says it's a 2024 carryover, deprecated, or insufficient adoption.
- **Add** any sub-domain or addon that ≥2 briefs surface but the meta-spec missed.
- **Rename** to match the dominant 2026 terminology (the briefs are authoritative on naming).

Constraint from meta-spec §2: sub-domains stay within 3–5; addons within 5–15. If research argues for outside-the-band, capture the justification — it goes into the spec's "Decisions locked" table.

- [ ] **Step 3: Sanity-check the partition**

Each sub-domain should have a one-sentence "Adopt if…" that's clearly distinct from every other sub-domain. If two sub-domains' adopt-ifs blur, merge them or re-cut the boundary. The `web` and `devops` packs both pass this sniff test — apply the same standard.

### Task 3: Write the data domain pack design spec

**Files:**
- Create: `docs/superpowers/specs/2026-05-22-data-domain-pack-design.md`

Use the devops spec (`docs/superpowers/specs/2026-05-21-devops-domain-pack-design.md`) as the structural template. Match its section order verbatim; replace devops-specific content with data-specific content informed by Tasks 1–2.

- [ ] **Step 1: Write Section 1 — Context & motivation**

Open with the standing of the data thin recipe today (already-shipped gates: `block-unbounded-sql`, `leakage-sentinel`, `ensuring-reproducibility` skill). Cite 2–3 forcing functions from Agent A's brief that justify graduating now (e.g. EU AI Act eval-logging, LLM-app eval-as-unit-test consensus, agent-driven warehouse-mutation incidents — adjust to what research actually surfaced). Frame the orthogonal axes that prove the flat thin recipe can't encode the domain.

Length: ~3 paragraphs. Tone: load-bearing, not promotional. Mirror devops spec §1.

- [ ] **Step 2: Write Section 2 — Decisions locked in brainstorming**

Reproduce the devops spec §2 table format. Lock in: sub-domain count, the partition heuristic ("by deliverable shape"), whether any axis becomes an addon vs a sub-domain, addons-may-contribute-agents (yes — pattern is established), thin recipe retirement timing (final commit of Phase B).

Each row: question on the left, decision on the right with a parenthetical reason. Cite the meta-spec where decisions inherit from it.

Length: ~10–15 rows. Mirror devops spec §2.

- [ ] **Step 3: Write Section 3 — Architecture (the data pack)**

Reproduce the devops spec §3 tree diagram with `templates/data/` paths. Confirm no changes to `_base/`, `_modules/`, `assemble.sh`, or the schema. List the shared layer (`DOMAIN.md`, `references.md`, `domain.claude-md.md`, shared `agents/`, shared `hooks/`, shared MCP fragments), the per-sub-domain layer, and the `_addons/` layer.

Length: ~1 code block + ~2 paragraphs. Mirror devops spec §3.

- [ ] **Step 4: Write Section 4 — Sub-domains**

For each sub-domain locked in Task 2, write a sub-section with:
- One-sentence purpose.
- Adopt if / Skip if bullets.
- The curated agent team (names + one-line role each).
- The skills the sub-domain installs.
- The default addon set in `domain.addons`.

Mirror the devops spec §4 sub-sections (`infrastructure`, `kubernetes-platform`, etc.).

- [ ] **Step 5: Write Section 5 — Addons**

For each addon locked in Task 2, write a one-paragraph entry:
- What it ships (`MODULE.md` + `claude-md.md` + `files/...` — be specific about hook names, skill names, agent names).
- Adopt if / Skip if (one sentence each).
- Which sub-domain(s) it pairs with.
- The 2026 source from Agent B's brief that justifies the choice.

Group by category as the devops spec does (warehouse-MCP, tooling, eval-framework, env-management, etc. — categories come from research, not pre-decided).

- [ ] **Step 6: Write Section 6 — Shared hooks, agents, and MCP defaults**

Existing thin-recipe hooks (`block-unbounded-sql.sh`, `leakage-sentinel.sh`) move to `templates/data/files/.claude/hooks/` and stay shared across sub-domains. Identify any new shared hook surfaced by research (e.g. if Agent A flagged a 2026 gate this pack must adopt). Name the cross-cutting agents (the data analog of devops's `incident-commander` — likely something like `eval-curator` or `dataset-card-author` — decide based on research). List the shared MCP fragment defaults (likely empty until per-warehouse addons populate, mirroring devops).

- [ ] **Step 7: Write Section 7 — Migration & retirement**

Describe how the thin recipe (`templates/data/{claude-md.md,harness.config.yml,README.md,files/}`) is retired in the final commit of Phase B. Note that the thin recipe stays present through every intermediate commit so both shapes assemble until the very end — same approach as the devops cycle.

- [ ] **Step 8: Write Section 8 — Non-goals**

Reproduce the devops spec §9 list verbatim, swapping `devops` for `data`. No changes to `_base/`, `_modules/`, `assemble.sh`, or the schema. No new top-level domains. No retroactive changes to `web/` or `devops/`. No test framework changes.

### Task 4: Self-review the spec

**Files:**
- Modify: `docs/superpowers/specs/2026-05-22-data-domain-pack-design.md` (fix any issues found)

The brainstorming skill's spec self-review checklist applies. Read the spec with fresh eyes.

- [ ] **Step 1: Placeholder scan**

Search the spec for: `TBD`, `TODO`, `implement later`, `fill in details`, `Add appropriate`, `similar to`, `etc.`, `and so on`. Every hit must be resolved or rewritten as a concrete commitment. The spec is a contract; vagueness here costs Phase B time.

Command: `grep -niE "tbd|todo|fill in|implement later|add appropriate|similar to" docs/superpowers/specs/2026-05-22-data-domain-pack-design.md`
Expected: zero matches (or only matches inside explicit prose context that's intentional, in which case rewrite).

- [ ] **Step 2: Internal consistency**

Check: every sub-domain named in §2 appears in §4 with a full entry. Every addon named in §2 appears in §5 with a full entry. The architecture tree in §3 matches the file structure that the §4/§5 entries will create. Agent names referenced in §4 match exactly across sub-domains (no `eval-curator` in one sub-domain, `eval-author` in another).

- [ ] **Step 3: Scope check**

Is this a single Phase-B-plannable spec, or does it secretly need decomposition? Sub-domain count within 3–5? Addon count within 5–15? Any sub-domain so big it deserves its own pack? If any answer is "no", capture the issue in a new section (`## N. Scope Risks`) rather than ignoring it — the user reviews this spec next and needs to see the honest assessment.

- [ ] **Step 4: Ambiguity check**

For every requirement (every "must", "ships", "installs"), could two reasonable engineers interpret it two ways? If yes, pick one interpretation and make it explicit. Example anti-pattern: "the eval-framework addon installs evaluation skills" — be specific about which skills (names) and which behaviors they enable.

- [ ] **Step 5: Fix issues inline**

Any issue found in steps 1–4: edit the spec directly. No need to re-review — fix and move on.

### Task 5: Commit the spec and hand to the user

**Files:**
- The committed spec is the deliverable.

- [ ] **Step 1: Stage the spec**

```bash
git add docs/superpowers/specs/2026-05-22-data-domain-pack-design.md
```

- [ ] **Step 2: Confirm only the spec is staged**

```bash
git status
```

Expected output: `new file: docs/superpowers/specs/2026-05-22-data-domain-pack-design.md` and no other staged changes. If anything else is staged, unstage it (`git restore --staged <path>`) — this commit is spec-only.

- [ ] **Step 3: Commit**

```bash
git commit -m "docs: data domain pack design spec

Locks the sub-domain split, addon catalog, shared hooks/agents, and
migration approach for graduating templates/data/ from v1 thin recipe
to curated three-layer pack. Phase A of cycle 1 in the thin-recipe
graduation plan.

Source: docs/superpowers/specs/2026-05-22-thin-recipe-graduation-plan-design.md"
```

No AI attribution. Per the meta-spec §2 and standing memory.

- [ ] **Step 4: Verify the commit**

```bash
git log -1 --stat
```

Expected: one commit, one file changed, no `Co-Authored-By` line.

- [ ] **Step 5: Present to the user**

Send a single message to the user:

> Data domain spec committed at `<short-sha>`: `docs/superpowers/specs/2026-05-22-data-domain-pack-design.md`. Please review (it's ~150 lines). Once approved, I'll write Phase B (build + retirement) as a separate plan via `superpowers:writing-plans`.

Wait for the user's response. If they request changes, fix the spec, amend or new-commit per their preference, re-present. If they approve, hand off to the next cycle-phase plan.

---

## Phase B preview (not part of this plan)

Once the data spec is approved, the next plan covers the **build** — the 10-commit sequence per the meta-spec §3 Step 4 (shared CLAUDE.md, shared MCPs, shared dossier, shared agents, per-sub-domain commits, per-addon-category commits, test extension, public-doc flip, thin retirement). That plan will reference the data spec's locked sub-domain and addon lists by name and ship working tasks with literal file paths and code blocks. It cannot be written yet because the sub-domain and addon lists are not yet committed.
