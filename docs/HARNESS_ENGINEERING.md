# Harness Engineering for Claude Code — A 2026 Reference

> **Purpose.** A prescriptive, opinionated reference for building production-grade Claude Code "harnesses" across software domains. Synthesized from the 2025–2026 state of the art: Anthropic engineering, METR, Princeton/SWE-agent, the practitioner canon (Hamel Husain, Eugene Yan, Shreya Shankar, Simon Willison, Birgitta Böckeler, Andrej Karpathy, Lance Martin, Dexter Horthy, Theo Browne, Lee Robinson), and the vendor harnesses now shipping from Cloudflare, AWS, Microsoft, Google, Vercel, Sentry, Stripe, Databricks, Snowflake, Alpaca, PagerDuty, Datadog, Replit, Anthropic.
>
> **Scope.** Theory → Claude Code primitives → per-domain templates (Web, Data, DevOps, Financial, Mobile, Game, Embedded, Scientific, Security, Content, Ops) → cross-cutting concerns (memory, multi-agent, cost, safety, eval, org adoption) → defaults and anti-patterns.
>
> **Stance.** Templates that lean on the model's good judgment fail their first incident. The harness — not the agent — is the contract.

---

## Table of Contents

- [Part I — Foundations of Harness Engineering](#part-i--foundations-of-harness-engineering)
- [Part II — The Claude Code Primitive Reference](#part-ii--the-claude-code-primitive-reference)
- [Part III — Domain Harness Templates](#part-iii--domain-harness-templates)
  - [1. Web Development](#1-web-development)
  - [2. Data Analysis, Data Science & ML/AI Engineering](#2-data-analysis-data-science--mlai-engineering)
  - [3. DevOps, SRE & Platform Engineering](#3-devops-sre--platform-engineering)
  - [4. Finance, Quant, Trading, Accounting & FinTech](#4-finance-quant-trading-accounting--fintech)
  - [5. Mobile Development](#5-mobile-development)
  - [6. Game Development](#6-game-development)
  - [7. Embedded / IoT / Firmware](#7-embedded--iot--firmware)
  - [8. Scientific Computing & Research](#8-scientific-computing--research)
  - [9. Security Research (Red & Blue Team)](#9-security-research-red--blue-team)
  - [10. Content, Marketing & SEO](#10-content-marketing--seo)
  - [11. Customer Support & Ops Automation](#11-customer-support--ops-automation)
- [Part IV — Cross-Cutting Concerns](#part-iv--cross-cutting-concerns)
- [Part V — Universal Anti-Patterns and Prescriptive Defaults](#part-v--universal-anti-patterns-and-prescriptive-defaults)
- [Part VI — Curated Reading List](#part-vi--curated-reading-list)

---

# Part I — Foundations of Harness Engineering

## 1. Definitions: what is a harness?

The term **harness** is borrowed from software testing (a test harness wraps code with fixtures, drivers, and assertions). In 2024 the agent community repurposed it for the runtime that wraps a language model. The shorthand the field has converged on is

> **Agent = Model + Harness**

— Birgitta Böckeler, Distinguished Engineer at Thoughtworks, in [*Harness Engineering for Coding Agent Users*](https://martinfowler.com/articles/harness-engineering.html). She decomposes the harness into **guides** (feedforward controls applied before the agent acts: linters, schemas, plan-mode) and **sensors** (feedback controls applied after: diff review, regression checks, evals). She names three regulatory dimensions: a *maintainability* harness, an *architecture-fitness* harness, and a *behavior* harness. Her operational definition is the most-cited in the field.

Other primary definitions worth internalizing:

- **Anthropic** ([*Effective harnesses for long-running agents*](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents), [*Building agents with the Claude Agent SDK*](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)): the harness gives a raw model "state, tool execution, feedback loops, and enforceable constraints," and you must evaluate model + harness *together*, not the model in isolation.
- **METR**: holds the model fixed while varying the scaffold to isolate the contribution of the harness — uses [UK AISI's Inspect](https://inspect.aisi.org.uk/) framework to standardize this. METR's [Time Horizon 1.1 (Jan 2026)](https://metr.org/blog/2026-1-29-time-horizon-1-1/) puts Claude Mythos at a 50%-success time-horizon of likely 16+ hours.
- **Princeton — SWE-agent / ACI** ([Yang et al., NeurIPS 2024](https://arxiv.org/abs/2405.15793)): the **Agent–Computer Interface** (file viewer, edit primitives, search affordances) is a *separate lever* from model capability — the founding academic source for "interface design matters as much as model size."
- **Simon Willison** ([*How coding agents work*](https://simonwillison.net/guides/agentic-engineering-patterns/how-coding-agents-work/)): "a coding agent is a piece of software that acts as a harness for an LLM, extending that LLM with additional capabilities that are powered by invisible prompts and implemented as callable tools."
- **Parallel Web Systems**: "everything between the language model and the real world. The model generates text. The harness decides what that text can touch."

The empirical case for harness primacy: on [Terminal-Bench 2.0](https://www.tbench.ai/) (Stanford + Laude Institute, Nov 2025), the same Claude Opus 4.5 model scored 17 problems apart on 731 issues across Augment, Cursor, and Claude Code harnesses. Same model, double-digit point swings.

## 2. Anatomy of a harness — the nine layers

Modern harnesses (Claude Code is the canonical reference) comprise:

1. **System prompt** — multi-thousand-token preamble defining identity, behavior contracts, output format, tool-use protocol. Claude Code's is reportedly tens of thousands of tokens; only economically viable because of prompt caching.
2. **Context-window management** — compaction (summarize at ~85% threshold), pruning, sliding windows, just-in-time file rehydration. Microsoft Agent Framework, Google ADK, and Anthropic's [*Effective context engineering*](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) all treat context as a *budget* to be allocated.
3. **Tool layer** — typed registry of callable functions. Tools may be local (Bash, Read, Edit), MCP-served, or skill-wrapped. See Anthropic's [*Writing effective tools for AI agents*](https://www.anthropic.com/engineering/writing-tools-for-agents).
4. **Sandbox / permissions** — OS-level (Linux `bubblewrap`, macOS `seatbelt`, Anthropic's [`sandbox-runtime`](https://github.com/anthropic-experimental/sandbox-runtime)) plus rule-based permissions evaluated `deny → ask → allow`. Defense in depth: permissions block intent, sandboxing blocks reach.
5. **Memory** — instruction-style files (CLAUDE.md / AGENTS.md, loaded at session start) plus learned auto-memory the agent writes about itself across sessions.
6. **Sub-agent dispatcher** — fork-with-isolated-context primitive (Claude Code's Task tool). Parent sees only the child's *final summary*; verbose work stays in the child's window.
7. **Hook lifecycle** — user-defined shell commands, HTTP endpoints, prompts, or agent calls firing at deterministic points. Claude Code exposes ~21 lifecycle events at three cadences: per-session, per-turn, per-tool-call. `PreToolUse` is the primary enforcement gate.
8. **Scheduling / loop control** — outer `while not done` loop with max-turn limits, depth counters per fork, spawn budgets, token/cost budgets.
9. **Evaluation / observability** — trace logging, eval-harness integration (Inspect, SWE-bench, Terminal-Bench), online quality monitoring.

## 3. Core principles

### 3.1 Context engineering

Coined by Andrej Karpathy, formalized by Anthropic's [*Effective context engineering*](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (Sept 2025). Reframes the work from "what string do I send the model?" to "what configuration of context state is most likely to generate the desired behavior?" Lance Martin's [*Context Engineering for Agents*](https://rlancemartin.github.io/2025/06/23/context_engineering/) is the practitioner companion.

### 3.2 Sub-agent isolation

Each sub-agent operates in an isolated context; tool calls and intermediate reasoning stay in its window, only the summary returns. Anthropic's [*How we built our multi-agent research system*](https://www.anthropic.com/engineering/multi-agent-research-system) reports a **90.2% uplift** over single-agent Opus 4 on internal research evals — at ~15× more tokens. The principle: spend tokens to *parallelize independent investigation*, not to extend a single thread.

### 3.3 Tool minimalism

Anthropic's tool-design guide, [Dexter Horthy's *12-Factor Agents*](https://github.com/humanlayer/12-factor-agents), and Jason Liu converge: **fewer, sharper tools** beat many overlapping ones. Horthy's heuristic: **<100 tools, <20 steps**. Anthropic warns specifically against tools that "merely wrap existing software functionality or API endpoints."

### 3.4 Deterministic affordances

Prefer deterministic tools (linters, type checkers, test runners, file ops) over inferential ones (LLM-as-judge) where possible. Constrained affordances make failures predictable and monitorable.

### 3.5 Just-in-time context

Maintain lightweight identifiers (paths, queries, URLs) and load data into context at runtime, instead of pre-stuffing the prompt. The ReAct pattern formalized for the agent era. Empirical motivation: the [*Lost in the Middle*](https://arxiv.org/abs/2307.03172) paper — models attend best to the start and end of context, poorly to the middle, so retrieval **precision** beats recall.

### 3.6 Cache-aware design

Anthropic prompt caching can cut cost ~90% and latency ~85%, but only if the cached prefix is preserved on every turn. Constraints shaping harness design:

- Up to 4 cache breakpoints
- 1024-token min cache (2048 for Haiku)
- 5-minute or 1-hour TTLs (longer must precede shorter)
- **The 5-minute TTL is the load-bearing constant in scheduler design.** If your tool loop has dead time exceeding 5 minutes (waiting on a build, on a human, on rate limits), the next turn pays full price.

Claude Code's fork-subagent design exists explicitly to keep child API requests byte-for-byte aligned with the parent's prefix.

### 3.7 Error budget per turn

Per *Your ReAct Agent Is Wasting 90% of Its Retries* and the production-reliability literature: retrying every error is the single most common cause of cost explosions. Discipline:

- Classify errors retryable vs non-retryable.
- Per-tool circuit breakers.
- Cap total retries per turn.

One published benchmark cited **90.8% of retries as wasted** on tool-name mismatches that would never succeed.

### 3.8 The bitter lesson, applied to harnesses

Sutton's bitter lesson — general methods that scale with compute beat handcrafted cleverness — re-derived for harness designers by Honeycomb (*If it Wanted to, it Would*) and Lance Martin (*Learning the Bitter Lesson*). Corollary: **design for the slope of progress, not today's snapshot**. Prefer letting the model choose tools dynamically over hard-coded workflows. Expect anything you over-engineer today to be deleted in 6 months when the model improves.

The flip side, from Martin Fowler's harness-engineering essay: a *good harness directs human input to where it matters*, rather than aiming to fully eliminate it.

## 4. Thin vs thick harnesses

Two-axis taxonomy: **interaction pattern** (pair-programmer vs autonomous orchestrator) × **harness depth** (raw API + tools vs full runtime).

- **Thin (pair-programmer)** — Aider, Cline, OpenAI Codex CLI. Optimize individual task quality; user is at the keyboard.
- **Thick (agent-orchestrator)** — Claude Code, Devin, Replit Agent, Cursor agent mode, Codex cloud. Take a goal and execute autonomously across many steps.

Per Haseeb Qureshi's architecture analysis: "Claude Code is 500K lines of code where the actual API call is maybe 200 of them, and everything else is the harness — where the differentiation happens." vtrivedy's *Harness as a Service* framing is the natural commercial extension: vendors sell the harness, customers bring the model and the goal.

## 5. Evaluation frameworks

| Framework | Purpose | Source |
|---|---|---|
| **SWE-bench / Verified / Lite / Multimodal** | Resolve real GitHub issues; the de-facto coding-agent benchmark | [swebench.com](https://www.swebench.com/) |
| **SWE-agent** | The companion ACI scaffold (Princeton/Stanford, NeurIPS 2024) | [arxiv 2405.15793](https://arxiv.org/abs/2405.15793) |
| **Terminal-Bench / 2.0** | Hand-curated CLI tasks; per-harness scoring | [tbench.ai](https://www.tbench.ai/) |
| **METR RE-Bench** | 7 hand-crafted ML R&D environments, head-to-head with 71 human experts | [metr.org](https://metr.org/AI_R_D_Evaluation_Report.pdf) |
| **METR Time Horizons** | How long a task an AI can complete with 50% reliability | [metr.org/time-horizons](https://metr.org/time-horizons/) |
| **Inspect** (UK AISI) | Standardized eval harness adopted by METR | [inspect.aisi.org.uk](https://inspect.aisi.org.uk/) |
| **Promptfoo / Inspect Evals / Braintrust / LangSmith / Phoenix** | Practitioner eval stack | various |

Practitioner methodology, per Hamel Husain's [*LLM Evals FAQ*](https://hamel.dev/blog/posts/evals-faq/) and the Maven course Husain runs with Shreya Shankar: spend 30 minutes manually reviewing 20–50 outputs after every meaningful change; pick one domain-expert "benevolent dictator"; prefer notebook-based trace analysis over heavy dashboards.

## 6. Failure modes

The catalog every harness designer must internalize:

- **Context rot.** Quantified by Chroma's 2025 study: every frontier model degrades at every context-length increment, well before the window limit. An *architectural property of transformer attention*, not a capability gap. ([trychroma.com/research/context-rot](https://www.trychroma.com/research/context-rot))
- **Tool sprawl / agent sprawl.** Too many tools inflates the system prompt and confuses routing; too many agents in an org creates a sprawling unmonitored fleet. Sub-100 tools per agent is the soft ceiling.
- **Runaway sub-agents.** Without a depth counter or spawn budget, the Task tool can recurse unboundedly. Mitigation: **inherited spawn budgets** — root with budget=12 means 12 *total* across all levels, not 12 per level.
- **Premature compaction.** ~85% threshold is the practitioner-recommended sweet spot. Worse failure mode: silent compaction failures where the summarizer errors and the middle of the conversation is dropped *without a summary*.
- **Over-eager planning.** Plan Mode for non-trivial tasks (3+ steps or architectural decisions); skip for trivial work to avoid token inflation and premature lock-in.
- **Sycophancy in code review.** RLHF rewards agreeable responses → "looks good" instead of identifying bugs. Mitigations: structured rubric review; use a *different model family* for review than for implementation.
- **Cache-busting prefix edits.** Any edit to the system prompt or tool list invalidates the cache. Schedule prompt-engineering changes deliberately, not opportunistically.

## 7. The 2025–2026 developments to know

- **Claude Agent SDK release** (2025). Same harness powering Claude Code as a programmable substrate.
- **AGENTS.md spec** (OpenAI, Aug 2025) — adopted by 60K+ open-source projects by Dec 2025. Now stewarded by the **Agentic AI Foundation** (Linux Foundation, Dec 2025), co-founded by Anthropic, OpenAI, Block.
- **Skills system** (Anthropic, late 2025) — model-discovered procedural modules with progressive disclosure. Made an [open standard via agentskills.io](https://agentskills.io/) in December 2025.
- **Plan Mode** (Claude Code) — first-class read-only mode for context gathering before mutation.
- **Subagent-driven development** — Jesse Vincent's `obra/superpowers` and the antigravity.codes skills formalized "fresh subagent per task with two-stage review."
- **Hooks platform maturity** — 21 lifecycle events, four handler types, JSON structured output.
- **Async coding agents** — Claude Code for web (Oct 2025), introducing notification, persistence, and cost-ceiling concerns.
- **Apple + Claude Agent SDK in Xcode 26.3** (2026), and Apple's App Review Guideline 5.1.2(i) requiring AI-data-sharing disclosure.
- **AAIF + Cowork** (Anthropic, 2026) — private plugin marketplaces for enterprises.
- **Anthropic Dreaming** (Code w/ Claude 2026) — overnight loop where the agent reviews previous sessions and writes new memories.
- **Revenue inflection** — Claude Code run-rate revenue hit $2.5B+ by Feb 2026 (more than doubled since Jan 2026).

---

# Part II — The Claude Code Primitive Reference

This part is a flat reference for every harness primitive Claude Code exposes. Each section gives the file location, frontmatter contract, and a minimal working example. Official docs at [code.claude.com/docs/en](https://code.claude.com/docs/en).

## 1. CLAUDE.md / AGENTS.md

**Purpose.** Persistent context loaded at every session start. CLAUDE.md takes precedence over AGENTS.md; symlink to share with other agents.

**Location precedence** (loaded in this order):

1. **Managed policy** (read-only, organization-wide):
   - macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
   - Linux/WSL: `/etc/claude-code/CLAUDE.md`
   - Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`
2. **User** — `~/.claude/CLAUDE.md` (personal, all projects)
3. **Project** — `./CLAUDE.md` or `./.claude/CLAUDE.md` (team-shared, committed)
4. **Local** — `./CLAUDE.local.md` (personal overrides, gitignored)
5. **Nested** — `.claude/CLAUDE.md` in subdirectories load on demand

**Import syntax** — `@path/to/file` (max 5-hop depth):

```markdown
See @README for overview and @package.json for build commands.
@docs/api-standards.md
@frontend/CLAUDE.md
```

**The 200-line rule.** Models reliably follow ~150–200 distinct instructions per context window; the system prompt already consumes ~50 of those slots. Practitioner consensus (alexop.dev, BSWEN, obviousworks.ch): keep project CLAUDE.md under ~60 lines, *never* over 200. The acid test:

> **Would Claude make a mistake without this line? If Claude already does it correctly, the line is noise.**

**Path-scoped rules** for file-type-specific instructions (saves context):

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API rules: validate input with Zod schemas in `schemas.ts`
# Error responses: { error: string, code: string, details?: object }
```

## 2. Skills

**Purpose.** On-demand procedural capabilities. Unlike CLAUDE.md (always loaded), skill bodies load only when invoked. Progressive disclosure: only the SKILL.md frontmatter (name + description) summarizes into context until the skill is needed.

**Location** — `~/.claude/skills/<name>/SKILL.md` (user) or `./.claude/skills/<name>/SKILL.md` (project) or in plugin packages.

**Directory layout:**

```
.claude/skills/deploy/
├── SKILL.md           (required)
├── reference.md       (loaded on demand by Claude)
├── examples/
│   └── canary.md
└── scripts/
    └── validate.sh
```

**Full frontmatter:**

```yaml
---
name: deploy                            # lowercase-kebab; namespaces under plugins
description: Deploy app to production    # what + when — drives auto-discovery
when_to_use: "release", "ship", "push"  # additional trigger phrases
arguments: [environment, sha]            # named args → $environment, $sha
argument-hint: "[environment]"
allowed-tools: "Bash(npm *) Read Edit"  # pre-approved tools while skill active
disable-model-invocation: false          # true → manual /name only, no auto-trigger
user-invocable: true                     # false → Claude-only knowledge
model: inherit                           # override model (e.g. opus for hard skills)
effort: high                             # override effort
context: fork                            # run in isolated subagent
agent: Explore                           # which subagent type to use with context: fork
paths: ["src/api/**/*.ts"]               # only activate for these files
shell: bash                              # bash | powershell for inline ! commands
---

Body here. Use $ARGUMENTS, $0, $environment, ${CLAUDE_SESSION_ID},
${CLAUDE_SKILL_DIR}.

## Current diff
!`git diff HEAD`

For deeper info, see [reference.md](reference.md).
```

**Discovery mechanism.** Claude's skill listing in context is a metadata summary. Full body loads on invocation. The `description` field drives auto-routing — make it specific enough that Claude matches your intent. Run `/doctor` to see if descriptions are truncated due to context budget overflow.

**Authoring norms** (Anthropic Skill Authoring Best Practices):

- Gerund-form names: `creating-shadcn-component`, not `shadcn-helper`.
- Description = "what + when," not "what."
- Keep SKILL.md body small — every line is a recurring token cost once loaded.
- Push large reference data into linked files for progressive disclosure.

## 3. Slash commands

**Purpose.** Quick invocation files in `.claude/commands/<name>.md`. Largely superseded by Skills (Skills support everything commands do, plus disable-model-invocation, supporting files, progressive disclosure). For new work, **prefer Skills**.

## 4. Sub-agents

**Purpose.** Specialized workers with isolated context, system prompt, and tool subset. Use when a side task would flood your main conversation with exploration you won't reference later.

**Location** — `.claude/agents/<name>.md`

**Frontmatter:**

```yaml
---
name: Code Reviewer
description: Expert code reviewer for architecture and security
tools: ["Read", "Glob", "Grep"]    # tool restriction — read-only here
model: claude-sonnet-4-6
effort: medium
disabled: false
permissions: auto                  # auto | askAlways | acceptEdits
---

You are an expert code reviewer. When given code:
1. Analyze for architectural issues
2. Check for security vulnerabilities
3. Verify test coverage
Return concise, specific findings.
```

**Tool restriction strategy.** A research/review agent should be read-only (`Read`, `Glob`, `Grep`, `WebFetch`); never grant `Edit`/`Write`/`Bash`. A code-fixer agent gets `Edit` but no `Bash`. A deploy agent gets a tightly scoped `Bash(kubectl get *)` glob, never raw `Bash`.

**When sub-agent beats skill:**
- Task warrants a fresh context (long, exploratory, results would pollute parent).
- Task should run with a *different model family* than the parent (eval, review).
- Task is parallelizable with other sub-agents.

## 5. Hooks

**Purpose.** Deterministic enforcement layer. Unlike CLAUDE.md (suggestions), hooks execute regardless of what the model decides. Configure in `settings.json` `hooks` block.

**Lifecycle events** (selected — full list of 21 in docs):

| Event | Cadence | Blockable | Use case |
|---|---|---|---|
| `SessionStart` | per session | no | inject env, log session ID |
| `SessionEnd` | per session | no | flush audit log |
| `UserPromptSubmit` | per turn | yes | content gate, telemetry |
| `Stop` | per turn | yes | "tasks really complete?" gate |
| `SubagentStop` | per turn | yes | wrap subagent return |
| `PreCompact` | per compaction | yes | persist critical state before summary |
| `PreToolUse` | per tool call | **yes — primary enforcement** | secret scan, command guard, two-key |
| `PostToolUse` | per tool call | no | lint-on-save, audit append |
| `PostToolUseFailure` | per tool call | no | error categorization |
| `Notification` | event-driven | no | desktop notifications |

**Handler types** — `command` (shell), `http` (POST to URL), `prompt` (ask Claude), `mcp_tool` (call an MCP tool).

**Exit codes:**

- `0` — success; parse stdout for JSON output
- `1` — non-blocking error (continues)
- `2` — **block** (only meaningful on blockable events)

The exit-code-2 path **survives `--dangerously-skip-permissions`**. That's the design — hooks are the deterministic gate; permissions are the model-level gate.

**Minimal example — block dangerous `rm -rf`:**

`.claude/hooks/block-rm.sh`:

```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked"
    }
  }'
  exit 2
fi
exit 0
```

`.claude/settings.json`:

```jsonc
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh"
      }]
    }]
  }
}
```

**Matcher patterns:** `"Bash"` (exact), `"Bash|Edit"` (alternation), `"^Bash"` (regex), `"mcp__github__.*"` (MCP namespace), `"*"` or `""` (all).

**Hook locations** (cascade): user → project shared → project local → plugin → skill/agent frontmatter.

## 6. MCP servers

**Purpose.** Connect Claude Code to external tools, databases, APIs. Servers expose tools and resources; resources appear as `mcp__server__resource`.

**Server types:**

```jsonc
{
  "servers": {
    // 1. Local stdio (program on your machine)
    "github": {
      "command": "npx",
      "args": ["@anthropics/github-mcp@latest"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    // 2. Remote SSE (HTTP with Server-Sent Events)
    "sentry": {
      "type": "sse",
      "url": "https://api.sentry.io/mcp/sentry",
      "env": { "SENTRY_AUTH_TOKEN": "${SENTRY_TOKEN}" }
    },
    // 3. Remote HTTP
    "custom-api": {
      "type": "http",
      "url": "http://localhost:8080",
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

**Configuration locations:** `.mcp.json` (project), `~/.claude/.mcp.json` (user), or inline `mcp_servers` in `settings.json` (SDK).

**Tool pre-approval:**

```jsonc
{
  "permissions": {
    "allow": ["mcp__github__*", "mcp__postgres__query"]
  }
}
```

## 7. settings.json hierarchy

**Cascade** (highest priority first):

1. **Managed** — `/Library/Application Support/ClaudeCode/managed-settings.json` (org policy, read-only)
2. **CLI args** — `--model`, `--settings`
3. **Local** — `.claude/settings.local.json` (gitignored)
4. **Project** — `.claude/settings.json` (committed)
5. **User** — `~/.claude/settings.json`

**Permissions block:**

```jsonc
{
  "permissions": {
    "allow": ["Bash(npm test)", "Bash(npm run build)", "Read(src/**)", "Edit"],
    "deny":  ["Bash(curl *)", "Read(secrets/**)", "Bash(rm -rf /)"],
    "defaultMode": "auto"        // ask | auto | reject
  }
}
```

**Permission rule syntax** — `ToolName`, `ToolName(pattern *)`, `Read(src/**/*.ts)`, `Edit|Write`, `mcp__github__*`.

## 8. Plan Mode and ExitPlanMode

Read-only mode in which Claude drafts a plan before any modification. Approve / refine / reject dialog appears on plan completion. Use Plan Mode for any task with **3+ steps or architectural decisions**; skip for trivial work.

**What survives the plan boundary:** CLAUDE.md, memory, session context, user settings.
**What does not:** the plan text itself.

## 9. Output styles

Modify the system prompt to change role/tone/format. Built-ins: Default, Explanatory, Learning, Proactive. Custom in `.claude/output-styles/<name>.md`. Frontmatter:

```yaml
---
name: Diagrams First
description: Lead explanations with Mermaid diagrams
keep-coding-instructions: true
---
```

## 10. Background tasks, Monitor, ScheduleWakeup, CronCreate

| Primitive | When |
|---|---|
| `/background` | Long multi-hour tasks; frees terminal |
| `Monitor` tool | Real-time log streaming; react per line |
| `ScheduleWakeup` | Check on async work after N seconds |
| `CronCreate` | Routine maintenance, daily syncs |

## 11. Claude Agent SDK (Python & TypeScript)

Same harness powering Claude Code, exposed as a library. When to use vs CLI:

- **CLI** — interactive, human-in-the-loop tasks
- **SDK** — CI/CD pipelines, production automation, custom apps

Python minimal:

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for msg in query(
        prompt="Fix the bug in auth.py",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        if hasattr(msg, "result"):
            print(msg.result)

asyncio.run(main())
```

Supports the same primitives: hooks (as Python callbacks), subagents (as `AgentDefinition`), MCP servers, sessions (programmatic resume).

## 12. Plugins

Bundle skills + commands + agents + hooks + MCP servers + output styles for distribution.

**Layout:**

```
my-plugin/
├── .claude-plugin/
│   ├── plugin.json
│   ├── hooks/hooks.json
│   ├── .mcp.json
│   └── settings.json
├── skills/<name>/SKILL.md
├── agents/<name>.md
└── output-styles/<name>.md
```

**Manifest** (`.claude-plugin/plugin.json`):

```json
{
  "name": "security-analyzer",
  "description": "Security scanning for code reviews",
  "version": "1.2.0",
  "author": { "name": "Security Team" },
  "repository": { "type": "git", "url": "https://github.com/co/security-analyzer" }
}
```

**Install** — `claude plugin install <name>` (marketplace) or `claude plugin install <git-url>` or `claude --plugin-dir ./my-plugin` (dev). Skills are namespaced: `/security-analyzer:scan`.

**Private marketplaces** — Anthropic Cowork (2026) lets enterprises publish plugins to internal marketplaces without routing code through Anthropic's infrastructure.

---

# Part III — Domain Harness Templates

Each domain section gives: opinionated *defaults*, the MCP servers and skills to wire up, the hooks that should be non-negotiable, real-world reference repos, and the anti-patterns the harness must structurally prevent.

The unifying instruction across all domains: **encode discipline as deterministic enforcement (hooks), not as documentation (CLAUDE.md prose). Hooks survive `--dangerously-skip-permissions`; documentation does not.**

---

## 1. Web Development

### 1.1 Frontend harness

**MCP servers — wire all of these:**

| MCP | Purpose |
|---|---|
| **Playwright** (`@playwright/mcp`, Microsoft official) | Accessibility-tree navigation; cheap, structured page reads |
| **Chrome DevTools** (`chrome-devtools-mcp`, Google official) | Real Chrome, Lighthouse, perf traces, source-mapped console |
| **shadcn/ui MCP** | Current shadcn v4 components for React/Vue/Svelte/RN — eliminates hallucination |
| **21st.dev Magic** | Generate novel components from NL prompts; complements shadcn |
| **Stitch** (`stitch-mcp`) | Import Google Stitch designs |

**The verification loop — accessibility tree, not screenshots.** Pasquale Pillitteri's [*AI is Blind*](https://pasqualepillitteri.it/en/news/205/ai-blind-playwright-mcp-invisible-bugs) is the definitive treatment. Playwright MCP returns the **accessibility tree** — what a screen reader sees — token-cheap and structured. Pixel screenshots are expensive and lossy for an LLM. Reserve screenshots for visual record / regression.

Loop:

1. Edit code
2. PostToolUse hook builds (`pnpm dev` already running) and triggers Playwright MCP
3. Agent fetches accessibility-tree snapshot
4. Agent runs `@axe-core/playwright` (WCAG) and `toMatchAriaSnapshot()` (structural regression)
5. Agent runs Chrome DevTools MCP Lighthouse against budget (LCP, INP, CLS)
6. Screenshot only on flagged visual diff

**Per-framework skills:**

| Stack | Skills |
|---|---|
| Next.js / React | `nextjs-app-router`, `react-server-components`, `tanstack-query`, `tailwind-design-system` |
| Vue / Nuxt | Official `nuxt-4-best-practices` (PR #33498), `vue-3-composition-api` |
| Svelte / SvelteKit | [`spences10/svelte-skills-kit`](https://github.com/spences10/svelte-skills-kit) — Svelte 5 runes (`$state`, `$derived`, `$effect`) |
| Astro | `claude-dev-suite-astro` — islands, content collections, hydration |
| Vanilla TS+Vite | Lighter — `tailwind-css-patterns` plus universal MCP stack |

### 1.2 Backend / API harness

**Per-language skills:**

- **Node/TS** (Express, Fastify) — `nodejs-backend-patterns`, `prisma-drizzle-orm`, `zod-validation`
- **Python (FastAPI)** — `python-expert` (uv, Pydantic V2, async DB), `fastapi-templates`
- **Python (Django)** — [`kjnez/claude-code-django`](https://github.com/kjnez/claude-code-django) — models, forms, DRF, Celery
- **Go** — `go-dev-server`, `backend-go-development` (clean-architecture)
- **Rust** — `rust-coding-skill` (rustfmt, clippy, test gates)
- **.NET** — less mature; lean on `fullstack-dev-skills`

**OpenAPI-first.** The `openapi-design` skill enforces docs-first: schemas → endpoints → security per OpenAPI 3.1, *then* code, then contract tests, then round-trip regen of the spec.

**Database migration safety.** [Atlas's `database-migration-best-practices` skill](https://atlasgo.io/guides/ai-tools/agent-skills) enforces idempotency, the **expand–contract pattern** for zero-downtime, and per-statement risk explanation (which DDL locks the table, estimated duration).

**Mandatory backend hooks (PreToolUse):**

1. **Secret scanner** — regex blocks `AKIA…`, `sk-…`, `ghp_…`, `BEGIN PRIVATE KEY` on `Write`/`Edit`. Reference: [`mafiaguy/claude-security-guardrails`](https://github.com/mafiaguy/claude-security-guardrails).
2. **SQL-injection gate** — flags new SQL string concatenation; suggests parameterized rewrite.
3. **Dependency audit** — `pnpm audit` / `pip-audit` / `cargo audit` after manifest edits; block on critical CVEs.

**Backend MCPs:** Postgres MCP, Redis MCP, **Sentry MCP** (built explicitly for human-in-the-loop coding agents — full error context → source file → fix), Linear MCP, GitHub MCP, Stripe MCP, Cloudflare Skills bundle (Workers, R2, D1, KV).

### 1.3 Full-stack monorepo harness

Claude reads CLAUDE.md from current directory **and every parent**. Use this:

```
/CLAUDE.md                       # 40–60 lines: monorepo-wide
/turbo.json                      # Claude reads task DAG
/pnpm-workspace.yaml             # Claude discovers packages
/apps/web/CLAUDE.md              # 30 lines: Next.js App Router
/apps/api/CLAUDE.md              # 30 lines: FastAPI conventions
/packages/ui/CLAUDE.md           # 20 lines: shadcn registry
/packages/db/CLAUDE.md           # 20 lines: migrations, RLS
```

**Skill scope:**

- **Project-level** (`/.claude/skills/`) — cross-package workflows: `release-changelog`, `cross-package-refactor`, `bumping-internal-deps`.
- **Package-level** (`/packages/ui/.claude/skills/`) — package-local: `creating-shadcn-component`, `adding-storybook-story`.

**Subagent topology** — one subagent per affected package, each in its own git worktree (`isolation: worktree`). The orchestrator owns integration. See [Claude Code Worktrees docs](https://code.claude.com/docs/en/worktrees).

### 1.4 Verification loop — the canonical six stages

Codified by Anthropic's [Superpowers plugin](https://claude.com/plugins/superpowers) and [evanklem/evanflow](https://github.com/evanklem/evanflow):

1. **Brainstorm** (`superpowers:brainstorming`)
2. **Plan** (`superpowers:writing-plans`) — 2–5 min tasks each with acceptance criteria
3. **Worktree isolate** (`superpowers:using-git-worktrees`)
4. **TDD red-green-refactor** (`superpowers:test-driven-development`) — *test must fail first*. [`nizos/tdd-guard`](https://github.com/nizos/tdd-guard) blocks implementation edits when no failing test exists.
5. **Verify** (`superpowers:verification-before-completion`) — evidence before assertions
6. **Review & ship** (`superpowers:requesting-code-review` → `finishing-a-development-branch`)

**Hooks wired as PostToolUse / Stop:**

```jsonc
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit|MultiEdit",
      "hooks": [
        { "type": "command", "command": "pnpm lint --fix $CLAUDE_FILE_PATHS" },
        { "type": "command", "command": "pnpm tsc --noEmit" }
      ]
    }],
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": ".claude/hooks/secret-scanner.sh" }]
    }],
    "Stop": [{
      "hooks": [{ "type": "command", "command": "pnpm test --run && pnpm build" }]
    }]
  }
}
```

### 1.5 The Next.js App Router CLAUDE.md (a worked example)

Highest-leverage lines per Greg Santos's gist and the obviousworks.ch guide:

```md
- App Router only. Never generate Pages Router patterns.
- Server Components by default. Add 'use client' ONLY for state, browser APIs, event handlers.
- Mutations via Server Actions, never client-side fetch to /api.
- Data fetching: async server components > React Query > SWR. No useEffect for data.
- Forms: Server Actions + useFormState; never controlled inputs without need.
- Styling: Tailwind only; shadcn/ui via shadcn MCP. Never hand-roll a button.
- Run `pnpm typecheck && pnpm lint && pnpm test` before claiming done.
```

### 1.6 AGENTS.md interop

AGENTS.md is read natively by Codex CLI, Cursor, Windsurf, Amp, Devin, Cline, Roo Code, Goose, Copilot. **Claude Code still uses CLAUDE.md** (AGENTS.md support pending as of mid-2026).

Pattern:
- Shared cross-tool instructions → `AGENTS.md`
- Claude-specific (skill triggers, MCP-aware workflows) → `CLAUDE.md`
- Symlink CLAUDE.md → AGENTS.md if you want one source of truth
- **MCP servers and SKILL.md are universally compatible** across all major agents — invest there for portability.

### 1.7 Reference repos

Vendor-published: [`cloudflare/skills`](https://developers.cloudflare.com/agent-setup/claude-code/), Shopify AI Toolkit, Vercel MCP, [`getsentry/sentry-mcp`](https://github.com/getsentry/sentry-mcp), Stripe MCP, [`anthropics/skills`](https://github.com/anthropics/skills).

Open-source harnesses worth studying: [`obra/superpowers`](https://claude.com/plugins/superpowers), [`evanklem/evanflow`](https://github.com/evanklem/evanflow), [`nizos/tdd-guard`](https://github.com/nizos/tdd-guard), `maxritter/pilot-shell`, `affaan-m/everything-claude-code`, `Matt-Dionis/claude-code-configs`, `kjnez/claude-code-django`, `mafiaguy/claude-security-guardrails`, `VoltAgent/awesome-agent-skills`.

### 1.8 Web anti-patterns

- **CLAUDE.md > 200 lines.** Compliance falls off a cliff. Ruthlessly prune.
- **Mega-skills** — kitchen-sink SKILL.md trying to cover commits + PRs + branch naming. Split into focused gerund-named skills.
- **Skill overload** — past 8–12 well-chosen skills, marginal value drops sharply.
- **Kitchen-sink session** — mixing unrelated tasks pollutes context. `/clear` between unrelated work.
- **Screenshot-only verification** — pixels are expensive and lossy for an LLM. Use accessibility tree.
- **Reinventing Claude Code primitives in a custom shell.** Per Theo Browne (T3 Code): models perform best in the harness they were trained against.
- **Over-engineering up front.** Per Lee Robinson (*Coding Agents & Complexity Budgets*): start with zero custom rules; add only what proves necessary.

---

## 2. Data Analysis, Data Science & ML/AI Engineering

### 2.1 Notebook-centric harness

The inflection point is reactive/deterministic notebooks plus the Jupyter MCP server replacing the old "edit-blind .ipynb JSON" pattern.

**Prescriptive defaults:**

1. **Disable `NotebookEdit` by default for Jupyter.** Require the [`jjsantos01/jupyter-notebook-mcp`](https://github.com/jjsantos01/jupyter-notebook-mcp) for any agent that touches `.ipynb`. The MCP gives the agent IPython kernel access — it can self-correct in a loop until cells run clean.
2. **For new projects, default to marimo, not Jupyter.** Marimo notebooks are pure Python files (git-diffable, importable, scriptable), executed in deterministic dependency-graph order. The cited 36% of 10M sampled Jupyter notebooks being non-reproducible is the load-bearing argument.
3. Install [`marimo-team/skills`](https://github.com/marimo-team/skills) — `uv tool install marimo-skills`.
4. **Notebook-to-script extraction as CI gate.** marimo has `marimo export script`; for Jupyter, `jupyter nbconvert --to script` + `nbqa ruff`. Reject merges where the converted script does not run end-to-end.
5. **Cell-level testing** — lift functions out of notebooks (nbdev or marimo `@app.cell` named cells), test in normal pytest.

For Hex / Deepnote / Observable — useful for analyst-facing exploration but vendor-locked and harder to govern with skills/hooks; not the canonical artifact.

### 2.2 DataFrame-heavy work — sample-then-scale

**The most underused harness primitive for data work is the PreToolUse hook.** Exit code 2 blocks the call and feeds stderr back to the model so the agent learns *why*.

Reference hook — `block_unbounded_sql.py` (PreToolUse on warehouse MCPs and Bash):

```python
import sys, json, re
event = json.load(sys.stdin)
if event["tool_name"] not in {"mcp__snowflake__query", "Bash", "mcp__bigquery__run_query"}:
    sys.exit(0)
sql = (event["tool_input"].get("query") or event["tool_input"].get("command") or "").lower()
if "select" in sql and "limit" not in sql and "where" not in sql:
    print("Rejected: SELECT against warehouse without WHERE or LIMIT. "
          "Use TABLESAMPLE or LIMIT 1000 first to validate.", file=sys.stderr)
    sys.exit(2)
if re.search(r"\b(drop|truncate|delete\s+from|update\s+\w+\s+set)\b", sql):
    print("Rejected: write/destructive SQL must go through migration PR.", file=sys.stderr)
    sys.exit(2)
```

This forces sample-then-scale: agent runs `LIMIT 1000` first, examines, then graduates.

**Warehouse MCPs:**

- **[Snowflake Managed MCP](https://www.snowflake.com/en/blog/managed-mcp-servers-secure-data-agents/)** — runs server-side; credentials never touch the agent host. Default for compliance-sensitive tenants.
- **[Databricks MCP](https://mcpservers.org/servers/databrickslabs/mcp)** — pairs with Genie + Mosaic; enforce Unity Catalog policies upstream.
- **[Felt MCP](https://felt.com/blog/introducing-felt-mcp-server)** — single MCP across Snowflake/BigQuery/Databricks/Postgres/Redshift; use when you can't pick a vendor.
- **[`AltimateAI/altimate-code`](https://github.com/AltimateAI/altimate-code)** — open-source agentic data engineering harness, dbt + 10 warehouses.

**DataFrame engines** — default Polars + DuckDB + Ibis for new code; pandas only for ecosystem glue. Ibis lets you write once and swap backends (DuckDB local → Snowflake prod) — the safest sample-then-scale architecture.

### 2.3 ML pipeline harness

**Tracking discipline.** PreToolUse on `Bash` rejects any `python train.py` invocation without `import (wandb|mlflow|aim)`. The cheapest enforceable "every run is logged" gate.

**Stack consensus** (per [Uplatz 2025 MLOps landscape](https://uplatz.com/blog/the-2025-mlops-landscape-a-comparative-analysis-of-mlflow-weights-biases-and-neptune/)):
- MLflow — open-source / Databricks-native
- W&B — developer UX (now CoreWeave-integrated)
- Neptune — GPT-scale governance
- Aim — lightweight self-hosted

**Reproducibility skill** (`reproducibility-precommit`) verifies before any commit:

1. Seeds pinned across `random`, `numpy`, `torch`, `jax`, `transformers.set_seed`, and `PYTHONHASHSEED`.
2. Lockfile (`uv.lock` / `pixi.lock`) is fresh.
3. CUDA / cuDNN versions recorded.
4. Data hash recorded (content hash of input parquet).

**Data versioning** — DVC for sub-100GB datasets; lakeFS for warehouse-scale (lakeFS acquired DVC Nov 2025). Hook on `Write` rejects any commit of a file >10MB unless under `data/raw/.dvc/` or with a `*.dvc` pointer.

**Eval suite ≠ model code.** Keep evals in a separate package or repo so the agent cannot conveniently "improve numbers" by editing both at once. See [Hugging Face's `huggingface/skills`](https://github.com/huggingface/skills) and the [Sionic AI case study](https://huggingface.co/blog/sionic-ai/claude-code-skills-training) (1000+ ML experiments/day with Claude Code skills).

### 2.4 LLM-app development harness — evals as the unit test

Hamel Husain's three-tier model is the field standard:

- **Level 1 — assertions/unit tests** on every code change (pytest-style: "JSON parses," "no PII in output," "answer contains expected entity")
- **Level 2 — model-graded** on a cadence (LLM-as-judge with a *different* model than under test)
- **Level 3 — human review** after major changes

**The order matters.** Hamel's clearest warning: teams skip Level 1 (because it feels low-status) and go straight to LangSmith dashboards, which become unfalsifiable theater.

**Avoid Claude judging Claude.** Self-preference bias is real and measurable: GPT-4 and Claude prefer their own outputs by 10–25%. Bake this into the eval skill as a hard constraint — if `--judge-model` matches the family of the generator, refuse to run.

**Tool selection:**

- **[Promptfoo](https://github.com/promptfoo/promptfoo)** — CI/CD gate. YAML in repo.
- **[Inspect AI](https://inspect.aisi.org.uk/)** (UK AISI) — rigorous dataset → solver → scorer; sandboxed Docker; can wrap Claude Code, Codex, Gemini CLI as agents under test. 200+ pre-built evals via [Inspect Evals](https://ukgovernmentbeis.github.io/inspect_evals/).
- **Braintrust / LangSmith / Phoenix** — dashboards for human annotation and regression tracking.

### 2.5 Statistical-rigor hooks (most under-shipped, highest leverage)

**The agent will happily commit `if p < 0.05: print('significant!')` across 47 simultaneous tests.** PreToolUse hooks scanning the diff:

1. **Bonferroni / Benjamini-Hochberg sentinel** — detect `scipy.stats.ttest_ind` or `pingouin.ttest` in a loop without `multipletests` / `fdrcorrection`. Block.
2. **Train/test leakage detector** — scan for `StandardScaler().fit(X)` / `SimpleImputer().fit(X)` outside a `Pipeline` / `ColumnTransformer`, or `fit` called before `train_test_split`.
3. **Look-ahead bias detector** for time series — forbid `.shift(-1)`, `.rolling(...).mean()` without `.shift(1)`, `resample(label='left')`. Borrow Freqtrade's automated approach: re-run backtest with future data masked, compare results — if they differ, fail commit.
4. **P-curve sanity** — flag clustering of p-values just below 0.05.
5. **Suspicious accuracy detector** — Level 2 eval flags any reported test accuracy > 0.99 on non-trivial datasets for human review.

These are 30–80 lines of Python each, regex + AST. They are also where the harness-vs-prompt distinction becomes real: you cannot tell Claude "don't p-hack"; you have to make p-hacking literally fail to commit.

### 2.6 Visualization — a `chart-critic` sub-agent

Sub-agent whose system prompt enumerates the canonical sins: truncated y-axis, dual y-axes implying spurious correlation, missing CIs, rainbow palettes for sequential data, color-only encoding (must combine with shape/pattern), 3D pie charts, distorting aspect ratio.

Pipeline: any `plt.savefig` / `fig.write_html` triggers PostToolUse → `chart-critic` sub-agent (vision model) scores or returns structured critique. Use a *different model family* than the generator.

Prefer **Altair** and **Observable Plot** — grammar-of-graphics constraints make many sins syntactically harder.

### 2.7 Reproducibility skills — the lockfile hierarchy

- **uv** — default for pure-Python. `uv lock --frozen` in CI. 10–100× faster than pip.
- **pixi** — when you need conda packages (CUDA, MKL, R, ffmpeg). Integrates uv internally; produces `pixi.lock` with both PyPI and conda deps. Right answer for any GPU-using project that doesn't want Docker.
- **conda** — legacy; pair with `conda-lock`.
- **poetry** — declining as uv subsumes it.
- **nix flakes** — for the brave; bit-for-bit reproducibility years out. `rix` and `rixpress` make Nix tractable for R/Python.

**Dev container** — base on `mcr.microsoft.com/devcontainers/python:3.12` or `ghcr.io/astral-sh/uv`. `postCreateCommand: uv sync --frozen`. Install Claude Code as a feature so the agent runs *inside* the container.

### 2.8 Real-world references

- **Hugging Face** — [`huggingface/skills`](https://github.com/huggingface/skills), [`huggingface/upskill`](https://github.com/huggingface/upskill) (uses Claude to *generate and evaluate* skills, including CUDA kernels), [Sionic AI post](https://huggingface.co/blog/sionic-ai/claude-code-skills-training)
- **Anthropic Cookbook** — [`anthropics/claude-cookbooks/skills`](https://github.com/anthropics/claude-cookbooks/tree/main/skills), [data analyst agent recipe](https://platform.claude.com/cookbook/managed-agents-data-analyst-agent), [financial Skills cookbook](https://platform.claude.com/cookbook/skills-notebooks-02-skills-financial-applications)
- **Posit (RStudio + Positron)** — Posit Assistant (GA Mar 2026); reads live R session context — the model for "agent that knows the actual data in memory, not just the script"
- **marimo Skills** — [`marimo-team/skills`](https://github.com/marimo-team/skills)
- **Cursor for data science** — [docs](https://docs.cursor.com/en/guides/advanced/datascience); the [Mito `.py` + `# %%` cell-marker workaround](https://www.trymito.io/blog/using-cursor-with-jupyter-notebooks-a-workaround-for-data-scientists) is durable

### 2.9 Data anti-patterns (codify against)

1. **Silent warehouse mutation.** Read-only role; human-approved migration PR for any DDL/DML.
2. **"Looks reasonable" outputs.** Numbers without provenance are hallucinations with extra steps. Every reported metric backed by a logged query, dataframe shape, source-table checksum.
3. **No audit trail of agent queries.** PostToolUse hook on every warehouse MCP appends query + row count + cost + session ID to `agent_audit` table. Single highest-ROI hook.
4. **Re-running expensive jobs without caching.** Content-addressed caching: hash `(query, schema_version, data_snapshot_id)`.
5. **Eval the model that wrote the code.** Hard constraint in eval skill frontmatter.
6. **Editing notebook JSON blind.** NotebookEdit on `.ipynb` — ban for production work.
7. **Letting the agent silently modify the lockfile.** PostToolUse hook on `Bash` detects `pip install` / `uv add` and routes through `uv add --frozen` or blocks outside controlled "deps update" mode.
8. **Treating the agent's plan as the audit trail.** The plan is fiction until validated; the audit trail is the recorded list of tool calls with inputs, outputs, costs, timestamps.

---

## 3. DevOps, SRE & Platform Engineering

### 3.1 IaC harness (Terraform / OpenTofu / Pulumi / CDK / Bicep)

**The non-negotiable rule.** The agent never runs `terraform apply` / `terraform destroy` directly. The agent proposes; a human or CI runs. Enforce via PreToolUse hook with exit code 2 — the only signal that survives `--dangerously-skip-permissions` and `bypassPermissions`.

**Plan-before-apply enforcement.** PreToolUse matcher on `Bash` regex `terraform\s+apply` (and `tofu apply`, `pulumi up`, `cdk deploy`, `az deployment .* create`):

1. Verify a `*.plan` file produced within the last 15 min exists.
2. Verify `terraform plan -detailed-exitcode` was the last terraform command in the agent transcript.
3. If the plan included `destroy` on a deny-list resource type (`aws_db_instance`, `aws_s3_bucket` with data, anything `*_kms_key`) — block unconditionally.

**Other IaC primitives:**

- **State-lock awareness** — wrap `terraform` in a shim that detects "Error acquiring the state lock" and aborts the agent loop (don't retry over an in-flight human operation).
- **Drift detection in the loop** — `terraform plan -refresh-only` as a read-only sub-agent. Critically: **autonomous drift remediation is itself an anti-pattern**. Drift may be intentional. Surface and explain; don't heal.
- **Cost gates** — Infracost + OPA. PreToolUse runs `infracost diff --terraform-plan-path plan.json` and blocks if monthly delta exceeds environment threshold.
- **Policy-as-code stack** — `tflint` → `tfsec`/`checkov` → `conftest` (OPA/Rego) → `sentinel` (HCP Terraform). All four as PostToolUse on `*.tf` writes, first three on a 5-second budget. **Trivy was supply-chain compromised twice in March 2026; default to `Checkov` for IaC and `Grype` for image scanning.**
- **Pulumi specifics** — [pulumi/agent-skills](https://github.com/pulumi/agent-skills): `pulumi-component`, `pulumi-esc` (OIDC + dynamic creds), migration skills.
- **CDKTF** — deprecated and archived Dec 2025. Migrate via `pulumi convert --from terraform`.
- **Bicep / ARM** — Microsoft's [`azure-skills`](https://github.com/microsoft/azure-skills) is the canonical SKILL.md set.

### 3.2 Kubernetes harness — the kubectl context guard

PreToolUse intercepts every `kubectl` / `helm` / `k` call. Sub-millisecond Rust/Go binary parses it. Reads current context (`kubectl config current-context`). YAML policy file maps context patterns → allowed verbs.

`*-prod*`, `*-prd*`, anything in `production-cluster-allowlist` blocks `delete`, `drain`, `cordon`, `scale --replicas=0`, `patch ... --type=json` on Deployments, and any `apply`/`replace`/`create` without `--dry-run=server`.

**Nuclear patterns** (ordered first so they match before generic `delete pod`): `delete namespace`, `delete pvc`, `delete pv`, `delete crd`, `delete pods --all`, `delete --all-namespaces` — deny unconditionally on prod, regardless of confirmation.

**Manifest validation pipeline (PostToolUse on `*.yaml` writes):**

- `kubeconform` — schema validation against actual K8s version
- `kube-linter` — opinionated best practices
- **Kyverno + OPA Gatekeeper, complementary not competitive.** Use Kyverno for K8s-native YAML policies (no Rego learning curve); OPA Gatekeeper for cross-domain policies sharing a Rego library with admission-controller policies in production.

**Progressive delivery.** Argo Rollouts dominates. **Never let the agent promote a canary directly.** The agent updates the `Rollout` manifest in Git → Argo CD reconciles → an analysis template (Prometheus / Datadog) decides promotion.

### 3.3 CI/CD pipelines

**OIDC-over-static-keys mandate.** Every harness template in 2026 should refuse to write `aws_access_key_id` or `AZURE_CLIENT_SECRET` into a workflow file. PreToolUse hook on `Write`/`Edit` to workflow files denies any diff that introduces a long-lived secret reference.

Skill auto-converts detected static-credential patterns to:

```yaml
permissions:
  id-token: write
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.DEPLOY_ROLE_ARN }}
```

**Reusable workflow design.** GitHub Actions reusable workflows pinned to commit SHAs (never `@main`). Skill refuses to introduce a `uses:` reference without a SHA pin.

**Prompt injection in CI.** The Cloud Security Alliance's May 2026 research note is required reading: any agent in CI with write access can be manipulated through PR comments, issue bodies, dependency README files. CI agent runs with read-only Git tokens by default; write operations require a separate, scoped, short-lived token via reusable workflow with explicit `permissions:`.

### 3.4 Cloud-specific & blast radius

**Encoding blast radius:**

1. **Identity per agent, never per user.** The agent has its own IAM principal, distinct from any human. Sonrai research: 92% of cloud identities are over-privileged.
2. **Account/project tags as the blast-radius primitive.** Every account/project tagged `env:dev|staging|prod` and `blast-radius:low|medium|high|nuclear`. PreToolUse hook reads current account ID (`aws sts get-caller-identity`) → tag → tier-specific deny rules.
3. **Default-deny for prod.** Anything `prod`/`nuclear` requires two-key confirmation.
4. **Time-bound credentials.** AWS STS `AssumeRole` with `DurationSeconds: 900` (15 min). Refuse credentials older than the session token.
5. **Session tags carry agent identity.** STS session tags include `agent-run-id`, `user`, `task-summary` so CloudTrail entries are attributable.

**Official MCP servers** — AWS Agent Toolkit (May 2026), Azure MCP Server, Google Colab MCP. Prefer official over community for production-touching agents.

### 3.5 Container & build

**Multi-arch + SBOM by default.** `docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=mode=max`. `ko` for Go (reproducible, SBOM-by-default, no Dockerfile). Bazel 9.2.0 with `rules_oci` for polyglot monorepos (rules_docker is deprecated).

**PostToolUse vulnerability scanning** on any `docker build` / `buildx build` / `ko build`:

1. `syft` generates SBOM
2. `grype` scans with `--fail-on high`

(2026 caveat: Trivy supply-chain compromises March 2026 — wait for verified-signed releases or default to syft+grype.)

### 3.6 Observability harnesses

MCP-as-telemetry-interface (2026 GA landscape):

| MCP | Status |
|---|---|
| **Datadog MCP** | GA Mar 9, 2026 |
| **New Relic AI MCP** | standardized agent interface |
| **Honeycomb MCP** | AI-native, Anomaly Detection + Canvas |
| **Sentry MCP / PagerDuty MCP** | event-driven, incident-response |

**Sub-agent specialization.** A `log-triage` sub-agent has read-only access to log MCP, returns top-N candidates plus correlated trace IDs — verbose dumps stay in its context. A `trace-analyzer` summarizes the slowest span. A `runbook-executor` loads a SKILL.md for a specific runbook and executes its steps.

Sub-agents use ~7× the tokens of single-thread, but isolation is the right tradeoff because the parent is making the human-facing decision.

### 3.7 Incident response — runbook-as-skill, war-room sub-agents, two-key

- **Runbook-as-skill.** Each runbook → SKILL.md with trigger, preconditions, ordered steps, rollback, success/abort criteria.
- **War-room architecture** (Komodor's articulation): main agent = Incident Commander (lifecycle, dispatch, synthesis, decision); specialist sub-agents per K8s/networking/database/affected-app domain; comms sub-agent drafts (never sends) Slack/status-page updates for human approval. The IC explicitly decides between conflicting specialist findings; specialists do not argue.
- **Two-key confirmation hook.** Adapted from OWASP AI Agent Security Cheat Sheet. Any PreToolUse matched as `prod-touching` emits a structured confirmation:
  - exact command
  - resolved blast radius
  - diff if applicable
  - typed (not clicked) `CONFIRM <last-4-of-resource-id>` token

  A single `y` or click is insufficient. The token requirement defeats reflexive approval — the most common failure mode in incident response when responders are tired.

### 3.8 GitOps cardinal rule

**The agent participates in the GitOps loop by writing to Git, never by writing to the cluster.** PreToolUse denies any `kubectl apply` against a cluster with an Argo CD `Application` for that namespace. Promotion happens via Argo's analysis runs, not via agent-issued `kubectl argo rollouts promote`.

### 3.9 DevOps anti-patterns

1. **Static long-lived cloud credentials in agent env.** Refuse to start with `AWS_ACCESS_KEY_ID` set; use OIDC + STS, ≤15-min sessions.
2. **Agent and user sharing the same IAM principal.** Defeats attribution.
3. **Hooks that rubber-stamp `terraform apply` after `terraform plan`.** A 30-min-old plan is stale. Hard-block on age > 15 min, or if state mutated since plan.
4. **Sub-agents inheriting parent credentials.** Each sub-agent requests its own scoped credentials.
5. **No audit log of agent-issued commands.** EU AI Act (Aug 2026 enforcement) makes this regulatory failure.
6. **`--dangerously-skip-permissions` in shared environments.** Only acceptable inside an isolated sandbox. Exit-code-2 hook path still works under skip-permissions; that's the design.
7. **Autonomous drift remediation.** Drift may be intentional.
8. **Compaction-dependent safety rules.** Critical rules belong in CLAUDE.md (system prompt), never in conversation history that may be compacted.
9. **Sub-agents whose verbose logs leak into parent context.** Always pre-summarize.

---

## 4. Finance, Quant, Trading, Accounting & FinTech

The financial domain demands extra rigor: auditability, determinism, regulatory traceability. Consensus pattern: **AI drafts; humans sign off.** No trade execution, journal entry, or client notification ever fully automated.

### 4.1 Quantitative research harness

**Backtesting framework selection** (2025–2026 consensus):

| Framework | Best for |
|---|---|
| **VectorBT Pro** | Vectorized parameter sweeps, millions of trades/sec |
| **Zipline-Reloaded** | Long/short equity factor research with dynamic universe |
| **Backtrader** | Broad broker integration; event-loop slow on big data |
| **NautilusTrader** | Rust core; minimizes backtest-vs-live gap; microstructure alpha |
| **QuantConnect LEAN** | 40 point-in-time data sources; integrated Mia LLM agent |

**Mandatory skills:**

1. **`point-in-time-data` skill** — refuses any dataset whose schema lacks `as_of_date` / `knowledge_date`.
2. **`survivorship-aware` skill** — checks universe constructor against a delisting database; warns when defunct tickers are missing. Standard 1–4% per-annum return overstatement otherwise.
3. **`purged-cv` / `cpcv` skill** — encodes Marcos López de Prado's [Combinatorial Purged Cross-Validation](https://en.wikipedia.org/wiki/Purged_cross-validation). Walk-forward alone gives a single high-variance path; CPCV embargoes overlapping samples for proper inference.

PreToolUse hook on Python execution greps proposed code for `train_test_split(shuffle=True)`, `KFold(shuffle=True)` without `TimeSeriesSplit`, or `.shift(-N)` patterns indicative of look-ahead — hard-block.

### 4.2 Market data

| Source | MCP | Grade |
|---|---|---|
| Polygon.io | Official MCP, Apache-2.0, 35+ tools | A |
| Databento | `Nice-Wolf-Studio/databento-mcp-server` | B |
| Tiingo | `matteoantoci/mcp-tiingo` | B |
| Refinitiv / Bloomberg | No MCP; use [findatapy](https://github.com/cuemacro/findatapy), `xbbg`, BLPAPI | n/a |

**Quota / rate-limit hooks:**

- **PreToolUse on `mcp__polygon__*`** — Redis counter; deny when quota exceeded.
- **Sample-vs-full-history gate** — hook inspects payload; `start < today - 90d` requires human approval. Prevents the classic "agent hammers vendor with 3000 RIC × 13 year request."
- **Backoff** — on HTTP 429, set cool-down flag the agent reads next PreToolUse.

### 4.3 Trading agents

[Alpaca's official MCP Server v2](https://alpaca.markets/blog/introducing-official-mcp-server-enabling-multi-market-trading-with-ai-interfaces/) (61 distinct actions) is the reference implementation.

**Mandatory hooks:**

1. **Paper-by-default** — PreToolUse strips/rewrites any `mcp__alpaca__place_order` whose `account_id` matches a live broker UUID unless session-scoped `LIVE_TRADING_APPROVED=true` was set out-of-band by a human.
2. **Two-key live confirmation** — even with the live flag, every order requires a human-issued nonce that the hook validates. The LLM cannot generate this nonce.
3. **Position-limit guard** — PreToolUse reads current portfolio state; blocks any order pushing notional, sector concentration, or single-name weight over preset limits.
4. **Stop-hook kill switch** — implements [KILLSWITCH.md](https://killswitch.md/): three-level escalation (throttle → pause → full stop), append-only JSONL audit, explicit OVERRIDE conditions. Calls broker's flatten-and-cancel-all on triggers (loss > X, error rate > Y, latency anomaly).
5. **Forbidden-action list** — explicit deny on naked options, leveraged ETFs, after-hours orders unless allowlisted.

Colorado, California, Texas, Illinois 2026 statutes now reference "kill switch" and "human override" requirements explicitly.

### 4.4 Risk & compliance

**Risk math skills** — [skfolio](https://skfolio.org/) (sklearn-compatible portfolio optimization with stress testing), QuantLib, PyPortfolioOpt, FIAQuant VAR-Stress-Test-Model.

**Required gates:**

- Every Sharpe must be accompanied by Probabilistic Sharpe Ratio (PSR), or — if multiple strategies tested — **Deflated Sharpe Ratio** ([Bailey & López de Prado](https://www.davidhbailey.com/dhbpapers/deflated-sharpe.pdf)). The False Strategy Theorem makes this non-negotiable: highest observed Sharpe across many random strategies will be positive even when all true Sharpes are zero.
- CVaR over VaR for tail-sensitive portfolios.

**Stress-test sub-agent.** Runs scenario libraries (1987, 2008, COVID-March-2020, 2022 rates shock) against any proposed allocation. Output is a required attachment to any human approval request.

**Model risk management — SR 11-7 → SR 26-02.** Federal Reserve [SR 11-7 was rescinded April 17, 2026](https://www.occ.treas.gov/news-issuances/bulletins/2026/bulletin-2026-13.html), replaced by [SR 26-02](https://www.federalreserve.gov/supervisionreg/srletters/SR2602.pdf). Foundational principles — sound governance, independent validation, effective challenge — remain. Agent runs are model runs and need an inventory entry.

**Immutable transcripts.** Append-only logs (Kafka / Pulsar / cloud event streams) with SHA-256 hash chaining covering prompt + retrieval + reasoning trace + response + handoff. SEC Rule 17a-4 and FFIEC require immutable seven-year retention. EU AI Act enforcement opens **August 2, 2026** with fines up to €35M or 7% of global turnover.

### 4.5 Accounting / bookkeeping

**Anthropic reference agents** in [`anthropics/financial-services`](https://github.com/anthropics/financial-services): General Ledger Reconciler (`claude plugin install gl-reconciler@claude-for-financial-services`), Month-End Closer, Statement Auditor. All ten follow "AI drafts, humans sign off."

**Double-entry invariant hook.** Σ debits = Σ credits per transaction; globally Σ all account balances + settlement = 0. PostToolUse on any DB-write: parse journal payload, refuse anything that doesn't balance to the cent. PreToolUse for QuickBooks / Xero MCP calls.

**Period-close skill** — six-phase framework with mandatory checklists, pressure-resistance logic preventing bypass, locks period only after all reconciliations pass. Master skill delegates to bank-recon, depreciation, AP/AR, budget-vs-actuals sub-skills.

### 4.6 Spreadsheet-heavy work

- [`xing5/mcp-google-sheets`](https://github.com/xing5/mcp-google-sheets)
- [`negokaz/excel-mcp-server`](https://github.com/negokaz/excel-mcp-server)

**Formula-audit skill** walks the dependency graph (Trace Precedents/Dependents) and flags cycles; detects hard-coded values inside formulas that should be parameters; enforces named-range usage for cross-sheet references; flags volatile functions (NOW, RAND, INDIRECT, OFFSET) misused in audited models.

**No-destructive-overwrite hook** (PreToolUse on `mcp__sheets__update_range` / `mcp__excel__write_cells`):

- Refuse writes to sheets matching `*_FINAL`, `*_AUDIT`, or "locked" metadata
- Require `--copy-first` mode that snapshots to `_backup_<timestamp>` before modification
- Block writes that would clear cells containing formulas (a common LLM failure mode)

### 4.7 Regulatory / compliance

**Hooks blocking unmasked PII / PAN / SSN:**

- Regex/Luhn-validate any 13-19 digit string about to be written; if Luhn-valid and unmasked, deny.
- SSN pattern `\d{3}-\d{2}-\d{4}` → mask to `XXX-XX-1234`.
- PCI DSS 3.5.1.1 (mandatory after Mar 31, 2025): PAN hash for storage must be **keyed cryptographic hash**.

**Encryption-in-transit hook** — PreToolUse on outbound HTTP refuses any `http://` or any `https://` to a host with non-current TLS / weak cipher suite.

### 4.8 DeFi / crypto

**Toolchain** — Foundry (Forge/Cast/Anvil), Hardhat, Slither (static), Mythril (symbolic), [Halmos](https://github.com/a16z/halmos) (a16z, symbolic with Foundry frontend), Certora (formal verification).

**"Never sign without simulation" hook:**

1. PreToolUse on any tx-signing tool intercepts calldata.
2. Forks current mainnet state via Anvil/Tenderly fork RPC.
3. Simulates the tx; extracts state changes, emitted events, token transfers, gas.
4. Diffs against an expected manifest the agent must declare BEFORE simulation (no post-hoc rationalization).
5. On mismatch → deny + record in audit log.
6. On match → still requires multisig confirmation; the agent never holds a private key with unilateral signing power.

**Always verify on hardware Secured Display.** True security requires final verification on a hardware wallet. **Never blind sign.**

### 4.9 Forecasting / time series

[Nixtla's StatsForecast](https://nixtlaverse.nixtla.io/statsforecast/index.html) wins on speed and benchmarks (SeasonalNaive +23% accuracy, 75× faster than Prophet). Add Darts, sktime, Prophet (baseline only).

**CV discipline skill** — refuses `KFold(shuffle=True)` / `train_test_split` without `shuffle=False` for time-indexed data. Mandates `TimeSeriesSplit` or Nixtla's `cross_validation`. For finance: requires CPCV.

**MASE-vs-MAPE.** Skill enforces every forecasting report includes [MASE](https://www.nixtla.io/blog/statsforecast-automatic-model-selection) (scaled vs seasonal naive). MAPE breaks near zero and asymmetrically penalizes overforecasting. Numbers reported as ratios to a baseline; **baseline-required gate** is a Stop hook that refuses to mark task done unless a baseline comparison is in the artifact.

### 4.10 Real-world references

- **Anthropic** — [Financial Services hub](https://claude.com/solutions/financial-services), [`anthropics/financial-services`](https://github.com/anthropics/financial-services), [knowledge-work-plugins/finance](https://github.com/anthropics/knowledge-work-plugins/tree/main/finance), [Claude for the financial industry deployment guide PDF](https://www-cdn.anthropic.com/files/4zrzovbb/website/34783bca828d7fa331f515ced26f1c9232151b2c.pdf)
- **Ramp** — AI Principles for autonomous finance ops; AI catches 15× more out-of-policy spend than non-AI systems with 99% policy enforcement accuracy
- **QuantConnect community** — public discussions of strategy validation emphasize CV-vs-walk-forward concordance as a stationarity test
- **Numerai** — explicit warnings: "It's trivial to overfit a signal on validation"; "treat diagnostics only as a final check"; "models should be stable, with little change week to week"
- **Marcos López de Prado** — *Advances in Financial Machine Learning* (Wiley); Deflated Sharpe Ratio paper

### 4.11 Financial anti-patterns

1. Agents holding production brokerage / multisig keys with unilateral signing power
2. "The model said it was profitable" without OOS verification
3. P-hacked Sharpe ratios (False Strategy Theorem); always report number of trials
4. Silent re-fitting on test data (CPCV embargo)
5. Missing audit trail (EU AI Act + SEC 17a-4 + NYDFS Part 500)
6. Walk-forward as the *only* validation
7. Survivorship-biased universes
8. Unbounded API calls to paid market data
9. **Blind-signing DeFi transactions** — always simulate
10. Single global agent with all permissions — split research / execution / reconciliation
11. Bypassable hooks — PreToolUse is the deterministic control layer; if `--dangerously-skip-permissions` actually skips them, the harness is theater

---

## 5. Mobile Development

**iOS (Xcode 26.3, 2026)** ships native integration with the Claude Agent SDK plus an MCP server exposing ~20 tools (file ops, diagnostics, SwiftUI previews). Outer harness: community-maintained [Sentry XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP) — 82 tools across builds, tests, simulators, LLDB. Returns categorized JSON of errors/warnings/locations rather than dumping a 3000-line `xcodebuild` log; keeps the context window useful.

**Android.** Wrap `./gradlew` and ADB. Google's Android CLI (2026) plus MCPs like `mcp-android-emulator` give structured access to screenshots, UI inspection, touch input, key presses (3× faster task completion, 70% fewer tokens than raw toolchain in internal benchmarks). Gradle sync remains the latency villain — 10–30 seconds — so design caches build state; avoid full re-syncs in inner loops.

**React Native, Expo, Flutter.** Expo bet heavily on agentic in 2026: [Expo Agent (beta, Mar 2026)](https://expo.dev/blog/expo-agent-beta) and [Expo Skills](https://docs.expo.dev/skills/) — structured instruction files for Claude Code, Cursor, Codex. RN+Expo currently has the strongest AI-assisted velocity (massive TS training corpus); Flutter's Dart corpus is thinner.

**The simulator/emulator-in-the-loop pattern** — write screen → boot device → install → screenshot → diff against expected — is now standard. Mobile analog of the web's headless-browser screenshot loop.

**Apple App Store (2026):** Updated Guideline 5.1.2(i) requires explicit disclosure when personal data is shared with third-party AI, and identification of the AI provider by name. Apple briefly blocked vibe-coding apps including Replit; emerging guidance favors **schema-based App Intents** as the legitimate surface for agentic capability.

---

## 6. Game Development

| Engine | Notes |
|---|---|
| **Unity** | Deepest commercial AI tool ecosystem (Bezi, Coplay/Aura) + Rider 2026.1 with Unity perf analysis |
| **Godot** | GDScript's small surface area + text-based scenes → agents write better Godot than Unity C# in head-to-head tests; Godot MCP launches editor, runs projects, captures debug |
| **Unreal** | Editor scripting + MCP for Blueprint scaffolding, batch level ops |
| **Bevy** (Rust ECS) | Surprise hit: data-driven, code-only, maps cleanly onto agent reasoning. `bevy-agent`, BerryCode IDE |

**The defining loop is "hot reload + screenshot."** Agents need to boot the editor, trigger play mode, visually verify. Text logs alone are insufficient for spatial reasoning, animation, shader work.

**Asset-pipeline awareness** — agents must understand `.meta` files, `.uasset` references, import settings or they'll silently break asset GUIDs and source-control diffs.

---

## 7. Embedded / IoT / Firmware

**Highest "irreversible action" surface area in software.** Frameworks now have first-class agent harnesses:

- **ESP-IDF v6.0** — local MCP server: set targets, build, flash, check status
- **Zephyr** — Twister-based HIL CI patterns, Linkable Loadable Extensions for AI workloads
- **[Embedder](https://embedder.com/)** — purpose-built; 400+ MCUs, 2000+ peripherals across STM32, ESP32, nRF52/91, NXP, Infineon, Microchip, RISC-V; closed-loop HIL verification
- **[BootLoop](https://bootloop.ai/)** — Zephyr, VxWorks, ESP-IDF, Yocto, bare metal to Linux; C/C++/Rust

**Hardware-in-the-loop is the discriminating capability.** Self-hosted runner flashes firmware on every push, captures serial logs, pass/fails on real board behavior.

**The "never flash without dry-run" hook.** PreToolUse intercepts any flash command and requires either a `--dry-run` simulation pass or explicit human approval. OTA frameworks like `micropython-ota` and `uota` enforce SHA256 verification and ota_0/ota_1 dual-bank rollback so a bricked firmware is recoverable. Without these, an agent that misreads `idf.py flash` versus `idf.py monitor` can brick a fleet.

---

## 8. Scientific Computing & Research

**Quarto** is the integration substrate. Executes Python, R, Julia, Observable from a single document; renders to LaTeX, HTML, PDF, EPUB, book formats. The natural harness target for "write paper end-to-end" agents.

**Reproducibility stack** — **Snakemake** and **Nextflow** workflow engines integrated with Singularity/Apptainer and Conda. Agents can trigger pipelines and parse failure logs without compromising governance. **Nix** is gaining traction as the declarative substrate for AI-provisioned reproducible research environments.

The harness target here is the **manuscript itself**: agent writes code → executes in pinned env → renders to LaTeX/Typst → opens PR — full pipeline as one tool surface. The Claude Code academic workflow template demonstrates 30 skills, 14 specialized agents, and adversarial QA gates wired into LaTeX/Quarto research.

**Julia** earns its place because reproducible environments (`Project.toml` + `Manifest.toml`) recreate identical environments across platforms — a property agents exploit when running long-horizon experiments. **R** + RMarkdown remains the statistics workhorse; **MATLAB** is grandfathered in by control systems and signals labs.

---

## 9. Security Research (Red & Blue Team)

**The defining harness pattern is the "is this engagement-scoped?" authorization gate.** [RedAmon](https://github.com/samugit83/redamon) implements per-tool human-in-the-loop gates where the agent pauses before any high-impact tool and presents an inline Allow/Deny prompt.

**NIST formally announced the AI Agent Standards Initiative (Feb 17, 2026)** and NCCoE proposed an OAuth 2.0 + SPIFFE/SPIRE + MCP demonstration project for agent identity and authorization.

**CTF harnesses** are now a recognized eval surface — OWASP's GenAI Security Project ships an agentic AI CTF with a simulated financial assistant covering goal manipulation and fraud.

**Defensive blue-team posture.** Wire SAST into the harness directly. [Semgrep guidance](https://semgrep.dev/blog/2026/security-skills-ai-agents/): canonical pattern is PostToolUse hooks running **semgrep + CodeQL + dependency-track** on every Edit/Write before the diff is shown. Microsoft Foundry's AI Red Teaming Agent and Palo Alto's agentic attack-surface analysis represent the industry-vendor side.

---

## 10. Content, Marketing & SEO

**Brand-voice consistency is the central problem.** Claude is widely cited as the strongest at adhering to custom style guides without drift. Effective harnesses encode brand voice as a Skill with explicit forbidden phrases, banned clichés ("game-changer," "leverage synergies"), required tone markers — then run a **brand-voice guard** as PostToolUse validator.

**Plagiarism check hooks** integrate enterprise APIs (Copyleaks, GPTZero, Winston AI) — not the bundled detector — for an independent QA layer.

**Schema.org structured-data verification** as PostToolUse — JSON-LD validated against schema.org and Google's Rich Results spec because AI Overviews, Perplexity, ChatGPT search citations now depend on it.

**The "no AI-detector tells" trap is foolish.** Independent 2026 testing showed Originality.ai at 76% real-world accuracy and GPTZero at 62%, despite vendor 99% claims. The base-rate problem makes this an arms race with no winning side. Build for brand voice + factual claims + originality of argument, not text-statistics laundering.

---

## 11. Customer Support & Ops Automation

The 2026 stack converges on **[Linear's MCP server](https://linear.app/docs/mcp)** as the work-item spine, with native Linear Agent integrations for Intercom, Zendesk, Gong. Intercom shipped **Procedures** in 2026, allowing AI to perform actions in other services (issue refunds, change subscriptions) without human intervention.

**The canonical safety hook is "human in the loop for refunds over $X"** — PreToolUse on the refund tool inspects the amount parameter, auto-approves under threshold, hard-blocks (Slack-DM-an-on-call human) above. Same pattern for subscription changes, account merges, any irreversible CRM mutation.

Notion and Slack MCPs round out the ops surface for documentation and human-escalation channels.

---

# Part IV — Cross-Cutting Concerns

## A. Memory & long-horizon work

Three memory shapes have become standard:

- **Episodic** (what happened)
- **Semantic** (what is known)
- **Procedural** (how things should be done) — where harnesses most distinguish themselves

**File-based memory is the simplest production-viable durable memory.** Cheap, version-controllable, human-auditable, survives every model upgrade.

- **CLAUDE.md** = canonical "always loaded" semantic memory
- **Subdirectory CLAUDE.md** = scoped semantic memory
- **Skills** = procedural memory loaded on demand

The 2026 **Code w/ Claude Dreaming** announcement added an overnight loop reviewing previous sessions and writing new memories (e.g. a `descent-playbook.md`) — agents authoring their own future-context.

**Vector store memory** when corpus is large, conversational, naturally semantic-retrieval-shaped:

- **Mem0** wraps your LLM calls; extracts facts and injects into prompts
- **Letta (formerly MemGPT)** treats memory as agent's editable state via tool calls — agent-native abstraction
- **Zep** uses a temporal knowledge graph tracking how facts change over time — right when facts have provenance and decay

**When each is appropriate:**

- File memory: small teams, code-shaped knowledge, things you grep
- Vector: long conversational histories, customer-specific personalization, KBs too large for context
- Knowledge graph: regulated industries where provenance matters, evolving facts, multi-hop reasoning

The mistake is reaching for the heavy infrastructure first. CLAUDE.md gets you 80% of the way for code-shaped work; measure where it breaks before adopting Letta or Zep.

## B. Multi-agent orchestration

Four canonical topologies — **supervisor-worker**, **swarm**, **blackboard**, **debate**.

The 2026 framework war:

- **LangGraph** won the enterprise — directed-graph model with conditional edges, audit trails, rollback points
- **CrewAI** dominates role-based crews — under 20 lines of Python for a working multi-agent system
- **AutoGen / AG2** owns conversational GroupChat patterns
- **OpenAI Agents SDK** (Mar 2025, replacing Swarm) made the **handoff** the core abstraction — agents transfer control explicitly, carrying conversation context
- **Anthropic's sub-agent model** is the simplest pragmatic version: each subagent has its own context window, tools, model; lead orchestrator fans out; the file system is the coordination substrate

Anthropic's 2026 **Managed Agents** added Dreaming, self-grading outcomes loops, parallel multi-agent orchestration. Rakuten reported feature delivery dropping from 24 days to 5.

**When multi-agent helps:** independent parallelizable tasks (research subtopics, parallel test generation, batch refactors), genuine separation of concerns (planner ≠ executor ≠ critic), and contexts exceeding a single window.

**When it's cargo-culted:** sequential tasks fitting one window, "let's debate every decision" loops that 10× cost without 10× quality, any time the orchestration overhead exceeds the work.

**Anthropic's own guidance:** start with simple composable patterns; reach for multi-agent only when single-agent breaks. ([Building Effective Agents](https://www.anthropic.com/research/building-effective-agents))

## C. Cost & latency engineering

Four economic levers:

| Lever | Discount | Constraint |
|---|---|---|
| **Prompt caching** | ~90% on cached portion | 5-min TTL default (1-hour at higher write cost), 1024-token min, 4 cache breakpoints |
| **Batch API** | 50% | 24-hour completion; multiplicatively stacks with cache (cached batched call ≈ 5% nominal price) |
| **Model routing** | the bigger lever in dollar terms | Haiku 4.5 → Sonnet 4.6 → Opus 4.6 |
| **Cache warming** | situational | Ping cache before known busy windows |

**The 2026 routing pattern** — 70% Haiku (triage, classification, extraction) / 28% Sonnet (workhorse, ~80% of execution) / 2% Opus (graduate-level reasoning, hard agentic coordination, novel problem-solving). Yields 50–80% cost reduction without measurable quality regression for most workloads.

**Harness implication:** schedulers should be cost-aware. Group eligible work into batch windows. Warm caches before known busy periods. Route by complexity rather than defaulting up. Treat every 5-minute idle as a paid-tier mistake.

## D. Safety & guardrails

Pattern stack:

1. **Two-key rule for irreversible actions.** Any tool that deletes data, sends money, deploys to prod, flashes firmware requires two independent approvers (one of which can be the agent's own self-check, the other must be human-in-the-loop or a separate principal). Lifted directly from the nuclear-launch and wire-transfer playbook.
2. **Kill-switch design.** Defined out-of-band procedure to terminate session and prevent further tool calls. **Critical architectural rule:** the policy check must run at the infrastructure layer, not inside agent code — a misbehaving agent can otherwise edit its own kill switch. [KILLSWITCH.md](https://killswitch.md/) proposes a standard format.
3. **Sandbox escape prevention.** The NomShub vulnerability (Cursor) showed the chain: indirect prompt injection in repo content → sandbox escape via shell builtins → persistent shell via remote tunnel. Defense: trust labeling on tool outputs, bounded reasoning with tool allow-lists and step limits, disabling unscoped network egress in agent containers.
4. **Prompt injection defense via tool output and MCP responses.** January 2026 disclosures of three prompt injection vulnerabilities in Anthropic's official Git MCP server underscore the principle: **MCP outputs are untrusted user input** and run through the same injection defenses. Any tool that returns text from network/database/third-party is a potential injection vector.

Lilian Weng's framing — Agent = LLM + memory + planning + tool use — makes the surface explicit: each component needs its own guardrail layer.

## E. Evaluation & continuous improvement

**The 2026 consensus, driven hardest by Hamel Husain and Shreya Shankar: evals are the differentiator** between teams that ship and teams that demo. Their Maven course has trained 2000+ PMs and engineers including teams at OpenAI and Anthropic.

**Practical methodology:**

1. **Look at traces.** Open up actual agent runs end-to-end. Build intuition before metrics.
2. **Label failure modes.** Cluster what went wrong into a small taxonomy.
3. **Build LLM-as-judge with held-out human labels.** Validate the judge against human agreement before trusting it.
4. **Golden traces.** Curate a small canonical dataset of input → expected behavior tuples; re-run on every prompt change.
5. **A/B prompt changes against the golden set.** Don't ship a prompt without seeing the eval delta.

**Eval-driven harness development.** Every harness change (new hook, new skill, new model route) gets evaluated against the golden traces; CI fails on regression. The only known way to keep complex harnesses from drifting into local minima of "feels good in the room" but underperforms in production.

## F. Team & org adoption

**Anthropic Cowork (2026)** introduced **private plugin marketplaces** — admins create internal marketplaces for plugins, connectors, skills; teams publish without routing code through Anthropic's infrastructure.

**Shared CLAUDE.md governance.** CLAUDE.md becomes a load-bearing artifact for organizational tacit knowledge (coding conventions, deploy procedures, post-mortem learnings). Governance questions: who can edit, who reviews changes, how it's audited, how stale rules get removed. Treat CLAUDE.md like a config file with PR review.

**IDE-vs-CLI tradeoffs.** Theo Browne's [T3 Code](https://github.com/t3dotgg) bridges the two — built on top of official CLIs (Claude Code, Codex CLI) with a graphical UX layer for parallel agent management. VS Code itself shipped multi-agent development capabilities in February 2026. **Honest answer:** CLI wins on power, scriptability, parallel orchestration; IDE wins on visual feedback, conversation history, onboarding ramp. Most production teams run both.

**Onboarding new developers.** **Maggie Appleton** has written about agents reshaping software design and the new bottlenecks of orchestration and critical thinking. **Geoffrey Litt** demonstrated a kanban-board agent management workflow where agents turn cards red when blocked — a UX pattern for keeping humans in the loop without staring at terminals.

**The "do not let juniors auto-accept" debate** divides the field:

- **Karpathy's "agentic engineering" camp**: juniors *should* learn by orchestrating agents — that's the new default skill
- **Mollick's jagged-frontier camp + most senior engineers privately**: juniors who auto-accept lose the skill of reading code critically and ship subtle bugs that compound

**Pragmatic middle ground** — juniors run agents in **plan-mode by default**, must read every diff before accepting, paired with senior reviewers for the first 90 days.

---

# Part V — Universal Anti-Patterns and Prescriptive Defaults

## V.1 Universal anti-patterns

These cross every domain. If your harness allows them, your harness is theater.

1. **Documentation-as-enforcement.** Telling Claude "don't" without a hook is a suggestion. Hooks are the contract.
2. **Hooks bypassable by `--dangerously-skip-permissions`.** PreToolUse exit-code 2 still fires under skip-permissions; that's the design. Use it.
3. **Long-lived credentials in agent env.** OIDC + STS, ≤15-min sessions. Refuse to start if static creds present.
4. **Agent and user sharing the same identity.** Defeats attribution, inflates blast radius.
5. **No audit trail.** Append-only, hash-chained, retention matched to the regulatory regime (7 years for finance, 6 months minimum for any high-risk system per NIST AI RMF 1.1 / ISO 42001).
6. **Same model family for generation and judging.** 10–25% self-preference bias — invalidates the eval.
7. **CLAUDE.md > 200 lines.** Compliance falls off a cliff.
8. **Skill > 12 in active rotation.** Marginal value drops; context tax rises.
9. **Sub-agents inheriting parent credentials.** Each sub-agent requests its own scoped credentials.
10. **Agents spawning agents without inherited spawn budget.** Recursion guard.
11. **Compaction-dependent safety rules.** Critical rules belong in CLAUDE.md (system prompt), never in conversation history that may be compacted.
12. **Reactive retry loops without circuit breakers.** 90%+ of retries are wasted on tool-name mismatches that will never succeed.
13. **Trusting MCP/tool output as safe text.** Treat as untrusted user input; run through the same prompt-injection defenses.
14. **Letting one agent run unbounded against a production-touching system without a human-gated PR step.**
15. **Reinventing Claude Code primitives in a custom shell.** Models perform best in the harness they were trained against.

## V.2 Prescriptive defaults — what every harness template should ship with

A new repository template, regardless of domain, should ship:

- **CLAUDE.md** ≤60 lines: commands, conventions, never-do list, pointers to skills, a *one-line* "stack lockdown" preventing wrong-paradigm regressions (e.g. "App Router only, never Pages Router"; "Vue 3 Composition not Options"; "Svelte 5 runes not legacy reactive").
- **AGENTS.md** mirror or symlink for cross-tool portability.
- **`.claude/skills/`** with 8–12 focused, gerund-named skills.
- **`.mcp.json`** referencing **only official, signed MCP servers** for production-touching tools. No community servers in production-touching agents without provenance review.
- **`.claude/hooks/`** with the deterministic gates the domain demands. Universal minimum:
  - PreToolUse secret-scanner on `Write|Edit`
  - PreToolUse command guard on `Bash`
  - PostToolUse lint + type-check on `Write|Edit`
  - Stop hook running tests + build before "completion"
  - PostToolUse audit-log appender to an append-only sink
- **TDD enforcement** — TDD-Guard or the Superpowers plugin so red-green-refactor is mechanical, not aspirational.
- **Worktree isolation** for any non-trivial feature work. Subagent triad (e.g. frontend / backend / review) with `isolation: worktree`.
- **A documented two-key flow** for any tool resolved to a `prod`/`nuclear` blast-radius tag.
- **Sandbox declaration** — Anthropic `sandbox-runtime` or container — pinning filesystem writes to working directory and restricting network egress to an allow-list.
- **Verification budgets** as code — `lighthouse-budget.json`, `axe-config.js`, `eval/golden.jsonl` — so the loop has objective pass/fail criteria, not vibes.

---

# Part VI — Curated Reading List

The highest-leverage primary sources to internalize, in approximate order.

## Anthropic engineering and docs (read first)

- [Building agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Writing effective tools for AI agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Claude Code: making it more secure and autonomous (sandboxing)](https://www.anthropic.com/engineering/claude-code-sandboxing)
- [Building Effective AI Agents](https://www.anthropic.com/research/building-effective-agents)
- [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- Claude Code docs — [hooks](https://code.claude.com/docs/en/hooks), [sub-agents](https://code.claude.com/docs/en/sub-agents), [memory](https://code.claude.com/docs/en/memory), [permissions](https://code.claude.com/docs/en/permissions), [skills](https://code.claude.com/docs/en/skills), [worktrees](https://code.claude.com/docs/en/worktrees), [plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

## Practitioner canon

- Birgitta Böckeler — [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html)
- Dexter Horthy — [12-Factor Agents](https://github.com/humanlayer/12-factor-agents)
- Hamel Husain — [LLM Evals: Everything You Need to Know](https://hamel.dev/blog/posts/evals-faq/), [Field Guide](https://hamel.dev/blog/posts/field-guide/), [Your AI Product Needs Evals](https://hamel.dev/blog/posts/evals/), [LLM-as-Judge guide](https://hamel.dev/blog/posts/llm-judge/)
- Shreya Shankar — [sh-reya.com](https://www.sh-reya.com/), the [Maven AI Evals course](https://maven.com/parlance-labs/evals)
- Eugene Yan — [Patterns for Building LLM-based Systems & Products](https://eugeneyan.com/writing/llm-patterns/), [Matching LLM Patterns to Problems](https://eugeneyan.com/writing/llm-problems/)
- Chip Huyen — *AI Engineering* (O'Reilly, 2025), [Building LLM Apps for Production](https://huyenchip.com/2023/04/11/llm-engineering.html)
- Lilian Weng — [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/)
- Jason Liu — [Instructor](https://python.useinstructor.com/), [Rethinking RAG architecture for the age of agents](https://jxnl.co/writing/2025/09/11/rethinking-rag-architecture-for-the-age-of-agents/)
- Simon Willison — [How coding agents work](https://simonwillison.net/guides/agentic-engineering-patterns/how-coding-agents-work/), [Claude Code for web](https://simonwillison.net/2025/Oct/20/claude-code-for-web/), [Claude Skills](https://simonwillison.net/2025/Oct/10/claude-skills/)
- Lance Martin — [Context Engineering for Agents](https://rlancemartin.github.io/2025/06/23/context_engineering/), [Learning the Bitter Lesson](https://rlancemartin.github.io/2025/07/30/bitter_lesson/)
- Andrej Karpathy — [2025 LLM Year in Review](https://karpathy.bearblog.dev/year-in-review-2025/)
- O'Reilly — [What We've Learned From a Year of Building with LLMs](https://www.oreilly.com/library/view/what-we-learned/9781098176716/) (Husain, Shankar, Yan, Bischof, Frye, Liu)
- Maggie Appleton — [garden](https://maggieappleton.com/garden/)
- Geoffrey Litt — [Malleable software in the age of LLMs](https://www.geoffreylitt.com/2023/03/25/llm-end-user-programming.html)

## Academic / benchmarks

- Yang et al. — [SWE-agent: Agent-Computer Interfaces](https://arxiv.org/abs/2405.15793) (NeurIPS 2024)
- METR — [RE-Bench evaluation report](https://metr.org/AI_R_D_Evaluation_Report.pdf), [Time Horizon 1.1](https://metr.org/blog/2026-1-29-time-horizon-1-1/)
- Stanford / Berkeley / Samaya AI — [Lost in the Middle](https://arxiv.org/abs/2307.03172)
- Chroma — [Context Rot: How Increasing Input Tokens Impacts LLM Performance](https://www.trychroma.com/research/context-rot)
- arXiv — [Vibe Coding vs Agentic Coding](https://arxiv.org/html/2505.19443v1)
- arXiv — [Standardized Benchmark of Look-ahead Bias in Point-in-Time data](https://arxiv.org/pdf/2601.13770)

## Standards & ecosystem

- [agents.md](https://agents.md), [agentskills.io](https://agentskills.io)
- [Linux Foundation — Agentic AI Foundation announcement](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation)
- OWASP — [AI Agent Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/AI_Agent_Security_Cheat_Sheet.html)
- [KILLSWITCH.md](https://killswitch.md/)

## Reference open-source harnesses

- [`obra/superpowers`](https://claude.com/plugins/superpowers) — structured workflow plugin
- [`evanklem/evanflow`](https://github.com/evanklem/evanflow) — 16 skills + 2 subagents implementing TDD-driven feedback
- [`nizos/tdd-guard`](https://github.com/nizos/tdd-guard) — hooks blocking skip-test patterns
- [`anthropics/skills`](https://github.com/anthropics/skills) — source of truth for skills
- [`anthropics/financial-services`](https://github.com/anthropics/financial-services) — reference financial agent suite
- [`huggingface/skills`](https://github.com/huggingface/skills), [`huggingface/upskill`](https://github.com/huggingface/upskill)
- [`marimo-team/skills`](https://github.com/marimo-team/skills)
- [`pulumi/agent-skills`](https://github.com/pulumi/agent-skills)
- [`microsoft/azure-skills`](https://github.com/microsoft/azure-skills)
- [`mafiaguy/claude-security-guardrails`](https://github.com/mafiaguy/claude-security-guardrails)
- [`VoltAgent/awesome-agent-skills`](https://github.com/VoltAgent/awesome-agent-skills)
- [`Matt-Dionis/claude-code-configs`](https://github.com/Matt-Dionis/claude-code-configs)
- [`affaan-m/everything-claude-code`](https://github.com/affaan-m/everything-claude-code)

---

*This document is a synthesis intended as the foundation for a template library. Each domain section should evolve into an actual ready-to-clone template directory under this repository — `templates/web/`, `templates/data/`, `templates/devops/`, `templates/finance/`, etc. — each instantiating the prescriptive defaults of its section with concrete `CLAUDE.md`, `.claude/skills/`, `.claude/hooks/`, and `.mcp.json` files. The harness, not the agent, is the contract.*

---

## See also (within this repo)

- [`docs/README.md`](README.md) — full documentation index organised by Diátaxis quadrant.
- [`docs/tutorials/getting-started.md`](tutorials/getting-started.md) — first-time walk-through.
- [`docs/reference/domains.md`](reference/domains.md) — catalog of every domain recipe with status.
- [`docs/explanation/why-harness.md`](explanation/why-harness.md) — the *agent = model + harness* premise condensed.
- [`docs/METHODOLOGIES.md`](METHODOLOGIES.md) and [`docs/AGENT_ROLES.md`](AGENT_ROLES.md) — companion deep references.
