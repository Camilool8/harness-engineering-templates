# How to add a module

A module is a cross-cutting opt-in capability under `templates/_modules/<category>/<option>/`. It applies regardless of domain — memory, progress tracking, methodology, orchestration, safety. Five categories total.

This guide walks you through adding a new module end-to-end: open the issue, create the directory, satisfy the structure check, submit the PR.

> **Two mirrored trees.** This repo maintains the content in two places that stay in sync: the `templates/` tree (the eject/assembler source) and the `plugins/harness-*/` tree (the marketplace). New cross-cutting content lands in `templates/_modules/` and in the corresponding location inside `plugins/harness-base/` so both stay aligned. Your change must pass **both** test suites before merge — `./templates/tests/run.sh` and `./plugins/tests/run-plugin-tests.sh`. The steps below cover the `templates/` shape; mirror the same content into the plugin and validate it in step 8.

---

## Step 1 — Open an issue first

Before investing time, open the **Propose new content** issue on the [issue tracker](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose). Describe:

- The category (`memory` / `progress-tracking` / `methodology` / `orchestration` / `safety`).
- The proposed option name (kebab-case, e.g. `ddd`, `kanban`, `bft`).
- The capability in one paragraph.
- The adopt-if / skip-if reasoning.

Wait for a maintainer thumbs-up before writing the PR. This step costs you nothing and saves you from rewriting against feedback.

---

## Step 2 — Choose the category and name

| Category | Options that already exist | Add when… |
|---|---|---|
| `memory` | `md-files`, `vector-store`, `knowledge-graph` | The capability changes where durable knowledge lives. |
| `progress-tracking` | `filesystem`, `github-issues`, `linear`, `jira` | The capability changes where work items live. |
| `methodology` | `tdd`, `spec-driven`, `eval-driven`, `bdd` | The capability mechanically enforces an engineering discipline. |
| `orchestration` | `supervisor-worker`, `pipeline`, `blackboard` | The capability changes the agent topology. |
| `safety` | `two-key`, `kill-switch`, `sandbox` | The capability adds an irreversible-action gate. |

If the capability does not fit any of these five, it is probably not a module. It might be:

- A domain-scoped extra → that is an **[addon](add-an-addon.md)**.
- A new domain → that is a [whole-domain contribution](add-a-subdomain.md).
- A standalone skill → drop a `SKILL.md` under `_base/.claude/skills/` instead.

---

## Step 3 — Create the directory

```bash
mkdir -p templates/_modules/<category>/<option>/files/.claude
cd templates/_modules/<category>/<option>
```

Every module ships exactly three things:

```
MODULE.md         human-readable adopt-if/skip-if/install/remove guide
claude-md.md      fragment appended to the project's CLAUDE.md when installed
files/            tree copied verbatim into the project
```

---

## Step 4 — Write `MODULE.md`

