# Contributing to harness-engineering-templates

This repository is a public library of opinionated Claude Code harness templates
spanning eleven engineering domains — web, data, DevOps, finance, mobile, game,
embedded, scientific, security, content, and ops. Contributions of new modules,
addons, sub-domains, and whole domains are welcome. The goal of every contribution
is the same as the repo itself: make the harness — not the agent — the contract,
so that any engineer can drop a template into their project and get a principled,
safe, well-structured Claude Code setup on day one.

---

## How it fits together

The template system has four layers:

1. **`_base/`** — the universal starter that every assembled project copies. It
   sets up the foundational `.claude/` structure: `settings.json`, `CLAUDE.md`,
   and the hooks and skills that belong in every harness regardless of domain.

2. **`templates/_modules/<category>/<option>/`** — cross-cutting opt-in modules
   that address concerns shared across all domains: where memory lives, how
   progress is tracked, which development methodology is enforced, which
   orchestration topology is used, and which safety gates are in place. Each
   module ships an `adopt-if / skip-if / install / remove` decision guide.

3. **Domain packs** — a domain pack like `templates/web/` bundles a
   `DOMAIN.md`, multiple sub-domains (`templates/web/<sub-domain>/`), and
   domain-specific addons (`templates/web/_addons/<addon>/`). The 11 non-web
   domains are currently v1 thin recipes — a single `harness.config.yml` plus
   a `files/` tree — pending curation into full packs.

4. **`assemble.sh`** — the one-command assembler. It reads a
   `harness.config.yml` manifest, merges `_base/`, selected modules, a
   domain-specific layer, and any addons, and writes a ready-to-use project
   directory. No external dependencies beyond `jq` and `bash`.

The deep reference documents are:
- [`docs/HARNESS_ENGINEERING.md`](docs/HARNESS_ENGINEERING.md) — foundations,
  per-domain template guidance, cross-cutting concerns, universal anti-patterns.
- [`docs/METHODOLOGIES.md`](docs/METHODOLOGIES.md) — SDD, TDD, BDD, ATDD, DDD,
  Agile, Waterfall, Lean, DevOps/SRE, eval-driven development, and more — each
  adapted to AI harnesses.
- [`docs/AGENT_ROLES.md`](docs/AGENT_ROLES.md) — single-agent baseline,
  multi-agent topologies, the canonical role catalog, sub-agent design principles.
- [`templates/README.md`](templates/README.md) — the assembly guide and
  pick/discard decision table.

---

## Before you start

Open an issue first using the
[**Propose new content**](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose)
template. Describe what you want to add, what it does, and the adopt-if / skip-if
reasoning. Wait for a maintainer thumbs-up before investing time in a large PR.
For small fixes — a typo, a broken link, a shellcheck error — you can go straight
to a PR.

---

## Adding a module

A module lives at `templates/_modules/<category>/<option>/`. The five categories
and their existing options are:

| Category | Options |
|---|---|
| `memory` | `md-files`, `vector-store`, `knowledge-graph` |
| `progress-tracking` | `filesystem`, `github-issues`, `linear`, `jira` |
| `methodology` | `tdd`, `spec-driven`, `eval-driven`, `bdd` |
| `orchestration` | `supervisor-worker`, `pipeline`, `blackboard` |
| `safety` | `two-key`, `kill-switch`, `sandbox` |

Every module directory must contain exactly three things:

1. **`MODULE.md`** — the human-readable decision guide. It must include all of
   the following sections in this order:
   - `# Module: <category>/<option>` — the title line.
   - `> Config: <config-key>` — a config reference line immediately below the title.
   - `**What it does.**` — a bold paragraph (two to four sentences) describing
     the capability.
   - `## Adopt if` — bulleted list of when to turn this module on.
   - `## Skip if` — bulleted list of when to leave it off.
   - `## Dependencies` — runtime or tooling requirements (write "None." if empty).
   - `## Install (manual)` — step-by-step instructions for a human copying files.
   - `## Install (assemble.sh)` — the one-liner config key to set and the
     `assemble.sh` command.
   - `## Remove` — what to delete and undo when discarding the module.
   - `## Files` — a bulleted inventory of every file in `files/` and what it does.

   See [`templates/_modules/methodology/tdd/MODULE.md`](templates/_modules/methodology/tdd/MODULE.md)
   for a complete worked example.

2. **`claude-md.md`** — a Markdown fragment that `assemble.sh` appends to the
   project's `CLAUDE.md`. It must start with a `## <Section heading>` line that
   names the capability. Keep it concise: the agent reads this on every turn.

3. **`files/`** — the files that get copied verbatim into the assembled project,
   preserving the directory structure under `files/` as-is. A typical module
   drops hooks under `.claude/hooks/` and skills under `.claude/skills/`, along
   with a `.claude/settings.fragment.json` that `assemble.sh` deep-merges into
   `.claude/settings.json`.

Once the directory exists, the test engine discovers it automatically — no test
edit required.

---

## Adding an addon

An addon lives at `templates/web/_addons/<addon>/` and follows the same shape as
a module: `MODULE.md` (same required sections), `claude-md.md`, and `files/`.
Addons are domain-scoped extras — they are optional integrations layered on top
of a sub-domain, not universal concerns.

