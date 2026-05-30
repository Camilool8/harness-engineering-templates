# Getting started

This tutorial walks you from an empty directory to a working Claude Code harness in about ten minutes. You will:

1. Add the `harness-engineering` plugin marketplace.
2. Install the `harness-web` pack and run `/harness-web:init`.
3. Watch a non-negotiable safety hook block an unsafe command.
4. Optionally arm one opt-in discipline (TDD) and watch its hook fire too.

We use `harness-web` for this lesson because it is the most universally legible: any client-side app shape (React, Vue, Svelte) recognises its conventions. The four base hooks fire identically across every pack, so the lesson transfers as you graduate to `harness-data`, `harness-devops`, or `harness-mobile`.

> Tutorials are about learning, not deciding. We pick everything for you here. The [how-to guides](../how-to/) cover *your* project's choices.

---

## Before you start

You need:

- [Claude Code](https://docs.claude.com/en/docs/agents-and-tools/claude-code/overview) installed and authenticated.
- `git`, and a project directory (an empty folder is fine for this lesson).

That is all. The plugin flow needs no `bash` assembler, no `jq`, and no clone of this repo — Claude Code fetches the marketplace for you.

> Prefer committed `.claude/` artifacts checked into your repo instead of installed plugins? That is the **eject path** — see [`reference/eject.md`](../reference/eject.md). This tutorial uses the plugin flow, which is the path most users want.

---

## Step 1 — Create a project to work in

Open a directory you want the harness to operate on. For the tutorial, an empty folder is fine:

```bash
mkdir ~/my-first-harness
cd ~/my-first-harness
claude
```

Claude Code is now running in your project. The next steps are slash commands you type **inside** the Claude Code session.

---

## Step 2 — Add the marketplace

Add the `harness-engineering` marketplace once. You only do this a single time per machine:

```
/plugin marketplace add Camilool8/harness-engineering-templates
```

Claude Code fetches the marketplace manifest and lists the five plugins it offers: `harness-base`, `harness-web`, `harness-data`, `harness-devops`, and `harness-mobile`.

---

## Step 3 — Install the web pack

Install the pack for your domain. For this lesson, web:

```
/plugin install harness-web@harness-engineering
```

You never install `harness-base` directly — installing `harness-web` pulls it in automatically via the dependency cascade. `harness-base` is what ships the four non-negotiable safety hooks; the domain pack layers web-specific sub-domains, agents, and gates on top.

The full plugin catalog and what each pack adds is in [`reference/plugins.md`](../reference/plugins.md).

---

## Step 4 — Run the init command

Pick your sub-domain with the pack's `init` command:

```
/harness-web:init
```

Claude asks which of the five web sub-domains fits — `api-service`, `design-system`, `distributed-backend`, `frontend-app`, or `fullstack-app`. For the tutorial, choose **frontend-app**.

The command writes a single file into your project, `.claude/HARNESS.toml`, recording your choice:

```toml
[web]
subdomain = "frontend-app"
```

This is the only file the plugins write into your repo. The matching skills and hooks read it to know which sub-domain conventions to apply. (Editing a YAML config to pick a sub-domain is the *eject* path — in the plugin flow, the `init` command owns this file.)

---

## How the harness activates in your repo

Installing a domain pack from the marketplace does **not** copy files into your
project's `.claude/`. Plugins load from the plugin cache — their skills, agents,
and hooks are active session-wide without being vendored into the repo. An empty
project `.claude/` is normal and expected.

To switch the pack on for a project, run its init command **once** and commit the
marker it writes:

```bash
/harness-web:init     # or harness-data:init, harness-devops:init, harness-mobile:init
```

This writes `.claude/HARNESS.toml`:

```toml
[web]
subdomain = "fullstack-app"
```

From then on, a `SessionStart` hook reads that marker at the start of **every**
session and pins the pack's shared `*-domain` rules plus your selected subdomain
skill into context automatically — no need to invoke them by hand. Other pack
skills (`using-*`, `addon-*`) remain available and load on demand when relevant.

If you would rather vendor the harness physically into the repo (so it travels
with the code and needs no plugin install), use the eject path instead:
`./templates/assemble.sh web/fullstack-app/harness.config.yml ./my-app`.

---

## Step 5 — Watch a non-negotiable hook fire

The four base hooks are now armed, with no configuration required. Watch one block a destructive command. Ask Claude:

> *"Please run `rm -rf /tmp/some-fake-path` for me."*

The `command-guard` hook intercepts the `Bash` tool call before it runs, exits with code 2, and feeds the reason back to the agent. Claude does **not** execute the command; you will see the agent reasoning about a safer alternative.

This is the contract. Documentation is a suggestion the model is free to ignore; a `PreToolUse` hook returning exit code 2 is not. The same is true of the secret scanner — ask Claude to add a line like `AWS_SECRET_ACCESS_KEY=AKIA...` to a file and `secret-scan` blocks the write the same way.

These four hooks (secret-scan, command-guard, audit-log, verify-gate) are always on and not configurable. See [`explanation/non-negotiables.md`](../explanation/non-negotiables.md) for *why*.

---

## Step 6 — (Optional) Arm an opt-in discipline

The base pack also ships four *opt-in* hooks that stay inert until you arm them with a flag. Try TDD. Add a `[harness]` table to `.claude/HARNESS.toml`:

```toml
[harness]
tdd = true       # arms tdd-guard

[web]
subdomain = "frontend-app"
```

Now ask Claude to edit an implementation file before any failing test exists for it. The `tdd-guard` hook blocks the edit and tells the agent to write a failing test first. Remove `tdd = true` and the same hook goes inert again — that is how an always-loaded plugin hook becomes a per-project opt-in.

The other three flags work the same way: `eval = true` (eval-gate), `two_key = true` (two-key-confirm), `kill_switch = true` (kill-switch). The full flag table is in [`reference/plugins.md`](../reference/plugins.md#claudeharnesstoml-the-project-marker).

---

## What you have now

A complete `harness-web` / `frontend-app` Claude Code harness with:

- The `harness-base` pack and its four always-on hooks: secret-scan, command-guard, audit-log, verify-gate.
- The `harness-web` pack: the accessibility-tree verify loop, lint+type checks, and the `frontend-app` agent team.
- A `.claude/HARNESS.toml` marker recording your sub-domain and any opt-in flags you armed.
- An append-only audit log under `.claude/audit/audit.jsonl` — in your project, so it commits with your work.

The plugins live in Claude Code's cache, not your repo, so there is nothing else to commit beyond `.claude/HARNESS.toml` (and whatever your project produces).

---

## What to read next

- [`how-to/pick-a-recipe.md`](../how-to/pick-a-recipe.md) — pick the right pack and sub-domain for your project (web, data, devops, mobile).
- [`how-to/customize-modules.md`](../how-to/customize-modules.md) — arm opt-in hooks, let skills auto-load, set your permissions.
- [`reference/plugins.md`](../reference/plugins.md) — the plugin catalog and the `HARNESS.toml` schema.
- [`reference/eject.md`](../reference/eject.md) — the bash assembler, if you want committed `.claude/` artifacts instead of installed plugins.
- [`explanation/why-harness.md`](../explanation/why-harness.md) — the philosophy behind the contract-not-prose design.
