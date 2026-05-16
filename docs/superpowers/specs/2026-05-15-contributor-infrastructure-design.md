# Contributor Infrastructure — Design

> Status: approved design, ready for implementation planning.
> Date: 2026-05-15.
> Adds CI, contribution documentation, and deletion governance so external
> contributors can open issues and PRs against `harness-engineering-templates`
> in a documented, automatically-verified way.

## 1. Context & motivation

The repository (`github.com/Camilool8/harness-engineering-templates`) is a
library of Claude Code harness templates: `_base/`, cross-cutting `_modules/`,
the `web` domain pack with sub-domains and `_addons/`, 11 v1 thin recipes, an
`assemble.sh` assembler, and a `templates/tests/run.sh` test harness.

It has a GitHub remote but **no `.github/` directory** — no CI, no PR/issue
templates, no contribution guide. A dead-code review (2026-05-15) confirmed the
repo is otherwise clean: no orphaned files, no broken references, all tests
pass. Only two minor hygiene items exist (see §6).

To open the project to public contribution, three things are needed: (a) a test
layer that **automatically verifies any contribution including brand-new units**,
(b) GitHub Actions CI that runs it on every PR and merge, plus a deletion-
governance gate, and (c) documentation that makes contributing easy.

## 2. Decisions locked in brainstorming

| Question | Decision |
|---|---|
| Contributor audience | **Public open-source** — anyone. Gates are fully automated and zero-trust; docs are welcoming and explicit. |
| Verifying a contribution | **Auto-discovery coverage.** CI discovers every module/addon/sub-domain from the filesystem and verifies each — a new unit is covered the instant its folder exists, with no test file to write. |
| Owner override of the deletion gate | **A PR label** (`override-deletion`) the owner applies. Auditable, needs no special Git permissions. |
| Terminology (confirmed mapping) | "module" → `templates/_modules/<cat>/<opt>/`; "sub-domain" → `templates/<domain>/<sub-domain>/`; "plugin/addon" → `templates/<domain>/_addons/<addon>/`; "the core" → `templates/_base/` + `assemble.sh` + `harness.config.yml` + `templates/tests/`. |

## 3. The verification engine

`templates/tests/` is restructured from a single `run.sh` into an orchestrator
plus focused, independently-runnable check scripts:

```
templates/tests/
  run.sh                 orchestrator — runs every checks/*.sh, prints one summary
  checks/
    assemble-coverage.sh  assembles every discovered unit
    structure-lint.sh     structural / convention checks
    hook-lint.sh          bash -n + shellcheck on every hook
  fixtures/
    mcp-merge/.mcp.json.fragment   (existing fixture — kept)
  lib/
    common.sh            shared assert / ok / fail helpers
```

### 3.1 `assemble-coverage.sh` — auto-discovery

Discovers every assemblable unit from the filesystem and assembles each into a
fresh temp dir, asserting success. No hard-coded list.

| Unit discovered | Probe config used |
|---|---|
| each `<domain>/harness.config.yml` thin recipe + the root `harness.config.yml` | the config itself |
| each `web/<sub-domain>/harness.config.yml` | the config itself |
| each `_modules/<category>/<option>/` | a generated base manifest with that module selected (see mapping below) |
| each `web/_addons/<addon>/` | a generated `web/<sub-domain>` config with `domain.addons: [<addon>]` |

Module → config-key mapping for probe generation:

- `memory/<x>` → `memory.backend: <x>`
- `progress-tracking/<x>` → `progress.backend: <x>`
- `methodology/<x>` → `methodology.<key>: true` (`tdd`, `spec-driven`→`spec_driven`, `eval-driven`→`eval_driven`, `bdd`)
- `orchestration/<x>` → `orchestration.topology: <x>`
- `safety/<x>` → `safety.<key>: true` (`two-key`→`two_key`, `kill-switch`→`kill_switch`, `sandbox`)

Probe configs for addons must be assembled from a path where `assemble.sh`'s
domain detection works (a sub-domain directory). The script generates a probe
config inside an existing web sub-domain directory under a gitignored
`.probe.*` name, assembles it, and removes it. Implementation detail for the
plan; the contract is "every addon is assembled at least once."

Assertions per assemble: exit 0; `.claude/settings.json` and `.mcp.json` are
valid JSON; no leftover `.claude/settings.fragment.json` or `.mcp.json.fragment`
(intentional manual-apply fragments at other paths, e.g.
`.claude/sandbox/settings.fragment.json`, are not flagged); every
`.claude/hooks/*.sh` is executable.

The `.mcp.json` deep-merge fixture test (currently in `run.sh`) moves into
`assemble-coverage.sh` unchanged.

### 3.2 `structure-lint.sh` — conventions

