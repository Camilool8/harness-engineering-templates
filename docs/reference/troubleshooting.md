# Reference: troubleshooting

Common stumbles when assembling, testing, or running the harness. Each entry is a symptom → cause → fix.

---

## Assembly

### `! jq not found — settings.fragment.json left for manual merge`

**Cause.** `jq` is not on `PATH`. `assemble.sh` falls back to leaving fragment files in place and printing a warning.

**Fix.** Install `jq`, then either re-run `assemble.sh` against a fresh target or merge fragments by hand:

```bash
brew install jq         # macOS
apt install jq          # Debian / Ubuntu
dnf install jq          # Fedora
```

```bash
# manual merge — repeat for each fragment
jq -s '
  def deepmerge($a;$b): reduce ($b|keys_unsorted[]) as $k ($a;
    if (($a[$k]|type)=="object") and (($b[$k]|type)=="object") then .[$k]=deepmerge($a[$k];$b[$k])
    elif (($a[$k]|type)=="array") and (($b[$k]|type)=="array") then .[$k]=($a[$k]+$b[$k])
    else .[$k]=$b[$k] end);
  deepmerge(.[0];.[1])' \
  .claude/settings.json .claude/settings.fragment.json \
  > .claude/settings.json.new && mv .claude/settings.json.new .claude/settings.json && rm .claude/settings.fragment.json
```

### `config not found: <path>`

**Cause.** The first argument to `assemble.sh` does not resolve to a file.

**Fix.** Use the full path. The path is relative to your shell's current directory, not to `templates/`:

```bash
# from the repo root
./templates/assemble.sh templates/web/frontend-app/harness.config.yml ./my-project
```

### `! addon not found: <name> (skipped)`

**Cause.** The `domain.addons` list references an addon directory that does not exist under `templates/<domain>/_addons/`.

**Fix.** Check the spelling against [`reference/domains.md`](domains.md). For the `web/` pack, see [`templates/web/_addons/`](../../templates/web/_addons/). Addons are only loaded when the config is a sub-domain config (its directory has a `DOMAIN.md` sibling).

### `! agent not found: <path> (skipped)`

**Cause.** `agents.include` references an agent file that does not exist. The expected path is `templates/<domain>/<subdomain>/files/.claude/agents/<agent>.md`.

**Fix.** Browse the source sub-domain's `files/.claude/agents/` to confirm the agent name. The `agents.include` list takes basenames without `.md`.

### A module I set in the config did not install

**Cause.** Misspelt key, wrong indentation, or value type.

