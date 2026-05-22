# `templates/` — the plug-and-play harness

This directory is the **assemble unit**. You do not adopt the whole thing: you pick a [recipe](../docs/reference/domains.md), edit the [config](../docs/reference/harness-config.md) if you want to deviate from defaults, and run `assemble.sh`.

For walk-throughs, decision flows, and the full doc set, see [`../docs/`](../docs/).

---

## Quickstart

```bash
# pick a domain recipe and assemble into your project
./assemble.sh generic/harness.config.yml ./my-project          # base only
./assemble.sh web/frontend-app/harness.config.yml ./my-app     # curated web sub-domain
./assemble.sh data/harness.config.yml ./my-data-project        # v1 thin recipe
```

Full tutorial: [`../docs/tutorials/getting-started.md`](../docs/tutorials/getting-started.md).

No-script install: [`../docs/how-to/assemble-by-hand.md`](../docs/how-to/assemble-by-hand.md).

---

## What is in here

```
harness.config.yml               canonical reference manifest with inline commentary
assemble.sh                      the one-command assembler

_base/                           universal starter — always copied first
  .claude/{settings.json,hooks/,skills/,agents/,verify.sh.example}
  CLAUDE.md, AGENTS.md, .mcp.json, .gitignore

_modules/                        cross-cutting opt-in modules
  memory/{md-files,vector-store,knowledge-graph}/
  progress-tracking/{filesystem,github-issues,linear,jira}/
  methodology/{tdd,spec-driven,eval-driven,bdd}/
  orchestration/{supervisor-worker,pipeline,blackboard}/
  safety/{two-key,kill-switch,sandbox}/

web/                             curated three-layer domain pack
  DOMAIN.md, references.md, domain.claude-md.md
  _addons/{vite-spa,nextjs,astro,tailwind-shadcn,drizzle,sanity-cms,
           authjs,playwright-e2e,sentry-observability}/
  design-system/  frontend-app/  fullstack-app/  api-service/  distributed-backend/
    SUBDOMAIN.md, harness.config.yml, references.md, claude-md.md, files/.claude/

data/ devops/ finance/ mobile/ game/ embedded/
scientific/ security/ content/ ops/ generic/                  v1 thin recipes
  harness.config.yml, README.md, claude-md.md, files/.claude/

tests/                           offline test suite
  run.sh, checks/{structure-lint,hook-lint,assemble-coverage}.sh
```

Every module ships a `MODULE.md` with adopt-if / skip-if / install / remove. Every sub-domain ships a `SUBDOMAIN.md`. The conventions are enforced by [`tests/checks/structure-lint.sh`](tests/checks/structure-lint.sh).

---

## Pointers into the docs

| You need… | Read |
|---|---|
| The full schema for `harness.config.yml` | [`../docs/reference/harness-config.md`](../docs/reference/harness-config.md) |
| What `assemble.sh` does and exits with | [`../docs/reference/assemble-cli.md`](../docs/reference/assemble-cli.md) |
| The catalog of every module + addon + domain | [`../docs/reference/modules.md`](../docs/reference/modules.md), [`../docs/reference/domains.md`](../docs/reference/domains.md) |
| To pick a recipe for your project | [`../docs/how-to/pick-a-recipe.md`](../docs/how-to/pick-a-recipe.md) |
| To swap a default (memory, methodology, orchestration, safety) | [`../docs/how-to/customize-modules.md`](../docs/how-to/customize-modules.md) |
| To install without `assemble.sh` | [`../docs/how-to/assemble-by-hand.md`](../docs/how-to/assemble-by-hand.md) |
| Why the four `_base` hooks are not configurable | [`../docs/explanation/non-negotiables.md`](../docs/explanation/non-negotiables.md) |
| To run the test suite locally | [`../docs/how-to/run-tests-locally.md`](../docs/how-to/run-tests-locally.md) |

---

## The non-negotiables (baked into `_base`)

Four hooks ship in `_base` and are not configurable: secret-scan, command-guard, audit-log, verify-gate. They survive `--dangerously-skip-permissions`. See [`../docs/explanation/non-negotiables.md`](../docs/explanation/non-negotiables.md) for *why*.

Everything else is opt-in and independently removable.
