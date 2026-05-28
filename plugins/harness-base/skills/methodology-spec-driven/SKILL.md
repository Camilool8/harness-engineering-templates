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

1. **Create the spec file.** Write `specs/<slug>.md` (short kebab-case slug)
   using the **Spec template** at the end of this skill. Create the `specs/`
   directory if it does not exist.

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

## Spec template

Create `specs/<slug>.md` with this structure:

```markdown
# Spec: <feature name>

> Status: draft | approved | shipped · Owner: <name> · Updated: <YYYY-MM-DD>
> Ticket: <link or id, if any>

## Problem

What is broken or missing, and for whom. Describe the current state and why it
is not good enough. State the user or system pain — not a proposed solution.

## Goal

The desired state in one or two sentences. What is true once this ships.

## Acceptance criteria

Concrete, testable statements. Each must be checkable as pass/fail. If a
criterion cannot be verified, it is not a criterion — sharpen it.

- [ ] Given <context>, when <action>, then <observable outcome>.
- [ ] ...

## Out of scope

What this change deliberately does NOT do. Naming non-goals prevents scope
creep and stops the agent from gold-plating.

- ...

## Approach (sketch)

A short outline of the intended implementation — key files, data shape, new
boundaries. Detail belongs in the Plan Mode plan, not here. One paragraph.

## Verification

How a reviewer confirms this is done — beyond "tests pass":

- Automated: <which tests / evals / lint must be green>.
- Manual: <steps a human runs to see it working>.

## Open questions

Unknowns to resolve before or during implementation. Empty when the spec is
approved.

- ...
```
