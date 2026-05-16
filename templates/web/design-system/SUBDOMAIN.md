# Web — design-system sub-domain

A shared component library consumed by two or more applications.
The library has no application shell; it ships tokens, primitives, and
composed components with a stable published API versioned by semver.

## Adopt if

- You are building a React/Vue/Svelte component library consumed by ≥2 apps.
- You need a shared token layer (colors, spacing, typography) that drives
  multiple product surfaces.
- You publish to an npm registry (internal or public) and need semver discipline.
- Storybook is the primary development and documentation environment.
- The primary concerns are component API stability, visual regression, and
  accessibility across all consumers.

## Skip if

- You are building a single app with its own components → use `frontend-app`.
- You own both frontend and backend in one deployable → use `fullstack-app`.
- You have no UI and are building a pure HTTP service → use `api-service`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `tailwind-shadcn` | Default: Tailwind design tokens + shadcn/ui primitives as the base layer |
| `playwright-e2e` | Add for cross-browser component tests that assert on the a11y tree |
| `sentry-observability` | Add when error monitoring in consuming apps feeds back to the library |

## Agent team

| Agent | Role |
|---|---|
| `component-architect` | Read-only; defines component API contract, token schema, semver impact, and Storybook story shape before any code is written |
| `component-implementer` | Read-write; implements the architect's component spec bounded to named files; updates stories and tests |
| `visual-regression-tester` | Read-only (Bash + screenshot); runs visual regression checks against Storybook; flags snapshot diffs; blocks "done" on regressions |
| `design-critic` | Shared; reviews rendered components for visual hierarchy, spacing, and UX quality |
| `accessibility-auditor` | Shared; WCAG 2.2 AA audit via axe-core; blocks "done" on any violation |
