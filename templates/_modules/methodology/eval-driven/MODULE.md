# Module: methodology/eval-driven

> Config: `methodology.eval_driven` · Depends on: none

**What it does.** Treats evals as the unit test for LLM/ML outputs. Ships a
golden dataset, a runbook encoding Hamel Husain's three eval tiers, a skill, and
a `Stop` hook that runs a fast eval subset before "done" is allowed.

## Adopt if
- The agent (or your product) produces judgmental output — generation, RAG,
  classification, summarization, agent trajectories — where correctness is not
  a single deterministic value.
- You are changing a prompt, model, retrieval config, or tool surface and need
  to know whether the change improved or regressed behavior.
- You want to escape "vibe coding without evals" — the cardinal 2025 anti-pattern.

## Skip if
- The code is purely deterministic — `methodology/tdd` already covers it. A
  passing eval would just be a slower unit test.
- There is no LLM/ML output anywhere in the work.
- (The two compose: use `tdd` for deterministic glue, `eval_driven` for the
  model surface — they are not alternatives.)

## Dependencies
- `jq` (parses the hook's stdin event).
- An `evals/run.sh` you provide — runs your eval harness. It MUST accept a
  `--fast` flag (or honor `EVAL_FAST=1`) to run a quick subset for the Stop hook;
  the hook no-ops gracefully if `evals/run.sh` is absent.
- For model-graded evals: API access to a judge model from a **different model
  family** than the generator (see RUNBOOK — this is a hard constraint).
- Optional MCP: Braintrust / LangSmith for hosted eval tracking.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. `chmod +x .claude/hooks/eval-gate.sh`.
4. Write `evals/run.sh` for your stack (the runbook describes the contract).
5. Register the hook in `.claude/settings.json` under `hooks.Stop`.

## Install (assemble.sh)
Set `methodology.eval_driven: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `evals/` and `.claude/hooks/eval-gate.sh` and
  `.claude/skills/running-evals/`.
- Remove the `eval-gate.sh` entry from `.claude/settings.json` `hooks.Stop`.
- Remove the `## Eval-Driven Development` section from `CLAUDE.md`.

## Files
- `files/evals/golden.jsonl` — golden dataset: one input→expected row per line,
  with a header comment. Grow it from observed failures, not from imagination.
- `files/evals/RUNBOOK.md` — how to run, read, and extend evals; encodes the
  three eval tiers and the different-family judge constraint.
- `files/.claude/hooks/eval-gate.sh` — `Stop` hook. If `evals/run.sh` exists,
  runs the fast eval subset; exits 2 to block "done" if it fails.
- `files/.claude/skills/running-evals/SKILL.md` — error-analysis-first workflow
  for building and iterating evals.
- `files/.claude/settings.fragment.json` — settings fragment registering the Stop
  hook. `assemble.sh` deep-merges it into `.claude/settings.json`; for a manual
  install, merge its `hooks.Stop` entry by hand.
