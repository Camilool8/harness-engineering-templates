# Harness Templates — plug-and-play Claude Code workspaces

A **copy-and-go** harness for any software project. You do not adopt the whole
thing. You pick a base, then pick or discard modules — memory backend, progress
tracking, methodology, orchestration topology, safety gates — and assemble.

> Built on the principles in [`../docs/HARNESS_ENGINEERING.md`](../docs/HARNESS_ENGINEERING.md),
> [`../docs/METHODOLOGIES.md`](../docs/METHODOLOGIES.md) and [`../docs/AGENT_ROLES.md`](../docs/AGENT_ROLES.md).
> **The harness — not the agent — is the contract.** Discipline lives in hooks
> and config, never in prose the model is free to ignore.

---

## 60-second quickstart

```bash
# 1. From your project root, copy this folder in (or clone the repo nearby):
cp -r path/to/templates ./_harness-templates

# 2. Edit the manifest — this is the ONLY file you tune:
$EDITOR ./_harness-templates/harness.config.yml

# 3. Assemble into your project (writes ./.claude/, ./CLAUDE.md, ./.mcp.json):
./_harness-templates/assemble.sh ./_harness-templates/harness.config.yml .

# 4. Make hooks executable, then open Claude Code:
chmod +x ./.claude/hooks/*.sh
claude
```

No script? Every module is also **install-by-hand** — see [Manual assembly](#manual-assembly).

---

## The mental model: base + modules

```
_base/                 ← always. The universal starter.
  CLAUDE.md  .mcp.json  .gitignore  .claude/{settings.json,hooks/,skills/,agents/}

_modules/<category>/<option>/   ← pick what fits, discard the rest
  MODULE.md     ← "adopt if / skip if / install / remove"  — READ THIS FIRST
  claude-md.md  ← snippet appended to your CLAUDE.md
  files/        ← tree copied verbatim into your project

<domain>/              ← optional recipe: a curated base + module selection
```

Every module is **independently removable**. Nothing in `_base/` depends on a
module; modules may depend on each other (declared in their `MODULE.md`).

---

## What you pick — the decision table

| Axis | Config key | Options | Default & when to change |
|---|---|---|---|
| **Memory** — where durable knowledge lives | `memory.backend` | `md-files` · `vector-store` · `knowledge-graph` · `none` | **`md-files`**. Cheap, git-diffable, auditable. Move to `vector-store` only when the corpus outgrows context; `knowledge-graph` when provenance/decay matters (regulated work). |
| **Progress tracking** — where work items live | `progress.backend` | `filesystem` · `github-issues` · `linear` · `jira` · `none` | **`filesystem`** for solo / small. Switch to a ticketing module when a team or external stakeholders already live there. |
| **Methodology** — what discipline is enforced | `methodology.*` | `tdd` `spec_driven` `eval_driven` `bdd` (booleans) | **`tdd` + `spec_driven` on**. Add `eval_driven` for any LLM/ML output; `bdd` when non-technical stakeholders sign off on behavior. |
| **Orchestration** — agent topology | `orchestration.topology` | `single-agent` · `supervisor-worker` · `pipeline` · `blackboard` | **`single-agent`**. Escalate only when work genuinely parallelizes — see `AGENT_ROLES.md`. |
| **Safety** — irreversible-action gates | `safety.*` | `two_key` `kill_switch` `sandbox` (booleans) | Secret-scan + command-guard + audit ship in `_base`. Add `two_key` for prod/money/data-deletion tools; `kill_switch` for autonomous loops; `sandbox` for untrusted input. |
| **Human-in-the-loop** | `hitl.*` | `plan_mode_default` `diff_review_required` | **Both on.** The harness should *direct* human attention, not eliminate it. |

Full commentary lives inline in [`harness.config.yml`](harness.config.yml).

---

## Manual assembly

If you do not want to run `assemble.sh`:

1. Copy the entire contents of `_base/` into your project root.
2. For each module you want, open its `MODULE.md` and follow **Install (manual)** —
   in every case it is: copy `files/` into your project, then paste
   `claude-md.md` into your `CLAUDE.md`.
3. If a module's `files/` contains a `.claude/settings.fragment.json`, merge its
   `hooks` / `permissions` entries into your `.claude/settings.json` (the
   assembler does this automatically with `jq`; by hand it is a copy-paste of the
   array entries). This is how module hooks register without overwriting the base.
4. Fill the `<PLACEHOLDERS>` in `CLAUDE.md`.
5. `chmod +x .claude/hooks/*.sh`.

To **discard** a module later, follow its **Remove** section. Because modules are
isolated directories plus an appended CLAUDE.md section, removal is always a
delete-files + delete-section operation.

---

## Domain recipes

A recipe is a pre-filled `harness.config.yml` plus domain-specific skills, hooks
and MCP servers. Pass it to `assemble.sh` instead of the generic manifest.

| Domain | Recipe | Headline gates |
|---|---|---|
| Web / SaaS | [`web/`](web/) | accessibility-tree verify loop, lint+type PostToolUse |
| Data / ML | [`data/`](data/) | unbounded-SQL block, leakage/p-hacking sentinels, eval ≠ code |
| DevOps / Platform | [`devops/`](devops/) | plan-before-apply, kubectl context guard, OIDC-only |
| Finance / regulated | [`finance/`](finance/) | paper-by-default, two-key, immutable audit, double-entry |
| Mobile | [`mobile/`](mobile/) | simulator-in-the-loop, structured build logs |
| Game | [`game/`](game/) | hot-reload + screenshot loop, asset-GUID awareness |
| Embedded / IoT | [`embedded/`](embedded/) | never-flash-without-dry-run, HIL gate |
| Scientific | [`scientific/`](scientific/) | pinned-env reproducibility, manuscript pipeline |
| Security | [`security/`](security/) | engagement-scope authorization gate, red/blue separation |
| Content / Marketing | [`content/`](content/) | brand-voice guard, schema.org validation |
| Support / Ops | [`ops/`](ops/) | refund threshold gate, drafter ≠ publisher |
| Generic | [`generic/`](generic/) | base only — start here if unsure |

---

## The non-negotiables (baked into `_base`, do not discard)

- **Secret scanner** (PreToolUse on `Write|Edit`) — blocks hardcoded credentials.
- **Command guard** (PreToolUse on `Bash`) — blocks irreversible shell commands.
- **Audit log** (PostToolUse) — append-only `.claude/audit/audit.jsonl`.
- **Verification gate** (Stop) — refuses "done" until `.claude/verify.sh` passes.

These survive `--dangerously-skip-permissions`. That is the point: documentation
is a suggestion, a `PreToolUse` exit-code-2 is the contract.
