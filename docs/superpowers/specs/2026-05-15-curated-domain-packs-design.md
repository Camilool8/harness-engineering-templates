# Curated Domain Packs — Design

> Status: approved design, ready for implementation planning.
> Date: 2026-05-15.
> Supersedes the flat "domain recipe" structure in `templates/` with curated,
> three-layer **domain packs**. Companion to `docs/HARNESS_ENGINEERING.md`,
> `docs/METHODOLOGIES.md`, `docs/AGENT_ROLES.md`.

## 1. Context & motivation

`templates/` currently ships a working harness system: `_base/` (universal
starter), `_modules/` (17 cross-cutting modules — memory, progress, methodology,
orchestration, safety), and **12 flat domain recipes** (`web/`, `data/`, … ,
`generic/`). It assembles via `harness.config.yml` + `assemble.sh`.

The skeleton is sound. The weakness is the **recipes**: a "domain" today is just
a pre-filled config plus one or two hooks and a skill. It has:

- no **sub-domain** specificity (a design system and a microservice get the
  same web harness),
- almost no **specialized agents** (only the orchestration modules ship agents),
- no **curated documentation** per area.

This design deepens recipes into **curated domain packs**: three layers
(domain → sub-domain → addons), a curated agent team per sub-domain, and a
curated, dated documentation dossier backed by a live-docs MCP.

## 2. Decisions locked in brainstorming

| Question | Decision |
|---|---|
| Scope of this design | Lock the **meta-architecture** AND fully design **one domain (web)** as the worked reference. The other 11 domains are future research→spec→build cycles. |
| Documentation form | **Curated dossier + Context7 MCP.** A dated, cited `references.md` per domain/sub-domain, plus the recipe wires Context7 for live library-doc lookup. |
| Agent packaging | **Curated team per sub-domain, agents also à-la-carte.** A sub-domain installs a pre-designed role-complete team; every agent is individually pick/discardable. |
| Structure | **Three layers: domain → sub-domain → addons.** Shared domain assets live once; the sub-domain is the assemble unit; addons are domain-scoped composable extras. |
| Web sub-domain partition | Partition by **deliverable shape** (what you ship), not by layer/topology. |

## 3. Architecture — the domain pack

`_base/` and `_modules/` are **unchanged**. The 12 flat recipes become domain
packs with this layout:

```
templates/<domain>/                    DOMAIN PACK
  DOMAIN.md               index + sub-domain decision guide ("adopt X if…")
  references.md           curated dossier — Verified: YYYY-MM, cited links
  domain.claude-md.md      shared domain rules, appended to CLAUDE.md
  files/.claude/...        shared domain assets (skills, hooks, agents,
                           settings.fragment.json, .mcp.json.fragment)
  _addons/<addon>/         domain-scoped composable extras — _modules-shaped:
                           MODULE.md + files/ + claude-md.md + settings.fragment.json
  <sub-domain>/                        THE ASSEMBLE UNIT
    SUBDOMAIN.md            what it is, adopt-if / skip-if, addons that pair well
    harness.config.yml      pre-filled manifest
    references.md           sub-domain dossier
    claude-md.md            sub-domain CLAUDE.md rules
    files/.claude/
      agents/               the curated agent team (.md definitions)
      skills/  hooks/
      settings.fragment.json
```

Everything that lands in a user's project lives under a `files/` tree, identical
to the `_modules/` convention, so `assemble.sh` copies it verbatim.

### 3.1 Extended `harness.config.yml`

The current schema keeps `project` (now just `name`), `memory`, `progress`,
`methodology`, `orchestration`, `safety`, `hitl`. `project.domain` is **removed**
and replaced by a new `domain` block. Three blocks are added:

```yaml
domain:
  pack: web                    # which domain pack ("" / omitted = base only)
  subdomain: frontend-app      # which sub-domain = the assemble unit
  addons: [nextjs, tailwind-shadcn, authjs]   # domain-scoped addons

agents:
  team: curated                # curated = install the sub-domain's team | none
  exclude: []                  # drop named agents from the curated team
  include: []                  # add agents à-la-carte, by path
                               #   e.g. web/distributed-backend/integration-tester

docs:
  context7_mcp: true           # wire the Context7 live-docs MCP server
```

### 3.2 `assemble.sh` v2

Layering order (each layer's `settings.fragment.json` and `.mcp.json.fragment`
deep-merged, not overwritten):

1. Copy `_base/`.
2. Cross-cutting `_modules/` selected by `memory` / `progress` / `methodology` /
   `orchestration` / `safety` — unchanged from v1.
3. If `domain.pack` set: copy `<domain>/files/`, append `<domain>/domain.claude-md.md`.
4. If `domain.subdomain` set: copy `<domain>/<subdomain>/files/`, append
   `<domain>/<subdomain>/claude-md.md`.
