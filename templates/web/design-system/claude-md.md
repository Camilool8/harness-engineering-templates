## Web — design-system

### Component API stability
- A published component's props, variants, and token names are public API.
  Never rename, remove, or change the default of an existing prop without a
  semver major bump. Deprecate with `@deprecated` JSDoc before removing.
- Token names (CSS custom properties, JS constants) that consumers reference
  are public API. Prefix all library tokens with a namespace to prevent
  collision with consumer tokens.
- Every public export is intentional. Barrel `index.ts` defines the surface;
  anything not exported is private and can change freely.

### Storybook and stories
- Every component must have a Default story, variant stories covering all
  meaningful prop combinations, and stories for empty/loading/error states.
- Run `storybook test` in CI — interaction tests and a11y checks must pass
  before "done" is declared.
- Story descriptions and JSDoc are the documentation. Write them as if
  explaining the component to a new engineer who has never used it.

### Design tokens
- Define tokens at three semantic layers: Primitive → Semantic → Component.
  Consumers reference semantic tokens; never expose primitives directly.
- Token pipeline: Style Dictionary generates CSS custom properties, JS
  constants, and Tailwind config from a single source. Do not hand-code the
  generated output — regenerate it from the source.

### Visual regression
- After every visual change, flag it explicitly: the `visual-regression-tester`
  agent runs snapshot diffs against the Storybook baseline.
- Snapshot diffs must be intentionally reviewed and accepted — never bulk-accept
  without inspecting each changed story.
- A visual regression is a blocker, not a note. Fix it or accept it
  deliberately before marking the task done.

### Accessibility
- A library is the leverage point for accessibility: fix once, fix everywhere.
- Every interactive component must be keyboard operable, announce its state
  to screen readers, and display a visible `:focus-visible` indicator.
- `@storybook/addon-a11y` runs axe-core on every story. Zero violations
  required before shipping a component version.

### Done criteria
- A component is not done until: variant stories pass, interaction tests pass,
  axe-core reports zero violations, and visual snapshots are accepted.
- Never claim a component API change "done" without updating the version in
  `package.json` and the changelog via Changesets.
