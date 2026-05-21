# Agentic Roles, Topologies & Orchestration — A 2026 Reference

> Companion to [`HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md). Covers "the agentic part" of a harness: when one agent suffices, when to escalate to multi-agent, the canonical topologies, the role catalog, sub-agent design principles, communication patterns, evaluation, and frameworks.
>
> **The 2026 consensus.** Start with **one well-equipped agent**. Escalate to *isolated* sub-agents only when the task decomposes naturally. Treat orchestration as **context engineering + tool-permission engineering + return-shape engineering**, not as agent-personality theatre. The June-2025 collision between Cognition's *Don't Build Multi-Agents* and Anthropic's *How we built our multi-agent research system* looked like a war; nine months later both ship orchestrator-plus-isolated-subagents architectures, and OpenAI Agents SDK, Microsoft Agent Framework 1.0, Google ADK, Cloudflare Agents, and Claude Code subagents have all converged on the same primitives.

---

## Table of Contents

- [1. The single-agent baseline](#1-the-single-agent-baseline)
- [2. Canonical multi-agent topologies](#2-canonical-multi-agent-topologies)
- [3. The canonical role catalog](#3-the-canonical-role-catalog)
- [4. Sub-agent design principles](#4-sub-agent-design-principles)
- [5. The fresh-subagent-per-task pattern](#5-the-fresh-subagent-per-task-pattern)
- [6. Communication patterns](#6-communication-patterns)
- [7. Evaluation & observability](#7-evaluation--observability)
- [8. Real-world references](#8-real-world-references)
- [9. Frameworks → roles fit](#9-frameworks--roles-fit)
- [10. Anti-patterns](#10-anti-patterns)

---

## 1. The single-agent baseline

Anthropic's [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents) (Dec 2024, still canonical) lays the rule that frames everything else:

> **"Always start with the simplest solution possible, and only increase complexity when needed."**

The post argues that across dozens of customer engagements, the most successful production agents were not built on heavyweight frameworks but on *simple, composable patterns* (prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer) implemented directly against an LLM API.

Simon Willison's running commentary across 2025 made the same point sharper: he was openly skeptical of multi-agent architectures because *"you can usually get something useful done with a single, carefully-crafted prompt against a frontier model"* — and he only flipped after Anthropic published the multi-agent research-system writeup.

Karpathy's "decade of agents" framing reinforces the tempo: 2025–2035, not 2025 alone, and the right primitive today is a *partially autonomous co-pilot* with an "autonomy slider," not a fully autonomous swarm.

**The harness rule.** The default agent is *one* agent with the right tools, the right skills, the right context window. Multi-agent topology is a controlled escalation, not a starting point. Anthropic's own multi-agent research system uses ~15× the tokens of a chat, so the unit economics only work for tasks where parallel exploration genuinely beats deeper sequential reasoning: open-ended research, large-scale codebase fan-out, parallel migrations.

---

## 2. Canonical multi-agent topologies

The 2026 vocabulary is now stable. A harness should support these as named patterns, not ad hoc inventions:

### Supervisor / orchestrator-worker

One lead agent decomposes the task, spawns N specialist workers in parallel, aggregates. Anthropic's research system (Opus lead + 3–5 Sonnet subagents in parallel, each calling 3+ tools in parallel; 90% latency cut on complex queries; lead-agent + subagent achieved **90.2% uplift** over single Opus on Anthropic's internal research eval). LangGraph's [supervisor pattern](https://reference.langchain.com/python/langgraph-supervisor) and the [langgraph-supervisor-py](https://github.com/langchain-ai/langgraph-supervisor-py) library codify it.

**Use when** tasks decompose into independent sub-questions and aggregation is cheap.

### Swarm / handoff

Peer agents pass control to each other; whichever agent currently holds the conversation owns the next response. Core of OpenAI's Agents SDK — handoffs are first-class (`handoff()`), explicitly distinguished from "agents-as-tools" in the [orchestration docs](https://developers.openai.com/api/docs/guides/agents/orchestration). Originated in OpenAI's experimental [Swarm](https://github.com/openai/swarm), now production in Agents SDK.

**Use when** a specialist should *own* the next response (e.g., billing agent for a refund question), not merely be consulted.

### Blackboard

Agents coordinate by reading/writing a shared workspace (file system, database, scratchpad). How Claude Code subagents *actually* coordinate in practice — through the file system and CLAUDE.md. Recent academic work ([arxiv 2510.01285](https://arxiv.org/abs/2510.01285)) shows blackboard architectures yielding 13–57% relative gains on data-discovery tasks while *reducing* per-agent prompt length, alleviating the memory bottleneck. Notion's "Token Town" treats databases as the blackboard primitive — agents invoke other agents and memory is just *pages and databases*.

**Use when** state is durable, agents are heterogeneous, and the next-action decision depends on shared context.

### Debate / critique

Agents argue or critique each other to converge on a better answer. Basis of generator-critic loops and Anthropic's two-stage review (spec-compliance reviewer then code-quality reviewer).

**Critical caveat:** 2025 research established naive debate is *fragile*. [arxiv 2509.23055](https://arxiv.org/pdf/2509.23055) (*Peacemaker or Troublemaker: How Sycophancy Shapes Multi-Agent Debate*) and [2509.05396](https://arxiv.org/pdf/2509.05396) (*Talk Isn't Always Cheap*) show that homogeneous debaters become progressively *more* sycophantic over rounds, and group accuracy can decline as exchanges multiply. The [CONSENSAGENT framework (ACL 2025)](https://aclanthology.org/2025.findings-acl.1141/) and DTE training mitigate this.

**Use only with** heterogeneous models, hard convergence criteria, max-rounds cap.

### Pipeline / sequential

A fixed graph of stages, each consuming the previous stage's output, often with programmatic gates. Anthropic's *prompt chaining* pattern. LangGraph's natural shape — nodes and edges in a DAG with conditional routing.

**Use when** steps are knowable in advance and gating is valuable (e.g., spec → architect-review → implement → test).

### Hierarchical

Orchestrators dispatch sub-orchestrators that dispatch workers. LangGraph's [Hierarchical Agent Teams](https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/). Notion's "manager agents supervising dozens of specialized agents." Rakuten's "ambient agent breaking complex tasks into 24 parallel Claude Code sessions."

**Use when** span of control exceeds ~5–10 workers per supervisor.

### Market / auction

Agents bid for tasks; the manager awards based on bid. Classic Contract Net Protocol applied to LLMs. 2025–2026 research (DALA, MarketBench, AucArena) shows the pattern is theoretically clean but practically unreliable because *current models forecast neither their success probability nor their token usage well*, and those errors compound through the auction.

**Use rarely; mostly research-stage.**

---

## 3. The canonical role catalog

By 2026 a stable role catalog has emerged. Each role is defined by four dimensions: **system prompt shape, tool set, model tier, context isolation**. Synthesized from [Anthropic Code Review plugin](https://claude.com/plugins/code-review), [VoltAgent awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents), [wshobson/agents](https://github.com/wshobson/agents), [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills), and the [Developers Digest 2026 Playbook](https://www.developersdigest.tech/blog/claude-code-agent-teams-subagents-2026).

| Role | Model | Tools | Context | Returns |
|---|---|---|---|---|
| **Planner / Architect / Spec Writer** | Opus-class with extended thinking | Read, Glob, Grep, WebFetch — **no Edit/Write/Bash** | Fresh, large | Typed plan with acceptance criteria, file paths, verification steps |
| **Researcher / Explorer** | Sonnet/Opus | Read, Glob, Grep, WebFetch, WebSearch — no mutating tools | Fresh, scoped | Structured summary with citations |
| **Implementer / Coder** | Sonnet (fast, capable) | Read, Edit, Write, Bash, Grep, Glob | Bounded — single ticket/file/task | Diff + summary |
| **Reviewer / Critic** | **Different model family** than implementer | Read-only | Fresh | Structured rubric output (passes spec? code quality?) |
| **Tester** | Often Haiku — fast iteration | Bash, Edit (test files only) | Scoped to test surface | Test pass/fail + coverage report |
| **Debugger** | Sonnet/Opus | Read, Edit, Bash; **bounded depth** (max steps, spawn budget) | Bounded | Hypothesis-driven trace + fix proposal |
| **Refactorer** | Sonnet | Edit + git; **no Write to non-existing files** (refactoring reshapes existing code) | Scoped to module | Refactor diff + behavior-preservation evidence |
| **Documenter** | Haiku/Sonnet | Edit/Write restricted to `.md` files; Read everywhere | Wide read, narrow write | Docs diff |
| **Integrator / Merger** | Sonnet | Git ops, conflict resolution | Often runs in separate worktree | Merged branch, conflict log |
| **Security auditor / Red teamer** | Opus-class | Read + scanning (semgrep, gitleaks) + WebFetch CVE — **no Edit** | Fresh per audit | Findings list with file/line + severity |
| **Compliance / Governance agent** | Sonnet | Read-only on code; Write only to audit log | Fresh | Compliance report; audit-trail entry |
| **DevOps / SRE / Deployer** | Sonnet | Restricted Bash (whitelist of `kubectl get *`, `terraform plan`); two-key for prod | Per-environment subagent | Deploy plan + postcondition checks |
| **Data engineer / Analyst** | Sonnet | Warehouse MCPs (BigQuery, Snowflake, Postgres); **no destructive SQL** at the connection level | Scoped to dataset | Query results + provenance |
| **ML researcher** | Opus | Train/eval scripts; experiment tracking required (MLflow/W&B) | Spawn budget enforced | Experiment results + artifact pointers |
| **Domain expert** (financial, legal, medical) | Opus | Domain-specific guardrails (PII redaction, regulatory citation requirements) | Fresh per matter | Domain-validated output with citations |
| **UX/UI designer** | Sonnet | Playwright + shadcn/ui MCPs + screenshot loop | Visual iteration loop | Render → critique → edit cycle output |
| **Comms / Drafter** | Sonnet/Haiku | **Drafts but never sends** — write to draft surface only | Scoped to recipient | Draft for human/publisher review |

### Notes on roles that need extra care

**Reviewer / Critic.** *Different model family or different model* than the implementer is non-negotiable. Same model = sycophancy cascade. Anthropic's two-stage review uses spec-compliance reviewer first, code-quality reviewer second — only runs the second after the first passes ([Superpowers code-quality-reviewer-prompt](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/code-quality-reviewer-prompt.md)).

**Comms / Drafter.** Always writes to a draft surface; a human or a separate "publisher" role with explicit authority is required to send. This is the canonical mitigation for prompt injection in the **Agents Rule of Two** model — see §10.

**DevOps / SRE / Deployer.** [Anthropic's Rule of Two](https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security) limits any session to ≤2 of {untrusted inputs, sensitive systems, external state change}. The deployer almost always has the last two, so it must never see untrusted input.

---

## 4. Sub-agent design principles

Six principles converged on by 2026:

### Least privilege on tools

Each subagent's config explicitly lists allowed tools. Anthropic recommends "the minimum set of permissions required for each subagent's role, limiting the blast radius in sensitive environments" ([InfoQ Aug 2025](https://www.infoq.com/news/2025/08/claude-code-subagents/)). The reviewer sees Read/Grep/Glob; the implementer sees Edit/Write/Bash. **Never the same set.**

### Model routing per role

Three-tier convention is now stable: **Haiku triages, Sonnet executes, Opus reasons** ([Augment routing guide](https://www.augmentcode.com/guides/ai-model-routing-guide)). Industry-reported savings: up to 79% cost reduction at equal output quality. Practical rule: *planner* and *critic* get the strongest model; *implementer* gets the fast one; *triager* gets the cheap one. Anthropic's research system uses this exact split (Opus lead, Sonnet workers).

### Context isolation vs shared context

The Cognition vs Anthropic debate ultimately resolved as: **isolation is right for parallel exploration; shared context is right for sequential coherent decisions.** Cognition's "Flappy Bird" failure mode — one subagent builds Mario backgrounds while another builds non-game-asset birds — happens precisely when isolation is applied to a task that requires unified design decisions. The 2026 consensus: **isolate research, share design.**

### Spawn budgets and recursion guards

Every harness needs explicit `max_subagents`, `max_depth`, per-subagent `max_steps`. Claude Code's 10-simultaneous-subagent ceiling (2026) is a hard limit; the harness should set softer limits per role. Without these, orchestrator-worker degenerates into runaway recursion with the lead endlessly delegating.

### Return-shape contracts

The parent should expect a *typed* return from a subagent — JSON with named fields, not free-form prose. This is what makes aggregation reliable and prevents verbose subagent logs from polluting the parent's context. OpenAI Agents SDK enforces this via Pydantic output types; Anthropic subagents do it via prompt-enforced structure.

### Two-stage review

**Spec compliance first, then code quality.** Only escalate to the second reviewer if the first passes. This is the structure of the Superpowers `subagent-driven-development` skill and the basis of Anthropic's multi-agent code-review plugin (April 2026).

### Different model family for evaluator

Same-model evaluation is sycophantic. When you generate with Sonnet, evaluate with Opus or with a Gemini/GPT-class model. **One of the few places to deliberately mix providers.**

---

## 5. The fresh-subagent-per-task pattern

Jesse Vincent's [obra/superpowers](https://github.com/obra/superpowers) (~93k GitHub stars by late 2025, the most popular Claude Code plugin) popularized the pattern that has since been adopted by Anthropic, Cognition (post-pivot), and most serious harnesses:

> **For each task in the plan, spawn a fresh subagent in a clean context, execute the task, run the two-stage review, return only the diff and a summary.**

The problem this solves is *context drift*: in long single-context sessions, the test-writer's intent leaks into the implementer's context and the implementer ends up writing code to make tests pass in ways the spec didn't intend; the reviewer's earlier praise of an approach makes the reviewer reluctant to criticize it later; debugging artifacts pollute subsequent feature work. By forcing a fresh context per task, Superpowers eliminates this leakage and enforces true red/green TDD.

**When it's overkill:** short bug fixes (single change, no test), exploratory spikes, or anything where the cost of subagent spin-up (context re-loading, planning re-cost) exceeds the cost of in-context drift. Superpowers itself recommends inline execution for tasks under ~2 minutes.

---

## 6. Communication patterns

Four sanctioned patterns plus one anti-pattern:

| Pattern | Use |
|---|---|
| **Parent → child via tool-result return** | Default in Claude Code subagents and OpenAI Agents SDK's `agent.as_tool()`. Parent invokes the subagent; subagent returns a structured summary. Subagent's full transcript is *not* exposed to the parent. |
| **Blackboard via file system** | Subagents write to known locations (`docs/research/`, `tmp/critic-report.md`); the orchestrator reads them. Notion uses databases as the blackboard. |
| **Event-driven via hooks** | Hooks fire on tool-call/edit/commit events; specialist agents subscribe (e.g., a security-auditor agent on every `Write` to `.env*`). How Claude Code's plugin system and Cloudflare Agents' workflow primitives both implement reactive coordination. |
| **Structured output / typed return contracts** | Pydantic (OpenAI Agents), TypeScript types (Cloudflare), JSON schemas (Anthropic). Always typed. |

**Anti-pattern: agents talking in free-form natural language.** AutoGen's GroupChat made this fashionable in 2024, but by 2026 it's recognized that free-form agent dialog is where sycophancy, context bloat, and untraceable failure modes incubate. Even Microsoft's Agent Framework 1.0 (April 2026) ships GroupChat as one orchestration option among several, no longer the default — *sequential handoffs* and *Magentic-One task-oriented planning* are foregrounded.

---

## 7. Evaluation & observability

Multi-agent observability requires three things single-agent monitoring doesn't:

1. **Per-agent traces with parent linkage.** A nested-span trace where each subagent invocation is a child span of the orchestrator's tool call. LangSmith, Langfuse, Helicone, AgentOps all support this; LangSmith specifically captures step-level cost and latency attribution per agent.
2. **Cost per agent / per role / per task.** Token spend attributed to the role, not just the model. This is how teams discover that their critic subagent is silently consuming 40% of the spend because it re-reads the entire diff three times per review.
3. **Quality per role.** Different evals for different roles — planner judged on plan completeness, critic on caught-bug recall, implementer on test pass rate. A single end-to-end eval (the temptation) hides which role is broken.

Anthropic's research-system writeup explicitly attributes 95% of BrowseComp performance variance to three factors — token usage (~80%), tool calls, model choice — and observability is what made that decomposition possible.

---

## 8. Real-world references

Load-bearing case studies a 2026 harness designer should be able to cite from memory:

- **[Anthropic multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system).** Opus lead + Sonnet subagents, 90.2% uplift over single Opus on internal research eval, 90% latency cut via parallelization, ~15× chat token cost.
- **[Rakuten + Claude Managed Agents](https://claude.com/customers/rakuten).** 24 days → 5 days delivery (79% cut). 7-hour autonomous coding sessions. "Ambient agent" decomposing into 24 parallel Claude Code sessions across the monorepo.
- **[Notion's Token Town](https://www.latent.space/p/notion).** 50-person AI infra team, manager agents supervising dozens of specialists, databases as the blackboard, the feature was rebuilt 4–5 times before production.
- **Shopify** — an "unlimited Opus" budget for engineering. Internal teams report Opus 4.5/4.6 making multi-agent workflows in Claude Code feel reliable rather than fragile; settings.json `sessionLimit` of 500K tokens is a common ceiling before forced compaction.
- **[OpenAI Frontier / "Token Billionaires"](https://www.latent.space/p/harness-eng).** Ryan Lopopolo, April 2026: >1M LOC codebase with 0% human-written code and 0% pre-merge human review, >1B tokens/day (~$2–3k/day in cached spend). Canonical existence-proof that fully-autonomous mass production of code in a hardened harness is real.
- **[Cloudflare Agents SDK](https://blog.cloudflare.com/build-ai-agents-on-cloudflare/).** Each agent runs on a Durable Object with its own SQLite + WebSocket; Project Think adds persistent workspaces, sandboxed code execution, durable long-running tasks, sub-agent coordination as platform primitives. Thousands of production agents.

---

## 9. Frameworks → roles fit

| Framework | Best for |
|---|---|
| **[LangGraph](https://www.langchain.com/langgraph)** | DAG-native, full audit trail, supervisor library. Hierarchical, pipeline, deterministic gating. Pick when you need replayability and graph-shaped workflows. |
| **[CrewAI](https://github.com/crewaiinc/crewai)** | Role-based, "crews" with backstories. Small fixed-role teams (<20 LOC), business-workflow automation. Easiest mental model. |
| **AutoGen / AG2** | Conversational GroupChat origin. Microsoft is shifting strategic focus to the broader Agent Framework; AutoGen receives security patches but limited new features. |
| **[OpenAI Agents SDK](https://openai.github.io/openai-agents-python/)** | Agents + handoffs + guardrails. Swarm/handoff topology; billing/triage style routing. |
| **[Anthropic sub-agents (Claude Code)](https://code.claude.com/docs/en/sub-agents)** | Pragmatic, file-system-coordinated, up to 10 simultaneous subagents (2026), per-subagent tool restriction. Coding harnesses; supervisor + isolated workers. |
| **[Microsoft Agent Framework 1.0](https://devblogs.microsoft.com/agent-framework/microsoft-agent-framework-version-1-0/)** (April 2026 GA) | .NET + Python, A2A protocol, MCP, sequential handoffs + GroupChat + Magentic-One. Enterprise .NET shops; multi-agent workflows needing standardized A2A. |
| **Google ADK** | Multimodal-first, A2A protocol, Gemini multimodal capabilities. Workflows requiring image/video/audio agents alongside text. |
| **Cloudflare Agents SDK** | Durable-Object-per-agent, WebSocket streaming, sandboxed code execution. Long-running, stateful, edge-distributed agents. |

---

## 10. Anti-patterns

The most expensive failure modes, all documented in production:

1. **Cargo-culted multi-agent for sequential tasks.** If steps are inherently sequential, multi-agent adds latency, cost, and context fragmentation with no upside. This was Cognition's June-2025 indictment, and it remains correct for that class of task.

2. **Sub-agents inheriting parent credentials.** Violates least privilege, blows past the **Agents Rule of Two**, and turns a subagent compromise into a full-system compromise. Each subagent should hold scoped credentials (or none).

3. **Sub-agent verbose logs leaking into parent context.** If the orchestrator sees the full transcript of every subagent, you've reconstructed the single-agent context-bloat problem with extra steps. **Return summaries only.**

4. **Debate loops without convergence criteria.** Without a max-rounds cap and an explicit convergence check, debate degrades to either runaway disagreement or sycophantic agreement.

5. **Sycophancy compounding.** Same-model reviewer praises same-model implementer; "looks good!" cascades. Mitigation: cross-family review, structured rubric, blind review (reviewer doesn't see who wrote the code).

6. **No spawn budget → recursion runaway.** Orchestrator-worker pattern with no `max_subagents` or `max_depth` is one prompt-injection or one ambiguous task away from exponential blowup.

7. **Same model for generator and reviewer.** See sycophancy. Always different model, ideally different family.

8. **Agents holding production credentials.** Combine with the **Rule of Two**: an agent that holds prod credentials must not also process untrusted input or change external state freely. Prefer drafter-then-publisher patterns where the drafter is unprivileged and the publisher requires explicit human or rule-based approval.

9. **Free-form natural-language inter-agent chat as the primary protocol.** Use typed contracts.

10. **Skipping evaluation per role.** End-to-end-only evals hide which role is broken. The Anthropic 95%-variance decomposition is only possible because each layer is independently measured.

---

## Closing synthesis

By May 2026 the agentic part of a coding harness has a clear shape:

- **One strong agent by default.**
- **A small library of named topologies** (supervisor, swarm, blackboard, debate, pipeline, hierarchical) deployed deliberately.
- **A stable role catalog** with role-specific tool restrictions and model routing.
- **Fresh subagents per task** with two-stage review.
- **Typed structured returns.**
- **Per-agent observability.**
- **The Agents Rule of Two enforced at the credential boundary.**

The frameworks have converged (Anthropic, OpenAI, Microsoft, Google, Cognition, Cloudflare all support the same primitives now). Open problems have moved from "should we use multi-agent?" to:

- How do we make per-agent context, cost, and quality observable enough to debug?
- How do we keep the Rule of Two intact when agents start managing other agents?

That, more than anything else, is the agentic frontier the harness has to keep up with.

---

## Sources

### Anthropic
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Code Review plugin](https://claude.com/plugins/code-review) and [Code Review for Claude Code](https://claude.com/blog/code-review)
- [Claude Code — Create custom subagents](https://code.claude.com/docs/en/sub-agents)
- [Rakuten case study](https://claude.com/customers/rakuten)
- [Claude Code Advanced Patterns: Subagents, MCP, and Scaling (PDF)](https://resources.anthropic.com/hubfs/Claude%20Code%20Advanced%20Patterns_%20Subagents,%20MCP,%20and%20Scaling%20to%20Real%20Codebases.pdf)

### Multi-agent debate & blackboard
- [Cognition — Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents) and [Multi-Agents: What's Actually Working](https://cognition.ai/blog/multi-agents-working)
- [CTOL — AI Leaders Clash Over Agent Architecture](https://www.ctol.digital/news/ai-leaders-clash-agent-architecture-cognition-anthropic-strategies/)
- [Simon Willison — Notes on Anthropic's multi-agent research system](https://simonwillison.net/2025/Jun/14/multi-agent-research-system/)
- [Lethal trifecta for AI agents](https://simonw.substack.com/p/the-lethal-trifecta-for-ai-agents)
- [Agents Rule of Two — Oso](https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security)
- [arxiv 2509.23055 — Peacemaker or Troublemaker](https://arxiv.org/pdf/2509.23055)
- [arxiv 2509.05396 — Talk Isn't Always Cheap](https://arxiv.org/pdf/2509.05396)
- [CONSENSAGENT (ACL 2025)](https://aclanthology.org/2025.findings-acl.1141/)
- [arxiv 2510.01285 — LLM-based Multi-Agent Blackboard System](https://arxiv.org/abs/2510.01285)
- [Building Intelligent Multi-Agent Systems with MCPs and the Blackboard Pattern](https://medium.com/@dp2580/building-intelligent-multi-agent-systems-with-mcps-and-the-blackboard-pattern-to-build-systems-a454705d5672)
- [arxiv 2604.23897 — MarketBench](https://arxiv.org/html/2604.23897)

### Frameworks
- [LangGraph](https://www.langchain.com/langgraph) and [Multi-Agent Workflows](https://blog.langchain.com/langgraph-multi-agent-workflows/) and [Hierarchical Agent Teams](https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/) and [langgraph-supervisor-py](https://github.com/langchain-ai/langgraph-supervisor-py)
- [LangSmith Observability](https://docs.langchain.com/langsmith/observability) and [AI Agent Observability](https://www.langchain.com/articles/agent-observability)
- [CrewAI](https://github.com/crewaiinc/crewai)
- [OpenAI Agents SDK](https://openai.github.io/openai-agents-python/) and [Handoffs](https://openai.github.io/openai-agents-python/handoffs/) and [Orchestration and handoffs](https://developers.openai.com/api/docs/guides/agents/orchestration) and [openai/swarm](https://github.com/openai/swarm)
- [Microsoft Agent Framework 1.0 GA](https://devblogs.microsoft.com/agent-framework/microsoft-agent-framework-version-1-0/) and [microsoft/agent-framework](https://github.com/microsoft/agent-framework)
- [Google ADK — Gemini Enterprise Agent Platform](https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/adk)
- [Cloudflare Agents docs](https://developers.cloudflare.com/agents/) and [Building agents with OpenAI and Cloudflare's Agents SDK](https://blog.cloudflare.com/building-agents-with-openai-and-cloudflares-agents-sdk/) and [Project Think](https://blog.cloudflare.com/project-think/)

### Practitioner / case studies
- [Lilian Weng — LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/)
- [Karpathy — Software 3.0 (Latent Space)](https://www.latent.space/p/s3)
- [Latent Space — Extreme Harness Engineering for Token Billionaires](https://www.latent.space/p/harness-eng)
- [Latent Space — Notion's Token Town](https://www.latent.space/p/notion)
- [Jesse Vincent — obra/superpowers](https://github.com/obra/superpowers) and [code-quality-reviewer-prompt](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/code-quality-reviewer-prompt.md)
- [blog.fsck.com — Superpowers (Oct 2025)](https://blog.fsck.com/2025/10/09/superpowers/)
- [InfoQ — Claude Code Subagents Enable Modular AI Workflows](https://www.infoq.com/news/2025/08/claude-code-subagents/)
- [InfoQ — Anthropic Introduces Agent-Based Code Review](https://www.infoq.com/news/2026/04/claude-code-review/)
- [Developers Digest — Claude Code Agent Teams, Subagents, and MCP: 2026 Playbook](https://www.developersdigest.tech/blog/claude-code-agent-teams-subagents-2026)
- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- [wshobson/agents](https://github.com/wshobson/agents)
- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
- [Augment — Best AI Model for Coding Agents in 2026: A Routing Guide](https://www.augmentcode.com/guides/ai-model-routing-guide)

---

## See also (within this repo)

- [`docs/README.md`](README.md) — full documentation index organised by Diátaxis quadrant.
- [`docs/reference/modules.md`](reference/modules.md) — orchestration modules (`supervisor-worker`, `pipeline`, `blackboard`) and when to switch.
- [`docs/how-to/customize-modules.md`](how-to/customize-modules.md) — escalating from `single-agent` deliberately.
- [`docs/HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md) and [`docs/METHODOLOGIES.md`](METHODOLOGIES.md) — companion deep references.
