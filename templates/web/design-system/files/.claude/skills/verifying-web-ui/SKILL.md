---
name: verifying-web-ui
description: Verifies UI changes via the accessibility tree and Storybook interaction tests, not screenshots. Use after editing any component, story, or token — run axe-core via the a11y addon, check interaction tests pass, then trigger visual-regression-tester for snapshot diffs.
---

# Verifying design-system components

A component library has two verification layers: **functional correctness**
(interaction tests, a11y) and **visual correctness** (snapshot diffs). Each
layer uses a different tool. Do not conflate them.

## The loop

Run this after every component or story edit:

1. **Run interaction tests.** Execute `storybook test` (or `npm run storybook:test`).
   The `play()` functions in your stories must all pass. A failing interaction
   test is a blocker — it means the component does not behave as specified.
2. **Run axe-core via the a11y addon.** The `@storybook/addon-a11y` panel in
   Storybook reports WCAG violations for each story. Zero violations is the bar.
   If running headless in CI, use `storybook test --coverage` — the a11y addon
   output is included in the test results.
3. **Assert the a11y tree snapshot.** For interactive components, use
   `locator.ariaSnapshot()` in a Playwright test to assert the component's
   accessibility tree matches the expected shape. This catches role, name, and
   state regressions that pixel diffs miss.
4. **Trigger visual-regression-tester.** Invoke the `visual-regression-tester`
   agent to diff the Storybook snapshot baseline. It will classify each diff as
   intentional or a regression and block on regressions.
5. **Screenshot only on a flagged regression.** If the visual-regression-tester
   flags a regression, capture a screenshot of the affected story for the human
   record. Screenshots are the exception, not the verification step.

## Rules

- `storybook test` passing is required before any component version ships.
- axe-core zero violations is required — a WCAG issue in the library propagates
  to every consumer. Fix it in the library, not in each consuming app.
- Visual snapshot diffs must be reviewed intentionally. Never bulk-accept without
  inspecting each changed story.
- Do not mark a component change complete without naming which stories were
  verified and what the axe-core result was.
