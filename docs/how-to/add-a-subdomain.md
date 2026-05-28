# How to add a sub-domain

A sub-domain is a distinct deliverable shape within a three-layer [domain pack](../reference/glossary.md#domain-pack). For `web/`, the existing sub-domains are `design-system`, `frontend-app`, `fullstack-app`, `api-service`, `distributed-backend`. Each represents a project shape with its own agent team, addon pairings, and conventions.

This guide covers adding a sub-domain to one of the four curated packs (`web`, `data`, `devops`, `mobile`). Adding a whole new domain pack is a larger effort — open a discussion issue first.

---

## Step 1 — Open an issue first

Use the [**Propose new content**](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose) template. Describe:

- The sub-domain name (kebab-case, e.g. `mobile-bff`, `serverless-functions`, `graphql-federation`).
- The deliverable shape — what kind of project this serves and how it differs from the other sub-domains in the same pack.
- The proposed agent team (architect, implementer, reviewer, auditors).
- The default addon set.
- The adopt-if / skip-if reasoning.

The bar for a new sub-domain is higher than for a module or addon. You are committing to maintaining a coherent slice of opinionated practice. Wait for a maintainer thumbs-up.

---

## Step 2 — Create the directory

```bash
mkdir -p templates/web/<sub-domain>/files/.claude
cd templates/web/<sub-domain>
```

A sub-domain ships five things:

```
SUBDOMAIN.md           the decision guide users read when picking
harness.config.yml     the pre-filled config (this is the assemble unit)
claude-md.md           fragment appended to CLAUDE.md
references.md          curated tool / framework / practice dossier
files/.claude/
  agents/              the curated agent team
  hooks/               sub-domain-specific hooks
  skills/              sub-domain-specific skills
```

---

## Step 3 — Write `SUBDOMAIN.md`

The [`structure-lint`](../reference/tests.md#structure-lint) check enforces these sections:

```markdown
# Web — <sub-domain> sub-domain

<One paragraph: the deliverable shape this serves.>

## Adopt if
- Bullet list.

## Skip if
- Bullet list. Especially: point at the other sub-domains for the cases this is *not*.

## Addons that pair well
| Addon | When to add |
|---|---|
| `addon-name` | … |

## Agent team
| Agent | Role |
|---|---|
| `<role>-architect` | Read-only; returns a typed plan with acceptance criteria. |
| `<role>-implementer` | Read-write; bounded scope; returns diff + summary. |
| `<role>-auditor` | Read-only; specific concern (a11y, performance, security). |
```

Canonical reference: [`templates/web/frontend-app/SUBDOMAIN.md`](../../templates/web/frontend-app/SUBDOMAIN.md).

---

## Step 4 — Write `harness.config.yml`

The sub-domain config is the assemble unit. Users pass it directly to `assemble.sh`:

```bash
./assemble.sh templates/web/<sub-domain>/harness.config.yml ./my-project
```

Start from the canonical [`templates/harness.config.yml`](../../templates/harness.config.yml) and adjust:

```yaml
project:
  name: my-project

memory:
  backend: md-files
progress:
  backend: filesystem

methodology:
  tdd: true
  spec_driven: true
  eval_driven: false
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: false
  kill_switch: false
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: web
  subdomain: <sub-domain>
  addons: [<default-addons>]

agents:
  team: curated
  exclude: []
  include: []

docs:
  context7_mcp: true
```

Pick defaults that make sense for the sub-domain. The `frontend-app` defaults include `vite-spa` and `tailwind-shadcn`; `fullstack-app` adds `drizzle`. Choose the addons that 80% of users will keep.

---

## Step 5 — Write `claude-md.md`

The sub-domain-specific section appended to `CLAUDE.md`. Keep it tight and behavioural — what does the agent need to know about *this deliverable shape* that the generic `_base` does not cover?

Example for `api-service`:

```markdown
## API service

This project is one HTTP service with no UI, schema-first (OpenAPI). Consumers depend on the contract; breakage is a customer-visible regression.

- **Contract first.** Every endpoint exists in the OpenAPI spec before its handler.
- **Status codes are the API.** Use the right one; `200` for errors is a bug.
- **No incidental coupling.** This service does not import code from any other.
- **Health endpoint is real.** `/healthz` checks downstream dependencies, not just process liveness.
```

---

## Step 6 — Write `references.md`

A curated dossier of the tools, frameworks, and practices this sub-domain relies on. The structure-lint check requires the second line to be a `> Verified: YYYY-MM` header so users know the dossier was reviewed recently:

```markdown
# Web — <sub-domain> references

> Verified: 2026-05

## Frameworks
- **<Framework>** — one-sentence summary. <Link to docs.>

## Build / dev tooling
- …

## Testing
- …
```

Refresh quarterly. The `> Verified:` date is the contract.

---

## Step 7 — Curate the agent team

Drop the agent files under `files/.claude/agents/<agent-name>.md`. Each must declare YAML frontmatter:

```markdown
---
name: <agent-name>
description: One sentence; what the agent does.
tools: [Read, Grep, Glob]            # ← least privilege
model: opus | sonnet | haiku
---

<system-prompt body>
```

**Least-privilege rule** (enforced by structure-lint):

- Agents named `*-architect`, `*-auditor`, `*-reviewer`, `*-critic` **must not** declare `Edit` or `Write` in `tools`. They return plans and findings, never patches.
- Only `*-implementer`, `*-tester`, `*-builder` may write.

This is not stylistic. The Rule of Two (any agent session ≤ 2 of {untrusted input, sensitive systems, external state change}) collapses if every agent has write access.

---

## Step 8 — Add sub-domain hooks (if any)

Hooks live under `files/.claude/hooks/`. Sub-domain hooks should be specific to the deliverable shape:

- `frontend-app` might add an accessibility-tree verifier.
- `api-service` might add a `verify-spec-sync.sh` that fails when handlers diverge from the OpenAPI spec.
- `distributed-backend` might add a consumer-driven-contract check.

Register hooks via `files/.claude/settings.fragment.json`. Same shape as for modules.

---

## Step 9 — Run the test suite

```bash
./templates/tests/run.sh
```

`assemble-coverage` discovers your new sub-domain automatically (any `harness.config.yml` under `web/<subdir>/` is treated as a sub-domain). It assembles your config into a temp dir and validates the output.

`structure-lint` validates `SUBDOMAIN.md`, every agent file's frontmatter, and the `references.md` `Verified:` header.

If any check fails, see [`troubleshooting.md`](../reference/troubleshooting.md#tests).

---

## Step 10 — Update the catalogs

- [`docs/reference/domains.md`](../reference/domains.md) — add a row to the `web/` sub-domain table.
- [`docs/how-to/pick-a-recipe.md`](pick-a-recipe.md) — add to the sub-domain table under Question 3.
- [`templates/web/DOMAIN.md`](../../templates/web/DOMAIN.md) — add to the sub-domain decision guide.

---

## Step 11 — Open the PR

Same workflow as [`your-first-contribution.md`](../tutorials/your-first-contribution.md). PR template **Type of change** = **New sub-domain**.

The reviewer will check:

- This sub-domain is genuinely distinct from existing ones (not a shade-of-grey variant).
- Agent team is least-privilege.
- `references.md` is current.
- Defaults are sensible — the 80% case is one `assemble.sh` invocation away from working.

---

## See also

- [`reference/domains.md`](../reference/domains.md) — current sub-domains.
- [`add-an-addon.md`](add-an-addon.md) — for sub-domain-scoped extras.
- Canonical reference: [`templates/web/frontend-app/`](../../templates/web/frontend-app/).
