# harness-engineering-templates

![CI](https://github.com/Camilool8/harness-engineering-templates/actions/workflows/ci.yml/badge.svg)

A library of opinionated **Claude Code harness templates** for software engineering across twelve domains — web, data, DevOps, finance, mobile, game, embedded, scientific, security, content, ops, and generic.

The premise (per Birgitta Böckeler, Anthropic engineering, METR, and the practitioner consensus of 2025–2026):

> **Agent = Model + Harness.** Templates that lean on the model's good judgement fail their first incident. The harness — not the agent — is the contract.

The full reasoning lives in [`docs/explanation/why-harness.md`](docs/explanation/why-harness.md).

---

## Start here

```bash
git clone https://github.com/Camilool8/harness-engineering-templates.git
cd harness-engineering-templates
./templates/assemble.sh templates/generic/harness.config.yml /path/to/your/project
```

Full walk-through with prerequisites and a "watch a hook fire" demo: [`docs/tutorials/getting-started.md`](docs/tutorials/getting-started.md).

---

## What this gives you

A copy-and-go harness for any software project. You pick a [recipe](docs/reference/domains.md), tune which [modules](docs/reference/modules.md) to include, and `assemble.sh` produces a fully-configured `.claude/` tree with:

- **Four non-negotiable safety hooks** — secret scanning, command guarding, append-only audit log, verification gate. See [why](docs/explanation/non-negotiables.md).
- **Opt-in modules** for memory backend, progress tracking, methodology (TDD / spec-driven / eval-driven / BDD), orchestration topology, and additional safety gates. Each ships with adopt-if / skip-if guidance.
- **Domain recipes** that pre-fill the manifest and add domain-specific gates (accessibility verify loop for web, unbounded-SQL block for data, paper-by-default for finance, etc.).
- **A test suite** (`./templates/tests/run.sh`) that runs offline and is what CI runs.

Every module is independently removable. Every default is the 2026 practitioner consensus.

---

## Documentation

| You want to… | Read |
|---|---|
| Run the harness for the first time | [`docs/tutorials/getting-started.md`](docs/tutorials/getting-started.md) |
| Pick a recipe for your project | [`docs/how-to/pick-a-recipe.md`](docs/how-to/pick-a-recipe.md) |
| Look up a config key | [`docs/reference/harness-config.md`](docs/reference/harness-config.md) |
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
  web/                             curated three-layer pack (5 sub-domains, 9 addons)
  data/ devops/ finance/ mobile/ game/ embedded/
  scientific/ security/ content/ ops/ generic/   11 domain recipes

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
