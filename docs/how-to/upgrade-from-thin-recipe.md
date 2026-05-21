# How to upgrade from a v1 thin recipe

Eleven of the twelve domains ship today as [v1 thin recipes](../reference/glossary.md#thin-recipe) — single `harness.config.yml` + `files/` tree, no sub-domains, no addons, no curated agent teams. They assemble and work; they have not yet been curated into the three-layer shape that `web/` uses.

This guide covers two distinct upgrades:

1. **For users** — you picked a thin recipe and want to layer additional modules onto it for your own project.
2. **For contributors** — you are graduating a thin recipe into a full three-layer domain pack and submitting the PR.

---

## Part 1 — User: layer modules onto a thin recipe

A thin recipe pre-fills the manifest with the domain's defaults. You can still customise. Edit the recipe's `harness.config.yml` directly before running `assemble.sh`:

```bash
cp templates/data/harness.config.yml /tmp/my-data-harness.yml
$EDITOR /tmp/my-data-harness.yml
./templates/assemble.sh /tmp/my-data-harness.yml ./my-project
```

This keeps the domain's gates (`block-unbounded-sql.sh`, `leakage-sentinel.sh`, the reproducibility skill) and lets you change the cross-cutting modules to taste:

```yaml
# /tmp/my-data-harness.yml
memory:
  backend: knowledge-graph        # was: md-files
progress:
  backend: jira                   # was: filesystem
safety:
  kill_switch: true               # was: false
orchestration:
  topology: supervisor-worker     # was: single-agent
```

See [`customize-modules.md`](customize-modules.md) for the per-module trade-offs.

### What you cannot do (yet) with a thin recipe

- **Pick a sub-domain.** Thin recipes have only one shape per domain. If your data work splits cleanly into "analysis notebook" vs "production ML pipeline", you currently pick the single recipe and live with the overlap.
- **Pick addons.** The `domain.addons` list is silently ignored on a thin recipe — only sub-domain configs (in a three-layer pack) load addons.
- **Pick a curated agent team.** Specialist agents come from the `_base` general-purpose set only.

These limits are the reason thin recipes are graduating to three-layer packs over time.

---

## Part 2 — Contributor: graduate a thin recipe into a three-layer pack

The reference is `web/`. The goal is to turn `templates/<domain>/` from this:

```
templates/data/
├── README.md
├── harness.config.yml
├── claude-md.md
└── files/
    └── .claude/
        ├── hooks/...
        └── skills/...
```

into this:

```
templates/data/
├── DOMAIN.md                       NEW
├── domain.claude-md.md             NEW (renamed from claude-md.md)
├── references.md                   NEW
├── files/                          shared across sub-domains (optional)
│   └── .claude/...
├── _addons/                        NEW (optional)
│   └── <addon>/
│       ├── MODULE.md
│       ├── claude-md.md
│       └── files/
├── <sub-domain-1>/                 NEW
│   ├── SUBDOMAIN.md
│   ├── harness.config.yml
│   ├── claude-md.md
│   ├── references.md
│   └── files/.claude/...
└── <sub-domain-2>/
    └── …
```

### Step 1 — Propose the shape

Open the **Propose new content** issue with:

- The list of sub-domains you propose (typically 2–5).
- For each: the deliverable shape, the adopt-if reasoning.
- The list of addons (if any) that make sense at the pack level.
- Where the existing thin recipe's `files/` and `claude-md.md` move to.

A graduating PR is one of the larger contributions in this repo. The maintainer review is more involved; align on the shape before writing code.

### Step 2 — Add the domain layer

Create `DOMAIN.md`:

```markdown
# <Domain> domain pack

<One paragraph: what this pack covers and who it serves.>

## Sub-domain decision guide

| Sub-domain | Adopt if… |
|---|---|
| `<sub-1>` | … |
| `<sub-2>` | … |

## Addons

<List or "None.">

## Assemble

\`\`\`bash
./assemble.sh templates/<domain>/<sub-domain>/harness.config.yml ./my-project
\`\`\`

## Reference material

- `templates/<domain>/references.md` — curated dossier (refresh quarterly)
- `docs/HARNESS_ENGINEERING.md §<n>` — engineering guide
```

Rename the existing `claude-md.md` to `domain.claude-md.md`. This is the cross-sub-domain fragment that `assemble.sh` appends *before* the sub-domain-specific one.

Create `references.md` with the `> Verified: YYYY-MM` second-line header.

### Step 3 — Create the sub-domains

For each sub-domain, follow [`add-a-subdomain.md`](add-a-subdomain.md). Each gets:

- `SUBDOMAIN.md`
- `harness.config.yml`
- `claude-md.md`
- `references.md`
- `files/.claude/{agents,hooks,skills}/`

Move the existing thin recipe's hooks and skills into the sub-domain where they primarily apply. If a hook applies across all sub-domains, keep it at the domain level under `templates/<domain>/files/`.

### Step 4 — Add addons (optional)

If the domain has natural opt-in extras, add them under `templates/<domain>/_addons/<addon>/`. Follow [`add-an-addon.md`](add-an-addon.md).

For the `web/` reference, addons include Next.js, Drizzle, Auth.js, Playwright — toolings that compose with multiple sub-domains.

### Step 5 — Remove the old recipe shape

Once sub-domains exist:

- Delete `templates/<domain>/harness.config.yml` (the root-level one). The sub-domain configs are now the assemble unit.
- Delete `templates/<domain>/claude-md.md` (renamed to `domain.claude-md.md`).
- Delete `templates/<domain>/README.md` if obsolete — its content typically moves to `DOMAIN.md`. Or keep it as a redirect stub.

Justify each deletion in the PR's `## Deletions` section ([deletion policy](../../CONTRIBUTING.md)).

### Step 6 — Run the test suite

```bash
./templates/tests/run.sh
```

`assemble-coverage` will discover the new shape automatically. The old "thin recipe" probe is replaced by sub-domain probes — no test edit required.

### Step 7 — Update the catalogs

- [`docs/reference/domains.md`](../reference/domains.md) — change the domain's status from "v1 thin" to "curated (3-layer)".
- [`docs/how-to/pick-a-recipe.md`](pick-a-recipe.md) — update the decision flow to include the new sub-domains.
- [`README.md`](../../README.md) — refresh the recipe table if it lists the domain's status.
- [`docs/HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) — link the new sub-domain references.

### Step 8 — Open the PR

PR template **Type of change** = **New sub-domain** (for the first sub-domain in the new pack; subsequent PRs may be incremental). The deletions section will be longer than usual — list every removed file with its justification.

---

## See also

- [`reference/domains.md`](../reference/domains.md) — current status of every domain.
- [`add-a-subdomain.md`](add-a-subdomain.md) — sub-domain anatomy.
- [`add-an-addon.md`](add-an-addon.md) — addon anatomy.
- [`docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`](../superpowers/specs/2026-05-15-curated-domain-packs-design.md) — the design spec for the graduation effort (if vendored).
- Canonical reference: [`templates/web/`](../../templates/web/).