See [`templates/web/_addons/nextjs/`](templates/web/_addons/nextjs/) for a
complete worked example.

To register a new addon so `assemble.sh` can include it, add its name to the
`domain.addons` list in the relevant sub-domain's `harness.config.yml` (or in a
consumer's own config). The test engine discovers all addon directories under
`web/_addons/` automatically.

---

## Adding a sub-domain

A sub-domain lives at `templates/web/<sub-domain>/` and represents a distinct
deliverable shape within the web domain — for example, `frontend-app`,
`fullstack-app`, `api-service`, or `design-system`.

A sub-domain directory must contain:

- **`SUBDOMAIN.md`** — a human-readable guide describing the sub-domain's
  purpose, the agent team it installs, and the addons it recommends.
- **`harness.config.yml`** — the config manifest that drives `assemble.sh` for
  this sub-domain. It specifies the base modules, the domain, and the default
  addon set.
- **`references.md`** — a dossier of tools, frameworks, and practices this
  sub-domain relies on. It **must** carry a `> Verified: YYYY-MM` header on the
  second line — the structure-lint check enforces this.
- **`claude-md.md`** — the sub-domain-specific `CLAUDE.md` fragment.
- **`files/.claude/{agents,skills,hooks}/`** — the agent team and supporting
  hooks and skills for this deliverable type.

**Agent least-privilege rule:** architects, auditors, reviewers, and critics
must be read-only. Their agent files must not list `Edit` or `Write` in the
`tools:` frontmatter key. Only implementers and testers may have `Edit`/`Write`.
The `structure-lint` check enforces this automatically.

See [`templates/web/frontend-app/`](templates/web/frontend-app/) for a complete
worked example.

---

## Enhancing the core

The core consists of `templates/_base/`, `templates/assemble.sh`, the
`harness.config.yml` schema, and `templates/tests/`. These components affect
every assembled project and every consumer of this library. Changes here receive
extra review scrutiny. Concretely:

- **`_base/`** changes must remain backward-compatible with all 11 existing
  recipes and the web domain pack. If a change would require every recipe to
  update its config, that is a breaking change and requires discussion.
- **`assemble.sh`** changes must keep the existing merge semantics for
  `settings.json`, `.mcp.json`, and `CLAUDE.md`. Run the full test suite before
  and after any change.
- **Test engine changes** (under `templates/tests/`) must not reduce coverage.
  Adding a new check is welcome; tightening an existing check is welcome;
  silencing or removing a check requires a very clear justification in the PR.

---

## Running the checks locally

The test suite runs entirely locally with no network access:

```bash
./templates/tests/run.sh
```

This runs every check under `templates/tests/checks/` and prints a combined
summary. The final line is either `ALL CHECKS PASSED` or `N CHECK(S) FAILED`.
Exit code mirrors the failure count.

Individual checks can also be run standalone — useful when iterating on a
specific concern:

```bash
templates/tests/checks/structure-lint.sh    # MODULE.md sections, agents, skills, JSON
templates/tests/checks/hook-lint.sh         # bash -n + shellcheck on every *.sh
templates/tests/checks/assemble-coverage.sh # assembles every unit discovered on disk
```

**Prerequisites:** `jq` must be installed (`brew install jq` / `apt install jq`).
`shellcheck` is recommended and is installed automatically in CI
(`brew install shellcheck` / `apt install shellcheck`). Without `shellcheck`, the
hook-lint check skips the shellcheck pass but still runs `bash -n`.

---

## The deletion policy

**Renaming a file is always fine.** Git records it as a rename; the CI
governance check passes automatically.

**Deleting a file requires justification.** For each file your PR deletes, add
an entry in the PR body's `## Deletions` section:

```
`path/to/deleted/file` — reason — replaced by `path/to/new` (or "no replacement: reason")
```

The CI `governance` job runs `scripts/check-deletions.sh` on every PR and fails
if any deleted path is not mentioned in the PR description. A maintainer can
apply the **`override-deletion`** label to waive the justification requirement —
for example, if a file is being removed as part of a well-understood cleanup.

Regardless of the label, the `verify` job (which runs `./templates/tests/run.sh`)
always has to pass. There is no override for test failures.

---

## PR lifecycle

1. **Fork and branch.** Work on a branch named for the change
   (`add-module-methodology-ddd`, `fix-hook-lint-error`, etc.).
2. **Fill the PR template.** The template prompts for a summary, a type-of-change
   checkbox, the standard checklist, and the deletions section. Fill it out.
3. **CI runs automatically.** Two jobs run on every PR:
   - **`verify`** — runs `./templates/tests/run.sh`; must be green.
   - **`governance`** — runs the deletion-policy check; must be green or waived
     by the `override-deletion` label.
4. **CODEOWNERS review.** `@Camilool8` is automatically requested as a reviewer.
   The branch-protection rule requires at least one approving review from a code
   owner before merge.
5. **Squash-merge.** The maintainer squash-merges the PR. Both `verify` and
   `governance` must be green (or `governance` waived) before merge is allowed.

---

## Code of Conduct

All participants in this project are expected to follow the
[Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.
