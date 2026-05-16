# Web — frontend-app reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### State management
- **TanStack Query v5** (React) / **SWR v2** are the industry defaults for
  server-state management. They handle caching, background refetch, optimistic
  updates, and loading/error states without boilerplate. Do not hand-roll fetch
  + `useState` + `useEffect` for async data.
- **Zustand v5** is the consensus pick for lightweight global client-state in
  React SPAs. Prefer collocated `useState` for purely local state; escalate to
  Zustand only when ≥2 components need the same slice.
- **Pinia** (Vue 3) and **Svelte stores** (SvelteKit) are the idiomatic
  equivalents. Do not mix paradigms within one framework.
- Derived / computed state lives in selectors or `useMemo`, never duplicated in
  a second state slice.

### Data fetching patterns
- Route-level loaders (TanStack Router `loader`, React Router `loader`, SvelteKit
  `load`) are the correct entry point for page data. Components should receive
  resolved data as props or via query hooks, not issue raw `fetch` calls.
- Use typed API clients (generated from OpenAPI via `openapi-typescript` + `hey-api`,
  or tRPC client) to enforce the contract at compile time. Never assume a field
  exists without a type declaration.
- Mock Service Worker (MSW v2) is the standard tool for intercepting network calls
  in tests and Storybook. Use it to decouple frontend development from a live backend.

### Routing
- **TanStack Router v1** (React) offers fully type-safe file-based routing with
  search-params typing. It is the recommended default for new Vite SPAs in 2026.
- **React Router v7** (merged from Remix 2025) retains the `loader`/`action` API.
  Use for apps already on React Router or that need progressive-enhancement semantics.
- Code-split every route by default (`lazy()`/`React.lazy` or file-based conventions).
  Bundle-split by route, not by component.
- Use `<Suspense>` boundaries at route boundaries for streaming and loading states.

### Client performance (Core Web Vitals)
- LCP ≤ 2.5 s: preload above-the-fold images, avoid render-blocking scripts,
  use `<link rel="preload">` for critical fonts and assets.
- INP ≤ 200 ms: defer non-critical JS (`<script defer>`), avoid long tasks on
  the main thread, use `startTransition` for deferred state updates in React.
- CLS ≤ 0.1: always set explicit width/height on images and videos, use loading
  skeletons with fixed dimensions, avoid inserting content above existing content.
- Use Vite's built-in `rollup-plugin-visualizer` or `vite-bundle-visualizer` to
  audit bundle composition before shipping.

### Forms
- **React Hook Form v7** + **Zod** is the standard form + validation stack for React.
  RHF minimizes re-renders; Zod provides schema-driven client + server validation.
- For Vue: VeeValidate + Zod. For Svelte: `superforms` + Zod.
- Always validate on the client for UX and on the server (in the API or action) for
  security — client validation is advisory, not a security boundary.
- Accessible forms: every input has an associated `<label>`, error messages are linked
  via `aria-describedby`, focus moves to the first error on failed submit.

## Common gotchas / failure modes

- **`useEffect` for data fetching:** causes layout shifts, misses hydration, and
  races with React StrictMode double-invocation. Use TanStack Query or a route loader.
- **Prop drilling past 2 levels:** a sign the state belongs in a store or context.
  Refactor before it becomes unmaintainable.
- **Forgetting loading / error / empty states:** a component is not done until all
  three are designed. Skeletons must have fixed dimensions or CLS follows.
- **Untyped API responses:** `any` types in API client code make refactors silently
  dangerous. Generate types from OpenAPI or define Zod schemas at the boundary.
- **Importing from the API client in a component directly:** breaks the route-level
  data boundary, makes testing harder, and causes waterfalls.
- **Over-fetching on every render:** use `staleTime` in TanStack Query to avoid
  redundant network calls when a component remounts.
- **Screenshot-only UI verification:** use the Playwright a11y tree as primary
  verification; screenshots are expensive and lossy for agents.

## Version-sensitive notes

- **TanStack Query v5 (2024–):** `useQuery` returns `{ data, isPending, isError }`;
  `isLoading` is split into `isPending`. Devtools require the separate
  `@tanstack/react-query-devtools` package. Migration guide: tanstack.com/query.
- **TanStack Router v1 (stable 2024–):** type-safe file-based routing. `loaderData`
  is inferred from the `loader` return type. Not compatible with Create React App.
- **React Router v7 / Remix merger (2025):** package is now `react-router`; Remix is
  re-emerging as a separate product (Remix 3). Do not mix `react-router-dom` v6 and v7.
- **MSW v2 (2024–):** browser worker and Node.js handler setup changed significantly
  from v1. `rest` handlers are now `http` handlers. Migration required.
- **Zustand v5 (2024–):** `create` returns a hook directly (no wrapper).
  `immer` middleware still available as `immer` from `zustand/middleware/immer`.
- **React Hook Form v7 (stable):** `register` API is stable. Avoid `Controller`
  for simple inputs; use it only for custom components that need `onChange`/`value`.

## Cited links

- https://tanstack.com/query/latest/docs/framework/react/overview — **TanStack Query docs**
  — authoritative reference for server-state management, caching, and data fetching patterns.
- https://tanstack.com/router/latest/docs/framework/react/overview — **TanStack Router docs**
  — type-safe file-based routing for Vite/React SPAs; covers loaders, search params, and
  code-splitting conventions.
- https://react-hook-form.com/docs — **React Hook Form docs** — form state, validation,
  error handling, and integration with Zod/Yup schema libraries.
- https://mswjs.io/docs — **Mock Service Worker v2 docs** — browser and Node.js API
  mocking; covers the v2 `http` handler API and Storybook integration.
- https://zustand.docs.pmnd.rs — **Zustand docs** — lightweight global state for React;
  covers slices, middleware (immer, persist, devtools), and v5 migration.
- https://web.dev/articles/vitals — **Core Web Vitals overview** — definitions,
  measurement methodology, and tooling for LCP, INP, and CLS.
- https://vite.dev/guide — **Vite docs** — build configuration, code splitting, env
  variables, and plugin ecosystem for SPA development.
- https://zod.dev — **Zod docs** — TypeScript-first schema validation; covers schema
  composition, refinements, and transform patterns used in form + API boundary validation.