5. For each `domain.addons[*]`: install `<domain>/_addons/<addon>/` (module-shaped).
6. Agent team: agents arrived via steps 3–4. If `agents.team: none`, delete all
   copied agent files. Apply `agents.exclude` (delete those files). Apply
   `agents.include` (copy each referenced agent `.md` by path).
7. If `docs.context7_mcp: true`, ensure the Context7 server is present in
   `.mcp.json` (the domain `.mcp.json.fragment` carries it).
8. Substitute `<PROJECT_NAME>`, write `.claude/HARNESS.lock`, `chmod +x` hooks.

**New capability:** `assemble.sh` deep-merges `.mcp.json` / `.mcp.json.fragment`
with the same jq routine it already uses for `settings.fragment.json`. In v1,
merging MCP fragments was a documented manual step; v2 automates it.

**Backward compatibility:** `assemble.sh` keys off the config file's directory.

- Config at `<domain>/<subdomain>/harness.config.yml` whose `../DOMAIN.md`
  exists → **domain pack**: apply the domain shared layer (step 3) then the
  sub-domain layer (step 4).
- Config at `<domain>/harness.config.yml` (v1 thin recipe, no sub-domain) →
  behaves exactly as v1 today.
- Root `harness.config.yml` / `generic/` → base + cross-cutting modules only.

All 12 existing recipes keep assembling throughout the migration.

## 4. The web domain pack (the worked reference)

### 4.1 Sub-domains — partitioned by deliverable shape

| Sub-domain | Ships | Distinct harness because |
|---|---|---|
| **design-system** | a reusable component library / design tokens | visual-regression, published-API stability, no app shell |
| **frontend-app** | a client app consuming APIs it does not own (SPA/SSR) | a11y-tree + Lighthouse loop; backend is mocked |
| **fullstack-app** | an app that owns its backend (Next.js fullstack, Remix, Rails, Django) | no network boundary — Server Actions/templates; loop spans both ends |
| **api-service** | one standalone backend service, no UI | contract tests, schema round-trip |
| **distributed-backend** | multiple cooperating services | consumer-driven contracts, messaging, integration harness |

Rationale: partitioning by *what you ship* makes each sub-domain a genuinely
distinct harness (different agent team, verification loop, gates). Layer
(frontend/backend) and framework choice are **not** sub-domain axes — they are
addons. "UI/UX" is an *activity* every sub-domain performs, not a deliverable;
it becomes a shared agent (`design-critic`) + skills, not a sub-domain.

Static / marketing sites are intentionally **not** a web sub-domain — they are
served by the `content` domain plus the `astro` addon.

### 4.2 Web `_addons/`

Composable, cut across sub-domains, selected in `domain.addons`:

- *Framework*: `nextjs` · `remix` · `astro` · `sveltekit` · `vite-spa`
- *Styling*: `tailwind-shadcn`
- *Data / ORM*: `drizzle` · `prisma`
- *Auth*: `authjs` · `clerk` · `better-auth`
- *API style*: `trpc` · `graphql` · `openapi-rest`
- *Cross-cutting*: `stripe-payments` · `playwright-e2e` · `sentry-observability`

**Initial addon set shipped with the first implementation** (scope guard):
`nextjs`, `vite-spa`, `tailwind-shadcn`, `drizzle`, `authjs`, `playwright-e2e`,
`sentry-observability`. The rest are added incrementally.

### 4.3 Agent teams

Every team obeys the four `AGENT_ROLES.md` invariants: **least-privilege tools**
(architects/auditors read-only; only implementers get `Edit/Write/Bash`,
scope-bounded), **model routing**, **typed return contracts**, and **evaluators
in a different model family than the implementer**.

**Shared web agents** (`web/files/.claude/agents/` — installed with any web
sub-domain):

- `design-critic` — read-only + Playwright MCP (a11y tree) + screenshot →
  structured UX/visual rubric. (The home of the UI/UX expertise.)
- `accessibility-auditor` — read-only + axe → WCAG findings list.
- `web-perf-auditor` — read-only + Chrome DevTools MCP / Lighthouse → budget
  pass/fail.

**Per sub-domain rosters** (specialists + which shared agents they pull):

| Sub-domain | Specialist agents | + shared | Model routing |
|---|---|---|---|
| design-system | component-architect, component-implementer, visual-regression-tester | design-critic, a11y | Opus / Sonnet / Haiku |
| frontend-app | frontend-architect, frontend-implementer | all 3 | Opus / Sonnet |
| fullstack-app | fullstack-architect, fullstack-implementer, data-layer-implementer, security-auditor | all 3 | Opus / Sonnet / Sonnet / Opus |
| api-service | api-architect, api-implementer, contract-reviewer, api-security-auditor | — | Opus / Sonnet / diff-family / Opus |
| distributed-backend | service-architect, service-implementer, contract-reviewer, integration-tester, security-auditor | — | Opus / Sonnet / diff-family / Sonnet / Opus |