`MODULE.md` is the contract. The [`structure-lint`](../reference/tests.md#structure-lint) check enforces these sections, in order:

```markdown
# Module: <category>/<option>

> Config: <config-key> · Depends on: <other-modules-or-"none">

**What it does.** Two to four sentences. State the capability concretely — what hook fires, what skill teaches, what changes about the agent's behaviour.

## Adopt if
- Bullet list. When does this module pay off?

## Skip if
- Bullet list. When is it wrong, unnecessary, or actively harmful?

## Dependencies
- Runtime tools (e.g. `jq`, a test runner), other modules that must also be on, MCP servers required. Write `None.` if empty.

## Install (manual)
1. Numbered steps. Copy files, append `claude-md.md` to `CLAUDE.md`, `chmod` hooks, register settings entries.

## Install (assemble.sh)
Set `<config-key>: true` (or the relevant value) in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `<files>`. Delete the `## <Section>` from `CLAUDE.md`. Drop the `<hook>` entry from `.claude/settings.json`.

## Files
- `files/.claude/hooks/<name>.sh` — what this hook does, on which event, with what matcher.
- `files/.claude/skills/<name>/SKILL.md` — what this skill teaches.
- `files/.claude/settings.fragment.json` — settings entries `assemble.sh` deep-merges.
```

Use [`_modules/methodology/tdd/MODULE.md`](../../templates/_modules/methodology/tdd/MODULE.md) as the canonical reference.

---

## Step 5 — Write `claude-md.md`

A Markdown fragment that `assemble.sh` appends to the project's `CLAUDE.md`. Must start with a `## <Section heading>`. Keep it concise — the agent reads `CLAUDE.md` on every turn, so each module's contribution is paid for in context cost on every prompt.

Good template:

```markdown
## <Capability name>

<One sentence: what the agent does differently with this module installed.>

<Two to four bullets of operational rules — the kind a reviewer would otherwise have to enforce by hand.>
```

Bad: a wall of text explaining the philosophy. The agent already has a context window full of philosophy; what it needs from a `claude-md.md` is *behaviour*.

---

## Step 6 — Add the `files/` tree

Mirror the target layout. Examples:

- A new hook: `files/.claude/hooks/<name>.sh`. Make it executable (`chmod +x` before `git add`).
- A new skill: `files/.claude/skills/<skill-name>/SKILL.md`. Open with YAML frontmatter declaring `name:` and `description:`.
- New settings entries: `files/.claude/settings.fragment.json`. Must be valid JSON. The deep-merge concatenates arrays and recurses into objects.

The fragment for a `PreToolUse` hook looks like:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.sh" }
        ]
      }
    ]
  }
}
```

Use `${CLAUDE_PROJECT_DIR}` so paths are project-rooted, not user-rooted.

---

## Step 7 — Register the config key (if new)

If your module is a new boolean (`methodology.<key>`) or a new value for an existing key (`memory.backend: <option>`), update `templates/assemble.sh`'s `--- map config → modules` block so the key actually selects your module.

For a new boolean methodology:

```bash
[ "$(cfg methodology.ddd)" = "true" ] && install_module "methodology/ddd"
```

For a new memory backend, no code change is needed — the existing line installs `memory/<backend>` for any value other than `none`.

Also add the key to the reference manifest `templates/harness.config.yml` with a comment.

---

## Step 8 — Mirror into the plugin tree and run both test suites

Mirror the same module content into `plugins/harness-base/` so the marketplace stays in sync with the eject tree, then run both suites:

```bash
./templates/tests/run.sh              # eject tree
./plugins/tests/run-plugin-tests.sh   # marketplace tree
```

Expected last lines: `ALL CHECKS PASSED` and `ALL PLUGIN CHECKS PASSED`. The `assemble-coverage` check discovers your new module automatically and assembles it — no test edit required. The plugin suite runs `claude plugin validate --strict` against `harness-base` plus the convention lint.

If `structure-lint` fails, the message tells you which `MODULE.md` section is missing. Fix and rerun.

If `hook-lint` fails on your new shell script, fix the syntax / shellcheck error.

If `assemble-coverage` fails, your fragment may not deep-merge cleanly, or a hook may not be executable. See [`troubleshooting.md`](../reference/troubleshooting.md#tests).

If the plugin suite fails, the `claude plugin validate --strict` output names the offending manifest field or path — fix the plugin mirror so it matches the `templates/` content.

---

## Step 9 — Update the catalog

Add a row for your module in [`docs/reference/modules.md`](../reference/modules.md). One line, one-liner description, link to your `MODULE.md`.

If your module changes a config default, also update [`docs/reference/harness-config.md`](../reference/harness-config.md).

---

## Step 10 — Open the PR

Follow [`tutorials/your-first-contribution.md`](../tutorials/your-first-contribution.md) for the PR workflow. The PR template's **Type of change** checkbox is **New module**. Fill the deletions section with `None.` unless you also deleted something.

The reviewer will check:

- `MODULE.md` is shaped correctly (structure-lint already enforces this).
- `claude-md.md` is concise and behaviour-focused.
- The `files/` tree is least-privilege and shellcheck-clean.
- The new module pulls its weight — there is a real adopt-if case, not just an "in case anyone wants it".

---

## See also

- [`reference/modules.md`](../reference/modules.md) — current catalog.
- [`reference/tests.md`](../reference/tests.md) — what the structure check enforces.
- [`add-an-addon.md`](add-an-addon.md) — for domain-scoped extras (different shape, different rules).
- [`add-a-subdomain.md`](add-a-subdomain.md) — for new web sub-domains.
- The canonical reference: [`_modules/methodology/tdd/`](../../templates/_modules/methodology/tdd/).
