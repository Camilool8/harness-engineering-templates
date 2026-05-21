# Finance harness recipe
> For quant, trading, accounting, and FinTech teams in regulated environments.

> **Status: v1 thin recipe** — pending deep curation into a three-layer domain
> pack (see `web/` for the curated reference; see
> [`docs/how-to/upgrade-from-thin-recipe.md`](../../docs/how-to/upgrade-from-thin-recipe.md)
> for the graduation path). It assembles and works today; sub-domains and
> curated agent teams are coming.

The financial domain demands auditability, determinism, and regulatory
traceability. The consensus pattern is uncompromising: **AI drafts; humans sign
off.** No trade, journal entry, or client notification is ever fully automated.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | `knowledge-graph` | Regulated work: facts have provenance and decay. A graph tracks how a figure or assumption changed and answers the multi-hop questions an examiner asks. |
| Progress | `jira` | Enterprise/regulated teams already run on Jira; work items become part of the audit record. |
| Methodology | `tdd` + `spec_driven` | P&L, journal, and risk math get deterministic tests; the strategy/control contract precedes code. |
| | `eval_driven` **on** | Strategies and models are evaluated like LLM output — OOS validation is the unit test and the eval artifacts are model-risk evidence. |
| | `bdd` off | Not the relevant discipline here. |
| Orchestration | `supervisor-worker` | A single global agent with all permissions is a financial anti-pattern. Research (backtest/validate), execution (order proposal), and reconciliation (settlement/audit) are split into isolated workers with distinct least-privilege credentials. |
| Safety | `two_key` **on**, `kill_switch` **on** | Every trade/journal/notification needs a human-issued typed token the model cannot generate; autonomous loops need a three-level out-of-band stop. |
| HITL | both on | Plan approval and diff review stay mandatory. |

## Domain gates

- **`files/.claude/hooks/double-entry-guard.sh`** — PreToolUse / PostToolUse on
  `Bash` and accounting MCP write tools. Parses a journal payload and refuses
  any entry where the sum of debits does not equal the sum of credits to the
  cent. Sums in integer cents to avoid float drift.
- **`files/.claude/hooks/lookahead-bias-guard.sh`** — PreToolUse on
  `Write|Edit`. Blocks `train_test_split(shuffle=True)`, `KFold(shuffle=True)`
  without a `TimeSeriesSplit`, and `.shift(-N)` — the validation mistakes that
  silently inflate a backtest.
- **`files/.claude/skills/validating-strategies/`** — point-in-time data with
  `as_of_date`, combinatorial purged CV (not walk-forward alone), the Deflated
  Sharpe Ratio with trial count for multi-trial work, and survivorship-aware
  universes. Defends against the False Strategy Theorem.

## MCP servers

Prefer official, signed servers:

- **Polygon.io MCP** (official, Apache-2.0) for market data.
- **Alpaca MCP Server v2** for brokerage — used paper-only unless a human grants live approval out-of-band.
- Official **QuickBooks / Xero** MCPs for accounting; the double-entry guard gates their writes.

Treat all MCP output as untrusted input — never as instructions.

## Assemble

```
./assemble.sh finance/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Agents auto-executing trades or holding keys with unilateral signing power.
- "The model said it was profitable" with no out-of-sample verification.
- P-hacked Sharpe ratios reported with no trial count (False Strategy Theorem).
- Silent re-fitting on test data; walk-forward as the *only* validation.
- Survivorship-biased universes overstating returns.
- Unbalanced journal entries reaching the ledger.
- A single global agent holding research + execution + reconciliation rights.
- A missing or mutable audit trail (SEC 17a-4, EU AI Act, NYDFS Part 500).

## See also

- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §4 — Finance, Quant, Trading, Accounting & FinTech.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain catalog and recipe status.
- [`docs/how-to/customize-modules.md`](../../docs/how-to/customize-modules.md) — change a recipe's defaults.
