# Reference: `harness.config.yml`

The single manifest that drives `./templates/assemble.sh`. Every key below is **pick or discard**; defaults are the 2026 practitioner consensus.

The reference template lives at [`templates/harness.config.yml`](../../templates/harness.config.yml). Each per-domain recipe ships a pre-filled variant at `templates/<domain>/harness.config.yml`.

---

## Schema overview

```yaml
project:
  name: <string>

memory:
  backend: md-files | vector-store | knowledge-graph | none

progress:
  backend: filesystem | github-issues | linear | jira | none

methodology:
  tdd:         <bool>
  spec_driven: <bool>
  eval_driven: <bool>
  bdd:         <bool>

orchestration:
  topology: single-agent | supervisor-worker | pipeline | blackboard

safety:
  two_key:     <bool>
  kill_switch: <bool>
  sandbox:     <bool>

hitl:
  plan_mode_default:    <bool>
  diff_review_required: <bool>

domain:
  pack:      "" | web | data | devops | finance | mobile | game | embedded | scientific | security | content | ops | generic
  subdomain: "" | <subdomain-name>
  addons:    [<addon>, …]

agents:
  team:    curated | none
  exclude: [<agent-name>, …]
  include: [<domain>/<subdomain>/<agent>, …]

docs:
  context7_mcp: <bool>
```

---

## `project`

| Key | Type | Default | Behaviour |
|---|---|---|---|
| `project.name` | string | `my-project` | If `perl` is available, `assemble.sh` substitutes `<PROJECT_NAME>` in the generated `CLAUDE.md` and `AGENTS.md` with this value. |

---

## `memory`

Where the agent's durable, cross-session knowledge lives.

| Value | When to use | Module installed |
|---|---|---|
| **`md-files`** *(default)* | Cheap, git-diffable, human-auditable, survives every model upgrade. Start here. | [`_modules/memory/md-files/`](../../templates/_modules/memory/md-files/MODULE.md) |
| `vector-store` | The corpus is too large for context and is naturally semantic-retrieval-shaped (Mem0 / Chroma). | [`_modules/memory/vector-store/`](../../templates/_modules/memory/vector-store/MODULE.md) |
| `knowledge-graph` | Regulated work where facts have provenance and decay, or multi-hop reasoning is required (Zep / Letta). | [`_modules/memory/knowledge-graph/`](../../templates/_modules/memory/knowledge-graph/MODULE.md) |
| `none` | One-shot or CI agents with no durable memory. | — |

---

## `progress`

Where work items, plans, and status live.

| Value | When to use | Module installed |
|---|---|---|
| **`filesystem`** *(default)* | Solo or small teams; `.claude/progress/` plan + task files. | [`_modules/progress-tracking/filesystem/`](../../templates/_modules/progress-tracking/filesystem/MODULE.md) |
| `github-issues` | The repo already runs on GitHub Issues. | [`_modules/progress-tracking/github-issues/`](../../templates/_modules/progress-tracking/github-issues/MODULE.md) |
| `linear` | Product teams already in Linear. | [`_modules/progress-tracking/linear/`](../../templates/_modules/progress-tracking/linear/MODULE.md) |
| `jira` | Enterprise or regulated teams already in Jira. | [`_modules/progress-tracking/jira/`](../../templates/_modules/progress-tracking/jira/MODULE.md) |
| `none` | Ephemeral, in-conversation tasks only. | — |

---

## `methodology`

Mechanically-enforced development discipline. Each key is an independent boolean.

| Key | Default | Module | Turn on when |
|---|---|---|---|
| `tdd` | `true` | [`_modules/methodology/tdd/`](../../templates/_modules/methodology/tdd/MODULE.md) | You write deterministic code with a test runner. Keep on by default. |
| `spec_driven` | `true` | [`_modules/methodology/spec-driven/`](../../templates/_modules/methodology/spec-driven/MODULE.md) | The work is non-trivial; you want a `specs/` contract before code. Keep on. |
| `eval_driven` | `false` | [`_modules/methodology/eval-driven/`](../../templates/_modules/methodology/eval-driven/MODULE.md) | Anywhere the agent ships LLM/ML output. Evals are unit tests for non-deterministic surfaces. |
| `bdd` | `false` | [`_modules/methodology/bdd/`](../../templates/_modules/methodology/bdd/MODULE.md) | Non-technical stakeholders sign off on behaviour via Gherkin `.feature` files. |

---

## `orchestration`

Agent topology. Start single-agent; escalate only when the work *genuinely* parallelises.

| Value | When to use | Module installed |
|---|---|---|
| **`single-agent`** *(default)* | One well-equipped agent. The correct default per the 2026 consensus. | None added beyond `_base`. |
| `supervisor-worker` | Tasks decompose into independent sub-questions; aggregation is cheap. | [`_modules/orchestration/supervisor-worker/`](../../templates/_modules/orchestration/supervisor-worker/MODULE.md) |
| `pipeline` | Steps are knowable in advance and gating is valuable (spec → review → implement → test). | [`_modules/orchestration/pipeline/`](../../templates/_modules/orchestration/pipeline/MODULE.md) |
| `blackboard` | State is durable, agents are heterogeneous, next action depends on shared context. | [`_modules/orchestration/blackboard/`](../../templates/_modules/orchestration/blackboard/MODULE.md) |

