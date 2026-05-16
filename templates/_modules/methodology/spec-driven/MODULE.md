# Module: methodology/spec-driven

> Config: `methodology.spec_driven` · Depends on: none

**What it does.** Externalizes ambiguity into a written contract before code is
touched. Non-trivial work starts with a spec in `specs/`; a skill teaches how to
write one, and a template enforces a consistent shape — problem, acceptance
criteria, out-of-scope, verification.

## Adopt if
- Work spans multiple files, crosses a service boundary, or touches non-trivial
  UX — anything a junior would need a design doc for.
- The requirement arrives vague (a Slack thread, a one-line ticket) and you want
  the agent constrained against drift. **Default on.**
- You want a reviewable, git-diffable record of *what* was agreed before *how*.

## Skip if
- The change "fits in one sentence" — a typo, a copy tweak, a config bump.
  Spec overhead would exceed the work.
- You are in a pure exploratory spike where the goal is to discover the
  requirement, not satisfy one (write the spec *after*, from what you learned).

## Dependencies
- None. Plain markdown plus Plan Mode (a built-in Claude Code primitive).
- Composes well with `progress/*` ticketing modules — pull acceptance criteria
  from the ticket into the spec.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Commit `specs/` so specs travel and version with the repo.

## Install (assemble.sh)
Set `methodology.spec_driven: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `specs/` and `.claude/skills/writing-specs/`.
- Remove the `## Spec-Driven Development` section from `CLAUDE.md`.

## Files
- `files/specs/TEMPLATE.md` — the spec contract template: problem, acceptance
  criteria, out-of-scope, verification. Copy it per feature.
- `files/.claude/skills/writing-specs/SKILL.md` — how to turn a vague request
  into a precise, testable spec.
