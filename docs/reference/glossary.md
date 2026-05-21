# Reference: glossary

Terms used throughout this repo's documentation. Where the term overlaps with a Claude Code or AI-engineering term of art, the cross-link is to the canonical authority.

---

### Addon

A domain-scoped optional extra. Lives under `templates/<domain>/_addons/<addon>/`. Same shape as a [module](#module) — `MODULE.md`, `claude-md.md`, `files/` — but applied only when the active [domain pack](#domain-pack) loads it. Only `web/` ships addons today.

### Agent

A Claude Code session governed by a [harness](#harness). In the multi-agent sense, a *subagent* is a session spawned by a parent session with its own tool restrictions and context window. See [`AGENT_ROLES.md`](../AGENT_ROLES.md).

### `_base`

The universal starter layer. Every assembled project copies `_base/` first, before any [module](#module) or [domain pack](#domain-pack). Source: [`templates/_base/`](../../templates/_base/). The four [non-negotiable hooks](#non-negotiable-hooks) come from here.

### `claude-md.md`

A Markdown fragment shipped by every [module](#module) and [addon](#addon). When the module is installed, the fragment is *appended* to the project's `CLAUDE.md` so the agent reads the module's conventions on every turn. Must start with a `## <Section heading>`.

### Domain

One of the twelve top-level categories of project this repo supports: `web`, `data`, `devops`, `finance`, `mobile`, `game`, `embedded`, `scientific`, `security`, `content`, `ops`, `generic`. Each domain has a recipe; some have a full domain pack.

### Domain pack

A curated, three-layer bundle of harness content for a [domain](#domain): a domain layer (`DOMAIN.md`, `domain.claude-md.md`), one or more [sub-domains](#sub-domain), and optional [addons](#addon). Today only `web/` is a three-layer pack; the other eleven domains ship as v1 thin recipes (see [`reference/domains.md`](domains.md)).

### Harness

The complete set of constraints, tools, hooks, skills, agents, settings, and documentation that surrounds the model and makes it produce reliable work. The premise of this repo, per Birgitta Böckeler and the 2025–2026 practitioner consensus: *agent = model + harness*, and the harness is the contract. The model is interchangeable; the harness is not.

### Hook

A shell script wired into Claude Code's [tool-event lifecycle](https://docs.claude.com/en/docs/agents-and-tools/claude-code/hooks). Four event surfaces: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`. Exit code 2 from a `PreToolUse` hook blocks the tool call. This is the harness's primary enforcement mechanism.

### `HARNESS.lock`

Plain-text manifest at `.claude/HARNESS.lock` written by `assemble.sh` recording the timestamp, the config used, and every layer assembled. Informational; nothing reads it back.

### MCP — Model Context Protocol

The [open protocol](https://modelcontextprotocol.io/) for connecting LLMs to external tools and data sources. MCP servers are wired in `.mcp.json`. The harness treats MCP output as *untrusted input*, never as instructions.

### Module

A cross-cutting opt-in capability under `templates/_modules/<category>/<option>/`. Five categories: `memory`, `progress-tracking`, `methodology`, `orchestration`, `safety`. Each module is independently removable. See [`reference/modules.md`](modules.md).

### `MODULE.md`

The human-readable decision guide every [module](#module) and [addon](#addon) ships. Required sections, in order: `# Module: …`, `> Config: …`, `**What it does.**`, `## Adopt if`, `## Skip if`, `## Dependencies`, `## Install (manual)`, `## Install (assemble.sh)`, `## Remove`, `## Files`. Enforced by [`structure-lint`](tests.md#structure-lint).

### Non-negotiable hooks

The four `_base` hooks that always ship and are not configurable: `secret-scan.sh`, `command-guard.sh`, `audit-log.sh`, `verify-gate.sh`. They survive `--dangerously-skip-permissions` by design — see [`explanation/non-negotiables.md`](../explanation/non-negotiables.md).

### Recipe

A pre-filled `harness.config.yml` plus the directory it sits in. Pass it to `assemble.sh` to get a fully configured harness for a [domain](#domain) in one step:

```bash
./templates/assemble.sh templates/data/harness.config.yml .
```

Two recipe shapes today: v1 thin recipes (eleven domains) and the curated three-layer pack (`web/`).

### Settings fragment

A `.claude/settings.fragment.json` file shipped by some [modules](#module) and [domain packs](#domain-pack). After `assemble.sh` copies it into the target, the fragment is deep-merged into `.claude/settings.json` (objects recurse, arrays concatenate) so module hooks add to the base hooks without overwriting. See [`reference/assemble-cli.md`](assemble-cli.md#merge-semantics).

### Skill

A Markdown file under `.claude/skills/<skill-name>/SKILL.md` that the agent can invoke as a procedural reference. Must declare `name:` and `description:` in YAML frontmatter. See [Claude Code skills](https://docs.claude.com/en/docs/agents-and-tools/claude-code/skills).

### Sub-domain

The assemble unit within a three-layer [domain pack](#domain-pack). For `web/`, the sub-domains are `design-system`, `frontend-app`, `fullstack-app`, `api-service`, `distributed-backend`. The sub-domain's `harness.config.yml` is what you pass to `assemble.sh`.

### `SUBDOMAIN.md`

The human-readable decision guide every [sub-domain](#sub-domain) ships. Required sections: `# <title>`, `## Adopt if`, `## Skip if`, `## Addons that pair well`, `## Agent team`. Enforced by [`structure-lint`](tests.md#structure-lint).

### Thin recipe

A domain that ships as a single `harness.config.yml` + `files/` tree, with no `DOMAIN.md`, no [sub-domains](#sub-domain), and no [addons](#addon). Eleven domains are thin recipes today (everything except `web/`). They assemble and work; they have not yet been curated into the three-layer shape. See [`how-to/upgrade-from-thin-recipe.md`](../how-to/upgrade-from-thin-recipe.md).

### Two-key

A [safety](#module) module that requires a typed token the model cannot self-issue before a privileged action (production deploy, money movement, deletion). The token is provisioned by a human out-of-band.

### Verify gate

The `Stop`-event hook (`verify-gate.sh`) that runs `./.claude/verify.sh` before letting a session end. The agent cannot self-declare "done" — the verification commands must pass first.

---

## See also

- [`README.md`](README.md) — the doc index.
- [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) — deep reference where these terms originate.
