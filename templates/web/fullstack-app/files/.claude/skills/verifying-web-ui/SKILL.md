---
name: verifying-web-ui
description: Verifies UI changes in a fullstack application via the accessibility tree, not screenshots. Use after editing any Server Component, Client Component, or page — capture the Playwright a11y snapshot, run axe-core for WCAG, check the Lighthouse budget, then verify the Server Action round-trip.
---

# Verifying fullstack-app UI

A fullstack app has two layers to verify: the UI (a11y, performance) and the
server round-trip (Server Action response, redirect, data reload). Both must
pass before a feature is done.

## The loop

Run this after every UI-affecting edit (dev server already running):

1. **Snapshot the accessibility tree.** Use the Playwright MCP page snapshot
   on the changed route. Confirm the element exists with the correct role and
   accessible name. Use `toMatchAriaSnapshot()` to catch regressions.
2. **Run axe-core for WCAG.** Drive `@axe-core/playwright` against the route.
   Zero violations is the bar. A violation is a blocker, not a note.
3. **Check the Lighthouse budget.** Run Lighthouse on the route and compare
   LCP / INP / CLS and category scores against `lighthouse-budget.json`.
   A regression past budget is a failure.
4. **Verify the Server Action round-trip.** Submit the form or trigger the
   action, confirm the redirect or response is correct, and reload the page
   to confirm the data change persisted.
5. **Screenshot only on a flagged visual diff.** If a step above flags
   something visual, capture a screenshot for the human record. Never
   screenshot as the primary verification step.

## Rules for fullstack apps

- Server Components render on the server — verify the rendered HTML via the
  a11y tree, not by inspecting client-side state.
- After a Server Action mutation, always reload the affected route and confirm
  the data change is reflected. A successful 200 from the action is not the
  same as a correctly persisted mutation.
- Check that loading states (Suspense boundaries) are visible for a meaningful
  duration when data is slow — artificially slow the dev server if needed.
- Do not mark a route "done" without naming the axe-core result and the
  Lighthouse scores you observed.
