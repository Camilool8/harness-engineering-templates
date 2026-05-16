# Web — design-system reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### Component API stability and semver

- **Published component APIs must be semver-versioned.** A prop rename, a
  removed variant, or a changed default value is a breaking change (major bump),
  not a patch. Use Changesets (`@changesets/cli`) to track and publish changes
  in monorepos.
- **Separate internal implementation from the public API.** Use barrel exports
  (`index.ts`) to define exactly what consumers can import. Anything not in the
  barrel is private and subject to change without semver.
- **Deprecation before removal:** mark props `@deprecated` in JSDoc at least one
  minor version before removing them. Ship a codemod when the migration is
  non-trivial.
- **Design token schema is a contract.** Token names (CSS custom properties or
  JS tokens) that consumers reference in their own code are public API.
  Rename or remove them only with a major version bump.

### Storybook and documentation

- **Storybook 8** (2024–) is the standard environment for component development,
  documentation, and visual review. Use CSF3 (Component Story Format 3) — stories
  are plain objects with an optional `play` function for interaction tests.
- Every component must have: a Default story, variant stories for each significant
  prop combination, and a story that demonstrates the empty/loading/error state.
- Use `@storybook/addon-a11y` on every story — axe-core runs in-browser and
  surfaces WCAG violations during development, not after.
- Use `@storybook/test` + Vitest for interaction tests within stories (replaces
  `@storybook/testing-library`). These run in the browser and in CI via
  `storybook test`.
- Document component props with JSDoc + TypeScript; Storybook's `autodocs` tag
  generates the props table from your types automatically.

### Design tokens

- **Style Dictionary** is the standard token pipeline: define tokens once in
  JSON/YAML, generate CSS custom properties, JS constants, and Tailwind config
  from a single source.
- Organise tokens in semantic layers: Primitive → Semantic → Component.
  Consumers reference semantic tokens, never primitives directly.
- Tailwind CSS v4 (2025–) uses CSS-native custom properties — align your token
  pipeline with CSS custom properties so Tailwind and your token layer share the
  same source.
- Use `@tokens-studio/sd-transforms` with Style Dictionary to consume Tokens
  Studio (Figma plugin) output directly in the pipeline.

### Visual regression testing

- **Chromatic** (from the Storybook team) is the cloud service for visual
  regression: it captures story snapshots, diffs them against the baseline, and
  blocks PR merges on unreviewed changes.
- For local / self-hosted setups, **Playwright** with `toHaveScreenshot()` against
  Storybook's static build provides baseline diffing without a cloud dependency.
- Never use screenshots as primary correctness verification — use the a11y tree.
  Screenshots are for catching unintended visual regressions flagged by the diff.
- Run visual regression on every PR; review and accept diffs intentionally, never
  bulk-accept without inspecting each changed component.

### Accessibility in component libraries

- A component library is the leverage point for accessibility: fixing a missed
  `aria-label` or focus style in one place fixes it for every consumer.
- Test with real assistive technology (VoiceOver + Safari, NVDA + Firefox) at
  least once per component. axe-core catches ~40 % of WCAG issues automatically.
- Every interactive component must: be keyboard operable, have a visible focus
  indicator (`:focus-visible`), announce its state to screen readers, and support
  high-contrast mode.
- Use Radix UI or Headless UI as accessible primitive foundations before
  hand-rolling ARIA patterns — these libraries encode the ARIA Authoring Practices
  Guide patterns correctly.

## Common gotchas / failure modes

- **Barrel imports causing bundler issues:** re-exporting everything from
  `index.ts` can prevent tree-shaking in older bundlers. Test that consumers
  can import a single component without pulling in the whole library.
- **CSS class collisions:** Tailwind class names in the library can conflict with
  the consumer's Tailwind config if not isolated (use a prefix or CSS Modules).
- **Unintentional peer-dependency changes:** bumping React or TypeScript version
  in the library forces the same bump on all consumers. Treat peer deps as
  part of the public API.
- **Story drift:** stories that no longer reflect the actual component API go
  stale quickly. Run `storybook test` in CI to catch broken interaction tests.
- **Token naming collisions:** without a namespace prefix on CSS custom properties,
  library tokens can overwrite the consumer's tokens. Prefix all library tokens.

## Version-sensitive notes

- **Storybook 8 (2024–):** CSF3 is required; `@storybook/test` replaces
  `@storybook/testing-library`. `storybook test` now runs Vitest under the hood.
  `@storybook/addon-interactions` is merged into core.
- **Changesets 2.x:** `changeset add` prompts for bump type; `changeset version`
  bumps packages and updates changelogs; `changeset publish` publishes to npm.
- **Style Dictionary 4 (2024–):** config is now TypeScript-native (`sd.config.ts`);
  the `expand` option handles composite tokens from Tokens Studio.
- **Tailwind CSS v4 (2025–):** configuration moves from `tailwind.config.js` to CSS
  via `@theme` blocks. The JS config file is still supported but deprecated.
- **Radix UI 2.x:** component props and API are stable; import from namespaced
  packages (`@radix-ui/react-dialog`, etc.), not a barrel.

## Cited links

- https://storybook.js.org/docs — **Storybook docs** — CSF3, addon ecosystem,
  interaction tests, a11y addon, and `storybook test` CLI reference.
- https://www.chromatic.com/docs — **Chromatic docs** — visual regression workflow,
  PR checks, snapshot diffing, and TurboSnap for change-scoped runs.
- https://amzn.github.io/style-dictionary — **Style Dictionary docs** — token
  pipeline configuration, transforms, formatters, and multi-platform output.
- https://www.radix-ui.com/primitives/docs/overview/introduction — **Radix UI docs**
  — accessible primitive components implementing ARIA Authoring Practices patterns.
- https://github.com/changesets/changesets — **Changesets docs** — semver
  management, changelog generation, and monorepo publish workflow.
- https://tailwindcss.com/docs — **Tailwind CSS docs** — utility-first classes,
  v4 CSS-native configuration, and the `@theme` block for design tokens.
- https://www.w3.org/WAI/ARIA/apg — **ARIA Authoring Practices Guide** — canonical
  keyboard interaction patterns and ARIA roles for every interactive widget.
