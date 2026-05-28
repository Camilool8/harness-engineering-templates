---
name: web-frontend-app
description: Conventions for a client-side SPA or SSG that consumes APIs it does not own. Use when .claude/HARNESS.toml selects web/frontend-app, or when building a React/Vue/Svelte app with a typed/mocked backend boundary, route-level data fetching, code-split routing, and a Core Web Vitals verification loop.
---

# Web — frontend-app

### Backend boundary
- The backend is a contract, not code you own. Mock it at a typed boundary
  (MSW, typed fetch wrapper, tRPC client) and never reach past that boundary.
- All network calls go through one typed client layer — never raw `fetch` in
  a component; never assume a field exists that the type doesn't declare.

### Data fetching and state
- Fetch data at the route level (TanStack Query / SWR loader), not inside
  individual components. Components receive props, not raw API calls.
- Local UI state only: `useState`/`useSignal`. Shared domain state: a store
  (Zustand, Pinia, Svelte stores). Do not mix the two layers.
- Never use `useEffect` for initial data fetching — use the loader or query.

### Routing
- Route = one data boundary + one page component. Collocate its loader,
  error boundary, and loading skeleton in the same file or folder.
- Code-split every route by default. Never bundle the whole app eagerly.

### Verification loop (run after every UI-affecting change)
1. Snapshot the Playwright accessibility tree (`locator.ariaSnapshot()`).
2. Run axe-core for WCAG 2.2 AA — zero violations required.
3. Check Lighthouse budget: LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1.
4. Screenshot only to confirm a visually-flagged diff, never as primary check.

### Done criteria
- A component is not done until empty, loading, and error states are designed.
- Never claim a UI task done without naming the route verified and the axe +
  Lighthouse results observed.
