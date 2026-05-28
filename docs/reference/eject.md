# Reference: the eject path (`assemble.sh`)

> **Most users should install the plugins instead** — see
> [`reference/plugins.md`](plugins.md) and
> [`tutorials/getting-started.md`](../tutorials/getting-started.md). This page
> documents the **eject path**: the bash assembler that writes a committed
> `.claude/` tree into your repo. Choose it when you need the harness as
> version-controlled artifacts in your project (audit-heavy or regulated teams)
> rather than as installed plugins.

The one-command assembler turns a `harness.config.yml` into a ready-to-use `.claude/` tree. No dependencies beyond `bash`, `coreutils`, and (recommended) `jq`. macOS bash 3.2 compatible. It assembles from the `templates/` tree, which mirrors the plugins' content.

Source: [`templates/assemble.sh`](../../templates/assemble.sh).

---

## Synopsis

```text
./assemble.sh [config-file] [target-dir]
```

| Argument | Default | Meaning |
|---|---|---|
| `config-file` | `./harness.config.yml` | Path to a manifest. See [`reference/harness-config.md`](harness-config.md). |
| `target-dir` | `.` | Directory to assemble into. Created if it does not exist. |

There are no flags or environment variables. The behaviour is fully determined by the config and the directory layout of `templates/`.

---

## Examples

Assemble a base-only harness from the root manifest:

```bash
./templates/assemble.sh templates/harness.config.yml .
```

Assemble a web sub-domain:

```bash
./templates/assemble.sh templates/web/frontend-app/harness.config.yml ./my-app
```

Assemble a base-only harness from a custom config:

```bash
./templates/assemble.sh ./my-harness.yml ./my-project
```

---

## What it does, in order

1. **Reads the config.** Flattens the YAML into `section.key=value` lines via `awk` (see [Parser notes](harness-config.md#parser-notes)).
2. **Copies `_base/`** into the target. This always happens.
3. **Installs cross-cutting modules** picked by the config:
   - `memory/<backend>` if `memory.backend` is not `none` or empty.
   - `progress-tracking/<backend>` if `progress.backend` is not `none` or empty.
   - `methodology/{tdd,spec-driven,eval-driven,bdd}` for each `true` flag.
   - `orchestration/<topology>` if topology is not `single-agent`.
   - `safety/{two-key,kill-switch,sandbox}` for each `true` flag.
4. **Layers a domain pack** when the config lives under `templates/<domain>/<subdomain>/` with a `DOMAIN.md` sibling in `<domain>/`. The domain layer and the sub-domain layer are applied in that order, and the `domain.addons` list is processed. If the config lives elsewhere (e.g. the root manifest), the domain step is skipped entirely.
5. **Applies addons** in order from `domain.addons`. Missing addons print `! addon not found: <name> (skipped)` and continue.
6. **Adjusts the agent roster**:
   - `agents.team: none` deletes every non-`README.md` agent file from `.claude/agents/`.
   - `agents.exclude: [a, b]` removes the named agents.
   - `agents.include: [<domain>/<subdomain>/<agent>]` copies extra agents from their sub-domain source.
7. **Wires Context7 MCP** if `docs.context7_mcp: true` *and* the active domain pack ships `files/.claude/context7.mcp.json.fragment`.
8. **Substitutes `<PROJECT_NAME>`** in `CLAUDE.md` and `AGENTS.md` with `project.name` (if `perl` is available).
9. **Writes `.claude/HARNESS.lock`** — see [HARNESS.lock format](#harnesslock-format) below.
10. **Runs `chmod +x` on every hook** under `.claude/hooks/`.

Each step prints a short line so you can see what was picked.

---

## Merge semantics

`settings.json` and `.mcp.json` are *deep-merged* across `_base`, modules, the domain pack, and addons. The merge runs every time a `*.fragment.json` lands in the target:

- **Objects** are merged recursively.
- **Arrays** are concatenated. This is why module hooks *add* to the base hooks instead of overwriting them.
- **Scalars** are overwritten by the later fragment.

`CLAUDE.md` is treated differently: each module's `claude-md.md` snippet is *appended* (with a blank line) in the order modules are installed. Sections are not deduplicated.

If `jq` is missing, fragments are left at their `.fragment.json` paths and a warning is printed. The assembler does not fail — but the merge is now your responsibility. See [`how-to/assemble-by-hand.md`](../how-to/assemble-by-hand.md).

---

## `HARNESS.lock` format

Written to `.claude/HARNESS.lock` at the end of assembly. Plain text:

```
# Assembled by assemble.sh on 2026-05-15T14:00:00Z
# Config: /path/to/harness.config.yml
base
module memory/md-files
module progress-tracking/filesystem
module methodology/tdd
module methodology/spec-driven
module domain/web/frontend-app
module addon/vite-spa
module addon/tailwind-shadcn
```

One entry per layer, top to bottom in install order. Comments mark the timestamp (UTC) and the absolute path of the config used. The lock is *informational* — it lets you see what was assembled and reverse it later. Nothing reads it back; the file is for humans and grep.

---

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Assembly completed. |
| `1` | The config file path did not resolve. |
| Non-zero from `set -euo pipefail` | An unexpected shell error — re-run with `bash -x` to see where. |

There is no "partial success" exit code: skipped addons and absent `jq` print warnings to stderr but do not fail the run. Test for completeness with `./templates/tests/run.sh` after assembly.

---

## What it never does

- It does **not** install your project's dependencies (`npm install`, `pip install`, etc.). The harness is independent of your stack.
- It does **not** write secrets. Credentials for MCP servers are referenced as `${ENV_VAR}` placeholders in `.mcp.json` and are your responsibility to provision.
- It does **not** delete anything outside the target directory. Files that already exist in the target *will* be overwritten where the harness ships a file at that path.
- It does **not** download anything. Every input is read from the `templates/` tree on disk.

---

## See also

- [`reference/harness-config.md`](harness-config.md) — every config key.
- [`reference/assembled-output.md`](assembled-output.md) — the file tree this command produces.
- [`how-to/assemble-by-hand.md`](../how-to/assemble-by-hand.md) — the manual equivalent.
- [`reference/troubleshooting.md`](troubleshooting.md) — common assembly errors.
