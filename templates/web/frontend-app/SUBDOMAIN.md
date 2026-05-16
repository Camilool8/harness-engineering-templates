# Web — frontend-app sub-domain

A client-side application (SPA or SSG) that consumes APIs it does not own.
The backend is a separate service or third-party; all network boundaries are
typed and mocked at the client boundary.

## Adopt if

- You are building a React/Vue/Svelte SPA that calls external or team-owned APIs.
- The backend is owned by another team, is a third-party SaaS, or is consumed
  via a stable typed contract (OpenAPI, tRPC, GraphQL).
- You want Vite, Next.js export, or Astro as your build tool with no server runtime.
- The primary concerns are component quality, bundle size, routing, state management,
  and client-side performance (Core Web Vitals).

## Skip if

- You own both frontend and backend in one deployable → use `fullstack-app`.
- You are building a shared component library consumed by ≥2 apps → use `design-system`.
- You have no UI whatsoever and are building a pure HTTP service → use `api-service`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `vite-spa` | Default: Vite + React SPA with client routing (TanStack Router or React Router) |
| `nextjs` | Swap for `vite-spa` when you need SSG, ISR, or hybrid rendering without owning a server |
| `tailwind-shadcn` | Default: Tailwind utility classes + shadcn/ui component collection |
| `authjs` | Add when the app has a login flow backed by OAuth or credentials |
| `playwright-e2e` | Add for page-object E2E tests against the running dev server |
| `sentry-observability` | Add when error monitoring and session replay are required in production |

## Agent team

| Agent | Role |
|---|---|
| `frontend-architect` | Read-only; returns a typed plan: routing map, state strategy, data-fetch boundaries, component breakdown, acceptance criteria |
| `frontend-implementer` | Read-write; implements the architect's plan bounded to named files; returns diff + summary |
| `design-critic` | Shared; reviews rendered UI for visual hierarchy, spacing, and UX quality |
| `accessibility-auditor` | Shared; WCAG 2.2 AA audit via axe-core; blocks "done" on any violation |
| `web-perf-auditor` | Shared; Lighthouse + Chrome DevTools trace; enforces `lighthouse-budget.json` |
