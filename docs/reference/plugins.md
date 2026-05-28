# Reference: plugins

The harness ships as a Claude Code **plugin marketplace** named
`harness-engineering`. Add it once, then install the pack you need.

```
/plugin marketplace add Camilool8/harness-engineering-templates
/plugin install harness-web@harness-engineering
/harness-web:init
```

Non-interactive equivalents exist too: `claude plugin marketplace add …`,
`claude plugin install …`.

---

## The five plugins

| Plugin | Install | Depends on | What it adds |
|---|---|---|---|
| **harness-base** | `harness-base@harness-engineering` | — | 4 non-negotiable hooks, 4 opt-in hooks, cross-cutting skills (memory, methodology, progress, orchestration, safety), 8 orchestration agents. |
| **harness-web** | `harness-web@harness-engineering` | harness-base | 5 sub-domains (api-service, design-system, distributed-backend, frontend-app, fullstack-app), 9 addons, web agents + verify hooks. |
| **harness-data** | `harness-data@harness-engineering` | harness-base | 4 sub-domains (analytics-engineering, data-analyst-notebook, llm-app, ml-pipeline), 12 addons, warehouse-safety hooks. |
| **harness-devops** | `harness-devops@harness-engineering` | harness-base | 4 sub-domains (cicd-platform, infrastructure, kubernetes-platform, observability-sre), 15 addons, plan-before-apply + supply-chain hooks. |
| **harness-mobile** | `harness-mobile@harness-engineering` | harness-base | 4 sub-domains (flutter-app, native-android, native-ios, react-native-expo), 10 addons, store-compliance hooks. |

You never install `harness-base` directly — installing any domain pack pulls it
in via the dependency cascade. Disabling `harness-base` while a domain pack is
enabled is refused.

---

## `.claude/HARNESS.toml` — the project marker

The only file the plugins write into your project. The `/<plugin>:init` command
records your sub-domain choice; the opt-in base hooks read their flags from it.

```toml
[harness]            # opt-in enforcement flags read by harness-base hooks
tdd = true           # arms tdd-guard.sh   (blocks impl edits without a failing test)
eval = true          # arms eval-gate.sh   (blocks "done" if the fast eval subset fails)
two_key = true       # arms two-key-confirm.sh (typed token for irreversible actions)
kill_switch = true   # arms kill-switch.sh (out-of-band throttle/pause/stop)

[web]                # written by /harness-web:init — one table per installed domain
subdomain = "frontend-app"
```

Without a flag, the corresponding hook is **inert** — the plugin loads the hook
but it exits immediately. This is how always-loaded plugin hooks become
per-project opt-in.

---

## Always-on vs opt-in hooks

| Hook (harness-base) | Status | Trigger |
|---|---|---|
| secret-scan, command-guard, audit-log, verify-gate | **always on** | the non-negotiable contract; run on every install |
| tdd-guard | opt-in | `tdd = true` |
| eval-gate | opt-in | `eval = true` |
| two-key-confirm | opt-in | `two_key = true` |
| kill-switch | opt-in | `kill_switch = true` |

The audit log lands in `${CLAUDE_PROJECT_DIR}/.claude/audit/audit.jsonl` — in
your project, not the plugin cache, so it commits with your work.

---

## MCP servers and secrets

Domain packs declare only **secretless** MCP servers in their manifest (these
auto-start when the plugin is enabled): e.g. `context7`, `playwright`,
`chrome-devtools`, `duckdb`, the cloud OAuth servers (`aws`, `azure`, `datadog`,
`firebase`).

Servers that need a secret token (Snowflake, BigQuery, Databricks, dbt Cloud,
Langfuse, W&B, Mem0, Zep, GitHub/Jira/Linear) are **not** auto-started. There is
no per-server opt-out in Claude Code, so shipping them in the manifest would
prompt every user for every token on install. Instead each lives as a
copy-paste `.mcp.json` snippet inside the relevant skill body — add only the one
you use and set its env var.

---

## Permissions

Plugins ship **no** `permissions` block — the manifest format has no such field,
and permissions are a per-project decision. The hooks are the enforcement layer.
For an opinionated allow/deny starting point, see
[`recommended-permissions.md`](recommended-permissions.md).

---

## See also

- [`how-to/pick-a-recipe.md`](../how-to/pick-a-recipe.md) — choose a domain pack and sub-domain.
- [`reference/eject.md`](eject.md) — the bash assembler, for committed `.claude/` artifacts.
- [`explanation/non-negotiables.md`](../explanation/non-negotiables.md) — why the four base hooks are not configurable.
