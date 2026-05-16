## Behavior-Driven Development

User-visible behavior changes start as a Gherkin `.feature` file in `features/`,
before implementation.

- **The feature file is the shared contract** with non-technical stakeholders.
  They must be able to read it and confirm "yes, that is what the system should
  do." If a stakeholder cannot read it, it has failed its job.
- **Write Given/When/Then in business language, not UI language.** "Given a
  customer with an overdue invoice" — not "Given the user clicks the blue
  button." UI-language scenarios lock the spec to the implementation.
- **Declarative, not imperative.** Describe *what* behavior is expected, not the
  click-by-click steps to exercise it.
- **One story, a handful of scenarios.** Cover the happy path plus the
  meaningful edge cases — do not generate dozens of scenarios from one story.
- **Gherkin must run.** Back every step with code-level step definitions in a
  BDD runner (Cucumber / Behave / pytest-bdd). Unrun feature files are stale
  documentation, not a contract.

See the `authoring-feature-files` skill and `features/TEMPLATE.feature`.
