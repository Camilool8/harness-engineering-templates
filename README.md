# harness-engineering-templates

![CI](https://github.com/Camilool8/harness-engineering-templates/actions/workflows/ci.yml/badge.svg)

A library of opinionated **Claude Code harness templates** for software engineering across four curated domains — web, data, DevOps, and mobile.

The premise (per Birgitta Böckeler, Anthropic engineering, METR, and the practitioner consensus of 2025–2026):

> **Agent = Model + Harness.** Templates that lean on the model's good judgement fail their first incident. The harness — not the agent — is the contract.

The full reasoning lives in [`docs/explanation/why-harness.md`](docs/explanation/why-harness.md).

---

## Start here

Install from inside Claude Code — add the marketplace, then install the pack for your domain:

```
/plugin marketplace add Camilool8/harness-engineering-templates
/plugin install harness-web@harness-engineering      # or harness-data / harness-devops / harness-mobile
/harness-web:init                                    # pick a sub-domain
```

Installing any domain pack pulls in `harness-base` automatically (the four non-negotiable safety hooks). Full walk-through: [`docs/tutorials/getting-started.md`](docs/tutorials/getting-started.md). Plugin catalog and the `HARNESS.toml` opt-in flags: [`docs/reference/plugins.md`](docs/reference/plugins.md).

> Prefer committed `.claude/` artifacts in your repo (audit-heavy or regulated teams)? The bash assembler is still supported as an **eject path** — see [`docs/reference/eject.md`](docs/reference/eject.md).

---

## What this gives you

Five installable plugins — a shared `harness-base` plus four curated domain packs (`harness-web`, `harness-data`, `harness-devops`, `harness-mobile`):

- **Four non-negotiable safety hooks** — secret scanning, command guarding, append-only audit log, verification gate. Always on. See [why](docs/explanation/non-negotiables.md).
- **Opt-in discipline** — TDD, eval-driven, two-key, and kill-switch hooks that arm only when you set a flag in `.claude/HARNESS.toml`; memory, progress-tracking, methodology, and orchestration guidance ship as auto-loading skills.
- **Curated domain packs** with sub-domains, addons, agent teams, and domain-specific gates (accessibility verify loop for web, unbounded-SQL block for data, plan-before-apply for devops, simulator-in-the-loop for mobile).
- **Permissions stay yours** — plugins ship the hooks (the enforcement contract) but never a `permissions` block; see [`docs/reference/recommended-permissions.md`](docs/reference/recommended-permissions.md) for an opt-in starting point.

Every default is the 2026 practitioner consensus.

---

## Documentation

| You want to… | Read |
|---|---|
| Install a pack for the first time | [`docs/tutorials/getting-started.md`](docs/tutorials/getting-started.md) |
| Browse the plugin catalog + `HARNESS.toml` flags | [`docs/reference/plugins.md`](docs/reference/plugins.md) |
| Pick a domain pack and sub-domain | [`docs/how-to/pick-a-recipe.md`](docs/how-to/pick-a-recipe.md) |
| Use the bash assembler (eject path) | [`docs/reference/eject.md`](docs/reference/eject.md) |
| Understand the design | [`docs/explanation/why-harness.md`](docs/explanation/why-harness.md) |
| Contribute a module, addon, or sub-domain | [`docs/how-to/`](docs/how-to/) and [`CONTRIBUTING.md`](CONTRIBUTING.md) |

The full documentation index, organised by [Diátaxis](https://diataxis.fr/) quadrant: [`docs/README.md`](docs/README.md).

Three deep-reference essays (the *why* behind the design):

- [`docs/HARNESS_ENGINEERING.md`](docs/HARNESS_ENGINEERING.md) — foundations, the Claude Code primitive reference, per-domain templates, cross-cutting concerns, universal anti-patterns.
- [`docs/METHODOLOGIES.md`](docs/METHODOLOGIES.md) — SDD, TDD, BDD, ATDD, DDD, Agile, Waterfall, Lean, DevOps/SRE, Eval-Driven Development — each adapted to AI harnesses.
- [`docs/AGENT_ROLES.md`](docs/AGENT_ROLES.md) — single-agent baseline, multi-agent topologies, the canonical role catalog, sub-agent design principles.

---

## Repository layout

```
docs/                              user-facing documentation (start here)
  tutorials/                       learning-oriented walk-throughs
  how-to/                          problem-oriented recipes
  reference/                       schemas, CLI, catalogs, glossary
  explanation/                     understanding-oriented design notes
  HARNESS_ENGINEERING.md           deep reference
  METHODOLOGIES.md                 deep reference
  AGENT_ROLES.md                   deep reference

templates/                         the plug-and-play harness
  harness.config.yml               the single manifest you tune
  assemble.sh                      one-command assembler (no dependencies)
  _base/                           universal starter every project copies
  _modules/                        opt-in modules
    memory/                        md-files | vector-store | knowledge-graph
    progress-tracking/             filesystem | github-issues | linear | jira
    methodology/                   tdd | spec-driven | eval-driven | bdd
    orchestration/                 supervisor-worker | pipeline | blackboard
    safety/                        two-key | kill-switch | sandbox
  web/                             curated pack (5 sub-domains, 9 addons)
  data/                            curated pack (4 sub-domains, 11 addons)
  devops/                          curated pack (4 sub-domains, 14 addons)
  mobile/                          curated pack (4 sub-domains)

scripts/                           CI governance helpers
```

---

## Contributing

Contributions of new modules, addons, sub-domains, and whole domains are welcome.

1. Open an issue with the [**Propose new content**](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose) template.
2. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) for the workflow and policy.
3. Follow the focused how-to for what you are adding: [`add-a-module.md`](docs/how-to/add-a-module.md), [`add-an-addon.md`](docs/how-to/add-an-addon.md), or [`add-a-subdomain.md`](docs/how-to/add-a-subdomain.md).

Every PR is automatically verified: `./templates/tests/run.sh` runs in CI and must pass before merge.

See also [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) and [`SECURITY.md`](SECURITY.md).