Discovers and checks, failing on any violation:

- Every `MODULE.md` under `_modules/**` and `web/_addons/**` contains the
  standard sections: a `# Module:` title, a `> Config:` line, **What it does**,
  **Adopt if**, **Skip if**, **Dependencies**, **Install (manual)**,
  **Install (assemble.sh)**, **Remove**, **Files**.
- Every agent `.md` under any `agents/` directory has YAML frontmatter with
  `name`, `description`, `tools`, and `model`.
- **Least-privilege:** any agent whose `name` matches
  `*-architect | *-auditor | *-reviewer | *-critic` must not list `Edit` or
  `Write` in `tools`.
- Every `SKILL.md` has frontmatter with `name` and `description`.
- Every `references.md` has a line beginning `> Verified:`.
- Every `*.json`, `*.fragment.json`, and `.mcp.json.fragment` is valid JSON.

### 3.3 `hook-lint.sh` — shell safety

- `bash -n` on every `*.sh` in the repo — **hard gate**.
- `shellcheck` at `error` severity on every `*.sh` if `shellcheck` is installed
  — hard gate at error severity; lower severities are advisory (printed, not
  failing). CI installs `shellcheck`.

### 3.4 Orchestrator

`run.sh` runs each `checks/*.sh`, collects pass/fail, prints one summary, and
exits non-zero if any check failed. Each check script is runnable on its own
(`./tests/checks/structure-lint.sh`) for fast local feedback. `run.sh` keeps
working when invoked from `templates/` as today.

## 4. CI workflows

### 4.1 `.github/workflows/ci.yml`

One workflow, two jobs:

- **`verify`** — triggers on `pull_request` (to `main`) and `push` to `main`.
  `ubuntu-latest`; ensures `jq` and `shellcheck` are present; runs
  `cd templates && ./tests/run.sh`. This is the contribution verification, run
  both in the PR and again on merge. **Never bypassable.**
- **`governance`** — `if: github.event_name == 'pull_request'` only.
  Checks out with `fetch-depth: 0` (the deletion check needs history), then runs
  `scripts/check-deletions.sh` with the PR body and labels passed as env vars.

### 4.2 `scripts/check-deletions.sh`

Inputs (env): `PR_BODY`, `PR_LABELS`, `BASE_REF` (default `origin/main`).

1. `git diff --diff-filter=D --name-only "$BASE_REF...HEAD"` → **pure deletions
   only**. Git-detected renames (`R`) are excluded — renaming is always allowed
   with no justification.
2. No deletions → exit 0.
3. `PR_LABELS` contains `override-deletion` → print "owner override applied",
   exit 0.
4. Otherwise, for each deleted path, require that the path string appears in
   `PR_BODY` (the contributor lists it in the PR template's `## Deletions`
   section with a reason + replacement). All covered → exit 0. Any uncovered →
   print each uncovered path and the fix instructions (fill `## Deletions`, or
   ask the owner for the `override-deletion` label), exit 1.

The check is presence-based (low false-positive). Reason *quality* is judged by
the human reviewer; CI only enforces that every deletion is acknowledged.

### 4.3 `scripts/setup-branch-protection.sh`

A `gh api` script the owner runs once to apply branch protection on `main`:
require a PR before merge, require the `verify` and `governance` status checks,
require 1 approving review, disallow force-pushes and direct pushes. Branch
protection is GitHub repo state, not a committable file — hence a script plus
documentation, not a workflow.

**Why this matches the requirement:** `verify` and `governance` are separate
required checks. The `override-deletion` label turns *only* `governance` green;
`verify` (the tests) must still pass independently. The owner can wave through a
justified structural deletion but never an unverified change.

## 5. Contribution documentation & templates

### 5.1 `.github/` files

- **`PULL_REQUEST_TEMPLATE.md`** — Summary; Type of change (checkboxes: new
  module / new addon / new sub-domain / new domain / core enhancement / bug fix
  / docs); a local checklist (`templates/tests/run.sh` passed locally; MODULE.md
  structure followed where applicable; agents least-privilege); and a
  **`## Deletions`** section — `None.` by default, otherwise one line per
  deleted file: `` `path` — reason — replacement (or "no replacement: why")``.
- **`ISSUE_TEMPLATE/`** — GitHub issue forms:
  - `bug_report.yml` — something in the templates/harness is broken or wrong.
  - `propose-content.yml` — propose a new module / addon / sub-domain / domain;
    structured fields incl. what it does and adopt-if / skip-if rationale.
  - `enhancement.yml` — improve the core or an existing unit.
  - `config.yml` — issue chooser; `blank_issues_enabled: false`.
- **`CODEOWNERS`** — `* @Camilool8` so every PR requests the owner's review.