The YAML parser is deliberately small ([details](harness-config.md#parser-notes)). Misspelt keys are silently ignored.

**Fix.** Diff your config against the canonical [`templates/harness.config.yml`](../../templates/harness.config.yml). Run `./templates/tests/run.sh` after editing — if your config is in a recipe directory, `assemble-coverage` will assemble it and catch parse drift.

### Output looks wrong but `assemble.sh` exited 0

**Cause.** `assemble.sh` exits 0 even when addons are skipped or `jq` is missing. The script reports problems to stderr but does not fail on them.

**Fix.** Re-run with stderr captured and inspect the warnings:

```bash
./templates/assemble.sh <config> <target> 2>assemble.log
grep '^!' assemble.log
```

---

## Running Claude Code

### A hook does not fire

**Cause 1.** The hook is not executable. `assemble.sh` runs `chmod +x` on every `*.sh` in `.claude/hooks/` at the end, but if you copied `_base/` by hand, you must do this yourself:

```bash
chmod +x .claude/hooks/*.sh
```

**Cause 2.** The hook is not registered in `.claude/settings.json`. The base hooks come from `_base/.claude/settings.json` and are wired automatically. Module hooks come from `settings.fragment.json` files merged at assembly time. If a module's fragment was left un-merged (`jq` missing), the hook is on disk but not wired.

**Fix.** Inspect `.claude/settings.json` and confirm an entry under the appropriate `hooks.<event>` array. If absent, re-run the merge (above) or copy the entry by hand.

### `command-guard.sh` blocks a command I actually need

**Cause.** The guard is a coarse pattern-match: `rm -rf`, force-push, `git reset --hard`, raw `DROP/TRUNCATE`, and similar. Some legitimate commands match these patterns.

**Fix.** Two options, in order of preference:

1. **Reformulate the command.** A surprisingly large fraction of "blocked" commands have a safer equivalent — `git restore --staged` instead of `git reset`, `rm <specific paths>` instead of `rm -rf`, a reviewed migration PR instead of raw `DROP`.
2. **Tighten or relax the guard locally.** Edit `.claude/hooks/command-guard.sh` for your project. Do *not* edit the upstream `_base` version.

If the guard is wrong in a way that affects many projects, open an issue.

### `verify-gate.sh` keeps re-running the session

**Cause.** The Stop-event verify gate runs `./.claude/verify.sh`. If `verify.sh` exits non-zero (or does not exist where the agent expects it), the gate refuses to let the session end and the agent keeps working.

**Fix.** Confirm `./.claude/verify.sh` exists and is executable. Copy from `.claude/verify.sh.example` if not. Fill in real commands for your project (lint, typecheck, tests). If you want to disable the gate temporarily for a spike, point `verify.sh` to `exit 0` — but understand the trade.

### `audit.jsonl` is growing without bound

**Cause.** The audit log is append-only by design (see [non-negotiables](../explanation/non-negotiables.md)). It is *not* rotated automatically.

**Fix.** Rotate or archive on your own schedule. Common patterns:

- Git-ignore `.claude/audit/` and rely on disk; rotate weekly with `mv audit.jsonl audit-$(date +%F).jsonl`.
- Pipe through `logrotate` (Linux) with a daily rotation policy.
- Stream to an immutable bucket (S3 + Object Lock) for regulated work.

Do *not* delete audit history on a regulated project without retention-policy approval.

---

## Tests

### `structure-lint` fails with `[## <section>]` after a new module

**Cause.** Your new `MODULE.md` is missing a required section.

**Fix.** Open a passing module's `MODULE.md` (e.g. [`_modules/methodology/tdd/MODULE.md`](../../templates/_modules/methodology/tdd/MODULE.md)) and copy the section order. The ten required sections are listed in [`reference/tests.md`](tests.md#1-modulemd-standard-sections).

### `structure-lint` fails with `[least-privilege: <agent> has Edit/Write]`

**Cause.** An agent named `*-architect`, `*-auditor`, `*-reviewer`, or `*-critic` declares `Edit` or `Write` in its `tools:` frontmatter.

**Fix.** Remove `Edit`/`Write` from `tools`. Reviewers and architects must be read-only — they return plans and findings, never patches. If you genuinely need a writing agent, rename it to something not matching the read-only suffixes (`-implementer`, `-tester`, `-builder` are fine).

### `hook-lint` shellcheck warning

**Cause.** A hook script fails `shellcheck -S error`.

**Fix.** Read the message. The fix is almost always quoting a variable (`"$foo"` instead of `$foo`) or escaping a literal. Run `shellcheck <file>` locally to see the suggested fix.

### `assemble-coverage` fails on a brand-new module

**Cause.** The module assembles, but something is wrong with the output — most often a leftover `.fragment.json` (which means the fragment did not deep-merge cleanly) or a non-executable hook.

**Fix.**

1. Reproduce the assembly manually:
   ```bash
   ./templates/assemble.sh templates/_modules/<cat>/<opt>/test.yml /tmp/probe
   ls -la /tmp/probe/.claude/
   ```
2. Inspect for `.fragment.json` files. If present, your fragment is malformed JSON or the deep-merge produced an unexpected shape. Validate the fragment with `jq -e . settings.fragment.json` directly.
3. Inspect `chmod` bits on hooks: `ls -l /tmp/probe/.claude/hooks/`.

---

## CI

### `verify` job red, `governance` job green

**Cause.** A test check failed. The PR cannot merge regardless of label.

**Fix.** Click into the failed job; the log shows which check failed and where. Reproduce locally with `./templates/tests/run.sh`, fix, push.

### `governance` job red on a PR that deletes files

**Cause.** Your PR deletes a file that is not justified in the PR description.

**Fix.** Edit the PR body's `## Deletions` section to include a line per deleted file:

```
`path/to/deleted/file` — reason — replaced by `path/to/new`  (or "no replacement: reason")
```

For a maintainer to waive the check, apply the `override-deletion` label. The `verify` job still has to pass.

### Branch-protection requires a code-owner review

**Cause.** `CODEOWNERS` auto-requests `@Camilool8` and branch protection requires one approving review.

**Fix.** Wait for review, or ping in the PR thread. Drive-by approvals from non-CODEOWNERS do not count toward the gate.

---

## See also

- [`reference/tests.md`](tests.md) — the full test catalog.
- [`reference/eject.md`](eject.md) — assembler behaviour and exit codes.
- [`reference/assembled-output.md`](assembled-output.md) — what the output tree should look like.
- [`how-to/run-tests-locally.md`](../how-to/run-tests-locally.md) — running checks in isolation.
