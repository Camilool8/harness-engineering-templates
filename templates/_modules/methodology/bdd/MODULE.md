# Module: methodology/bdd

> Config: `methodology.bdd` · Depends on: none

**What it does.** Captures behavior as Gherkin `.feature` files so non-technical
stakeholders can read and sign off on what the system does. Ships a feature
template and a skill for authoring scenarios in business language.

## Adopt if
- A non-technical stakeholder (product, customer, compliance) must sign off on
  behavior before or after it ships.
- The system has many user-visible flows, and acceptance criteria evolve faster
  than the implementation.
- Multiple agents or teams need a shared, executable vocabulary for behavior.

## Skip if
- The work has no external stakeholder and `methodology/tdd` plus
  `methodology/spec_driven` already give you the contract you need — BDD's extra
  ceremony only pays off when someone outside engineering reads it.
- The surface is internal/infra with no user-facing behavior to describe.
- You would write Gherkin but never wire step definitions to run it — unrun
  Gherkin is just stale documentation.

## Dependencies
- None to author `.feature` files.
- To execute them you need a BDD runner — Cucumber, Behave, pytest-bdd,
  SpecFlow — wired with real code-backed step definitions (not prompts).

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Wire a BDD runner to `features/` when you are ready to execute scenarios.

## Install (assemble.sh)
Set `methodology.bdd: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `features/` and `.claude/skills/authoring-feature-files/`.
- Remove the `## Behavior-Driven Development` section from `CLAUDE.md`.

## Files
- `files/features/TEMPLATE.feature` — Gherkin template: Feature, Background,
  Scenario, Scenario Outline with Given/When/Then.
- `files/.claude/skills/authoring-feature-files/SKILL.md` — how to write
  declarative, business-language scenarios from a user story.
