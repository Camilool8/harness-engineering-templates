# Why a harness, not a better prompt

> *"Agent = Model + Harness. Templates that lean on the model's good judgement fail their first incident. The harness — not the agent — is the contract."*

This is the premise everything in this repo is built around. It is not a stylistic preference; it is the conclusion drawn from two years of practitioner reports, incident write-ups, and capability evaluations. This page explains the reasoning so you can decide whether the premise applies to your work.

If you accept the premise, the design decisions in this repo follow as consequences. If you reject it, the repo is the wrong tool for your project — and that is fine; pick something else.

---

## What the premise means

Roughly: a working agentic engineering setup has two components, not one.

- **The model** — Claude, GPT, Gemini, whichever frontier LLM you are using. It is a stochastic, contextual, fundamentally non-deterministic component. Its behaviour drifts between sessions, between model versions, between days. *The model has good judgement on average and unreliable judgement specifically.*
- **The harness** — everything *around* the model: tool definitions, permission rules, hooks that intercept tool calls, system prompts, sub-agent isolation, output validators, audit logs, memory, the project's CLAUDE.md, the verification gate. The harness is deterministic. It does what its code says, every time.

When something goes wrong, the question is which component to fix. **Fix the harness whenever you can.** The model improves on a release schedule you do not control. The harness is yours.

---

## Where the premise comes from

Two convergent sources, each strong on its own:

### The 2025 practitioner consensus

Birgitta Böckeler's writing on agentic coding at Thoughtworks; Simon Willison's notebook posts on tool restriction and exit-code-2 gates; the Anthropic engineering blog's multi-agent research write-up; the [METR](https://metr.org/) capability and incident reports through 2025; the OpenAI Agents SDK design notes; the [Oso "Agents Rule of Two"](https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security) security paper. The variation in these accounts is enormous, but every one of them reaches the same conclusion about *where the reliability lives*: in the contracts the surrounding system enforces, not in the prompts that ask the model to behave.

### The incident evidence

A few patterns repeat across post-mortems:

- An agent given write access to production deleted production state. ("The model has access to `kubectl` and *also* permission to use destructive verbs" — the harness, not the model, is the problem.)
- An agent given a credential leaked the credential in a tool call. ("We told it not to" — documentation is a suggestion, the model is free to ignore.)
- An agent given an MCP server with an LLM-prompt-injection payload in its output executed the payload. ("We treated MCP output as instructions" — the harness should treat it as untrusted input.)
- An agent reported a task complete when no verification ran. ("Trust the agent's self-report" — the agent has every incentive to claim success and no mechanism to prove it.)

Every incident here is a harness failure, not a model failure. A better model would have made the incident less likely on average — and equally surprising the day it happened.

---

## What "the harness is the contract" looks like in practice

Concretely, in this repo:

| Behaviour | Wrong way | Right way |
|---|---|---|
| Stop the agent from committing secrets | "Please don't commit secrets" in CLAUDE.md | `secret-scan.sh` `PreToolUse` hook, exit code 2 |
| Stop the agent from `rm -rf` | "Be careful with destructive commands" | `command-guard.sh` `PreToolUse` hook, exit code 2 |
| Require verification before "done" | "Run the tests before claiming complete" | `verify-gate.sh` `Stop` hook, refuses session end |
| Track what the agent did | "Please be transparent about your work" | `audit-log.sh` `PostToolUse` hook, append-only JSONL |
| Bound a sub-agent's blast radius | "Reviewer, please don't edit code" | `tools: [Read, Grep, Glob]` in the agent frontmatter |
| Prevent production deploys without approval | "Ask before deploying" | `safety/two-key` module, human-issued typed token |

The pattern: the constraint moves from prose the model parses to mechanism that runs whether the model parsed anything or not.

Documentation is *not useless* — it shapes the model's average behaviour. But documentation alone is not enough for any constraint that matters. The combination is the harness.

---

## What this premise does *not* claim

To prevent the common strawmen:

- **It does not claim models are bad.** Frontier models are remarkable. The point is that *remarkable* is not the same as *contractually reliable*.
- **It does not claim prompts are useless.** A good CLAUDE.md sharpens the model's defaults. But prompts are guidance, not gates.
- **It does not claim hooks are sufficient.** A model that consistently produces low-quality code does not get rescued by a better hook. The model has to be good *and* the harness has to be tight.
- **It does not claim agentic work is reliable.** It claims agentic work *with a tight harness* is reliable *enough* for production engineering — with a human in the loop for the irreversible decisions.

---

## When the premise does not apply

If your use case is:

- **Prototyping** where speed matters more than safety, and you will throw the output away — a tight harness is overkill.
- **Greenfield exploration** with no production blast radius and no shared state — a tight harness is overkill.
- **A single tightly-scoped tool call** with a deterministic check on the output — you do not need this much machinery.

Use a lighter setup for that work. The harness is for engineering work that other humans will rely on. The cost of the harness is real; pay it where the payoff is real.

---

## See also

- [`picking-vs-discarding.md`](picking-vs-discarding.md) — how the harness stays adaptable even though it is the contract.
- [`non-negotiables.md`](non-negotiables.md) — which parts of the harness are not configurable, and why.
- [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) — the master reference with full citations.
- [`AGENT_ROLES.md`](../AGENT_ROLES.md) — how the contract extends to multi-agent topologies (least privilege, return-shape contracts, the Rule of Two).
