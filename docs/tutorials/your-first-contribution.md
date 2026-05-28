# Your first contribution

This tutorial walks a new contributor through their first merged PR. The change we will make is intentionally tiny — a one-line fix to a domain README — so the lesson is about the *process*, not the *content*.

By the end, you will have:

1. Forked the repo and created a working branch.
2. Made a one-line change.
3. Run the test suite locally.
4. Opened a PR that passes both CI jobs.

If you are contributing something larger (a new module, addon, or sub-domain), do this tutorial first to learn the workflow, then read the relevant [how-to guide](../how-to/) for the substance.

---

## Before you start

You need:

- A GitHub account.
- `git`, `bash`, `jq` installed locally.
- A clone of *your fork* of the repo (we cover this below).

`shellcheck` is recommended (`brew install shellcheck` / `apt install shellcheck`). Without it, the `hook-lint` check skips the shellcheck pass but still runs `bash -n`.

---

## Step 1 — Fork and clone

Click **Fork** on [the repo](https://github.com/Camilool8/harness-engineering-templates) on GitHub. Then clone *your fork*:

```bash
git clone https://github.com/<your-username>/harness-engineering-templates.git
cd harness-engineering-templates
```

Add the upstream remote so you can pull changes later:

```bash
git remote add upstream https://github.com/Camilool8/harness-engineering-templates.git
```

---

## Step 2 — Create a branch

Branch off `main` with a name that describes the change:

```bash
git checkout -b docs-typo-fix-getting-started
```

The branch name will become part of the PR URL; keep it short and descriptive.

---

## Step 3 — Make the change

For this tutorial, pick *any* user-facing README and fix something tiny — a typo, a broken-looking sentence, an unclear word. Good candidates:

- `templates/web/DOMAIN.md`
- `templates/data/DOMAIN.md`
- `docs/tutorials/getting-started.md`

If you cannot find a typo, add a single missing serial comma or rephrase an awkward sentence. The exercise is the workflow, not the prose.

Save the file. Confirm only one file changed:

```bash
git status
git diff
```

---

## Step 4 — Run the tests locally

The repository ships a test suite that runs entirely offline:

```bash
./templates/tests/run.sh
```

Expected last line:

```
ALL CHECKS PASSED
```

If a check fails, read its output, fix the issue, and rerun. See [`how-to/run-tests-locally.md`](../how-to/run-tests-locally.md) for the catalog of individual checks and what they assert.

For a documentation-only change to a README that is not under `templates/_modules/`, `templates/web/_addons/`, or `templates/web/<sub-domain>/`, the structure-lint check does not apply — all three checks should pass trivially.

---

## Step 5 — Commit

Stage the file and commit:

```bash
git add templates/web/DOMAIN.md
git commit -m "docs: tighten one sentence in the web DOMAIN.md"
```

Use a conventional-style prefix (`docs:`, `fix:`, `feat:`, `ci:`, `test:`) so the commit history stays scannable. The repo's existing commit log is the style reference.

---

## Step 6 — Push and open the PR

Push your branch to your fork:

```bash
git push -u origin docs-typo-fix-getting-started
```

GitHub prints a URL — open it. The PR template loads with four sections:

- **Summary** — fill in one or two sentences. For this change: *"Fixes a typo in `templates/web/DOMAIN.md`."*
- **Type of change** — check **Documentation**.
- **Checklist** — tick the items that apply. For docs-only changes, the agent/dossier items are not relevant; the `tests/run.sh` item is.
- **Deletions** — leave `None.` (this PR deletes nothing).

Submit the PR.

---

## Step 7 — Watch CI

Two jobs run on every PR:

- **verify** — runs `./templates/tests/run.sh`. Must be green.
- **governance** — runs `scripts/check-deletions.sh`. Must be green or waived with the `override-deletion` label.

CI usually finishes in under two minutes. If either job fails, the PR page links to the run log. Read it, push a fix to the same branch, and CI re-runs automatically.

---

## Step 8 — Address review

`@Camilool8` is auto-requested as reviewer via `CODEOWNERS`. Branch protection requires one approving review from a code owner before merge.

Respond to comments by pushing additional commits to the same branch — the PR updates in place. Once approved, the maintainer squash-merges.

---

## What you learned

- The repo's branch-name convention.
- How to run tests locally before pushing.
- How to fill the PR template, including the deletions section.
- The two CI jobs and what each enforces.

You are now ready for larger contributions. The relevant how-tos:

- [`how-to/add-a-module.md`](../how-to/add-a-module.md) — a new cross-cutting opt-in module.
- [`how-to/add-an-addon.md`](../how-to/add-an-addon.md) — a new web-domain extra.
- [`how-to/add-a-subdomain.md`](../how-to/add-a-subdomain.md) — a new web-domain sub-domain.

For policy and conventions, see [`CONTRIBUTING.md`](../../CONTRIBUTING.md) and [`CODE_OF_CONDUCT.md`](../../CODE_OF_CONDUCT.md) in the repo root.
