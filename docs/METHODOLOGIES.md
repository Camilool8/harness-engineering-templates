# Software Methodologies in the AI Harness Era — A 2026 Reference

> Companion to [`HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md). Where the master doc covers the *what* of harness primitives and per-domain templates, this doc covers the *how* — the methodologies you compose into the harness so an LLM-powered agent ships code a human will actually merge.
>
> **The thesis.** Methodologies are not in conflict; they target different concerns (correctness, coordination, discovery, compliance, measurement). A working harness composes them as a **stack**, not a single choice. The agent transforms the economics of every methodology — collapsing some, demanding others, breaking a few outright.

---

## Table of Contents

- [The methodology stack](#the-methodology-stack)
- [1. SDD — Spec-Driven Development](#1-sdd--spec-driven-development)
- [2. TDD — Test-Driven Development](#2-tdd--test-driven-development)
- [3. BDD — Behavior-Driven Development](#3-bdd--behavior-driven-development)
- [4. ATDD — Acceptance Test-Driven Development](#4-atdd--acceptance-test-driven-development)
- [5. DDD — Domain-Driven Design](#5-ddd--domain-driven-design)
- [6. Agile / Scrum / Kanban](#6-agile--scrum--kanban)
- [7. XP — Extreme Programming](#7-xp--extreme-programming)
- [8. Waterfall](#8-waterfall)
- [9. Lean / Lean Startup](#9-lean--lean-startup)
- [10. DevOps / SRE / GitOps as methodologies](#10-devops--sre--gitops-as-methodologies)
- [11. Design Sprint / Double Diamond / discovery vs delivery](#11-design-sprint--double-diamond--discovery-vs-delivery)
- [12. Plan-driven vs adaptive](#12-plan-driven-vs-adaptive)
- [13. Subagent-driven development](#13-subagent-driven-development)
- [14. Vibe coding vs agentic coding](#14-vibe-coding-vs-agentic-coding)
- [15. Brainstorm → Plan → TDD → Verify → Review → Ship](#15-brainstorm--plan--tdd--verify--review--ship)
- [16. Eval-driven development](#16-eval-driven-development)
- [Methodology selection by domain](#methodology-selection-by-domain)
- [The three universal anti-patterns](#the-three-universal-anti-patterns)
- [Sources](#sources)

---

## The methodology stack

You don't pick one methodology; you layer them. A working harness composes:

| Layer | Methodologies |
|---|---|
| **Foundation** (every harness) | SDD spec contract + DDD glossary in CLAUDE.md + XP-style CI + verification-before-completion |
| **Inner loop** (per task) | Plan-driven (Plan Mode) + TDD (hook-enforced) + subagent dispatch |
| **Outer loop** (per feature) | Brainstorm → Plan → TDD → Verify → Review → Ship (Superpowers canonical) |
| **Cross-cutting** | Evals for any LLM-judgment surface; SRE error budgets for ops surfaces; ATDD/BDD when stakeholders are external |
| **Adaptive layer** | Lean MVP variants in parallel worktrees when the answer is unknown; discovery-vs-delivery framing for each new initiative |
| **Audit layer** | Waterfall-style phase gates + signed artifacts when SR 11-7, FDA SaMD, or DO-178C apply |

Each section below gives the textbook definition, agent-harness mapping, the Claude Code primitives that implement it, when to choose it, anti-patterns, and pioneers.

---

## 1. SDD — Spec-Driven Development

**Textbook.** Treat an executable, versioned natural-language specification as the source of truth from which code, tests, infrastructure, and docs are derived. Canonical pipeline: `constitution.md → spec.md → plan.md → tasks.md → implementation`. Popularized by [GitHub spec-kit](https://github.com/github/spec-kit) and [AWS Kiro](https://kiro.dev/).

**Agent mapping.** SDD is the methodology that fits agents most naturally because it externalizes the very thing that bottlenecks them: ambiguity. An agent reading a precise `spec.md` is constrained against drift; an agent reading a vague Slack thread will hallucinate scope. Sean Grove's [*The New Code*](https://www.youtube.com/watch?v=8rABwKRsec4) (AI Engineer World's Fair 2025) reframes it as a values shift: code is 10–20% of the value a programmer creates; the other 80–90% is "structured communication" — which a markdown spec captures.

**Best Claude Code primitives.**
- **Plan Mode** = the SDD `/plan` step in primitive form (read-only research before any edit)
- A `specs/` directory committed to the repo and referenced from `CLAUDE.md`
- Skills: `superpowers:writing-plans`, `superpowers:brainstorming`
- Hooks: block file edits when no current `tasks.md` exists
- MCP: Linear, Jira, GitHub for pulling acceptance criteria

**Choose when.** Multi-file features, non-trivial UX, anything crossing a service boundary, anything a junior would need a design doc for. Skip when "the diff fits in one sentence."

**Anti-patterns.**
1. **SDD as waterfall in disguise** — writing a 40-page spec and expecting the agent to one-shot it. The spec is a contract, not a Gantt chart; iterate the spec.
2. **Spec inflation** — auto-generating specs from prompts and never reading them.
3. **Spec without acceptance criteria** — agents will satisfy the prose but fail the unstated test. Always include "how we'll know it's done."

**vs PRD-driven and TDD.** A PRD is product-facing and stops at "what users get"; an SDD spec continues into architecture, contracts, and task decomposition. TDD's source of truth is failing tests; SDD's source of truth is prose plus tests. SDD is a superset — a mature SDD pipeline emits TDD-style tasks at the `/tasks` stage.

**Pioneers.** GitHub spec-kit, AWS Kiro, Sean Grove (OpenAI).

---

## 2. TDD — Test-Driven Development

**Textbook.** Kent Beck's red-green-refactor: write a failing test capturing the next slice of behavior (red), write the minimum code to make it pass (green), then refactor without changing behavior. Tests are the executable specification.

**Agent mapping.** TDD is the single most powerful constraint you can impose on an agent. Beck himself ([*Augmented Coding: Beyond the Vibes*](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes), 2025) calls TDD a "superpower" with AI agents — but warns of the central agentic anti-pattern: **agents will delete or weaken tests to make them pass.** The harness must treat tests as an integrity surface, not just an output.

**Best Claude Code primitives.**
- **Hooks are load-bearing.** [TDD-Guard](https://github.com/nizos/tdd-guard) — a `PreToolUse` hook on `Write|Edit|MultiEdit|TodoWrite` — blocks: implementation without a failing test, over-implementation beyond test requirements, multiple tests added at once
- Superpowers `test-driven-development` skill teaches the cycle in prose; the hook enforces it in code
- A `bash test` slash command + Stop hook running the full suite closes the loop

**Choose when.** Pure functions, business logic, data transformations, any deterministic I/O. Mandatory in regulated codebases. With agents shipping at 10× volume, "the cost of a regression > the cost of writing the test first" is almost always true.

**Anti-patterns.**
1. Letting the agent write the test and the code in the same turn — it will fit them to each other. Force a checkpoint.
2. Allowing test deletion in the same PR that adds features — gate this in CI.
3. Mocking the system under test — agents over-mock; require integration tests for critical paths.
4. TDD theater — writing tests after the fact and back-dating commits.

**Pioneers.** Kent Beck, Pragmatic Engineer podcast (*TDD, AI agents and coding with Kent Beck*), Nizar Selander (TDD-Guard), Jesse Vincent (Superpowers).

---

## 3. BDD — Behavior-Driven Development

**Textbook.** Dan North's reframing of TDD around shared language: tests as Given/When/Then scenarios in Gherkin, authored collaboratively between business and engineering, executed by Cucumber/SpecFlow/Behave/pytest-bdd. Unit of work is the *scenario*, not the test method.

**Agent mapping.** BDD has had an unexpected renaissance in 2025–2026 because LLMs are exceptional at translating between prose and structured Gherkin. Recent work ([*LLMs are making BDD & Gherkin rise again*](https://hungdoan.com/2025/04/25/llms-are-making-bdd-gherkin-rise-again/), [SCITEPRESS *Agentic AI for BDD Testing Using LLMs*](https://www.scitepress.org/Papers/2025/133744/133744.pdf)) shows agents can author Gherkin from user stories, generate step definitions, and self-review for ambiguity. Levi9's [hybrid Cucumber+Playwright+LLM](https://levi9-serbia.medium.com/beyond-prompt-only-testing-a-hybrid-ai-bdd-approach-with-cucumber-and-playwright-82a98a89946d) is the reference. Caveat: 2024 ACM work on Gherkin execution by LLM agents found agents tend to summarize multi-step scenarios — step definitions still need to be code, not prompts.

**Best Claude Code primitives.**
- Skills for "author a Gherkin feature from this user story" and "review for ambiguity"
- MCP for Cucumber/Behave runners
- Hooks requiring a corresponding `.feature` file before code edits in `src/`
- CLAUDE.md should include the project's Gherkin style guide (declarative not imperative, business language not UI language)

**BDD beats TDD when.** Stakeholder is non-technical, acceptance criteria evolve faster than implementation, you need executable documentation, multiple agents/teams need a shared vocabulary, the system has many user-visible flows.

**Anti-patterns.**
1. Letting the agent author Gherkin in UI language ("click the blue button") — locks the spec to the implementation.
2. Generating 200 scenarios from one story.
3. Treating Gherkin as documentation and not running it.

**Pioneers.** Dan North, Aslak Hellesøy (Cucumber), Humanizing Work, Hung Doan, Levi9.

---

## 4. ATDD — Acceptance Test-Driven Development

**Textbook.** Acceptance tests written collaboratively between customer, developer, tester *before* implementation. Often tabular (FitNesse, Concordion, Cucumber). Heavily overlaps BDD but emphasizes the "three amigos" discovery conversation. Gojko Adzic's *Specification by Example* is the canonical text.

**Agent mapping.** The agent can play the third amigo: ingest a user story, ask clarifying questions, propose tabular acceptance criteria, generate the harness. [`swingerman/atdd`](https://github.com/swingerman/atdd) is an explicit "ATDD for Claude Code" implementation. Pattern: customer-facing spec → agent-generated table-driven tests → agent-generated implementation, with the table as the contract.

**Best Claude Code primitives.** Same as BDD: a `specs/` folder, hooks gating edits on the presence of an acceptance file, MCP into the test runner. Plan Mode is where the "three amigos" conversation happens with the human.

**Choose when.** B2B SaaS with explicit customer SLAs, regulated industries with auditable acceptance criteria, projects where the customer is a separate organization, data-heavy features (lots of input/output combinations).

**Anti-patterns.** Same as BDD plus: treating ATDD as a synonym for "QA writes tests later." The "A" is for *acceptance* by the customer, before code.

**Pioneers.** Gojko Adzic, Robert C. Martin, swingerman.

---

## 5. DDD — Domain-Driven Design

**Textbook.** Eric Evans' 2003 book frames complex software around a *model* of the business domain, captured in a *ubiquitous language* shared by experts and engineers. Strategic DDD divides the system into *bounded contexts* with explicit *context maps*; tactical DDD provides patterns (aggregate, entity, value object, repository, domain event). Vaughn Vernon operationalized it.

**Agent mapping.** DDD maps most cleanly to `CLAUDE.md`. The ubiquitous language *is* an agent asset: a glossary of canonical terms with definitions disambiguates the agent against the synonym soup of a real codebase. Bounded context maps tell the agent which directory owns which concept and prevent cross-context coupling. Aggregate roots become architectural fitness functions a hook can verify ("no write to entity X except through aggregate Y"). Vernon's strategic patterns also tell you *when to spawn a subagent* — one bounded context per subagent prevents context pollution.

**Best Claude Code primitives.**
- A CLAUDE.md section titled "Ubiquitous Language" with a term/definition table
- A `docs/contexts/` directory with one file per bounded context
- A subagent per context for refactoring work
- Hooks that grep for forbidden cross-context imports
- MCP into a glossary database for orgs large enough to maintain one

**Choose when.** Any non-trivial business domain (insurance, finance, healthcare, logistics). Especially valuable when the agent must work across many quarters of a long-lived codebase. Skip for thin CRUD apps and pure infra.

**Anti-patterns.**
1. Inventing a glossary the team doesn't actually use.
2. Letting the agent rename concepts without updating CLAUDE.md.
3. Bounded contexts that don't match team boundaries (Conway's Law).

**Pioneers.** Eric Evans (Domain Language), Vaughn Vernon, Martin Fowler's bliki on Ubiquitous Language and Bounded Context.

---

## 6. Agile / Scrum / Kanban

**Textbook.** The 2001 Agile Manifesto's four values, operationalized via Scrum (sprints, standups, retros, roles) or Kanban (WIP limits, pull-based flow, continuous delivery).

**Agent mapping.** **This is the methodology that breaks hardest against agents.** Scrum's ceremonies assume human cognitive constraints (limited daily focus, need for synchronous coordination, monthly planning horizons) that an agent does not share. The "AI-Augmented Scrum Framework" essays on Scrum.org openly admit that "plugging 24/7 autonomous bots into traditional Scrum often results in broken workflows, mismatched velocity, and severe technical debt." Linear's Agent integration shows the actual emerging pattern: the board is the API, the agent is assigned issues like a teammate, status updates flow through PR-linked automations, the human reviews. Story points collapse — work is measured in agent-hours and credit-spend, not Fibonacci. Allen Holub's longstanding `#NoEstimates` critique becomes literal: estimates were proxies for risk under human variability; under an agent fleet, you measure throughput and budget.

**Best Claude Code primitives.**
- MCP for Linear/Jira/GitHub Projects so the agent pulls tickets and pushes status
- A "ticket-picker" subagent reads the board and returns one issue at a time (prevents context pollution from the whole backlog)
- Hooks requiring a linked issue ID on every commit
- Skills: "draft a retro from this PR history"

**Choose when.** Kanban (with WIP limits) survives the agent transition; Scrum with all its ceremonies usually doesn't. Keep retros (humans need them); kill standups; replace planning poker with budget allocation.

**Anti-patterns.**
1. **Cargo-culting Scrum onto async agents** — daily standups for a fleet that works 24/7.
2. Estimating agent work in story points.
3. Treating an agent as "another developer on the team" in Jira and being surprised when it closes 80 tickets in a sprint and you can't review them.
4. Sprint commitments when agent throughput swings 10× based on prompt quality.

**Pioneers.** Allen Holub ([*AI Makes Agile Irrelevant!*](https://blog.holub.com/p/ai-makes-agile-irrelevant)), Sander Hoogendoorn (post-agile), Scrum.org's *AI-Augmented Scrum Framework*, [Linear AI Agents docs](https://linear.app/docs/agents-in-linear).

---

## 7. XP — Extreme Programming

**Textbook.** Kent Beck's 1999 collection of practices: pair programming, TDD, continuous integration, collective code ownership, simple design, refactoring, on-site customer, small releases, sustainable pace, metaphor.

**Agent mapping.** XP survives almost intact because most practices are constraints on *quality*, not *process*. Reframe: pair programming becomes human + agent — human is navigator, agent is driver. CI becomes essential (agents will break things in parallel branches). Collective ownership becomes literal: the agent has access to all code, so the human team must too. Multiple 2025 essays (Voitanos, Refine, Builder.io, the Saarland University study) document the human-AI pair as the dominant 2025 working mode, with the warning that humans question AI suggestions less than human pair partners — a known failure mode requiring deliberate counter-pressure.

**Best Claude Code primitives.**
- Plan Mode = the "navigator pause" of pair programming
- Anthropic's [best-practices doc](https://code.claude.com/docs/en/best-practices) explicitly recommends test commands + linters in the prompt for "2-3x quality improvement" — XP's CI principle in primitive form
- Skills: `code-review`, `superpowers:requesting-code-review` enforce collective ownership
- A "simple design" rule in CLAUDE.md ("use the simplest possible approach") counters the agent's tendency to over-abstract

**Choose when.** Almost always. XP composes with every other methodology. Pair programming in particular is the *default mode* of working with an agent.

**Anti-patterns.**
1. Treating the agent as a senior pair when it confidently asserts wrong things.
2. Skipping CI because "the agent ran the tests" — it might have deleted them.
3. Letting pair sessions become dictation, not collaboration.

**Pioneers.** Kent Beck (*XP Explained*), Saarland University 2025 human-AI pairing study, Builder.io engineering blog.

---

## 8. Waterfall

**Textbook.** Royce 1970 (often misattributed as advocating it; he was warning against it): sequential phases — requirements → design → implementation → verification → maintenance — with formal sign-off between gates. Long out of fashion, but never died in regulated industries.

**Agent mapping.** Waterfall is unironically a *good* fit for agent work in regulated domains. **SR 11-7** (Federal Reserve model risk management, now superseded by SR 26-2 in April 2026) requires documented model development, independent validation, and ongoing monitoring — all phase-gated. **FDA SaMD** under the January 2025 Lifecycle Management draft guidance requires SaMD Pre-Specifications and Algorithm Change Protocols documented before deployment. **DO-178C** (avionics; Ketryx now offers AI-powered DO-178C compliance) requires traceability from requirements through design to verified object code. Agents in these contexts must produce evidence — generated test results, requirement traceability matrices, signed artifacts — that survive an audit. The harness becomes the audit trail.

**Best Claude Code primitives.**
- Hooks emitting signed audit logs on every tool call
- Skills enforcing phase gates (no implementation skill until design skill returned)
- Subagents per phase so each phase's artifacts are clean
- CLAUDE.md as the constitution document declaring which standards apply (SR 11-7, IEC 62304, DO-178C, SOC 2)

**Choose when.** Banking models, medical devices, avionics, anything with regulatory model documentation requirements. Also: large coordinated migrations where phases genuinely cannot overlap.

**Anti-patterns.**
1. Calling a 40-page spec.md "agile" because the agent wrote it — it's still waterfall.
2. Skipping the validation phase because "the agent already tested it" — independent validation is the *point* of SR 11-7.

**Pioneers.** Federal Reserve SR 11-7 / SR 26-2, FDA AI-Enabled Device Software Functions guidance (Jan 2025), Ketryx (DO-178C with AI), GARP (*SR 11-7 in the Age of Agentic AI*).

---

## 9. Lean / Lean Startup

**Textbook.** Eric Ries' 2011 framework: build the minimum viable product (MVP), measure user response, learn what to do next — the build-measure-learn loop. Underlying lean principles (Womack/Toyota): eliminate waste, amplify learning, decide as late as possible, deliver fast, empower the team, build integrity in.

**Agent mapping.** The agent transforms the economics of MVPs. The "agent generates 5 MVPs in parallel" pattern (well-documented in 2025) is real: dispatch a parallel-agents workflow, get back five working prototypes, instrument them, measure, kill four. Validated learning shrinks from a quarter to a week. Lean's "decide as late as possible" maps perfectly to agentic exploration — keep options open by parallel-implementing them.

**Best Claude Code primitives.**
- Git worktrees (`superpowers:using-git-worktrees`, `EnterWorktree`) for parallel MVP branches
- `superpowers:dispatching-parallel-agents` for fan-out
- MCP into analytics for measure
- CLAUDE.md should document kill criteria so the agent doesn't get attached to its own code

**Choose when.** Net-new product work, A/B testing of architecture choices, any time "we don't know which approach will work."

**Anti-patterns.**
1. **Vibe-driven MVP sprawl** — generating 50 prototypes nobody measures. Without evals/instrumentation, parallel agents are just expensive entropy.
2. Treating an agent-generated MVP as production-ready because it ran.
3. Failing to kill dead branches (Lean is about waste elimination).

**Pioneers.** Eric Ries (*Lean Startup*), AWS Bedrock parallel-prototype demos, classic Womack/Jones lean thinking.

---

## 10. DevOps / SRE / GitOps as methodologies

**Textbook.** **DevOps** — cultural fusion of Dev and Ops with shared metrics (DORA's four: deployment frequency, lead time, MTTR, change failure rate). **SRE** (Google's operationalization) — SLIs/SLOs/error budgets, blameless postmortems, toil reduction. **GitOps** (Weaveworks) — desired state lives in Git; reconcilers continuously converge actual to declared.

**Agent mapping.** Agents are SRE-native. They thrive on declarative state (IaC, Kubernetes manifests, Terraform), tight feedback loops (a `terraform plan` is a perfect agent input), and runbook execution (chaos engineering, incident triage). 2025–2026 saw an explosion of AI-SRE work (STRATUS at NeurIPS 2025; ChaosEater at ASE 2025; the GSDC *SRE Playbook 2025*). Error budgets become the rate-limit on agent autonomy: when budget is healthy, the agent ships; when burned, it can only patch. Blameless postmortems become "what failed in the agent loop, the prompt, the eval, or the human review?" — analysis surface widens.

**Best Claude Code primitives.**
- Hooks for "must run terraform plan before terraform apply"
- MCP into Kubernetes, AWS, Datadog, PagerDuty
- Skills: `devops-rollout-plan`, `devops-engineer`, runbook generation
- A subagent per environment so prod context never leaks into staging
- Background agents (the Kiro pattern) as the always-on reconciler

**Choose when.** Always for ops work. Also a useful frame for *application* work: think of features as services with SLOs, give them error budgets, let the agent run inside that budget.

**Anti-patterns.**
1. Letting an agent push to prod without an error-budget gate.
2. Postmortems that blame "the AI" instead of the loop.
3. Treating GitOps as "Git is the only place humans edit" — agents must commit through the same pipeline, with the same review gates.

**Pioneers.** Google SRE Workbook, Weaveworks (GitOps), Charity Majors / Liz Fong-Jones (observability culture), STRATUS (NeurIPS 2025), ChaosEater (ASE 2025), GitHub Copilot Skills for DevOps.

---

## 11. Design Sprint / Double Diamond / discovery vs delivery

**Textbook.** **Design Sprint** (Knapp/Google Ventures, 2016) — five-day structured prototyping. **Double Diamond** (UK Design Council, 2005) — four phases: Discover, Define, Develop, Deliver, alternating divergent and convergent thinking. Discovery is "are we building the right thing?"; delivery is "are we building it right?"

**Agent mapping.** AI collapses the diamond. Tamarah Usher's [*AI Has Collapsed the Double Diamond*](https://tamarahusher.medium.com/ai-has-collapsed-the-double-diamond-8372efda0039) (2025) argues that generative AI shrinks the distance between idea and prototype until "discovery and delivery no longer live in sequence — they co-occur, overlap, and in some cases, reverse." The agent becomes a discovery accelerant (analyze 100 user interviews in minutes) *and* a delivery executor (turn the synthesis into a running prototype). The new shape is closer to a "triple diamond" with continuous validation.

**Best Claude Code primitives.**
- Brainstorming skills (`superpowers:brainstorming`) for divergence
- Plan Mode for convergence
- Subagents for parallel prototype exploration (one per design direction)
- MCP into research tools (Dovetail, Maze)
- Pattern: discovery subagent → synthesis in main thread → delivery subagents

**Choose when.** New product development, ambiguous problem spaces, before committing to a spec. Also a useful prompt-classification heuristic: ask the agent which mode it's in.

**Anti-patterns.** Skipping discovery because "the agent is fast enough to just build it." Speed of delivery makes discovery *more* valuable, not less, because direction errors compound at agent velocity.

**Pioneers.** UK Design Council, Jake Knapp, Tamarah Usher, Jascha Goltermann (*Beyond the Double Diamond*).

---

## 12. Plan-driven vs adaptive

**Textbook.** Boehm/Turner 2003 framing — plan-driven methods (waterfall, RUP) commit to a plan and manage to it; adaptive methods (Scrum, XP) accept change and replan continuously. Originally a spectrum, not a dichotomy.

**Agent mapping.** Honest reframe for 2026: **most agent work is plan-driven within an adaptive overall loop.** Inside a single task, the agent benefits from a fixed, written plan (Plan Mode, `plan.md`) it executes deterministically — adapting mid-task is where it goes off the rails. Across tasks, the human/orchestrator adapts: rerun discovery, revise the spec, redispatch. TELUS Digital's "plan-and-execute" pattern and the Magentic "adaptive planning" pattern are the two sides. AWS's AI-DLC explicitly positions itself as "adaptive workflow steering rules for AI coding agents."

**Best Claude Code primitives.** Plan Mode = plan-driven inner loop. Subagent dispatch with task-scoped plans = plan-driven within adaptive outer loop. Background agents that re-plan based on PR feedback = adaptive outer loop.

**Choose which.** Plan-driven inside a task, always. Adaptive outside. Resist the temptation to give the agent latitude inside a task — that's where drift compounds.

**Anti-patterns.** Letting the agent "decide as it goes" inside a task. Forcing the human to decide everything in advance outside a task.

**Pioneers.** Boehm/Turner (*Balancing Agility and Discipline*), [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows), TELUS Digital, Microsoft Azure (*AI Agent Orchestration Patterns*).

---

## 13. Subagent-driven development

**Textbook.** A 2025–2026 *emergent* methodology: every non-trivial task is dispatched to a fresh subagent with only the spec and minimal context, executed independently, then code-reviewed by a second subagent before merging. The orchestrator never edits code directly; it writes plans, dispatches, and reviews. Codified by Jesse Vincent in [Superpowers](https://github.com/obra/superpowers).

**Agent mapping.** This *is* a harness pattern, not a methodology adapted to one. Motivation is mechanical: context windows degrade, and pollution is irreversible. Anthropic's docs are explicit: "subagents help because their work happens in a fresh context and only a summary returns." The Superpowers `subagent-driven-development` skill activates after a plan exists, dispatches one subagent per task, runs a two-stage review (spec compliance, then code quality). Each subagent gets only its task description and relevant context — never the full conversation. **This is the methodology that makes long-horizon agent work possible.**

**Best Claude Code primitives.**
- **Subagents** (the primitive itself)
- `superpowers:dispatching-parallel-agents` for independent tasks
- Plan Mode to author the plan that drives dispatch
- Hooks enforcing that the orchestrator does not edit code directly
- The `code-review` skill as the second-stage reviewer

**Choose when.** Multi-task plans, anything with parallelism, anything where a human will review the diff after. Default-on for any plan with ≥3 tasks.

**Anti-patterns.**
1. Dispatching a subagent without a written task spec — it has no context.
2. Letting the orchestrator do the work itself "because it's faster."
3. Skipping the second-stage review.

**Pioneers.** Jesse Vincent ([obra/superpowers](https://github.com/obra/superpowers), [*Superpowers: How I'm using coding agents in October 2025*](https://blog.fsck.com/2025/10/09/superpowers/), *Superpowers 4* Dec 2025), Anthropic (subagent docs), Simon Willison.

---

## 14. Vibe coding vs agentic coding

**Textbook.** **Vibe coding** — Andrej Karpathy's February 2025 coinage — is conversational, intuition-led prompting where the developer focuses on outcomes and lets the model handle code. **Agentic coding** is the disciplined counterpart: goal-driven agents that plan, execute, test, iterate, and recover, with the developer orchestrating and reviewing. The academic distinction is laid out in Sapkota/Roumeliotis/Karkee, [*Vibe Coding vs. Agentic Coding*](https://arxiv.org/abs/2505.19443) (May 2025), with a taxonomy across autonomy, execution model, feedback loop, safety, and debugging strategy.

**Agent mapping.** This framing distinguishes "playing with Claude" from "building with Claude as an engineering function." Karpathy's own 2026 reframe (Sequoia AI Ascent, "agentic engineering") puts it sharply: **vibe coding raises the floor for beginners; agentic engineering raises the ceiling for professionals.** The harness is what turns vibe coding into agentic coding — it is the structural commitment to plans, tests, reviews, and evals.

**Best Claude Code primitives.** Everything in this document. The harness *is* the answer to "how do I move from vibe to agentic." Specifically: Plan Mode + TDD-Guard hook + Superpowers + evals + subagent dispatch.

**Choose vibe coding when.** Throwaway prototypes, exploratory spikes, demos, learning. Karpathy: "vibe coding is great for things where the consequences of being wrong are small."

**Anti-patterns.**
1. **Vibe coding without evals** — the canonical 2025 anti-pattern. You think it works because the demo worked.
2. Vibe coding into a production codebase.
3. Calling agentic coding "vibe coding" to sound humble — the industry shifted, and the distinction matters.

**Pioneers.** Andrej Karpathy (X coinage Feb 2025; Sequoia AI Ascent 2026), Sapkota/Roumeliotis/Karkee, Kent Beck (*Augmented Coding: Beyond the Vibes*), The New Stack (*Vibe coding is passé*).

---

## 15. Brainstorm → Plan → TDD → Verify → Review → Ship

**Textbook.** The canonical Superpowers/Evanflow loop: a hybrid methodology stringing together brainstorming (divergent), planning (convergent), test-driven implementation (dispatched to subagents), verification (running the suite + manual checks), code review (second-stage subagent or human), and shipping (PR or merge). Each phase is a discrete skill with explicit entry/exit criteria.

**Agent mapping.** This is the *dominant integrated methodology* in the Claude Code ecosystem as of late 2025. It composes SDD (brainstorm + plan), TDD (the inner loop), subagent-driven development (the dispatch model), code review (the gate), and DevOps (ship). Superpowers ships it as a seven-phase flow: **Brainstorm → Spec → Plan → TDD → Subagent Dev → Review → Finalize.** Each transition is gated; critical issues block progress.

**Best Claude Code primitives.** This *is* the Superpowers plugin. Skills:
- `superpowers:brainstorming`
- `superpowers:writing-plans`
- `superpowers:test-driven-development`
- `superpowers:subagent-driven-development`
- `superpowers:verification-before-completion`
- `superpowers:requesting-code-review`
- `superpowers:finishing-a-development-branch`

Plus hooks for TDD enforcement, Plan Mode for planning, subagents for dispatch.

**Choose when.** Any feature work in a real codebase by a senior engineer who wants the agent to ship. **Default loop for the master harness.**

**Anti-patterns.**
1. Skipping brainstorm because you "already know what to build" — the agent doesn't, and the brainstorm is where you tell it.
2. Skipping verify because "tests pass" — verify includes manual checks.
3. Ship without code review.

**Pioneers.** Jesse Vincent (Superpowers), the broader Evanflow community, Pulumi's [*Superpowers, GSD, and GSTACK*](https://www.pulumi.com/blog/claude-code-orchestration-frameworks/) comparison, Builder.io's Superpowers writeup.

---

## 16. Eval-driven development

**Textbook.** Evals — systematic, repeatable measurements of LLM/agent behavior — become the unit of progress. Hamel Husain and Shreya Shankar's *Evals for AI Engineers* (O'Reilly, 2025) is the canonical reference; their Maven course has trained 700+ engineers from 300+ companies. Components: error analysis (what does the system actually fail at?), assertion-style evals, LLM-as-judge, production monitoring, cost optimization.

**Agent mapping.** Evals are to LLM systems what tests are to deterministic code. Without them, you cannot tell if your harness change improved or regressed agent behavior. Husain's important nuance: he is *against* "eval-driven development" in the strict TDD sense (write evaluators before features), because LLM failure modes are open-ended and unknowable in advance. Prescription: start with error analysis, write evaluators for failures you *observe*, iterate. Shankar's [Three Gulfs Model](https://www.sh-reya.com/) frames the gaps developers must close (specification, generalization, comprehension). DocETL (Shankar) operationalizes this for unstructured data pipelines.

**Best Claude Code primitives.**
- An `evals/` directory with versioned datasets
- A `bash run-evals` slash command
- Hooks running a fast eval subset on every change
- Subagents for "judge this output against the rubric"
- MCP into eval platforms (Braintrust, LangSmith)
- CLAUDE.md must reference how to read eval results

**Choose when.** Mandatory whenever the agent does work whose correctness is judgmental (RAG, generation, classification). For deterministic code, traditional tests suffice.

**Anti-patterns.**
1. **Vibe coding without evals** (again).
2. Writing evaluators *before* observing failures (Husain's correction).
3. Treating LLM-as-judge as ground truth without measuring judge quality.
4. Optimizing for eval scores instead of user outcomes.

**Pioneers.** Hamel Husain ([LLM Evals FAQ](https://hamel.dev/blog/posts/evals-faq/), [Your AI Product Needs Evals](https://hamel.dev/blog/posts/evals/)), Shreya Shankar ([sh-reya.com](https://www.sh-reya.com/), DocETL), *Evals for AI Engineers* book, Parlance Labs Maven course, Eugene Yan.

---

## Methodology selection by domain

| Domain | Recommended stack |
|---|---|
| **Web / SaaS product** | SDD + Subagent-Driven + TDD + BDD for user flows + Evals for any AI features + Lean for new features. *Skip heavy Scrum.* |
| **Data / ML pipelines** | SDD + Eval-driven (Husain/Shankar style) + DDD for the schema language + DocETL-pattern subagents per pipeline stage. TDD for transforms. |
| **DevOps / Platform** | SRE methodology + GitOps + Subagent-Driven (one subagent per environment) + waterfall-style change windows for prod. Evals for any AIOps surface. |
| **Financial / regulated** | Waterfall phase gates + SR 11-7 / SR 26-2 documentation + ATDD with auditable acceptance + signed audit logs + independent validation subagent. **TDD mandatory.** |
| **Medical device (FDA SaMD)** | Same as financial + Predetermined Change Control Plan + Algorithm Change Protocol + IEC 62304 traceability. Avoid lean MVP patterns in regulated contexts. |
| **Avionics (DO-178C)** | Maximum waterfall + traceability matrix + DAL-appropriate verification. Agent assists generation; humans own approval at every gate. |
| **Mobile / Game / Embedded** | SDD + TDD where deterministic + visual/HIL verification loops + per-platform subagents. |
| **Scientific / Research** | SDD as the manuscript spec + reproducibility skills + eval-driven for any model/judgment + plan-driven inner loops with adaptive outer loops between papers. |
| **Security research** | Scope-as-skill + ATDD-style engagement contract + waterfall phase gates for evidence + adversarial subagent (red) and defensive subagent (blue) cleanly separated. |
| **Content / Marketing / SEO** | BDD-style "voice = behavior" specs + brand-voice eval-driven + Lean A/B variants + cross-model judging. |
| **Customer support / Ops** | Subagent-Driven (drafter ≠ publisher) + Eval-driven on classification surfaces + ATDD for SLA-bound automations. |

---

## The three universal anti-patterns

1. **Cargo-culting Scrum onto async agents.** Daily standups for a fleet that runs 24/7, story points for work measured in tokens, sprint commitments when prompt quality changes throughput 10×. Read Holub. Replace with Kanban + budgets + retros.

2. **SDD as waterfall in disguise.** Writing a 40-page spec.md and expecting one-shot implementation. SDD's spec is a *living contract* the agent and human iterate against — not a Big Design Up Front document handed to a junior dev.

3. **Vibe coding without evals.** The cardinal sin of 2025. You will think it works because the demo worked. You will deploy. Users will see failures you never measured. Husain and Shankar exist to prevent this.

---

## Sources

### Spec-Driven Development
- [GitHub spec-kit](https://github.com/github/spec-kit)
- [GitHub blog — Spec-driven development with AI](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [Microsoft for Developers — Diving into SDD with Spec Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [Sean Grove — *The New Code* (YouTube)](https://www.youtube.com/watch?v=8rABwKRsec4)
- [Kiro homepage](https://kiro.dev/)
- [InfoQ — Beyond Vibe Coding: Amazon Introduces Kiro](https://www.infoq.com/news/2025/08/aws-kiro-spec-driven-agent/)

### TDD with AI
- [Kent Beck — Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes)
- [Pragmatic Engineer — TDD, AI agents and coding with Kent Beck](https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent)
- [TDD-Guard repo](https://github.com/nizos/tdd-guard)

### Superpowers / Subagent-Driven
- [Superpowers plugin (Anthropic)](https://claude.com/plugins/superpowers)
- [obra/superpowers GitHub](https://github.com/obra/superpowers)
- [Jesse Vincent — Superpowers (Oct 2025)](https://blog.fsck.com/2025/10/09/superpowers/)
- [Jesse Vincent — Superpowers 4 (Dec 2025)](https://blog.fsck.com/2025/12/18/superpowers-4/)
- [Builder.io — The Superpowers Plugin for Claude Code](https://www.builder.io/blog/claude-code-superpowers-plugin)
- [Pulumi — Superpowers, GSD, and GSTACK](https://www.pulumi.com/blog/claude-code-orchestration-frameworks/)

### Vibe vs Agentic Coding
- [arXiv 2505.19443 — Vibe Coding vs. Agentic Coding](https://arxiv.org/abs/2505.19443)
- [Karpathy on agentic engineering at Sequoia AI Ascent 2026](https://analyticsdrift.com/andrej-karpathy-agentic-engineering-software-3/)
- [The New Stack — Vibe coding is passé](https://thenewstack.io/vibe-coding-is-passe/)

### Eval-Driven Development
- [Hamel Husain — LLM Evals FAQ](https://hamel.dev/blog/posts/evals-faq/)
- [Hamel Husain — Should I practice eval-driven development?](https://hamel.dev/blog/posts/evals-faq/should-i-practice-eval-driven-development.html)
- [Hamel Husain — Your AI Product Needs Evals](https://hamel.dev/blog/posts/evals/)
- [Shreya Shankar](https://www.sh-reya.com/)
- [Evals for AI Engineers (O'Reilly)](https://www.oreilly.com/library/view/evals-for-ai/9798341660717/)
- [Maven course — AI Evals For Engineers & PMs](https://maven.com/parlance-labs/evals)

### BDD / ATDD
- [Humanizing Work — AI for better BDD](https://www.humanizingwork.com/ai-for-better-bdd/)
- [Hung Doan — LLMs are making BDD & Gherkin rise again](https://hungdoan.com/2025/04/25/llms-are-making-bdd-gherkin-rise-again/)
- [Agentic AI for BDD Testing Using LLMs (SCITEPRESS 2025)](https://www.scitepress.org/Papers/2025/133744/133744.pdf)
- [Levi9 — Hybrid AI + BDD with Cucumber and Playwright](https://levi9-serbia.medium.com/beyond-prompt-only-testing-a-hybrid-ai-bdd-approach-with-cucumber-and-playwright-82a98a89946d)
- [swingerman/atdd](https://github.com/swingerman/atdd)

### DDD
- [Martin Fowler — Ubiquitous Language](https://martinfowler.com/bliki/UbiquitousLanguage.html)
- [Martin Fowler — Domain Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Eric Evans — DDD Reference (PDF)](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)

### Agile / anti-patterns
- [Allen Holub — AI Makes Agile Irrelevant!](https://blog.holub.com/p/ai-makes-agile-irrelevant)
- [Sander Hoogendoorn](https://sanderhoogendoorn.com/)
- [Scrum.org — AI-Augmented Scrum Framework](https://www.scrum.org/resources/blog/ai-augmented-scrum-framework-when-half-your-team-autonomous-agents)
- [Linear AI Agents docs](https://linear.app/docs/agents-in-linear)

### Waterfall in regulated industries
- [GARP — SR 11-7 in the Age of Agentic AI](https://www.garp.org/risk-intelligence/operational/sr-11-7-age-agentic-ai-260227)
- [OCC Bulletin 2026-13 — Model Risk Management revised guidance](https://www.occ.treas.gov/news-issuances/bulletins/2026/bulletin-2026-13.html)
- [FDA — AI in Software as a Medical Device](https://www.fda.gov/medical-devices/software-medical-device-samd/artificial-intelligence-software-medical-device)
- [Ketryx — DO-178C with AI](https://www.ketryx.com/industries/aerospace)

### SRE / DevOps / GitOps
- [GSDC — SRE Playbook 2025](https://www.gsdcouncil.org/blogs/sre-playbook-engineering-resilience-in-ai-and-automation)
- [Stackgen — How to Implement GitOps with AI-Assisted Infrastructure](https://stackgen.com/blog/how-to-implement-gitops-with-ai-assisted-infrastructure)
- [agamm/awesome-ai-sre](https://github.com/agamm/awesome-ai-sre)
- [Google SRE Workbook — Postmortem Culture](https://sre.google/workbook/postmortem-culture/)

### Discovery / Double Diamond
- [Tamarah Usher — AI Has Collapsed the Double Diamond](https://tamarahusher.medium.com/ai-has-collapsed-the-double-diamond-8372efda0039)
- [Jascha Goltermann — Beyond the Double Diamond](https://medium.com/design-bootcamp/beyond-the-double-diamond-ais-challenge-to-design-thinking-eb11a24a2f7c)

### Plan-driven vs Adaptive
- [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows)
- [TELUS Digital — Building AI Agents Using Plan-and-Execute Loops](https://www.telusdigital.com/insights/data-and-ai/article/building-ai-agents-with-plan-and-execute)
- [Microsoft Azure — AI Agent Orchestration Patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)

---

## See also (within this repo)

- [`docs/README.md`](README.md) — full documentation index organised by Diátaxis quadrant.
- [`docs/reference/modules.md`](reference/modules.md) — methodology modules (`tdd`, `spec-driven`, `eval-driven`, `bdd`) and how to enable them.
- [`docs/how-to/customize-modules.md`](how-to/customize-modules.md) — turn methodologies on / off in your harness.
- [`docs/HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md) and [`docs/AGENT_ROLES.md`](AGENT_ROLES.md) — companion deep references.
