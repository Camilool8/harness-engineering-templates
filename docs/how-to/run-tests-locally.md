# How to run the tests locally

The repo ships a deliberately small, offline test suite. You should run it before every PR; CI runs the exact same script.

```bash
./templates/tests/run.sh
```

The final line is either:

```
ALL CHECKS PASSED
```

or:

```
N CHECK(S) FAILED
```

Exit code mirrors the failure count.

---

## Prerequisites

| Tool | Required? | Install |
|---|---|---|
| `bash` 3.2+ | Yes | Default on macOS and Linux. |
| `jq` | Yes | `brew install jq` / `apt install jq` / `dnf install jq`. |
| `shellcheck` | Recommended | `brew install shellcheck` / `apt install shellcheck`. Without it, `hook-lint` skips the shellcheck pass but still runs `bash -n`. CI installs it automatically. |

No language runtimes, no Docker, no network. The entire suite runs in a few seconds on a laptop.

---

## Run the whole suite

From the repo root:

```bash
./templates/tests/run.sh
```

Output is a sequence of `✓` / `✗` lines per check, then a summary. The script is safe to interrupt; it does nothing irreversible.

---

## Run a single check

When iterating on one concern, run that check in isolation:

```bash
./templates/tests/checks/structure-lint.sh
./templates/tests/checks/hook-lint.sh
./templates/tests/checks/assemble-coverage.sh
```

Each prints its own pass / fail summary. The same script is what `run.sh` runs.

---

## Which check to run when

| You changed… | Run first | Why |
|---|---|---|
| A `MODULE.md`, `SUBDOMAIN.md`, agent file, or `SKILL.md` | `structure-lint` | Catches missing sections, missing frontmatter, least-privilege violations. |
| Any `*.sh` file | `hook-lint` | `bash -n` + `shellcheck` at error severity. |
| A `harness.config.yml`, a module's `files/`, an addon, or `assemble.sh` | `assemble-coverage` | Assembles every affected unit and validates the output tree. |
| A new module / addon / sub-domain directory | All three | The new unit is discovered automatically; you do not edit any test. |

---

## Reproducing CI

CI runs the same `./templates/tests/run.sh` script in the `verify` job. The `governance` job is separate — it runs `scripts/check-deletions.sh` on the PR diff against `main`.

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
4. When green, re-run the whole suite once before pushing.

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

- [`reference/tests.md`](../reference/tests.md) — what each check asserts in detail.
- [`reference/troubleshooting.md`](../reference/troubleshooting.md#tests) — diagnosing specific failures.
- [`tutorials/your-first-contribution.md`](../tutorials/your-first-contribution.md) — where running the tests fits in the PR workflow.
