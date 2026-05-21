# Documentation

This directory is the user-facing documentation for **harness-engineering-templates**, organised by intent ([Diátaxis](https://diataxis.fr/)). Four quadrants, four jobs:

| Quadrant | Purpose | Read when… |
|---|---|---|
| **[Tutorials](tutorials/)** | Learning by doing — guided lessons with a guaranteed outcome | You are new and want to *use* the harness end-to-end once. |
| **[How-to guides](how-to/)** | Problem-oriented recipes — specific tasks, no fluff | You know what you want to achieve and need the steps. |
| **[Reference](reference/)** | Information-oriented — schemas, CLIs, file inventories | You need to look something up. |
| **[Explanation](explanation/)** | Understanding-oriented — the *why* behind the design | You want to evaluate whether this approach fits your work. |

Three deep-reference essays sit alongside the four quadrants:

- [`HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md) — the master reference. Foundations, the Claude Code primitive reference, per-domain templates, cross-cutting concerns.
- [`METHODOLOGIES.md`](METHODOLOGIES.md) — software development methodologies (SDD, TDD, BDD, ATDD, DDD, Agile, Waterfall, Lean, DevOps/SRE, Eval-Driven) adapted to AI harnesses.
- [`AGENT_ROLES.md`](AGENT_ROLES.md) — single-agent baseline, multi-agent topologies, the canonical role catalog, sub-agent design principles.

These are deep Explanation in the Diátaxis sense — read them when you are making architectural decisions, not when you are trying to ship a first harness.

---

## Start here

| You are… | Read |
|---|---|
| New to this repo | [`tutorials/getting-started.md`](tutorials/getting-started.md) |
| Picking a recipe for a real project | [`how-to/pick-a-recipe.md`](how-to/pick-a-recipe.md) |
| Looking up what a config key does | [`reference/harness-config.md`](reference/harness-config.md) |
| Asking *why* it is shaped this way | [`explanation/why-harness.md`](explanation/why-harness.md) |
| About to open your first PR | [`tutorials/your-first-contribution.md`](tutorials/your-first-contribution.md) |

---

## Documentation index

### Tutorials

- [`tutorials/getting-started.md`](tutorials/getting-started.md) — clone the repo, assemble the generic recipe into a fresh project, run Claude Code, watch a hook fire.
- [`tutorials/your-first-contribution.md`](tutorials/your-first-contribution.md) — fork → small fix → tests → PR → merge, end-to-end.

### How-to guides

- [`how-to/pick-a-recipe.md`](how-to/pick-a-recipe.md) — choose the right domain, sub-domain, and addon set for your project.
- [`how-to/customize-modules.md`](how-to/customize-modules.md) — swap memory backend, add a methodology, turn on a safety gate.
- [`how-to/assemble-by-hand.md`](how-to/assemble-by-hand.md) — install the harness without running `assemble.sh`.
- [`how-to/add-a-module.md`](how-to/add-a-module.md) — contribute a new module under `templates/_modules/`.
- [`how-to/add-an-addon.md`](how-to/add-an-addon.md) — contribute a new addon under `templates/web/_addons/`.
- [`how-to/add-a-subdomain.md`](how-to/add-a-subdomain.md) — contribute a new sub-domain under `templates/web/`.
- [`how-to/run-tests-locally.md`](how-to/run-tests-locally.md) — run `./templates/tests/run.sh` and individual checks; install prerequisites.
- [`how-to/upgrade-from-thin-recipe.md`](how-to/upgrade-from-thin-recipe.md) — layer modules onto a v1 thin recipe, or graduate it into a three-layer pack.

### Reference

- [`reference/harness-config.md`](reference/harness-config.md) — every key in `harness.config.yml` with type, default, valid values, behaviour.
- [`reference/assemble-cli.md`](reference/assemble-cli.md) — `./templates/assemble.sh` invocation, inputs, outputs, exit codes, `HARNESS.lock`.
- [`reference/assembled-output.md`](reference/assembled-output.md) — the file tree a fully-assembled project ends up with; what each file does.
- [`reference/modules.md`](reference/modules.md) — catalog of every module under `templates/_modules/`.
- [`reference/domains.md`](reference/domains.md) — catalog of every domain pack and its status (curated vs v1 thin).
- [`reference/tests.md`](reference/tests.md) — every check under `templates/tests/checks/`; what it asserts, how it fails.
- [`reference/glossary.md`](reference/glossary.md) — base, module, addon, sub-domain, recipe, domain pack, hook, MCP.
- [`reference/troubleshooting.md`](reference/troubleshooting.md) — common stumbles and how to fix them.

### Explanation

- [`explanation/why-harness.md`](explanation/why-harness.md) — the *agent = model + harness* premise and where it comes from.
- [`explanation/picking-vs-discarding.md`](explanation/picking-vs-discarding.md) — why every module is opt-in and removable, and what *adopt if / skip if* is for.
- [`explanation/non-negotiables.md`](explanation/non-negotiables.md) — why the four `_base` hooks are not configurable.

### Deep reference

- [`HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md) — foundations, primitives, per-domain guidance, anti-patterns.
- [`METHODOLOGIES.md`](METHODOLOGIES.md) — SDD, TDD, BDD, ATDD, DDD, Agile, Waterfall, Lean, DevOps/SRE, Eval-Driven, and the Brainstorm→Plan→TDD→Verify→Review→Ship loop.
- [`AGENT_ROLES.md`](AGENT_ROLES.md) — topologies, canonical role catalog, sub-agent design principles, anti-patterns.
