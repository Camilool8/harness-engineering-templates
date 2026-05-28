# `templates/` — the plug-and-play harness

This directory is the **assemble unit**. You do not adopt the whole thing: you pick a [domain pack and sub-domain](../docs/reference/domains.md), edit the [config](../docs/reference/harness-config.md) if you want to deviate from defaults, and run `assemble.sh`.

For walk-throughs, decision flows, and the full doc set, see [`../docs/`](../docs/).

---

## Quickstart

```bash
# pick a curated domain pack + sub-domain and assemble into your project
./assemble.sh web/frontend-app/harness.config.yml ./my-app             # web SPA / SSR app
./assemble.sh data/ml-pipeline/harness.config.yml ./my-ml-project      # ML training + eval
./assemble.sh devops/infrastructure/harness.config.yml ./my-iac        # cloud IaC
./assemble.sh mobile/react-native-expo/harness.config.yml ./my-rn-app  # cross-platform mobile
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

data/ devops/ mobile/                                         curated three-layer packs
  DOMAIN.md, references.md, domain.claude-md.md, _addons/, <sub-domain>/...

tests/                           offline test suite
  run.sh, checks/{structure-lint,hook-lint,assemble-coverage}.sh
```

Every module ships a `MODULE.md` with adopt-if / skip-if / install / remove. Every sub-domain ships a `SUBDOMAIN.md`. The conventions are enforced by [`tests/checks/structure-lint.sh`](tests/checks/structure-lint.sh).

---

## Pointers into the docs

| You need… | Read |
|---|---|
| The full schema for `harness.config.yml` | [`../docs/reference/harness-config.md`](../docs/reference/harness-config.md) |
| What `assemble.sh` does and exits with | [`../docs/reference/eject.md`](../docs/reference/eject.md) |
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
