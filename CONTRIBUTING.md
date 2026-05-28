# Contributing

Contributions of new modules, addons, sub-domains, and whole domains are welcome. The goal of every contribution is the same as the repo itself: make the harness — not the agent — the contract.

This file is the **policy and workflow overview**. The detailed how-to guides for each contribution type live under [`docs/how-to/`](docs/how-to/).

---

## Before you start

Open an issue first using the [**Propose new content**](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose) template. Describe what you want to add, what it does, and the adopt-if / skip-if reasoning. Wait for a maintainer thumbs-up before investing time in a large PR.

For small fixes — a typo, a broken link, a shellcheck error — go straight to a PR.

If this is your very first contribution, walk through [`docs/tutorials/your-first-contribution.md`](docs/tutorials/your-first-contribution.md) end-to-end. It is intentionally tiny so the lesson is the workflow.

---

## What you can contribute

| Contribution | Detailed how-to |
|---|---|
| A new **module** under `templates/_modules/<category>/<option>/` (memory, progress, methodology, orchestration, safety) | [`docs/how-to/add-a-module.md`](docs/how-to/add-a-module.md) |
| A new **addon** under `templates/web/_addons/<addon>/` (project-type-specific scaffolding) | [`docs/how-to/add-an-addon.md`](docs/how-to/add-an-addon.md) |
| A new **sub-domain** under `templates/web/<sub-domain>/` (deliverable shape within the web pack) | [`docs/how-to/add-a-subdomain.md`](docs/how-to/add-a-subdomain.md) |
| **Core enhancements** to `_base/`, `assemble.sh`, the config schema, or the test engine | This file, [Core enhancements](#core-enhancements) below |
| **Documentation** improvements anywhere | Straight to PR (small) or issue first (large) |

The how-to for each contribution type covers directory shape, required files, conventions, and structure-lint requirements. Read the relevant one before opening the PR.

---

## How the templates fit together

The template system has four layers:

1. **`_base/`** — the universal starter every assembled project copies. Sets up the foundational `.claude/` structure: `settings.json`, `CLAUDE.md`, and the four non-negotiable hooks (secret-scan, command-guard, audit-log, verify-gate).
2. **`_modules/<category>/<option>/`** — cross-cutting opt-in modules. Each ships an adopt-if / skip-if / install / remove decision guide.
3. **Domain packs** — four curated three-layer packs: `web/`, `data/`, `devops/`, `mobile/`. Each ships a `DOMAIN.md`, sub-domains, and addons.
4. **`assemble.sh`** — the one-command assembler. Reads a `harness.config.yml`, merges `_base/` + selected modules + a domain layer + any addons, writes a ready-to-use project directory.

Deep reference: [`docs/HARNESS_ENGINEERING.md`](docs/HARNESS_ENGINEERING.md), [`docs/METHODOLOGIES.md`](docs/METHODOLOGIES.md), [`docs/AGENT_ROLES.md`](docs/AGENT_ROLES.md).

---

## Running the tests locally

The repo ships a hermetic, offline test suite:

```bash
./templates/tests/run.sh
```

The final line is `ALL CHECKS PASSED` or `N CHECK(S) FAILED`. Exit code mirrors the failure count.

Three checks, each runnable standalone:

```bash
templates/tests/checks/structure-lint.sh       # MODULE.md sections, agents, skills, JSON
templates/tests/checks/hook-lint.sh            # bash -n + shellcheck on every *.sh
templates/tests/checks/assemble-coverage.sh    # assembles every unit discovered on disk
```

Prerequisites: `jq` (`brew install jq` / `apt install jq`). `shellcheck` is recommended; CI installs it automatically.

Full guide: [`docs/how-to/run-tests-locally.md`](docs/how-to/run-tests-locally.md). When a check fails: [`docs/reference/troubleshooting.md`](docs/reference/troubleshooting.md#tests).

---

## The deletion policy

**Renaming a file is always fine.** Git records it as a rename; the CI governance check passes automatically.

**Deleting a file requires justification.** For each file your PR deletes, add an entry in the PR body's `## Deletions` section:

```
`path/to/deleted/file` — reason — replaced by `path/to/new` (or "no replacement: reason")
```

The CI `governance` job runs `scripts/check-deletions.sh` on every PR and fails if any deleted path is not mentioned in the PR description. A maintainer can apply the `override-deletion` label to waive the justification — for example, if a file is being removed as part of a well-understood cleanup.

Regardless of the label, the `verify` job (which runs `./templates/tests/run.sh`) always has to pass. There is no override for test failures.

---

## Core enhancements

The core consists of `templates/_base/`, `templates/assemble.sh`, the `harness.config.yml` schema, and `templates/tests/`. These components affect every assembled project and every consumer of this library. Changes here receive extra review scrutiny.

- **`_base/`** changes must remain backward-compatible with all four curated domain packs. If a change would require every recipe to update its config, that is a breaking change and requires discussion.
- **`assemble.sh`** changes must keep the existing merge semantics for `settings.json`, `.mcp.json`, and `CLAUDE.md`. Run the full test suite before and after.
- **Test engine changes** (under `templates/tests/`) must not reduce coverage. Adding a new check is welcome; tightening an existing check is welcome; silencing or removing a check requires a very clear justification in the PR.

---

## Least-privilege rule for agents

Architects, auditors, reviewers, and critics **must be read-only**. Their agent files must not list `Edit` or `Write` in the `tools:` frontmatter key. Only implementers, testers, and builders may have `Edit` / `Write`.

The `structure-lint` check enforces this automatically. This is not stylistic — it is the basis of the harness's compliance with the [Agents Rule of Two](https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security).

---

## PR lifecycle

1. **Fork and branch.** Work on a branch named for the change (`add-module-methodology-ddd`, `fix-hook-lint-error`, etc.).
2. **Fill the PR template.** It prompts for a summary, a type-of-change checkbox, the standard checklist, and the deletions section. Fill it out.
3. **CI runs automatically.** Two jobs on every PR:
   - **`verify`** — runs `./templates/tests/run.sh`; must be green.
   - **`governance`** — runs the deletion-policy check; must be green or waived by the `override-deletion` label.
4. **CODEOWNERS review.** `@Camilool8` is automatically requested as a reviewer. Branch protection requires at least one approving review from a code owner before merge.
5. **Squash-merge.** The maintainer squash-merges the PR. Both `verify` and `governance` must be green (or `governance` waived) before merge is allowed.

---

## Code of Conduct

All participants in this project follow the [Code of Conduct](CODE_OF_CONDUCT.md). Read it before contributing.

For security issues, follow [`SECURITY.md`](SECURITY.md) — do not open a public issue.

---

## See also

- [`docs/README.md`](docs/README.md) — the documentation index.
- [`docs/tutorials/your-first-contribution.md`](docs/tutorials/your-first-contribution.md) — end-to-end first-PR walk-through.
- [`docs/reference/tests.md`](docs/reference/tests.md) — what each check enforces in detail.
