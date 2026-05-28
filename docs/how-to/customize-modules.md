# How to customise your harness

You have a pack installed (or you are about to install one) and you want to tune it — arm a discipline, change how memory or progress tracking behaves, wire an MCP server, set your permissions. In the plugin world you customise through four levers, none of which require editing plugin files:

1. **Arm opt-in hooks** via flags under `[harness]` in `.claude/HARNESS.toml`.
2. **Let skills auto-load** — memory, progress, methodology, and orchestration ship as skills the agent loads on demand.
3. **Add opt-in MCP snippets** copied from the relevant skill body.
4. **Set permissions yourself** — plugins ship none.

> **Eject path.** If you assemble committed `.claude/` artifacts instead of installing plugins, the same choices map to keys in `harness.config.yml`. Each section below ends with the config key equivalent. See [`reference/harness-config.md`](../reference/harness-config.md) and [`reference/eject.md`](../reference/eject.md).

---

## 1. Arm an opt-in hook

`harness-base` ships four always-on hooks (secret-scan, command-guard, audit-log, verify-gate) and four *opt-in* hooks that load but stay inert until you set their flag. You arm them by adding flags to a `[harness]` table in `.claude/HARNESS.toml`:

```toml
[harness]
tdd = true           # arms tdd-guard       — blocks impl edits without a failing test
eval = true          # arms eval-gate       — blocks "done" if the fast eval subset fails
two_key = true       # arms two-key-confirm  — typed token for irreversible actions
kill_switch = true   # arms kill-switch     — out-of-band throttle/pause/stop

[web]                # written by /harness-<domain>:init — leave it alone
subdomain = "frontend-app"
```

Remove a flag (or set it `false`) and the corresponding hook goes inert again. This is how an always-loaded plugin hook becomes a per-project opt-in. The full flag table is in [`reference/plugins.md`](../reference/plugins.md#always-on-vs-opt-in-hooks).

When to arm each:

| Flag | Arm when |
|---|---|
| `tdd` | You want the agent to write a failing test before touching implementation. Rarely wrong; the default discipline for production code. |
| `eval` | LLM/ML work where "done" must mean the fast eval subset passes, not just unit tests. |
| `two_key` | Production deploys, money movement, or destructive actions need a human-issued typed token the model cannot self-issue. Standard for devops in prod and anything irreversible. |
| `kill_switch` | Any agent that runs longer than a human attention span — file-based, env-var, and signal stops. |

> **Eject equivalent.** `methodology.tdd` / `methodology.eval_driven` become methodology modules; `safety.two_key` / `safety.kill_switch` / `safety.sandbox` become safety modules. Set the boolean in `harness.config.yml` and reassemble.

---

## 2. Let skills auto-load (memory, progress, methodology, orchestration)

In the plugin world, the cross-cutting capabilities that used to be assembled modules ship as **skills** inside `harness-base`. The agent loads them on demand when the work calls for them — you do not install or remove them per project.

- **Memory** — the memory skills teach the agent how to write durable knowledge as markdown notes by default, and how to use a vector store or knowledge graph when one is wired (see MCP snippets below). The cheap, git-diffable markdown path is the default; reach for vector/graph only when the corpus is too large for context or facts need provenance and decay.
- **Progress tracking** — the progress skills default to filesystem plans under `.claude/progress/`, and switch to a ticketing backend (GitHub Issues, Linear, Jira) when its MCP is wired and the work is cross-team.
- **Methodology** — the methodology guidance (TDD, spec-driven, eval-driven, BDD) loads as skills; the *enforcement* of TDD and eval is what the `[harness]` flags above arm.
- **Orchestration** — start with one well-equipped agent. The orchestration skills and the eight base agents let you escalate to supervisor-worker, pipeline, or blackboard topologies only when the work decomposes naturally and aggregation is cheap. The most common failure mode is cargo-culting a multi-agent topology onto sequential tasks. Full guide: [`AGENT_ROLES.md`](../AGENT_ROLES.md).

You do not "switch a backend" in the plugin flow — you wire the MCP server for the backend you want (next section) and the matching skill takes over.

> **Eject equivalent.** These are the `memory.backend`, `progress.backend`, `methodology.*`, and `orchestration.topology` keys in `harness.config.yml`, selected at assemble time. See [`reference/harness-config.md`](../reference/harness-config.md).

---

## 3. Add an opt-in MCP server snippet

Domain packs auto-start only **secretless** MCP servers (e.g. `context7`, `playwright`, `chrome-devtools`, `duckdb`, and the cloud OAuth servers). Servers that need a secret token — Snowflake, BigQuery, Databricks, dbt Cloud, Langfuse, W&B, Mem0, Zep, GitHub/Jira/Linear — are **not** auto-started, because Claude Code has no per-server opt-out and shipping them would prompt every user for every token on install.

Instead, each token-bearing server lives as a copy-paste `.mcp.json` snippet inside the relevant skill body. To wire one:

1. Open the skill that documents the server (e.g. the memory skill for Mem0/Zep, the progress skill for Jira/Linear, a data skill for BigQuery).
2. Copy its `.mcp.json` snippet into your project's `.mcp.json`.
3. Set the env var the snippet references.

For example, to wire the Context7 live-docs MCP by hand on a pack that does not auto-start it:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    }
  }
}
```

Add only the servers you actually use. The MCP/secret model is documented in full in [`reference/plugins.md`](../reference/plugins.md#mcp-servers-and-secrets).

> **Eject equivalent.** The `docs.context7_mcp` key wires Context7 when the active domain pack ships a `context7.mcp.json.fragment`; other servers are added to `.mcp.json` by hand the same way. See [`reference/harness-config.md`](../reference/harness-config.md).

---

## 4. Set your permissions

Plugins ship **no** `permissions` block — the plugin manifest has no such field, and permissions are a per-project decision. The hooks are the enforcement layer; permissions are yours to set.

For an opinionated allow/deny starting point you can paste into `.claude/settings.json`, see [`reference/recommended-permissions.md`](../reference/recommended-permissions.md). The harness also keeps two human-in-the-loop habits on by default — plan mode and diff review — which you should leave on for normal development; removing them is the single most common silent regression in agentic-coding setups.

> **Eject equivalent.** The assembler also ships no `permissions` block. The `hitl.plan_mode_default` and `hitl.diff_review_required` keys gate plan mode and diff review at assemble time.

---

## See also

- [`reference/plugins.md`](../reference/plugins.md) — the `HARNESS.toml` schema, the hook table, and the MCP/secret model.
- [`reference/recommended-permissions.md`](../reference/recommended-permissions.md) — an opt-in permissions starting point.
- [`pick-a-recipe.md`](pick-a-recipe.md) — choose a pack and sub-domain.
- [`reference/harness-config.md`](../reference/harness-config.md) — the config keys these levers map to on the eject path.
- [`reference/eject.md`](../reference/eject.md) — the assembler, for committed artifacts.
