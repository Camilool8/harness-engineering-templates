# Picking and discarding modules

This repo is opinionated *and* removable. Every module ships with explicit **adopt if** / **skip if** guidance, and every module's `MODULE.md` ends with a **Remove** section. That tension — opinionated but removable — is intentional. This page explains why.

---

## The two anti-patterns we are trying to avoid

**Anti-pattern 1 — the kitchen sink.** A template repo that installs everything by default. Every project gets a vector store, a knowledge graph, four methodologies, three orchestration topologies, and seven safety gates. The result is unreadable, slow, and intimidating; most users delete things in random order until something seems to work, which is rarely the right subset.

**Anti-pattern 2 — the bare skeleton.** A template repo that installs nothing by default and tells you to "configure it for your needs". The result is that nobody configures it well; everyone reinvents the same wheels; the defaults that should exist (TDD, Plan Mode, secret scanning) end up missing in the projects that need them most.

The middle path — opinionated defaults that are explicitly opt-out — is the design we have settled on.

---

## What "opinionated default" means here

Every module has a *default state*:

| Default state | Examples |
|---|---|
| **Always on, not configurable** | The four `_base` hooks: secret-scan, command-guard, audit-log, verify-gate. See [`non-negotiables.md`](non-negotiables.md). |
| **On by default, can be turned off** | `methodology.tdd`, `methodology.spec_driven`, `hitl.plan_mode_default`, `hitl.diff_review_required`. |
| **Off by default, easy to turn on** | `methodology.eval_driven`, `methodology.bdd`, `safety.two_key`, `safety.kill_switch`, `safety.sandbox`. |

The defaults are *the 2026 practitioner consensus* — what the average engineering project should run with. Where there is a strong case to deviate (e.g. `eval_driven` should be on for any LLM-output project), the relevant module's `MODULE.md` says so explicitly under **Adopt if**.

This means the friction of doing the *right* thing is low. You start with `assemble.sh templates/web/frontend-app/harness.config.yml .` (or the curated pack that matches your work) and you have a reasonable setup. You change one flag when you have a reason. You read one `MODULE.md` when you are deciding whether to flip it.

---

## Why every module is independently removable

The harness's value compounds when modules layer cleanly:

- TDD without spec-driven is fine.
- Spec-driven without TDD is fine.
- Both with eval-driven on top is fine.
- All three with the kill-switch off is fine.

The implementation enforces this in two ways:

1. **Isolation in the file tree.** Every module's files live under its own subtree in `.claude/`. There are no shared mutable files where one module steps on another. The merge semantics ([deep-merge for `settings.json` and `.mcp.json`](../reference/eject.md#merge-semantics), append for `CLAUDE.md`) guarantee additive composition.

2. **A `Remove` section in every `MODULE.md`.** It tells you exactly which files to delete and which `CLAUDE.md` section to drop. Removing a module is always: delete files + delete section. No tangle.

The test suite enforces this property continuously: `assemble-coverage` assembles every module against the base and checks the output is valid. If a module is not cleanly removable, it would not pass review.

---

## What "adopt if / skip if" is for

Every `MODULE.md` includes two prominent bullet lists:

```markdown
## Adopt if
- You write deterministic code with a test runner.
- Regression cost is high.
- You want to ship work a human will merge.

## Skip if
- The output is judgmental (LLM/ML generation). Use `eval_driven` instead.
- This is a throwaway spike where being wrong is cheap.
- You have no test runner and no intent to add one.
```

The form is deliberate. It addresses two different readers:

- **The "should I turn this on?" reader.** They scan **Adopt if** and check whether any line matches their project. If multiple do, they turn it on.
- **The "should I turn this off?" reader.** They scan **Skip if** and check whether any line matches. If one does, they turn it off and consider the recommended alternative.

The lists are not exhaustive; they are *decisive*. We would rather a reader feel "yes, that is exactly my situation" than "this might apply, let me read more". Long, equivocal adopt-if lists are a sign the module's purpose is unclear.

The [`structure-lint`](../reference/tests.md#1-modulemd-standard-sections) check enforces the section's presence, not its content. The reviewer enforces decisiveness.

---

## What you should and should not customise

| Comfortable to customise | Use the existing module shape |
|---|---|
| Toggling modules in `harness.config.yml`. | Edit and re-assemble. |
| Editing the generated `CLAUDE.md` after assembly to fit your project. | Always — `CLAUDE.md` is yours. |
| Replacing the `.claude/verify.sh` with your project's real commands. | Always — that is the point of the example. |
| Adding deny patterns to `.claude/settings.json` `permissions.deny`. | Always — your project's threat model is specific. |
| Editing the four `_base` hooks. | **Don't.** See [`non-negotiables.md`](non-negotiables.md). Edit a *copy* in your project if you must, but understand the trade. |
| Disabling `verify-gate.sh`. | **Almost never right.** Evidence before assertions is what makes the harness load-bearing. |

---

## Why "pick what fits" is not the same as "pick whatever"

There is real engineering judgement in module selection. Wrong picks are common:

- **Vector store on day one.** The corpus is not yet too big for context. The graph backend is heavy and you do not need it. Start with `md-files`; switch when it stops working.
- **`supervisor-worker` topology for sequential tasks.** Cargo-culting multi-agent because it sounds impressive. Sequential tasks should run in one well-equipped agent. See [`AGENT_ROLES.md`](../AGENT_ROLES.md).
- **`eval_driven` off in an LLM-output project.** The single most common silent regression in 2025. Turn it on.
- **`hitl.diff_review_required: false` to "ship faster".** This eliminates the human in the loop, not the friction. The harness directs human attention; do not remove the gate.

The `MODULE.md` files exist to make these judgement calls explicit. Read them. Choose deliberately.

---

## See also

- [`why-harness.md`](why-harness.md) — why the harness is the contract.
- [`non-negotiables.md`](non-negotiables.md) — the parts that are not in the pick-or-discard category.
- [`how-to/customize-modules.md`](../how-to/customize-modules.md) — the practical recipes for swapping modules.
- [`reference/modules.md`](../reference/modules.md) — the full catalog with adopt-if links.
