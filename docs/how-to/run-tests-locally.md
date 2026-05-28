# How to run the tests locally

The repo maintains **two mirrored trees** — the `templates/` tree (the eject/assembler source) and the `plugins/harness-*/` tree (the marketplace) — and ships a deliberately small, offline test suite for each. Both run in CI on every PR. Run both before pushing:

```bash
./templates/tests/run.sh              # the eject/assembler tree
./plugins/tests/run-plugin-tests.sh   # the marketplace tree
```

Each finishes with a summary line:

| Suite | Pass line | Fail line |
|---|---|---|
| `templates/tests/run.sh` | `ALL CHECKS PASSED` | `N CHECK(S) FAILED` |
| `plugins/tests/run-plugin-tests.sh` | `ALL PLUGIN CHECKS PASSED` | `N PLUGIN CHECK(S) FAILED` |

Each exit code mirrors its failure count.

### What each suite gates

- **`./templates/tests/run.sh`** — three checks over the `templates/` tree: `structure-lint` (MODULE/SUBDOMAIN/agent/skill shape), `hook-lint` (`bash -n` + `shellcheck` on every `*.sh`), and `assemble-coverage` (assembles every unit on disk and validates the output). Detailed below.
- **`./plugins/tests/run-plugin-tests.sh`** — runs `claude plugin validate --strict` against each `plugins/harness-*/` plugin, then `plugins/tests/lint-conventions.sh` (the Harness convention lint). If the `claude` CLI is not installed locally the validate step skips with a notice; CI installs the CLI so it always runs there.

Because content is mirrored across both trees, a domain change must pass **both** suites before merge.

---

## Prerequisites

| Tool | Required? | Install |
|---|---|---|
| `bash` 3.2+ | Yes | Default on macOS and Linux. |
| `jq` | Yes | `brew install jq` / `apt install jq` / `dnf install jq`. |
| `shellcheck` | Recommended | `brew install shellcheck` / `apt install shellcheck`. Without it, `hook-lint` skips the shellcheck pass but still runs `bash -n`. CI installs it automatically. |
| `claude` CLI | Recommended | [Claude Code](https://docs.claude.com/en/docs/agents-and-tools/claude-code/overview). Used by the plugin suite for `claude plugin validate --strict`. Without it that step skips locally; CI always runs it. |

No language runtimes, no Docker, no network. Both suites run in a few seconds on a laptop.

---

## Run the whole suite

From the repo root, run both:

```bash
./templates/tests/run.sh
./plugins/tests/run-plugin-tests.sh
```

`templates/tests/run.sh` prints a sequence of `✓` / `✗` lines per check then a summary; the plugin runner prints each plugin's `validate` output then the convention-lint result. Both scripts are safe to interrupt; they do nothing irreversible.

---

## Run a single check

When iterating on one concern in the eject tree, run that check in isolation:

```bash
./templates/tests/checks/structure-lint.sh
./templates/tests/checks/hook-lint.sh
./templates/tests/checks/assemble-coverage.sh
```

Each prints its own pass / fail summary. The same script is what `run.sh` runs. The plugin runner has no per-check split — run `./plugins/tests/run-plugin-tests.sh` as a whole, or `bash plugins/tests/lint-conventions.sh` for just the convention lint.

---

## Which check to run when

| You changed… | Run first | Why |
|---|---|---|
| A `MODULE.md`, `SUBDOMAIN.md`, agent file, or `SKILL.md` under `templates/` | `structure-lint` | Catches missing sections, missing frontmatter, least-privilege violations. |
| Any `*.sh` file under `templates/` | `hook-lint` | `bash -n` + `shellcheck` at error severity. |
| A `harness.config.yml`, a module's `files/`, an addon, or `assemble.sh` | `assemble-coverage` | Assembles every affected unit and validates the output tree. |
| Anything under `plugins/harness-*/` | `./plugins/tests/run-plugin-tests.sh` | `claude plugin validate --strict` per plugin plus the convention lint. |
| A new module / addon / sub-domain (it lives in **both** trees) | all of `templates/tests/run.sh` **and** `plugins/tests/run-plugin-tests.sh` | The new unit is discovered automatically in each tree; you do not edit any test. |

---

## Reproducing CI

CI runs three jobs on every PR:

- **`verify`** runs the same `./templates/tests/run.sh` script over the eject tree.
- **`plugins`** lints every `plugins/` shell script (`bash -n` + `shellcheck -S error`) and then runs `./plugins/tests/run-plugin-tests.sh` over the marketplace tree.
- **`governance`** runs `scripts/check-deletions.sh` on the PR diff against `main`.

To reproduce `governance` locally for a PR that deletes files:

```bash
./scripts/check-deletions.sh
```

The script reads your PR description from a file path (in CI, GitHub's event payload). Locally, set `PR_BODY_FILE` to a file containing your draft PR description:

```bash
PR_BODY_FILE=/tmp/pr-body.md ./scripts/check-deletions.sh
```

---

## When a check fails

The failing line includes the path and the problem:

```
✗ MODULE.md  templates/_modules/methodology/ddd/MODULE.md — [## Files]
✗ shellcheck  templates/_modules/safety/two-key/files/.claude/hooks/two-key-guard.sh
✗ assemble:module:methodology/ddd — settings.json invalid
```

Cross-reference the symptom in [`reference/troubleshooting.md`](../reference/troubleshooting.md#tests).

The fix loop is:

1. Read the failing message.
2. Make the smallest change that addresses it.
3. Re-run *just that check* (not the whole suite).
4. When green, re-run the whole suite once before pushing — and the plugin suite too if you touched a `plugins/harness-*/` mirror.

Do **not** disable a check or work around it. Tightening a check is welcome; silencing one requires a very clear PR justification.

---

## Cleaning up after failed runs

`assemble-coverage` writes to `mktemp -d` directories and cleans them up itself. If you Ctrl-C mid-run, you may find orphans under `$TMPDIR`. They are safe to delete:

```bash
# macOS
ls $TMPDIR | grep -E '^tmp\.' | xargs -I{} rm -rf "$TMPDIR/{}"
# Linux
find /tmp -maxdepth 1 -name 'tmp.*' -user "$USER" -delete
```

The repo itself is never modified by the test suite — assembly always writes to a temporary directory.

---

## See also

- [`reference/tests.md`](../reference/tests.md) — what each eject-tree check asserts in detail.
- [`reference/plugins.md`](../reference/plugins.md) — the marketplace the plugin suite validates.
- [`reference/troubleshooting.md`](../reference/troubleshooting.md#tests) — diagnosing specific failures.
- [`tutorials/your-first-contribution.md`](../tutorials/your-first-contribution.md) — where running the tests fits in the PR workflow.
