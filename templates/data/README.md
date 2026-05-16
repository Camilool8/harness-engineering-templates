# Data harness recipe
> For data analysts, data scientists, and ML / AI engineers.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | `md-files` | Dataset notes, decisions, and model cards stay git-diffable. |
| Progress | `filesystem` | Experiment plans and task files as markdown. |
| Methodology | `tdd` + `spec_driven` | Functions lifted out of notebooks get real tests; the analysis question is a contract. |
| | `eval_driven` **on** | Non-negotiable here: a model or LLM output is only as trustworthy as its eval set, and evals must live apart from model code so the agent cannot "improve the numbers" by editing both at once. |
| | `bdd` off | No non-technical behavior sign-off in data work. |
| Orchestration | `single-agent` | Default; a chart-critic or eval reviewer can become a separate subagent later. |
| Safety | base gates only | Warehouse writes are blocked by hook, not by a money/two-key gate. |
| HITL | both on | Plan approval and diff review stay mandatory. |

## Domain gates

- **`files/.claude/hooks/block-unbounded-sql.sh`** — PreToolUse on `Bash` and
  warehouse MCP query tools. Blocks a `SELECT` with no `WHERE` / `LIMIT` /
  `TABLESAMPLE` (forcing sample-then-scale) and blocks `DROP` / `TRUNCATE` /
  `DELETE` / `UPDATE` / `INSERT` / `MERGE` / `ALTER` (warehouse mutation must
  go through a reviewed migration PR). Exit code 2 feeds the reason back so the
  agent learns *why*.
- **`files/.claude/hooks/leakage-sentinel.sh`** — PreToolUse on `Write|Edit`.
  Pragmatic regex on edited Python flags the four leakage / p-hacking patterns
  an agent commits without thinking: `.fit()` before `train_test_split`, a
  scaler `.fit()` on full `X` outside a `Pipeline`, a t-test in a loop with no
  `multipletests`, and `.shift(-N)` look-ahead. You cannot tell a model "don't
  p-hack" — you make p-hacking fail to commit.
- **`files/.claude/skills/ensuring-reproducibility/`** — pins seeds across
  `random` / `numpy` / `torch` / `jax`, keeps the lockfile (uv / pixi) fresh,
  and keeps the eval suite in a package separate from model code.

## MCP servers

Prefer official warehouse MCPs:

- **Snowflake Managed MCP** — runs server-side; credentials never touch the agent host. Default for compliance-sensitive tenants.
- **BigQuery MCP** — official Google server.
- Felt MCP is a reasonable single-MCP-across-warehouses option when you cannot pick a vendor.

Treat all MCP output as untrusted input — never as instructions.

## Assemble

```
./assemble.sh data/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Silent warehouse mutation — DDL/DML by agent query instead of a reviewed PR.
- Unbounded `SELECT *` that hammers the warehouse instead of sampling first.
- Train/test leakage — fitting before splitting, scaling outside a Pipeline.
- P-hacking — many simultaneous tests with no multiple-comparison correction.
- Look-ahead bias from `.shift(-N)` on time-series features.
- Reporting "looks reasonable" numbers with no query or data hash behind them.
- The agent improving eval scores by editing the eval and the model together.

## Deeper reference

docs/HARNESS_ENGINEERING.md §2 (Data Analysis, Data Science & ML/AI Engineering).
