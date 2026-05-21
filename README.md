# harness-engineering-templates

![CI](https://github.com/Camilool8/harness-engineering-templates/actions/workflows/ci.yml/badge.svg)

A library of opinionated **Claude Code harness templates** for software engineering across domains — web, data, DevOps, finance, mobile, game, embedded, scientific, security, content, ops.

The premise (per Birgitta Böckeler, Anthropic engineering, METR, and the practitioner consensus of 2025–2026):

> **Agent = Model + Harness.** Templates that lean on the model's good judgment fail their first incident. The harness — not the agent — is the contract.

## Deep references

| Doc | Covers |
|---|---|
| [`docs/HARNESS_ENGINEERING.md`](docs/HARNESS_ENGINEERING.md) | Foundations, the Claude Code primitive reference, per-domain templates (web, data, devops, finance, mobile, game, embedded, scientific, security, content, ops), cross-cutting concerns, universal anti-patterns, curated reading list |
| [`docs/METHODOLOGIES.md`](docs/METHODOLOGIES.md) | Software development methodologies adapted to AI harnesses — SDD, TDD, BDD, ATDD, DDD, Agile/Scrum/Kanban, XP, Waterfall, Lean, DevOps/SRE/GitOps, Design Sprint/Double Diamond, Plan-driven vs Adaptive, Subagent-Driven Development, Vibe vs Agentic, Brainstorm→Plan→TDD→Verify→Review→Ship, Eval-Driven Development |
| [`docs/AGENT_ROLES.md`](docs/AGENT_ROLES.md) | The agentic part — single-agent baseline, multi-agent topologies, the canonical role catalog, sub-agent design principles, the fresh-subagent-per-task pattern, communication patterns, evaluation, frameworks, anti-patterns |

---

## Methodologies — choosing what to layer into your harness

Methodologies are not in conflict; they target different concerns (correctness, coordination, discovery, compliance, measurement). A working harness composes them as a **stack**, not a single choice. The agent transforms the economics of every methodology — collapsing some, demanding others, breaking a few outright. The full treatment lives in [`docs/METHODOLOGIES.md`](docs/METHODOLOGIES.md); this section is the at-a-glance summary.

### The methodology stack

```
audit layer       Waterfall phase gates + signed artifacts (SR 11-7, FDA SaMD, DO-178C)
adaptive layer    Lean MVP variants, discovery vs delivery
cross-cutting     Evals, SRE error budgets, ATDD/BDD for external stakeholders
outer loop        Brainstorm → Plan → TDD → Verify → Review → Ship  (Superpowers canonical)
inner loop        Plan Mode (plan-driven) + TDD (hook-enforced) + subagent dispatch
foundation        SDD spec contract + DDD glossary in CLAUDE.md + XP-style CI
```

### Methodology one-liners

| Methodology | One-line take | Best Claude Code primitive |
|---|---|---|
| **SDD — Spec-Driven Development** | Externalize ambiguity. The spec is the contract the agent works against. | Plan Mode + `specs/` + `superpowers:writing-plans` |
| **TDD — Test-Driven Development** | Single most powerful constraint on an agent. *Tests are an integrity surface, not just an output.* | TDD-Guard hook (PreToolUse) + `superpowers:test-driven-development` |
| **BDD — Behavior-Driven Development** | LLMs are excellent at translating prose ↔ Gherkin; renaissance via Cucumber+Playwright+LLM. | Skill that authors `.feature` files; runner MCP |
| **ATDD — Acceptance Test-Driven Development** | Customer-acceptance criteria as code; agent plays the third amigo. | `specs/`, hooks gating edits on acceptance file presence |
| **DDD — Domain-Driven Design** | Ubiquitous language *is* an agent asset. One bounded context = one subagent. | CLAUDE.md "Ubiquitous Language" + `docs/contexts/` + per-context subagent |
| **Agile / Scrum / Kanban** | Scrum ceremonies break against 24/7 agents. Keep Kanban + retros, kill standups. | Linear/Jira MCP, "ticket-picker" subagent |
| **XP — Extreme Programming** | Survives almost intact. Pair programming = human + agent (human is navigator). | Plan Mode (navigator pause) + CI in the prompt |
| **Waterfall** | Unironically a *good* fit for SR 11-7 / FDA SaMD / DO-178C agent work. | Phase-gate skills + signed audit-log hooks |
| **Lean / Lean Startup** | Agent transforms MVP economics — generate 5 in parallel, measure, kill 4. | Worktrees + `superpowers:dispatching-parallel-agents` |
| **DevOps / SRE / GitOps** | Agents are SRE-native. Error budgets become rate-limits on agent autonomy. | "Must run plan before apply" hooks; per-environment subagents |
| **Design Sprint / Double Diamond** | AI collapses the diamond. Discovery and delivery now overlap. | Brainstorming skill → synthesis → delivery subagents |
| **Plan-driven vs Adaptive** | **Plan-driven inside a task; adaptive outside.** Drift compounds when the agent decides as it goes. | Plan Mode for inner; orchestrator for outer |
| **Subagent-Driven Development** | The 2025–2026 emergent methodology. Fresh subagent per task + two-stage review. *Makes long-horizon agent work possible.* | `superpowers:subagent-driven-development` |
| **Vibe vs Agentic Coding** | Vibe raises the floor for beginners; agentic raises the ceiling for professionals. The harness is what turns one into the other. | The whole repo |
| **Brainstorm → Plan → TDD → Verify → Review → Ship** | The dominant *integrated* methodology in the Claude Code ecosystem. | Superpowers plugin (the canonical loop) |
| **Eval-Driven Development** | Evals are to LLMs what tests are to deterministic code. Husain's nuance: write evaluators *after* observing failures, not before. | `evals/` + Stop-hook running fast subset + cross-model judge |

### By domain

| Domain | Recommended stack |
|---|---|
| Web / SaaS | SDD + Subagent-Driven + TDD + BDD for user flows + Evals + Lean. *Skip heavy Scrum.* |
| Data / ML | SDD + Eval-driven + DDD for the schema language + DocETL-style subagents per stage |
| DevOps / Platform | SRE + GitOps + Subagent-Driven + waterfall change windows for prod |
| Financial / regulated | Waterfall phase gates + SR 11-7 docs + ATDD with auditable acceptance + signed audit + independent validation subagent. **TDD mandatory.** |
| Medical (FDA SaMD) | Financial + Predetermined Change Control + Algorithm Change Protocol + IEC 62304 traceability |
| Avionics (DO-178C) | Maximum waterfall + traceability matrix + DAL-appropriate verification |
| Mobile / Game / Embedded | SDD + TDD where deterministic + visual / HIL verification loops + per-platform subagents |
| Scientific / Research | SDD as manuscript spec + reproducibility skills + eval-driven for any judgment + plan-driven inner / adaptive outer |
| Security | Scope-as-skill + ATDD engagement contract + waterfall evidence gates + adversarial (red) and defensive (blue) subagents cleanly separated |
| Content / Marketing | BDD-style "voice = behavior" + brand-voice eval-driven + Lean A/B + cross-model judging |
| Customer support / Ops | Subagent-Driven (drafter ≠ publisher) + Eval-driven on classification + ATDD for SLA-bound automations |

### Three universal methodology anti-patterns

1. **Cargo-culting Scrum onto async agents.** Daily standups for a fleet that runs 24/7. Replace with Kanban + budgets + retros.
2. **SDD as waterfall in disguise.** A 40-page spec.md is not agile because the agent wrote it. The spec is a *living contract*.
3. **Vibe coding without evals.** The cardinal sin of 2025. You will think it works because the demo worked.

→ Full treatment, source citations, and per-methodology Claude Code primitives in [`docs/METHODOLOGIES.md`](docs/METHODOLOGIES.md).

---

## The agentic part — roles, topologies & orchestration

The 2026 consensus: **start with one well-equipped agent**; escalate to *isolated* sub-agents only when the task decomposes naturally; treat orchestration as **context engineering + tool-permission engineering + return-shape engineering**, not as agent-personality theatre. Full treatment in [`docs/AGENT_ROLES.md`](docs/AGENT_ROLES.md); summary below.

### Topologies (use named patterns, not ad hoc inventions)

| Topology | Use when |
|---|---|
| **Supervisor / orchestrator-worker** | Tasks decompose into independent sub-questions; aggregation is cheap. (Anthropic's research system: 90.2% uplift over single Opus.) |
| **Swarm / handoff** | A specialist should *own* the next response (billing handles refund), not merely be consulted. (OpenAI Agents SDK.) |
| **Blackboard** | State is durable, agents are heterogeneous, next-action depends on shared context. (Notion uses databases as the blackboard.) |
| **Debate / critique** | Two-stage review (spec then quality). *Only* with heterogeneous models, hard convergence criteria, max-rounds cap — naive debate is sycophantic. |
| **Pipeline / sequential** | Steps are knowable in advance and gating is valuable (spec → architect-review → implement → test). |
| **Hierarchical** | Span of control exceeds 5–10 workers per supervisor. (Rakuten: 24 parallel sessions.) |
| **Market / auction** | Rarely; mostly research-stage — current models forecast neither success probability nor token usage well. |

### The canonical role catalog

Each role is defined by four dimensions: **system-prompt shape, tool set, model tier, context isolation**.

| Role | Model | Tools (least privilege) | Returns |
|---|---|---|---|
| **Planner / Architect** | Opus + extended thinking | Read, Glob, Grep, WebFetch — **no Edit/Write/Bash** | Typed plan with acceptance criteria |
| **Researcher / Explorer** | Sonnet/Opus | Read, Glob, Grep, WebFetch, WebSearch | Structured summary with citations |
| **Implementer / Coder** | Sonnet (fast) | Read, Edit, Write, Bash, Grep, Glob — bounded scope | Diff + summary |
| **Reviewer / Critic** | **Different model family** than implementer | Read-only | Structured rubric output |
| **Tester** | Often Haiku | Bash, Edit (test files only) | Pass/fail + coverage |
| **Debugger** | Sonnet/Opus | Read, Edit, Bash; bounded depth | Hypothesis + fix proposal |
| **Refactorer** | Sonnet | Edit + git; **no Write to non-existing files** | Refactor diff + behavior-preservation evidence |
| **Documenter** | Haiku/Sonnet | Edit/Write `.md` only | Docs diff |
| **Integrator** | Sonnet | Git ops; runs in separate worktree | Merged branch + conflict log |
| **Security auditor / Red teamer** | Opus | Read + scanning tools — **no Edit** | Findings list |
| **Compliance / Governance** | Sonnet | Read-only on code; Write only to audit log | Compliance report |
| **DevOps / SRE / Deployer** | Sonnet | Restricted Bash whitelist; two-key for prod | Deploy plan + postcondition checks |
| **Data engineer / Analyst** | Sonnet | Warehouse MCPs; no destructive SQL at connection level | Query results + provenance |
| **ML researcher** | Opus | Train/eval scripts; tracking required | Experiment results + artifact pointers |
| **Domain expert** (financial/legal/medical) | Opus | Domain-specific guardrails | Domain-validated output with citations |
| **UX/UI designer** | Sonnet | Playwright + shadcn MCPs + screenshot loop | Render → critique → edit cycle |
| **Comms / Drafter** | Sonnet/Haiku | **Drafts but never sends** — write to draft surface only | Draft for human/publisher review |

### Six sub-agent design principles

1. **Least privilege on tools.** Reviewer sees Read/Grep/Glob; implementer sees Edit/Write/Bash. *Never the same set.*
2. **Model routing per role.** Haiku triages, Sonnet executes, Opus reasons. Industry-reported cost reduction up to 79%.
3. **Context isolation vs shared.** *Isolate research, share design.* Cognition's "Flappy Bird" failure mode comes from isolating tasks needing unified design decisions.
4. **Spawn budgets and recursion guards.** `max_subagents`, `max_depth`, `max_steps` — without these, orchestrator-worker degenerates into runaway recursion.
5. **Return-shape contracts.** Subagents return *typed* JSON, not free-form prose. Verbose logs stay in the child's context, not the parent's.
6. **Different model family for evaluator.** Same-model evaluation is sycophantic. Sonnet generates, Opus or Gemini judges.

### Communication patterns (and one anti-pattern)

| ✓ | Pattern | Notes |
|---|---|---|
| ✓ | Parent → child via tool-result return | Default. Subagent transcript not exposed to parent. |
| ✓ | Blackboard via file system | Subagents write to known locations; orchestrator reads. |
| ✓ | Event-driven via hooks | Specialist agents subscribe to tool-call/edit/commit events. |
| ✓ | Structured / typed return contracts | Pydantic, TypeScript types, JSON schemas. Always typed. |
| ✗ | **Free-form natural-language inter-agent chat** | Where sycophancy, context bloat, and untraceable failure modes incubate. |

### Frameworks → roles fit

| Framework | Best for |
|---|---|
| LangGraph | Hierarchical / pipeline / deterministic gating; replayability |
| CrewAI | Small fixed-role teams (<20 LOC); business-workflow automation |
| OpenAI Agents SDK | Swarm/handoff topology; billing/triage routing |
| Anthropic sub-agents (Claude Code) | Coding harnesses; supervisor + isolated workers; up to 10 simultaneous |
| Microsoft Agent Framework 1.0 | Enterprise .NET shops; A2A protocol |
| Cloudflare Agents SDK | Long-running, stateful, edge-distributed |

### The Agents Rule of Two

[Anthropic's Rule of Two](https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security): any agent session may hold ≤2 of {**untrusted inputs**, **sensitive systems**, **external state change**}. The deployer almost always has the last two — so it must never see untrusted input. The drafter-then-publisher pattern (drafter is unprivileged; publisher requires explicit approval) is the canonical mitigation.

### Top agentic anti-patterns

1. Cargo-culted multi-agent for sequential tasks
2. Sub-agents inheriting parent credentials
3. Sub-agent verbose logs leaking into parent context
4. Debate loops without convergence criteria
5. Sycophancy compounding (same-model reviewer praising same-model implementer)
6. No spawn budget → recursion runaway
7. Same model for generator and reviewer
8. Agents holding production credentials
9. Free-form natural-language inter-agent chat as the primary protocol
10. Skipping evaluation per role (end-to-end-only evals hide which role is broken)

→ Full treatment, real-world references (Anthropic multi-agent research, Rakuten 24→5 days, Notion's Token Town, OpenAI Frontier "Token Billionaires"), framework deep-dives, and per-role system-prompt patterns in [`docs/AGENT_ROLES.md`](docs/AGENT_ROLES.md).

---

## Repository layout

```
docs/
  HARNESS_ENGINEERING.md   # the master reference (start here)
  METHODOLOGIES.md         # SDD, TDD, BDD, DDD, Agile, Waterfall, etc.
  AGENT_ROLES.md           # topologies, role catalog, orchestration
templates/                 # the plug-and-play harness — see templates/README.md
  README.md                # assembly guide + pick/discard decision table
  harness.config.yml       # the single manifest you tune
  assemble.sh              # one-command assembler (no dependencies)
  _base/                   # universal starter every project copies
  _modules/                # opt-in modules — each with adopt-if/skip-if/remove
    memory/                # md-files | vector-store | knowledge-graph
    progress-tracking/     # filesystem | github-issues | linear | jira
    methodology/           # tdd | spec-driven | eval-driven | bdd
    orchestration/         # supervisor-worker | pipeline | blackboard
    safety/                # two-key | kill-switch | sandbox
  web/ data/ devops/ finance/ mobile/ game/ embedded/
  scientific/ security/ content/ ops/ generic/   # 12 domain recipes
```

## Templates — start here

The [`templates/`](templates/) directory turns this reference into a
**copy-and-go harness**. You do not adopt the whole thing: copy `_base/`, then
pick or discard modules in [`harness.config.yml`](templates/harness.config.yml) —
where memory lives, where progress is tracked, which methodology is enforced,
which orchestration topology, which safety gates — and run `assemble.sh`.

```bash
./templates/assemble.sh templates/web/harness.config.yml ./my-project
```

Every module ships a `MODULE.md` with **adopt-if / skip-if / install / remove**,
so picking and discarding is genuinely plug-and-play. Full guide:
[`templates/README.md`](templates/README.md).

## Contributing

Contributions — new modules, addons, sub-domains, or whole domains — are welcome.
Start with the [Propose new content](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose)
issue template, then read **[CONTRIBUTING.md](CONTRIBUTING.md)** for the step-by-step
guide and **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)**.

Every PR is automatically verified: `./templates/tests/run.sh` runs in CI and
must pass before merge.
