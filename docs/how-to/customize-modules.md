# How to customise modules

You have a recipe assembled, or you are about to assemble one, and you want to change a default — swap the memory backend, add a methodology, turn on a safety gate. This guide is the recipe set.

Two timelines:

- **Before assembly** — edit `harness.config.yml`, then run `./templates/assemble.sh`.
- **After assembly** — follow the target module's `MODULE.md` → **Install (manual)** / **Remove** sections directly on the assembled project.

The before-assembly path is easier; prefer it.

---

## Swap the memory backend

Default: `md-files`. Alternatives: `vector-store`, `knowledge-graph`, `none`.

### Before assembly

```yaml
# in harness.config.yml
memory:
  backend: vector-store
```

Then run `./templates/assemble.sh`. The `vector-store` module's files land in `.claude/`, and its `claude-md.md` section is appended to `CLAUDE.md`.

### After assembly

1. Follow `_modules/memory/md-files/MODULE.md` → **Remove** to strip the current backend.
2. Follow `_modules/memory/vector-store/MODULE.md` → **Install (manual)** to add the new one.

### Choose

| Backend | Switch to it when |
|---|---|
| `md-files` | **Default.** Cheap, git-diffable, human-auditable. |
| `vector-store` | The corpus is too large for context and is naturally semantic-retrieval-shaped. |
| `knowledge-graph` | Regulated work where facts have provenance and decay; multi-hop reasoning. |
| `none` | One-shot or CI agents with no durable memory. |

Full guidance: [`reference/harness-config.md` §memory](../reference/harness-config.md#memory).

---

## Add or remove a methodology

The four methodology keys are independent booleans. Defaults: `tdd: true`, `spec_driven: true`, `eval_driven: false`, `bdd: false`.

### Add `eval_driven` for an LLM/ML project

```yaml
methodology:
  tdd: true
  spec_driven: true
  eval_driven: true     # ← turn on
  bdd: false
```

Reassemble (or manually install [`_modules/methodology/eval-driven/`](../../templates/_modules/methodology/eval-driven/MODULE.md)).

### Remove `tdd` for a spike

```yaml
methodology:
  tdd: false            # ← turn off
  spec_driven: true
  eval_driven: false
  bdd: false
```

After assembly: follow `_modules/methodology/tdd/MODULE.md` → **Remove**. Delete the hook, delete the marker file, delete the `## Test-Driven Development` section from `CLAUDE.md`, drop the hook entry from `.claude/settings.json`.

**Note.** Turning off `tdd` is rarely right. Spikes turn into production code, and removing the discipline mid-stream is harder than working around it. Prefer `git stash` of the TDD marker for a short detour.

---

## Switch the progress-tracking backend

Default: `filesystem`. Alternatives: `github-issues`, `linear`, `jira`, `none`.

```yaml
progress:
  backend: github-issues
```

This is the typical move when a project graduates from solo to a team that already runs on a ticketing system. The `filesystem` backend stays useful for short-lived plans; the ticketed backend takes over for cross-team work.

After assembly: see [`_modules/progress-tracking/github-issues/MODULE.md`](../../templates/_modules/progress-tracking/github-issues/MODULE.md).

---

## Escalate orchestration

Default: `single-agent`. Alternatives: `supervisor-worker`, `pipeline`, `blackboard`.

```yaml
orchestration:
  topology: supervisor-worker
```

**Do not do this on day one.** The 2026 consensus: start with one well-equipped agent; escalate to isolated subagents only when the work decomposes naturally and aggregation is cheap. The most common failure mode is cargo-culting `supervisor-worker` onto sequential tasks.

When to switch:

| To | Switch when |
|---|---|
| `supervisor-worker` | Tasks decompose into independent sub-questions (Anthropic's research system: 90.2% uplift over single Opus on multi-question research). |
| `pipeline` | Steps are knowable in advance and gating between them is valuable (spec → review → implement → test). |
| `blackboard` | State is durable, agents are heterogeneous, the next action depends on shared context. |

Full topology guide: [`AGENT_ROLES.md`](../AGENT_ROLES.md).

---

## Turn on a safety gate

Defaults: all three off. The four `_base` hooks (secret-scan, command-guard, audit-log, verify-gate) always ship — see [`explanation/non-negotiables.md`](../explanation/non-negotiables.md). Safety modules layer on top.

### Two-key for production

```yaml
safety:
  two_key: true
```

Every production deploy, money movement, or destructive action requires a typed token a human issues out-of-band. The model cannot self-issue the token. Standard for devops in prod, payment-system work, and anything irreversible.

### Kill-switch for autonomous loops

```yaml
safety:
  kill_switch: true
```

Three-level out-of-band stop: file-based, env-var, signal. Standard for any agent that runs longer than a human attention span.

### Sandbox for untrusted input

```yaml
safety:
  sandbox: true
```

Restricts filesystem and network egress. Turn on when the agent ingests PR descriptions, issue bodies, web fetches, or anything else the model treats as input but an attacker could shape.

---

## Disable HITL gates (think first)

Defaults: both on. The harness directs human attention; it does not remove the human.

```yaml
hitl:
  plan_mode_default: false       # rarely right
  diff_review_required: false    # very rarely right
```

Disable only when:

- The work is a one-shot CI agent with no human in the loop *by design*.
- The session is a sandboxed spike not landing on `main`.

For normal development, both gates stay on. Removing them is the single most common silent regression in agentic-coding setups.

---

## Wire the Context7 docs MCP

The `docs.context7_mcp` key wires the [Context7](https://context7.com/) live-docs MCP so agents fetch current library documentation at runtime rather than recalling stale training-data versions.

```yaml
docs:
  context7_mcp: true
```

The key is a no-op unless the active domain pack ships a `files/.claude/context7.mcp.json.fragment`. Today `web/` does; the other packs do not. If you want Context7 on a pack that does not ship the fragment, drop a `context7` entry into `.mcp.json` by hand:

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

---

## Customise the agent roster (web pack only)

After picking a sub-domain, you can prune or extend the curated agent team:

```yaml
agents:
  team: curated                              # or: none
  exclude: [web-perf-auditor]                # drop named agents
  include: [web/api-service/api-architect]   # add agents by path
```

`agents.team: none` removes every specialist agent from `.claude/agents/` after copy; the `_base` general-purpose set stays.

---

## See also

- [`reference/harness-config.md`](../reference/harness-config.md) — schema and defaults.
- [`reference/modules.md`](../reference/modules.md) — module catalog with `MODULE.md` links.
- [`pick-a-recipe.md`](pick-a-recipe.md) — start-of-project recipe selection.
- [`assemble-by-hand.md`](assemble-by-hand.md) — applying modules without re-running `assemble.sh`.
