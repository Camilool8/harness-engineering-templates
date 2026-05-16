# Module: methodology/tdd

> Config: `methodology.tdd` · Depends on: none

**What it does.** Mechanically enforces red-green-refactor: a `PreToolUse` hook
blocks edits to implementation files unless a failing test was observed first,
and a skill teaches the agent the cycle. Tests become an integrity surface the
agent cannot quietly weaken.

## Adopt if
- You write deterministic code — pure functions, business logic, data transforms,
  any I/O with a knowable correct output.
- You have a test runner and want the agent to ship code a human will merge.
- You are in a regulated codebase where regression cost is high. **Default on.**

## Skip if
- The output is judgmental (LLM/ML generation, RAG, classification) — a passing
  unit test does not prove quality. Use `methodology/eval_driven` instead (the
  two compose: TDD for deterministic glue, evals for the model surface).
- The work is a throwaway spike or demo where being wrong is cheap.
- You have no test runner and no intent to add one.

## Dependencies
- `jq` (parses the hook's stdin event).
- A test runner reachable from the shell (`pytest`, `npm test`, `go test`, …).
- Optional, recommended for production: [`nizos/tdd-guard`](https://github.com/nizos/tdd-guard)
  — a far stronger `PreToolUse` guard that parses real test-runner output and
  also blocks over-implementation and multi-test-at-once. The bundled
  `tdd-guard.sh` is a pragmatic, zero-dependency stand-in.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. `chmod +x .claude/hooks/tdd-guard.sh`.
4. Register the hook in `.claude/settings.json` under `hooks.PreToolUse` for
   matcher `Write|Edit` (see the snippet in **Files** below).

## Install (assemble.sh)
Set `methodology.tdd: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `.claude/hooks/tdd-guard.sh` and `.claude/skills/practicing-tdd/`.
- Delete the marker file `.claude/.tdd-last-fail` if present.
- Remove the `tdd-guard.sh` entry from `.claude/settings.json` `hooks.PreToolUse`.
- Remove the `## Test-Driven Development` section from `CLAUDE.md`.

## Files
- `files/.claude/hooks/tdd-guard.sh` — `PreToolUse` hook on `Write|Edit`. Allows
  edits to test files freely; for non-test files, requires a fresh
  `.claude/.tdd-last-fail` marker (written when a failing test was observed) and
  exits 2 to block otherwise.
- `files/.claude/skills/practicing-tdd/SKILL.md` — the red-green-refactor cycle
  and how to record the failing-test marker.
- `files/.claude/settings.fragment.json` — settings fragment registering the hook.
  `assemble.sh` deep-merges it into `.claude/settings.json`; for a manual install,
  merge its `hooks.PreToolUse` entry by hand.
