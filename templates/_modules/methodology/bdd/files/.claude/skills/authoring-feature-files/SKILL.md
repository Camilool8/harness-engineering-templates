---
name: authoring-feature-files
description: Writes Gherkin .feature files from a user story so non-technical stakeholders can sign off on behavior. Use before implementing any user-visible behavior change.
---

# Authoring Feature Files

A `.feature` file is the shared contract between engineering and a non-technical
stakeholder. Its single test of quality: can a product or compliance person read
it and confirm the behavior is correct?

## When to write one

Before implementing any user-visible behavior change, when a stakeholder outside
engineering needs to sign off, or when the behavior has enough variants to
warrant executable documentation.

## How

1. **Copy the template.** `cp features/TEMPLATE.feature features/<slug>.feature`.

2. **Write the `Feature:` from the user story.** Capture role, capability, and
   business value. This is the *why*.

3. **Write scenarios as outcomes.** Name each scenario after the result, not the
   action ("Overdue customer is blocked from checkout", not "Test checkout").
   Cover the happy path plus the meaningful edge cases — typically three to
   seven scenarios. Do not generate dozens from one story.

4. **Use business language, never UI language.**
   - Good: `Given a customer with an overdue invoice`
   - Bad: `Given the user clicks the blue "Pay" button`
   UI-language steps lock the spec to the current implementation and break on
   every redesign.

5. **Stay declarative.** State *what* behavior is expected, not the click-by-
   click procedure. The step definitions handle the *how*.

6. **Use `Background` for shared preconditions** and `Scenario Outline` +
   `Examples` when one behavior varies only by input — do not copy-paste near-
   identical scenarios.

## After authoring

- Have the stakeholder read it. If they cannot, rewrite in plainer language.
- **Wire step definitions in code** (Cucumber / Behave / pytest-bdd / SpecFlow).
  Steps must be real code, not prompts — agents tend to summarize multi-step
  scenarios if asked to "execute" Gherkin directly.
- An unrun feature file is stale documentation, not a contract. Keep it green.
