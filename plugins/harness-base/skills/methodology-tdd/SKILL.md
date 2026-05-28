---
name: practicing-tdd
description: Drives deterministic code red-green-refactor. Use before writing or changing any implementation file — write a failing test first, watch it fail, write minimal code to pass, then refactor. Arm the blocking gate with tdd = true in .claude/HARNESS.toml.
---

# Practicing TDD

To arm the gate, add this to `.claude/HARNESS.toml` (create the file if needed):

```toml
[harness]
tdd = true
```

While armed, the `tdd-guard.sh` hook blocks edits to implementation files until
you have observed a real failing test. Work the cycle; the gate is on your side.
(Without the flag the hook is inert and the discipline below is still the right
way to work.)

## The cycle

### 1. Red — write one failing test
Write a single test for the *next* slice of behavior. One behavior, one test.
Test files are never blocked by the hook, so write freely here.

### 2. Watch it fail
Run the test. Confirm it fails, and that it fails for the *expected* reason
(assertion failure — not an import error or a typo). A test that fails for the
wrong reason proves nothing.

### 3. Record the failure
Once you have seen a genuine failure, write the marker:

```bash
echo "$(date +%s)" > .claude/.tdd-last-fail
```

This unlocks exactly one implementation edit. The hook deletes the marker once
that edit is allowed, so each observed failure buys one green step.

### 4. Green — minimum code to pass
Write the *least* code that makes the test pass. Do not add unrequested
behavior, error handling, or abstraction — that belongs to a future red step.
Run the test; confirm green.

### 5. Refactor
With the suite green, improve names, structure, and duplication. Behavior must
not change. Re-run the suite after refactoring.

Repeat from step 1 for the next slice.

## Integrity rules — non-negotiable

- **Never weaken a test to reach green.** Do not delete it, skip it, mark it
  xfail, loosen an assertion, or widen a tolerance to make failing code pass.
- **Never mock the system under test.** Mock collaborators at boundaries only;
  critical paths need real integration tests.
- If a test itself is genuinely wrong, fixing it is its own red step: change the
  test, watch the new expectation fail against current code, record the marker,
  and state explicitly that you are correcting a faulty test.
- Do not write the test and the implementation in one unbroken motion — the
  failure observation in step 2 is the checkpoint that keeps them honest.
