---
name: verifying-web-ui
description: Verifies UI changes via the accessibility tree, not screenshots. Use after editing any component, page, or style — fetch the Playwright a11y snapshot, run axe-core for WCAG, check the Lighthouse budget, and only screenshot on a flagged visual diff.
---

# Verifying web UI

An LLM is blind to pixels but fluent in structure. Screenshots are expensive and
lossy; the **accessibility tree** is what a screen reader sees — token-cheap,
structured, and the right primitive for an agent. Verify with the tree first.

## The loop

Run this after every UI-affecting edit (dev server already running):

1. **Snapshot the accessibility tree.** Use the Playwright MCP page snapshot —
   it returns roles, names, and structure, not a bitmap. Read it to confirm the
   element you changed exists with the right role and accessible name.
2. **Run axe-core for WCAG.** Drive `@axe-core/playwright` against the route.
   Zero violations is the bar. Color contrast, missing labels, ARIA misuse, and
   heading-order breaks all surface here.
3. **Assert structural regression.** Use `toMatchAriaSnapshot()` so an
   unintended change to the tree fails like a unit test.
4. **Check the Lighthouse budget.** Run Chrome DevTools MCP Lighthouse and
   compare LCP / INP / CLS and category scores against `lighthouse-budget.json`.
   A regression past budget is a failure, not a note.
5. **Screenshot only on a flagged visual diff.** If — and only if — a step above
   flags something visual (layout shift, contrast, an element a11y cannot
   describe), capture a screenshot for the human record. Never screenshot as
   the primary verification step.

## Rules

- The a11y tree is the source of truth; the screenshot is the exception.
- A WCAG violation or an over-budget metric blocks "done" — treat it like a
  failing test, not advice.
- Test keyboard reachability and focus order for anything interactive — the
  a11y tree shows tab structure; use it.
- Do not mark a UI task complete without naming the route you verified and the
  axe + Lighthouse results you observed.
