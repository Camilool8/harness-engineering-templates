# How to add an addon

An addon is a domain-scoped optional extra — a Next.js wiring, a Drizzle migration setup, an Auth.js flow, a Playwright E2E harness. They live at `templates/<domain>/_addons/<addon>/`; the `web/` pack ships the largest set.

Addons are *not* cross-cutting modules. A module changes how the agent works regardless of project type; an addon adds project-type-specific scaffolding.

> **Two mirrored trees.** This repo maintains the content in two places that stay in sync: the `templates/` tree (the eject/assembler source) and the `plugins/harness-*/` tree (the marketplace). A new addon lands in `templates/<domain>/_addons/` and in the matching domain plugin (e.g. `plugins/harness-web/`). Your change must pass **both** test suites before merge — `./templates/tests/run.sh` and `./plugins/tests/run-plugin-tests.sh`. The steps below cover the `templates/` shape; mirror the same content into the plugin and validate it in step 8.

---

## Step 1 — Open an issue first

Use the [**Propose new content**](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose) template. Describe:

- The addon's purpose in one paragraph.
- Which sub-domains it pairs with (frontend-app, fullstack-app, api-service, design-system, distributed-backend).
- The adopt-if / skip-if reasoning.
- Whether the addon needs a new MCP server, a new hook, or just files and conventions.

Wait for a maintainer thumbs-up before writing the PR.

---

## Step 2 — Confirm the shape is "addon"

Addon-shaped:

- Project-type-specific (Next.js, Drizzle, Tailwind+shadcn, Astro, Auth.js, Playwright, Sentry, Sanity CMS).
- Sensible to add or remove without rewriting the project.
- Sits on top of a sub-domain.

Not addon-shaped — pick a different contribution type:

- Cross-cutting concern (memory, progress, methodology, orchestration, safety) → [add a **module**](add-a-module.md).
- New deliverable shape within a domain (e.g. "GraphQL Federation server") → [add a **sub-domain**](add-a-subdomain.md).
- Pure documentation → just a docs PR.

---

## Step 3 — Create the directory

```bash
mkdir -p templates/web/_addons/<addon>/files/.claude
cd templates/web/_addons/<addon>
```

The shape is identical to a module:

```
MODULE.md         adopt-if/skip-if/install/remove guide
claude-md.md      fragment appended to CLAUDE.md
files/            tree copied verbatim into the project
```

---

## Step 4 — Write `MODULE.md`

Same required sections as a module ([`structure-lint`](../reference/tests.md#structure-lint) enforces them):

1. `# Module: web/_addons/<addon>`
2. `> Config: domain.addons += [<addon>] · Depends on: <other-addons-or-"none">`
3. `**What it does.**` paragraph.
4. `## Adopt if`
5. `## Skip if`
6. `## Dependencies`
7. `## Install (manual)`
8. `## Install (assemble.sh)`
9. `## Remove`
10. `## Files`

Adopt-if / skip-if for addons must be sharper than for modules — there are nine web addons today and a clear decision matrix matters. Reference: [`templates/web/_addons/nextjs/MODULE.md`](../../templates/web/_addons/nextjs/MODULE.md).

---

## Step 5 — Write `claude-md.md`

Even more important for addons than for modules: tell the agent *the conventions it would otherwise get wrong*. Examples:

- `nextjs` → "App Router only, never Pages Router. Server Components default; mark `'use client'` only when needed."
- `drizzle` → "All schema lives in `db/schema/*`. Migrations go through `drizzle-kit generate` then a reviewed PR."
- `tailwind-shadcn` → "Tokens via `@theme inline`; shadcn components in `components/ui/`; never edit generated shadcn files."

One sentence per rule. Pretend you are writing the briefest possible code review for the next 50 PRs.

---

## Step 6 — Add the `files/` tree

Typical addon contents:

- Config files (`next.config.mjs`, `drizzle.config.ts`, `playwright.config.ts`) under `files/` at the project root.
- Skills under `files/.claude/skills/<skill-name>/SKILL.md` that teach the addon's idiom.
- Optionally a hook under `files/.claude/hooks/` (e.g. an Astro addon might add a content-collection lint).
- Optionally `.claude/settings.fragment.json` to register the hook.
- Optionally `.mcp.json.fragment` if the addon wires an MCP server.

Keep generated/template files minimal — provide structure, not example application code. The user fills in the rest.

---

## Step 7 — Pair correctly with sub-domains

Update [`templates/web/<sub-domain>/SUBDOMAIN.md`](../../templates/web/) if your addon "pairs well" with that sub-domain. The pairing table in each `SUBDOMAIN.md` is what users read when picking addons.

Update the default `domain.addons` list in `templates/web/<sub-domain>/harness.config.yml` only if the addon is genuinely default for that sub-domain. Most addons are opt-in additions, not defaults.

---

## Step 8 — Mirror into the plugin tree and run both test suites

Mirror the addon into the matching domain plugin (e.g. `plugins/harness-web/`) so the marketplace stays in sync, then run both suites:

```bash
./templates/tests/run.sh              # eject tree
./plugins/tests/run-plugin-tests.sh   # marketplace tree
```

`assemble-coverage` automatically discovers every addon under `templates/web/_addons/` and assembles it against `web/frontend-app`'s config (with `domain.addons` set to just your addon). You do not edit the test. The plugin suite runs `claude plugin validate --strict` against the domain plugin plus the convention lint.

If the addon depends on another addon being installed first, document it in `MODULE.md` → **Dependencies**, and order it correctly in any `harness.config.yml` `domain.addons` list that uses both.

---

## Step 9 — Update the catalogs

- [`docs/reference/domains.md`](../reference/domains.md) — add a row to the `web/` addons table.
- [`docs/how-to/pick-a-recipe.md`](pick-a-recipe.md) — add to the addons table under Question 4.

---

## Step 10 — Open the PR

Same workflow as [`your-first-contribution.md`](../tutorials/your-first-contribution.md). PR template **Type of change** = **New addon**.

The reviewer will check:

- The addon-vs-module decision is right (sub-domain-coupled is the test).
- `MODULE.md` is sharp on adopt-if / skip-if.
- `claude-md.md` is *behavioural* — the rules the agent would otherwise get wrong.
- Files are minimal — structure, not bloat.

---

## See also

- [`reference/domains.md`](../reference/domains.md) — current web addons.
- [`add-a-module.md`](add-a-module.md) — for cross-cutting capabilities.
- [`add-a-subdomain.md`](add-a-subdomain.md) — for new deliverable shapes.
- Canonical reference: [`templates/web/_addons/nextjs/`](../../templates/web/_addons/nextjs/).
