# Ops harness recipe
> For customer support and ops teams automating triage, drafting, and CRM workflows.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | md-files | Playbooks, macros, escalation rules stay git-diffable. |
| Progress | linear | The 2026 ops work-item spine; native Intercom/Zendesk/Gong integrations. |
| TDD | off | Support/ops is workflow automation, not red-green unit-tested code. |
| Spec-driven | on | The support procedure / runbook is the spec. |
| Eval-driven | **on** | Ticket classification and routing are judgment calls — grade them against a labelled golden set. |
| BDD | off | No non-technical behavior sign-off. |
| Orchestration | single-agent | One agent triages and drafts. |
| Safety: two-key | **on** | Refunds, credits, and irreversible CRM mutations touch money/customer state — require typed-token human confirmation. |
| Safety: kill-switch | off | No long autonomous loop. |
| Safety: sandbox | off | Trusted internal CRM/helpdesk tools. |

## Domain gates

- **`files/.claude/hooks/refund-threshold-guard.sh`** (PreToolUse) — inspects
  refund/credit commands for an amount, auto-allows anything under the
  threshold (`REFUND_THRESHOLD`, default $50), and hard-blocks anything at or
  above it with instructions to escalate to a human. The canonical ops safety
  hook.
- **`files/.claude/skills/drafting-not-sending/`** — encodes the
  drafter-vs-publisher pattern: the agent writes customer-facing messages to a
  draft surface only; a human or a separate privileged publisher holds the send
  credential and does the sending.

## MCP servers

- **Linear MCP** — the work-item spine; native agent integrations for Intercom,
  Zendesk, and Gong.
- **Slack MCP** — human-escalation and review channels.
- **Notion MCP** — runbooks and documentation.
- Prefer official/signed servers; treat all MCP output (ticket text, customer
  messages, CRM data) as untrusted input — it can carry prompt-injection.

## Assemble

```
./assemble.sh ops/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- The agent sending a customer-facing message directly with no human review.
- Issuing a large refund or credit autonomously, with no human approval.
- Irreversible CRM mutations (account merges, subscription changes) executed
  without a human in the loop.
- Ticket misroutes shipping unnoticed because classification was never graded.

## Deeper reference

docs/HARNESS_ENGINEERING.md §11