### 5.2 Repo-root docs

- **`CONTRIBUTING.md`** — the canonical guide:
  - Orientation: the base / modules / addons / domain-pack model, linking to
    `docs/HARNESS_ENGINEERING.md`, `METHODOLOGIES.md`, `AGENT_ROLES.md`.
  - "Open an issue first" for new content (use `propose-content`).
  - **Step-by-step "how to add"** for each contribution type — a module, an
    addon, a sub-domain, a core enhancement — each pointing at the exact
    conventions (MODULE.md's standard sections, agent least-privilege + model
    routing, dossier `Verified:` header, the `files/` copy convention).
  - Running tests locally: `cd templates && ./tests/run.sh`, and individual
    `./tests/checks/*.sh`.
  - The deletion policy: rename freely; a deletion needs the `## Deletions`
    justification; the owner may apply `override-deletion`.
  - The PR lifecycle: fill the template → CI (`verify` + `governance`) must pass
    → CODEOWNERS review → merge.
- **`CODE_OF_CONDUCT.md`** — Contributor Covenant, standard text.
- **`SECURITY.md`** — how to privately report a security concern (the repo
  ships security-adjacent hooks and a `security` domain).

### 5.3 `README.md` update

Add a short **Contributing** section pointing to `CONTRIBUTING.md`, and a CI
status badge:
`![CI](https://github.com/Camilool8/harness-engineering-templates/actions/workflows/ci.yml/badge.svg)`.

## 6. Repo hygiene fixes

The only two items from the dead-code review:

1. Add a `> Status: ✓ Completed 2026-05-15` header to
   `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md` and
   `docs/superpowers/plans/2026-05-15-curated-domain-packs.md`, so their
   `- [ ]` checkboxes are not mistaken for open work.
2. Fix `templates/README.md` so it states clearly that the three-layer
   `DOMAIN.md` / sub-domain / `_addons/` structure currently applies **only to
   the `web` pack**; the other 11 domains remain v1 thin recipes.

## 7. Scope

**In scope (this spec's implementation plan):**

1. Restructure `templates/tests/` into the orchestrator + `checks/` + `lib/`
   auto-discovery engine (§3), preserving green status for all current units.
2. `.github/workflows/ci.yml` (§4.1).
3. `scripts/check-deletions.sh` and `scripts/setup-branch-protection.sh` (§4.2–4.3).
4. `.github/` PR template, issue forms, `CODEOWNERS` (§5.1).
5. `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, README update (§5.2–5.3).
6. The two hygiene fixes (§6).

**Out of scope:** applying GitHub branch-protection settings (the owner runs
`setup-branch-protection.sh` or sets them in the UI — not possible from a
committed file); GitHub Discussions setup; a CLA/DCO bot.

## 8. Success criteria / verification

- `templates/tests/run.sh` discovers and passes **every** existing unit — all
  cross-cutting modules, all web addons, all web sub-domains, all 11 thin
  recipes, the root manifest — with `Failed: 0`.
- A deliberately-added throwaway module directory is picked up by
  `assemble-coverage.sh` with no edit to any test file (then removed).
- `structure-lint.sh` flags a deliberately-malformed `MODULE.md` / an agent with
  `Edit` added to a reviewer / invalid JSON, and passes the clean repo.
- `hook-lint.sh` passes every current hook (`bash -n`; `shellcheck` at error
  severity).
- `check-deletions.sh`: fails an unjustified deletion; passes when the path is
  listed in `PR_BODY`; passes when `PR_LABELS` contains `override-deletion`.
- `ci.yml` is syntactically valid (well-formed YAML; `actionlint`-clean if
  available).
- `CONTRIBUTING.md` documents each contribution type with steps; all new docs
  exist and cross-references resolve.
- The two hygiene fixes are applied.

## 9. Risks & open questions

- **`shellcheck` on existing hooks.** If current hooks have `error`-severity
  findings, `hook-lint.sh` would fail. The plan runs `shellcheck` early; any
  genuine error-level finding in an existing hook is fixed as part of the work
  (the hooks are small). Lower-severity findings stay advisory.
- **Addon probe assembly.** Addons only assemble inside a domain-pack sub-domain
  directory. The coverage script writes a temporary gitignored `.probe.*`
  config into a web sub-domain folder; `.probe.*` is added to `.gitignore`.
- **CI history depth.** The `governance` job must check out with
  `fetch-depth: 0` so `git diff origin/main...HEAD` resolves.
- **Deletion-reason quality.** CI enforces only that each deleted path is
  acknowledged in the PR body; a low-effort reason is caught by the human
  reviewer, not CI. This is intentional — CI gates structure, humans gate
  judgment.