See [`AGENT_ROLES.md`](../AGENT_ROLES.md) for the full topology guide.

---

## `safety`

Irreversible-action gates beyond the four `_base` hooks (which always ship — see [`explanation/non-negotiables.md`](../explanation/non-negotiables.md)).

| Key | Default | Module | Turn on when |
|---|---|---|---|
| `two_key` | `false` | [`_modules/safety/two-key/`](../../templates/_modules/safety/two-key/MODULE.md) | Production deploys, financial actions, deletions — anything that needs a human-issued typed token the model cannot generate. |
| `kill_switch` | `false` | [`_modules/safety/kill-switch/`](../../templates/_modules/safety/kill-switch/MODULE.md) | Long-running autonomous loops. Three-level out-of-band stop. |
| `sandbox` | `false` | [`_modules/safety/sandbox/`](../../templates/_modules/safety/sandbox/MODULE.md) | The agent ingests untrusted input (PR descriptions, web fetches, issue bodies). Restricts filesystem + network egress. |

---

## `hitl`

Human-in-the-loop gates. Both default to `true`. The harness should *direct* human attention, not eliminate it.

| Key | Default | Behaviour |
|---|---|---|
| `hitl.plan_mode_default` | `true` | Non-trivial work pauses for plan approval before any Edit/Write. |
| `hitl.diff_review_required` | `true` | The agent must surface every diff for review before claiming "done". |

These keys are read by `_base` hooks and by the methodology modules; they do not install separate modules.

---

## `domain`

Curated, layered domain content. See [`reference/domains.md`](domains.md) for the catalog.

| Key | Type | Behaviour |
|---|---|---|
| `domain.pack` | enum or `""` | The domain pack to layer on top. Empty string = base-only. |
| `domain.subdomain` | string or `""` | For three-layer packs (currently `web/` only), the sub-domain to assemble — e.g. `frontend-app`. Empty for v1 thin recipes. |
| `domain.addons` | list of strings | Domain-scoped extras layered after the sub-domain. Currently only `web/` ships addons; see [`templates/web/_addons/`](../../templates/web/_addons/). |

**Detection rules** (handled by `assemble.sh`):

- If the config path is `<domain>/<subdomain>/harness.config.yml` *and* there is a `DOMAIN.md` in `<domain>/`, the pack is applied as **domain + sub-domain**, and addons are layered.
- If the config path is `<domain>/harness.config.yml`, it is treated as a **v1 thin recipe** — only the `files/` and `claude-md.md` at that level apply; addons are not loaded.

---

## `agents`

Curated agent roster picked from a sub-domain's `files/.claude/agents/`.

| Key | Type | Default | Behaviour |
|---|---|---|---|
| `agents.team` | `curated` \| `none` | `curated` | `curated` installs the sub-domain's whole roster. `none` removes every specialist agent after copy (the `_base` general-purpose set stays). |
| `agents.exclude` | list of agent file basenames | `[]` | Removes named agents from the installed roster after copy. |
| `agents.include` | list of `<domain>/<subdomain>/<agent-name>` paths | `[]` | Adds agents à-la-carte. Source is `templates/<domain>/<subdomain>/files/.claude/agents/<agent-name>.md`. |

---

## `docs`

| Key | Type | Default | Behaviour |
|---|---|---|---|
| `docs.context7_mcp` | bool | `true` *(in domain recipes)* | When the domain pack ships a `files/.claude/context7.mcp.json.fragment`, it is merged into `.mcp.json` so agents fetch current library docs at runtime. Set `false` for a dossier-only workflow. |

If the active domain pack does not ship a Context7 fragment, this key is a no-op.

---

## Parser notes

`assemble.sh` ships a deliberately small YAML reader:

- Two-space indentation is required for nested keys.
- Only top-level sections (`memory:`, `progress:`, …) and their direct children are read.
- Lists use bracket form: `addons: [nextjs, tailwind-shadcn]`. Block-list (`- nextjs`) is not parsed.
- Inline `# comments` are stripped.
- Quoted strings are not required; values are read raw.

Two consequences worth remembering:

1. The parser does *not* validate the schema. Misspelt keys are silently ignored (the corresponding module is just not installed). Run `./templates/tests/run.sh` after editing a config to catch drift.
2. Add new top-level keys cautiously — `assemble.sh` only handles the ones above. See [`reference/assemble-cli.md`](assemble-cli.md) for how to extend the parser.

---

## See also

- [`reference/assemble-cli.md`](assemble-cli.md) — what `assemble.sh` does with this config.
- [`reference/assembled-output.md`](assembled-output.md) — what the resulting `.claude/` tree contains.
- [`how-to/customize-modules.md`](../how-to/customize-modules.md) — recipes for changing the values above.
- [`templates/harness.config.yml`](../../templates/harness.config.yml) — the canonical reference manifest, with inline commentary.
