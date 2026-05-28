# How to assemble the harness by hand

You want to install the harness without running `./templates/assemble.sh` — because you do not have `jq` installed, because you want to understand exactly what lands where, or because you are applying a single module to an existing project.

This guide walks the manual equivalent. Every module is install-by-hand; the assembler is convenience, not contract.

---

## When to do this

| Situation | Approach |
|---|---|
| Greenfield project, you have `jq` | Use `assemble.sh`. [Skip this guide.](../tutorials/getting-started.md) |
| Greenfield project, no `jq` and you cannot install it | Manual install of `_base/` + your chosen modules. |
| Existing project; want to add one module | Manual install of just that module. |
| You want to read what would happen before committing to it | Manual install (or dry-run with `--target /tmp/probe` first). |

---

## Step 1 — Copy `_base/`

`_base/` is the universal starter. Every harness ships it.

```bash
cp -R templates/_base/. ./
```

This drops, at the project root:

- `CLAUDE.md` (with placeholders to fill)
- `AGENTS.md`
- `.mcp.json`
- `.gitignore`
- `.claude/` (settings, hooks, skills, agents, verify.sh.example)

Make hooks executable:

```bash
chmod +x .claude/hooks/*.sh
```

Confirm `.claude/settings.json` is valid JSON:

```bash
jq -e . .claude/settings.json   # or: python -m json.tool .claude/settings.json
```

---

## Step 2 — Install each module

For every module you want, follow its `MODULE.md` → **Install (manual)** section. The pattern is always the same:

1. **Copy the module's `files/` tree into your project root.**

   ```bash
   cp -R templates/_modules/methodology/tdd/files/. ./
   ```

   The `files/` tree mirrors the target layout — so `files/.claude/hooks/tdd-guard.sh` lands at `.claude/hooks/tdd-guard.sh`.

2. **Append the module's `claude-md.md` to your `CLAUDE.md`.**

   ```bash
   printf '\n' >> CLAUDE.md
   cat templates/_modules/methodology/tdd/claude-md.md >> CLAUDE.md
   ```

3. **Merge the module's `settings.fragment.json` into `.claude/settings.json`** (if present).

   With `jq`:

   ```bash
   jq -s '
     def dm($a;$b): reduce ($b|keys_unsorted[]) as $k ($a;
       if (($a[$k]|type)=="object") and (($b[$k]|type)=="object") then .[$k]=dm($a[$k];$b[$k])
       elif (($a[$k]|type)=="array") and (($b[$k]|type)=="array") then .[$k]=($a[$k]+$b[$k])
       else .[$k]=$b[$k] end);
     dm(.[0];.[1])' \
     .claude/settings.json .claude/settings.fragment.json \
     > .claude/settings.json.new && \
     mv .claude/settings.json.new .claude/settings.json && \
     rm .claude/settings.fragment.json
   ```

   Without `jq`: open both files in your editor; copy the fragment's `hooks.<event>` array entries into the base's matching array. Do not overwrite — *append*.

4. **Re-`chmod`** any new hooks the module dropped:

   ```bash
   chmod +x .claude/hooks/*.sh
   ```

Repeat for each module from [`reference/modules.md`](../reference/modules.md).

---

## Step 3 — Apply a domain layer

Every curated pack (`web`, `data`, `devops`, `mobile`) ships a domain layer plus sub-domain layers. Apply the domain layer first, then the sub-domain layer of your choice:

```bash
# domain layer (example: web)
cp -R templates/web/files/. ./ 2>/dev/null || true
printf '\n' >> CLAUDE.md
cat templates/web/domain.claude-md.md >> CLAUDE.md

# sub-domain layer (example: frontend-app)
cp -R templates/web/frontend-app/files/. ./
printf '\n' >> CLAUDE.md
cat templates/web/frontend-app/claude-md.md >> CLAUDE.md

chmod +x .claude/hooks/*.sh
```

Replace `web/frontend-app` with the sub-domain you picked (e.g. `data/ml-pipeline`, `devops/infrastructure`, `mobile/react-native-expo`).

Then merge any new `.claude/settings.fragment.json` and `.mcp.json.fragment` the way Step 2 describes.

---

## Step 4 — Apply addons (web only)

For each addon under your sub-domain:

```bash
cp -R templates/web/_addons/vite-spa/files/. ./
printf '\n' >> CLAUDE.md
cat templates/web/_addons/vite-spa/claude-md.md >> CLAUDE.md
```

Merge any settings/mcp fragments. `chmod +x` any new hooks.

---

## Step 5 — Fill placeholders

Open `CLAUDE.md`. Replace every `<PLACEHOLDER>`:

- `<PROJECT_NAME>` — your project name.
- `<cmd>` under `## Commands` — the actual lint / typecheck / test / build commands.

Open `.mcp.json`. Provision any `${ENV_VAR}` references in your shell environment.

---

## Step 6 — Write your own `verify.sh`

The Stop-event gate runs `./.claude/verify.sh` before letting a session end. Copy the example:

```bash
cp .claude/verify.sh.example .claude/verify.sh
chmod +x .claude/verify.sh
```

Edit it to run your project's verification commands — lint, typecheck, tests. If any returns non-zero, the gate refuses "done". This is what enforces *evidence before assertions*.

---

## Step 7 — Write a `HARNESS.lock` (optional)

`assemble.sh` writes a manifest of what was assembled. You can recreate it by hand:

```bash
cat > .claude/HARNESS.lock <<EOF
# Assembled by hand on $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Config: (manual install)
base
module memory/md-files
module progress-tracking/filesystem
module methodology/tdd
module methodology/spec-driven
EOF
```

The lock is informational — nothing reads it back. But future-you will appreciate the breadcrumb when you want to know which modules are currently on.

---

## Removing a module by hand

Follow the target `MODULE.md` → **Remove** section. The pattern, again, is always the same:

1. Delete the files the module installed under `.claude/`.
2. Delete the module's appended section from `CLAUDE.md`.
3. Remove the module's hook entries from `.claude/settings.json` `hooks.<event>` arrays.

Because every module is an isolated directory plus an appended `CLAUDE.md` section, removal is always delete-files + delete-section.

---

## See also

- [`tutorials/getting-started.md`](../tutorials/getting-started.md) — the assembler-based walk-through.
- [`reference/assemble-cli.md`](../reference/assemble-cli.md) — what the assembler does, step by step.
- [`reference/assembled-output.md`](../reference/assembled-output.md) — what the final tree looks like.
- [`reference/modules.md`](../reference/modules.md) — catalog of every module's contribution.
