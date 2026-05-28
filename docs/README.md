# Documentation

This directory is the user-facing documentation for **harness-engineering-templates**, organised by intent ([Diátaxis](https://diataxis.fr/)). The harness ships as a Claude Code **plugin marketplace** (`harness-engineering`) — `/plugin marketplace add Camilool8/harness-engineering-templates`, then install a domain pack and run its `init` command. That is the primary path. The bash `assemble.sh` assembler is retained as an **eject path** for teams that want committed `.claude/` artifacts checked into their repo. Four quadrants, four jobs:

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
| Browsing the plugin catalog | [`reference/plugins.md`](reference/plugins.md) |
| Picking a pack and sub-domain for a real project | [`how-to/pick-a-recipe.md`](how-to/pick-a-recipe.md) |
| Asking *why* it is shaped this way | [`explanation/why-harness.md`](explanation/why-harness.md) |
| About to open your first PR | [`tutorials/your-first-contribution.md`](tutorials/your-first-contribution.md) |

---

## Documentation index

### Tutorials

- [`tutorials/getting-started.md`](tutorials/getting-started.md) — add the marketplace, install `harness-web`, run `/harness-web:init`, watch a safety hook fire, optionally arm an opt-in discipline.
- [`tutorials/your-first-contribution.md`](tutorials/your-first-contribution.md) — fork → small fix → both test suites → PR → merge, end-to-end.

### How-to guides

- [`how-to/pick-a-recipe.md`](how-to/pick-a-recipe.md) — choose the right plugin pack and sub-domain for your project (with the eject-path equivalent).
- [`how-to/customize-modules.md`](how-to/customize-modules.md) — arm opt-in hooks via `HARNESS.toml`, let skills auto-load, wire MCP servers, set permissions.
- [`how-to/run-tests-locally.md`](how-to/run-tests-locally.md) — run both `./templates/tests/run.sh` and `./plugins/tests/run-plugin-tests.sh`; install prerequisites.
- [`how-to/add-a-module.md`](how-to/add-a-module.md) — contribute a new module (mirrored across both trees).
- [`how-to/add-an-addon.md`](how-to/add-an-addon.md) — contribute a new addon (mirrored across both trees).
- [`how-to/add-a-subdomain.md`](how-to/add-a-subdomain.md) — contribute a new sub-domain (mirrored across both trees).
- [`how-to/assemble-by-hand.md`](how-to/assemble-by-hand.md) — install the harness manually without running `assemble.sh` (eject path).

### Reference

- [`reference/plugins.md`](reference/plugins.md) — the plugin marketplace: the five plugins, install commands, `HARNESS.toml` flags, the MCP/secret model.
- [`reference/harness-config.md`](reference/harness-config.md) — every key in `harness.config.yml` with type, default, valid values, behaviour (eject path).
- [`reference/eject.md`](reference/eject.md) — `./templates/assemble.sh` invocation, inputs, outputs, exit codes, `HARNESS.lock` (eject path).
- [`reference/assembled-output.md`](reference/assembled-output.md) — the file tree a fully-assembled project ends up with; what each file does.
- [`reference/modules.md`](reference/modules.md) — catalog of every module under `templates/_modules/`.
- [`reference/domains.md`](reference/domains.md) — catalog of the four curated domain packs.
- [`reference/recommended-permissions.md`](reference/recommended-permissions.md) — opt-in `permissions` block to paste into `.claude/settings.json` if you want one.
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
