# Reference: module catalog

Every cross-cutting module under [`templates/_modules/`](../../templates/_modules/). Each module is independently removable; each ships an `adopt-if / skip-if / install / remove` decision guide in its own `MODULE.md`.

Five categories. Pick at most one option per category (except `methodology`, which is a set of independent booleans).

---

## `memory/` — where durable knowledge lives

| Option | Config | One-liner | MODULE.md |
|---|---|---|---|
| `md-files` | `memory.backend: md-files` | `CLAUDE.md` + `.claude/memory/*.md`. Git-diffable, human-auditable. **Default.** | [link](../../templates/_modules/memory/md-files/MODULE.md) |
| `vector-store` | `memory.backend: vector-store` | Mem0 / Chroma. For corpora too large for context. | [link](../../templates/_modules/memory/vector-store/MODULE.md) |
| `knowledge-graph` | `memory.backend: knowledge-graph` | Zep / Letta. Provenance + decay; multi-hop reasoning. | [link](../../templates/_modules/memory/knowledge-graph/MODULE.md) |

To turn off durable memory entirely, set `memory.backend: none` — no module installed.

---

## `progress-tracking/` — where work items live

| Option | Config | One-liner | MODULE.md |
|---|---|---|---|
| `filesystem` | `progress.backend: filesystem` | `.claude/progress/` plan + task files. **Default.** | [link](../../templates/_modules/progress-tracking/filesystem/MODULE.md) |
| `github-issues` | `progress.backend: github-issues` | GitHub Issues via `gh` CLI / GitHub MCP. | [link](../../templates/_modules/progress-tracking/github-issues/MODULE.md) |
| `linear` | `progress.backend: linear` | Linear MCP. | [link](../../templates/_modules/progress-tracking/linear/MODULE.md) |
| `jira` | `progress.backend: jira` | Atlassian MCP. | [link](../../templates/_modules/progress-tracking/jira/MODULE.md) |

To use ephemeral, in-conversation tasks only, set `progress.backend: none`.

---

## `methodology/` — what discipline is mechanically enforced

| Option | Config | One-liner | MODULE.md |
|---|---|---|---|
| `tdd` | `methodology.tdd: true` | Red-green-refactor. Hook blocks edits to non-test files unless a failing test was observed first. **Default on.** | [link](../../templates/_modules/methodology/tdd/MODULE.md) |
| `spec-driven` | `methodology.spec_driven: true` | `specs/` directory; agent works against a written contract. Plan Mode pairs with this. **Default on.** | [link](../../templates/_modules/methodology/spec-driven/MODULE.md) |
| `eval-driven` | `methodology.eval_driven: true` | `evals/` golden set. Stop-hook runs a fast subset on every session end. Turn on for any LLM/ML output. | [link](../../templates/_modules/methodology/eval-driven/MODULE.md) |
| `bdd` | `methodology.bdd: true` | Gherkin `.feature` files; agent translates prose ↔ acceptance criteria. Turn on for non-technical stakeholder sign-off. | [link](../../templates/_modules/methodology/bdd/MODULE.md) |

Multiple methodology modules can be on at once. The defaults — `tdd + spec_driven` — apply to almost every domain.

---

## `orchestration/` — agent topology

| Option | Config | One-liner | MODULE.md |
|---|---|---|---|
| *(none)* | `orchestration.topology: single-agent` | One well-equipped agent. **Default.** | — |
| `supervisor-worker` | `orchestration.topology: supervisor-worker` | Orchestrator fans out to isolated subagents; aggregates typed JSON returns. | [link](../../templates/_modules/orchestration/supervisor-worker/MODULE.md) |
| `pipeline` | `orchestration.topology: pipeline` | Fixed sequential stages with gates (spec → review → implement → test). | [link](../../templates/_modules/orchestration/pipeline/MODULE.md) |
| `blackboard` | `orchestration.topology: blackboard` | Heterogeneous agents coordinate via the file system. | [link](../../templates/_modules/orchestration/blackboard/MODULE.md) |

See [`AGENT_ROLES.md`](../AGENT_ROLES.md) for the full topology comparison.

---

## `safety/` — gates beyond the `_base` four

| Option | Config | One-liner | MODULE.md |
|---|---|---|---|
| `two-key` | `safety.two_key: true` | Typed-token confirmation for production / money / deletions. The model cannot self-issue the token. | [link](../../templates/_modules/safety/two-key/MODULE.md) |
| `kill-switch` | `safety.kill_switch: true` | Three-level out-of-band stop for autonomous / long-running loops. | [link](../../templates/_modules/safety/kill-switch/MODULE.md) |
| `sandbox` | `safety.sandbox: true` | Restricts filesystem + network egress when the agent ingests untrusted input. | [link](../../templates/_modules/safety/sandbox/MODULE.md) |

The four `_base` hooks (secret-scan, command-guard, audit-log, verify-gate) always ship and are not in this catalog. See [`explanation/non-negotiables.md`](../explanation/non-negotiables.md).

---

## Anatomy of a module

Every module directory under `templates/_modules/<category>/<option>/` ships exactly three things:

```
MODULE.md       human-readable adopt-if/skip-if/install/remove guide
claude-md.md    Markdown fragment appended to the project's CLAUDE.md
files/          tree copied verbatim into the project
```

`MODULE.md` must include the following sections, in order (enforced by `structure-lint`):

1. `# Module: <category>/<option>` — title.
2. `> Config: <config-key>` — config reference line.
3. `**What it does.**` — bold paragraph (2–4 sentences).
4. `## Adopt if` — bullet list.
5. `## Skip if` — bullet list.
6. `## Dependencies` — runtime requirements (or `None.`).
7. `## Install (manual)` — step-by-step.
8. `## Install (assemble.sh)` — config key + command.
9. `## Remove` — what to delete to undo.
10. `## Files` — inventory of `files/`.

`files/` typically drops hooks under `.claude/hooks/`, skills under `.claude/skills/`, and a `.claude/settings.fragment.json` that `assemble.sh` deep-merges into `.claude/settings.json`.

---

## See also

- [`how-to/add-a-module.md`](../how-to/add-a-module.md) — how to contribute a new module.
- [`how-to/customize-modules.md`](../how-to/customize-modules.md) — how to swap modules in an existing project.
- [`reference/harness-config.md`](harness-config.md) — config keys that select each module.
- [`reference/domains.md`](domains.md) — domain-scoped recipes that bundle module selections.
