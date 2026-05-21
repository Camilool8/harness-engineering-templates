# Reference: the test suite

The repo ships a deliberately small, hermetic test suite at [`templates/tests/`](../../templates/tests/). It runs offline, has no test dependencies, and finishes in under a minute on a laptop.

```bash
./templates/tests/run.sh
```

The final line is either `ALL CHECKS PASSED` or `N CHECK(S) FAILED`. The script's exit code mirrors the failure count.

---

## The three checks

| Check | What it asserts | Source |
|---|---|---|
| `structure-lint` | Every `MODULE.md`, `SUBDOMAIN.md`, agent file, and skill is shaped to the conventions. | [`tests/checks/structure-lint.sh`](../../templates/tests/checks/structure-lint.sh) |
| `hook-lint` | Every `*.sh` in the repo passes `bash -n`; passes `shellcheck -S error` when installed. | [`tests/checks/hook-lint.sh`](../../templates/tests/checks/hook-lint.sh) |
| `assemble-coverage` | Every thin recipe, every web sub-domain, every cross-cutting module, and every web addon assembles cleanly into a temp dir. | [`tests/checks/assemble-coverage.sh`](../../templates/tests/checks/assemble-coverage.sh) |

Run them individually when iterating:

```bash
./templates/tests/checks/structure-lint.sh
./templates/tests/checks/hook-lint.sh
./templates/tests/checks/assemble-coverage.sh
```

---

## `structure-lint`

Convention checks across the harness templates. Run as one check, but internally four passes:

### 1. `MODULE.md` standard sections

For every `MODULE.md` under `_modules/` and `web/`, asserts the file contains, in order:

- `# Module: <category>/<option>` title line.
- `> Config: <key>` reference line.
- `**What it does.**` bolded summary.
- `## Adopt if`, `## Skip if`, `## Dependencies`, `## Install (manual)`, `## Install (assemble.sh)`, `## Remove`, `## Files`.

Failure example:

```
✗ MODULE.md  templates/_modules/methodology/ddd/MODULE.md — [## Files]
```

Means the `## Files` section is missing. Add it; rerun.

### 2. Agent frontmatter + least-privilege

For every agent file under `_modules/**/agents/` and `web/**/agents/`:

- First line is `---` (YAML frontmatter open).
- Keys `name`, `description`, `tools`, `model` are present.
- Agents named `*-architect`, `*-auditor`, `*-reviewer`, `*-critic` **must not** declare `Edit` or `Write` in `tools`.

The least-privilege rule is the hard one. Reviewers must be read-only. If a critic needs to write a report, write to a designated draft surface — never the working tree.

### 3. `SUBDOMAIN.md` standard sections

For every `SUBDOMAIN.md` under `web/`:

- A first-line title (`# …`).
- `## Adopt if`, `## Skip if`, `## Addons that pair well`, `## Agent team` sections.

### 4. `SKILL.md` frontmatter

For every `SKILL.md` anywhere in the repo: opens with `---`, declares `name:` and `description:`.

### 5. Misc

Also checks `references.md` files carry the `> Verified: YYYY-MM` second-line header.

---

## `hook-lint`

Two passes over every `*.sh` file in the repo (excluding `.git/`):

### 1. `bash -n` (always runs)

Static parse. Any syntax error fails the check.

### 2. `shellcheck -S error` (when installed)

Runs `shellcheck` at error severity — i.e. warnings and style notes are *not* gates, but real bugs are. If `shellcheck` is not installed, the pass is skipped with a note; CI installs it automatically.

Install locally:

```bash
brew install shellcheck      # macOS
apt install shellcheck       # Debian/Ubuntu
dnf install shellcheck       # Fedora
```

Failure example:

```
✗ shellcheck  templates/_modules/safety/two-key/files/.claude/hooks/two-key-guard.sh
      In two-key-guard.sh line 12:
      if [ $token = "expected" ]; then
           ^----^ SC2086: Double quote to prevent globbing and word splitting.
```

The fix is usually quoting a variable. Don't ignore — exit-code-2 hooks that pass `shellcheck` are the basis of the harness's safety claims.

---

## `assemble-coverage`

The most important check. Discovers every assemblable unit on disk and assembles it into a temporary directory, then validates the output.

### What it discovers

- **Thin recipes**: every directory under `templates/<domain>/` with a `harness.config.yml` and no `DOMAIN.md` sibling.
- **Web sub-domains**: every directory under `templates/web/<sub>/` with a `harness.config.yml`.
- **Cross-cutting modules**: every directory under `templates/_modules/<cat>/<opt>/`. Each is assembled by copying the root manifest, flipping the one key that selects this module, and assembling.
- **Web addons**: every directory under `templates/web/_addons/<addon>/`. Assembled by using `web/frontend-app/harness.config.yml` with `domain.addons` set to just this addon.

### What it asserts per output

For every assembly:

- `.claude/settings.json` parses as JSON.
- `.mcp.json` parses as JSON.
- No leftover `.fragment.json` files (everything was merged).
- Every `.claude/hooks/*.sh` is executable.

### Bonus

A fixture exercises the `.mcp.json` deep-merge: it assembles `generic`, drops in a known-shape `.mcp.json.fragment`, runs the merge, and asserts the additional MCP server is present in the result.

### Why this matters

The check turns "new module on disk = new module under test" into a property of the directory layout. You do not edit the test when you add a module; you do not edit the test when you add a sub-domain; you do not edit the test when you add an addon. The test discovers them.

---

## Prerequisites

- `bash` 3.2+ (default on macOS and Linux)
- `jq` — required by `assemble.sh` for the deep-merge step. `brew install jq` / `apt install jq` / `dnf install jq`
- `shellcheck` — recommended; CI installs it. `brew install shellcheck` / `apt install shellcheck`

CI runs the same `./templates/tests/run.sh` script. There is no "CI-only" test — what you run locally is what merges.

---

## See also

- [`how-to/run-tests-locally.md`](../how-to/run-tests-locally.md) — practical walk-through of running the suite.
- [`how-to/add-a-module.md`](../how-to/add-a-module.md), [`add-an-addon.md`](../how-to/add-an-addon.md), [`add-a-subdomain.md`](../how-to/add-a-subdomain.md) — what the conventions enforced above look like in practice.
- [`reference/troubleshooting.md`](troubleshooting.md) — when a check fails and the message is unclear.
