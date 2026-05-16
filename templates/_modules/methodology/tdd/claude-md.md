## Test-Driven Development

Deterministic code is built red-green-refactor. The `tdd-guard.sh` hook enforces
this — it blocks edits to implementation files unless a failing test was just
observed.

- **Red.** Write one failing test that captures the next slice of behavior. Run
  it and confirm it fails for the expected reason.
- **Record the failure.** After observing a real test failure, write the marker:
  `echo "$(date +%s)" > .claude/.tdd-last-fail`. This unlocks implementation
  edits. The marker is consumed (deleted) on the next implementation edit.
- **Green.** Write the *minimum* code to make the test pass. Nothing more.
- **Refactor.** Improve structure with the suite green; behavior must not change.
- **Tests are an integrity surface — never weaken a test to make it pass.**
  Do not delete, skip, loosen an assertion, or mock the system under test to get
  green. If a test is wrong, fix it deliberately as its own red step and say so.
- Test files (`*test*`, `*spec*`, `tests/`, `__tests__/`) may be edited freely.

See the `practicing-tdd` skill for the full cycle.
