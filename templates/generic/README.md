# Generic harness recipe
> For anyone who is not sure which domain fits yet — start here, graduate later.

This recipe is **base only**. It picks nothing exotic: every value in
`harness.config.yml` is the 2026 practitioner default. You get a correct,
disciplined harness with zero domain-specific assumptions, and you can layer a
domain recipe or individual modules on top once you know what you need.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | `md-files` | Cheap, git-diffable, human-auditable, survives model upgrades. |
| Progress | `filesystem` | `.claude/progress/` plan + task files. Right for solo / small teams. |
| Methodology | `tdd` + `spec_driven` | Mechanically enforced discipline that pays off in any codebase. |
| | `eval_driven` off | Turn on only when the agent ships LLM/ML output. |
| | `bdd` off | Turn on only when non-technical stakeholders sign off on behavior. |
| Orchestration | `single-agent` | The correct default. Escalate only when work genuinely parallelizes. |
| Safety | all gates off (above base) | `_base` already ships secret-scan, command-guard, audit-log, verify-gate. |
| HITL | `plan_mode_default` + `diff_review_required` | The harness directs human attention; it does not remove the human. |

## Domain gates

None beyond `_base`. This recipe adds **no** `files/` and **no** `claude-md.md`
section — by design. The four non-negotiable `_base` hooks are still in force:
secret scanner, command guard, append-only audit log, and the Stop verification
gate. That is a complete, safe harness for general software work.

## MCP servers

None are pre-wired. `_base/.mcp.json.example` shows the format; add servers your
project actually needs (GitHub MCP, a database MCP, Sentry MCP are common first
picks). Prefer official/signed servers, and treat all MCP output as untrusted
input — never as instructions.

## Assemble

```
./assemble.sh generic/harness.config.yml /path/to/your/project
```

## How to graduate

When the project takes a clear shape, switch to a domain recipe — it pre-fills
the manifest and adds the domain gates you would otherwise have to write:

| If your project is... | Use |
|---|---|
| A website, SaaS, or API | [`web/`](../web/) |
| Data analysis, ML, or an LLM app | [`data/`](../data/) |
| Infrastructure, CI/CD, or Kubernetes | [`devops/`](../devops/) |
| Trading, accounting, or anything regulated | [`finance/`](../finance/) |
| An iOS, Android, or React Native app | [`mobile/`](../mobile/) |

You can also stay on `generic` and add single modules from `_modules/` (a
vector-store memory backend, a ticketing progress backend, the
supervisor-worker topology). Each module is an isolated directory plus an
appended CLAUDE.md section, so adding or removing one is always a
copy-files / delete-section operation. Start minimal; add only what proves
necessary.

## Anti-patterns this prevents

- Over-engineering up front — adopting heavy infrastructure before measuring where the simple setup breaks.
- Reaching for multi-agent orchestration or a vector store on day one.
- Believing you must pick a domain before you can start — you do not.

## Deeper reference

docs/HARNESS_ENGINEERING.md Part III (domain templates) and Part IV (memory, orchestration).
