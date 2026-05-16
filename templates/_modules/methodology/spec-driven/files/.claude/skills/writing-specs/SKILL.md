---
name: writing-specs
description: Turns a vague request into a precise, testable spec contract. Use at the start of any non-trivial feature — before Plan Mode, before any edit — to externalize ambiguity into specs/.
---

# Writing Specs

A spec is the contract the agent and the human iterate against. Its job is to
remove ambiguity *before* code, so the agent is constrained against drift.

## When to write one

Write a spec when the work spans multiple files, crosses a service boundary,
touches non-trivial UX, or arrived as a vague request. Skip it only when the
diff genuinely fits in one sentence.

## How

1. **Copy the template.** `cp specs/TEMPLATE.md specs/<slug>.md`. Use a short
   kebab-case slug for the feature.

2. **Name the problem before the solution.** Write the *Problem* section as
   current-state pain. If you find yourself describing a solution, you are
   ahead of yourself — back up.

3. **Make acceptance criteria testable.** Each criterion must be pass/fail
   checkable. Prefer Given/When/Then phrasing. "The page is fast" is not a
   criterion; "Largest Contentful Paint < 2.5s on a mid-tier mobile profile"
   is. If you cannot say how to verify it, it is not done — sharpen it.

4. **Write Out of scope deliberately.** List what this change will *not* do.
   Non-goals are the cheapest defense against scope creep and gold-plating.

5. **Fill Verification with real steps.** Name the tests, evals, or lint that
   must pass, and the manual steps a human runs to see it work. "Tests pass" is
   not verification on its own.

6. **Surface unknowns.** Put genuine uncertainties in *Open questions*. The spec
   is not approved until that list is empty.

## After the spec

- Enter **Plan Mode** to research and produce an implementation plan from the
  approved spec. Do not edit files before the plan is approved.
- The spec is a **living contract**. When implementation reveals the spec was
  wrong, update the spec in the same change and note what moved — never diverge
  silently. Iterate the spec; do not treat it as a frozen up-front document.
