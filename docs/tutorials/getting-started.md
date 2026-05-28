# Getting started

This tutorial walks you from an empty directory to a working Claude Code harness in about ten minutes. You will:

1. Clone this repository.
2. Assemble the `web/frontend-app` recipe into a fresh project.
3. Open Claude Code and watch a safety hook block an unsafe command.

We use `web/frontend-app` for this lesson because it is the most universally legible: any client-side app shape (React, Vue, Svelte) recognises its conventions. The four `_base` hooks fire identically across every recipe, so the lesson transfers as you graduate to `data/`, `devops/`, or `mobile/`.

> Tutorials are about learning, not deciding. We pick everything for you here. The [how-to guides](../how-to/) cover *your* project's choices.

---

## Before you start

You need:

- `bash` 3.2+ (default on macOS and Linux)
- `jq` — `brew install jq` / `apt install jq` / `dnf install jq`
- `git`
- [Claude Code](https://docs.claude.com/en/docs/agents-and-tools/claude-code/overview) installed and authenticated

`shellcheck` is recommended but optional (it tightens the hook-lint check; without it, that check skips the shellcheck pass).

---

## Step 1 — Clone the repository

Pick a directory you do *not* mind cloning into. For this tutorial we will work from your home directory:

```bash
cd ~
git clone https://github.com/Camilool8/harness-engineering-templates.git
```

This gives you the templates library. You will not modify it; you will *copy from* it into a target project in the next step.

---

## Step 2 — Create a target project

Create the directory you want to drop the harness into. For the tutorial, an empty folder is fine:

```bash
mkdir ~/my-first-harness
cd ~/my-first-harness
```

This is the directory `assemble.sh` will write into. The harness adds files at the root (`CLAUDE.md`, `.mcp.json`, `.gitignore`) and a `.claude/` subtree.

---

## Step 3 — Assemble the recipe

Run the assembler. It takes two arguments: the config to use, and the target directory. We pass the `web/frontend-app` sub-domain config and `.` for *current directory*:

```bash
~/harness-engineering-templates/templates/assemble.sh \
  ~/harness-engineering-templates/templates/web/frontend-app/harness.config.yml .
```

Expected output (truncated):

```
→ base
  · merged settings.fragment.json
→ domain: web
  · merged settings.fragment.json
→ sub-domain: frontend-app
  · merged settings.fragment.json
→ wrote .claude/HARNESS.lock
```

Verify what landed:

```bash
ls -la
ls .claude/
cat .claude/HARNESS.lock
```

You should see `CLAUDE.md`, `.mcp.json`, `.gitignore`, and a `.claude/` directory containing `settings.json`, `hooks/`, `skills/`, `agents/`, and the lock file that records exactly which modules were assembled. See [`reference/assembled-output.md`](../reference/assembled-output.md) for the full inventory.

---

## Step 4 — Verify hooks are executable

`assemble.sh` runs `chmod +x` on every hook itself, so this is just a verification step. Check the four `_base` hooks landed and are executable:

```bash
ls -l .claude/hooks/
# -rwxr-xr-x  audit-log.sh
# -rwxr-xr-x  command-guard.sh
# -rwxr-xr-x  secret-scan.sh
# -rwxr-xr-x  verify-gate.sh
```

If any hook is not executable (e.g. you copied `_base/` by hand without running the assembler), run `chmod +x .claude/hooks/*.sh`.

These are the four non-negotiable hooks every harness ships — see [`explanation/non-negotiables.md`](../explanation/non-negotiables.md) for *why*.

---

## Step 5 — Fill in `CLAUDE.md` placeholders

Open `CLAUDE.md` in your editor. It is a project-shaped template with placeholders:

- Replace `<PROJECT_NAME>` with whatever you want to call your project.
- Replace the `<cmd>` placeholders under `## Commands` with the shell commands your project actually uses (if you have none yet, fill in something like `echo "not yet"` — you can refine later).

The agent reads `CLAUDE.md` on every turn. Keep it under ~60 lines; long context is not free.

---

## Step 6 — Open Claude Code

From the project directory:

```bash
claude
```

Claude Code reads `.claude/settings.json` and registers the four base hooks. You will see a normal Claude Code prompt.

---

## Step 7 — Watch a hook fire

Ask Claude to run a destructive command, e.g.:

> *"Please run `rm -rf /tmp/some-fake-path` for me."*

The `command-guard.sh` hook intercepts the `Bash` tool call before it runs, exits with code 2, and feeds the reason back to the agent. Claude does **not** execute the command; you will see the agent reasoning about an alternative.

This is the contract. Documentation is a suggestion the model is free to ignore; a `PreToolUse` hook returning exit code 2 is not.

For the secret scanner, ask Claude to add a line like `AWS_SECRET_ACCESS_KEY=AKIA...` to a file. The `secret-scan.sh` hook blocks the write the same way.

---

## What you have now

A complete `web/frontend-app` Claude Code harness with:

- Four `_base` hooks: secret-scan, command-guard, audit-log, verify-gate.
- `tdd` + `spec_driven` methodology modules enforced.
- `filesystem` progress tracking under `.claude/progress/`.
- `md-files` memory under `.claude/memory/`.
- The `web` domain layer (accessibility-tree verify loop, lint+type PostToolUse) and the `frontend-app` sub-domain agent team.
- A `.claude/HARNESS.lock` manifest recording what was assembled.

You can commit this to git and start working.

---

## What to read next

- [`how-to/pick-a-recipe.md`](../how-to/pick-a-recipe.md) — pick the right domain pack and sub-domain for your project (web, data, devops, mobile).
- [`how-to/customize-modules.md`](../how-to/customize-modules.md) — swap memory backend, add orchestration, turn on safety gates.
- [`reference/harness-config.md`](../reference/harness-config.md) — every config key explained.
- [`explanation/why-harness.md`](../explanation/why-harness.md) — the philosophy behind the contract-not-prose design.