Each agent is one `.md`: frontmatter (`name`, `description`, `tools`, `model`,
optional `permissions`) plus a focused system prompt that states the agent's
typed return shape. `service-implementer` is bounded to a single service per
invocation; `data-layer-implementer` may not run destructive SQL.

## 5. Documentation / dossier model

Every `references.md` (domain level and sub-domain level) has a fixed shape:

```
# <area> — reference dossier
> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices
## Common gotchas / failure modes
## Version-sensitive notes
## Cited links   (each annotated: what it is good for)
```

The domain wires the **Context7 MCP** through `files/.claude/.mcp.json.fragment`.
The domain `domain.claude-md.md` instructs the agent:

> `references.md` is the curated, opinionated baseline. For exact current API or
> version-specific syntax of a library or framework, query Context7
> (`resolve-library-id` then `query-docs`) — it is the live source.

This splits the concern cleanly: humans curate *judgment* (what is good practice,
what to avoid) in the dossier; Context7 serves *live syntax*. The dossier is the
output of the per-domain deep-research cycle.

## 6. Migration — nothing breaks

- **`web/`** is restructured into the full domain pack defined here. Existing
  web assets are redistributed, not discarded:
  - `web-verify.sh` hook + `lighthouse-budget.json` → shared web assets
    (`web/files/.claude/`), referenced by `frontend-app` / `fullstack-app`.
  - `verifying-web-ui` skill → shared web skills.
  - web `claude-md.md` → `web/domain.claude-md.md`.
  - web `README.md` → `web/DOMAIN.md`.
  - web `harness.config.yml` → split into the five per-sub-domain configs.
- **The other 11 domains** (`data`, `devops`, `finance`, `mobile`, `game`,
  `embedded`, `scientific`, `security`, `content`, `ops`) stay as today's
  working **v1 thin recipes**, each marked in its `README.md`
  *"v1 thin recipe — pending deep curation into a domain pack."*
- **`generic/`** is unchanged.
- `assemble.sh` v2 supports both shapes simultaneously (see §3.2), so every
  recipe keeps working during and after migration.

## 7. Scope of the first implementation

**In scope (this spec's implementation plan):**

1. `assemble.sh` v2 — extended config schema, domain/sub-domain/addon layering,
   agent-team resolution, `.mcp.json` deep-merge, backward compatibility.
2. The extended `harness.config.yml` schema + documentation in `templates/README.md`.
3. The complete **web domain pack**: 5 sub-domains, the **initial addon set**
   (§4.2), all agent teams (§4.3), domain + sub-domain dossiers, Context7 wiring.
4. Migration of the current `web/` recipe assets into the pack.
5. Marking the other 11 recipes as v1 thin.

**Out of scope (future cycles):** deep curation of the other 11 domains; the
non-initial web addons (`remix`, `astro`, `sveltekit`, `prisma`, `clerk`,
`better-auth`, `trpc`, `graphql`, `openapi-rest`, `stripe-payments`).

## 8. Roadmap — remaining domains

One research→spec→build cycle each, suggested order (by likely usage):
**data → devops → mobile → finance → security → game → embedded → scientific →
content → ops.** Each cycle: deep-research the area, define sub-domains by
deliverable shape, design agent teams, write dossiers, build the pack.

## 9. Success criteria / verification

- `assemble.sh` produces a valid harness for **each** of the 5 web sub-domains.
- A representative addon combination (e.g. `frontend-app` + `nextjs` +
  `tailwind-shadcn` + `authjs`) assembles; `settings.json` and `.mcp.json` are
  valid JSON with base + module + domain + addon entries all merged (none lost).
- Backward compatibility: all 11 v1 thin recipes still assemble cleanly.
- Every agent `.md` has valid frontmatter and least-privilege `tools` (no
  architect/auditor with `Edit`/`Write`/`Bash`).
- Every `references.md` has a `Verified:` header and at least one cited link.
- All hooks pass `bash -n`; all JSON/JSONL valid.

## 10. Risks & open questions

- **Stacked `CLAUDE.md` length.** Many modules + a domain + sub-domain + addons
  can push `CLAUDE.md` past the ~200-line guideline. Mitigation: keep every
  `claude-md.md` snippet tight; the domain pack's snippets must be ruthlessly
  pruned. Accepted as a known tradeoff for heavy configs.
- **Context7 MCP availability.** If a user has not enabled Context7, the dossier
  still stands alone; `docs.context7_mcp: false` cleanly omits the wiring.
- **Addon × sub-domain combinatorics.** Not every addon is valid for every
  sub-domain (e.g. `authjs` is meaningless for `design-system`). Each
  `SUBDOMAIN.md` lists the addons that pair well; `assemble.sh` does not
  hard-validate combinations (advisory, not enforced).
