# Web — reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### Framework landscape
- **Next.js App Router (v15/v16)** is the dominant full-stack React framework. Server
  Components are the default; add `'use client'` only for state, browser APIs, or
  event handlers. Use Server Actions for mutations — no hand-rolled API routes needed.
  Turbopack is stable in Next.js 15+ and default in v16.
- **Remix / React Router v7** merged in 2025; Remix 3 is re-emerging as a distinct
  product. Prioritises web-standard fetch, progressive enhancement, and nested loaders.
  Best fit: server-rendered apps where each route fetches its own data independently.
- **Astro (acquired by Cloudflare, Jan 2026)** ships zero JS by default; opt-in
  "islands" hydrate interactive components. Best fit: content-heavy sites, marketing,
  docs. Not suited for highly interactive apps.
- **SvelteKit 2 + Svelte 5 runes** offers the smallest bundles and a compile-time
  reactivity model. 55%+ bundle reduction vs React SPA reported in production migrations.
  Growing enterprise adoption; smaller ecosystem than React.

### Rendering strategy
- Default to hybrid rendering: static where content is stable, dynamic (streaming SSR)
  where data is per-user or real-time. Never default to pure CSR for a public page.
- Prefer streaming (`Suspense` boundaries in React / `+page.server.js` in SvelteKit)
  over waterfall SSR; reduces TTFB and improves perceived LCP.

### Accessibility-tree verification
- Use the **accessibility tree** as the primary verification signal, not screenshots.
  Playwright ≥ 1.49 exposes `locator.ariaSnapshot()` — structured YAML of the a11y
  tree — which is token-cheap and reliable. Microsoft's `@playwright/mcp` surfaces this
  to AI agents natively.
- Pair with `axe-core` (≥ 4.5 for WCAG 2.2 rules) for automated rule checks. axe-core
  finds ~57% of WCAG issues automatically; target WCAG 2.2 AA.
- Screenshots are a last resort — use only to confirm a visually-flagged diff.

### Core Web Vitals budgets
- **LCP** (Largest Contentful Paint) — Good: ≤ 2.5 s · Needs improvement: 2.6–4.0 s · Poor: > 4 s
- **INP** (Interaction to Next Paint) — Good: ≤ 200 ms · Needs improvement: 201–500 ms · Poor: > 500 ms
- **CLS** (Cumulative Layout Shift) — Good: ≤ 0.1 · Needs improvement: 0.11–0.25 · Poor: > 0.25
- Google requires 75% of page views to meet the "good" threshold. A regression past
  budget blocks "done" — enforce via Lighthouse CI against `lighthouse-budget.json`.

### shadcn/ui
- shadcn/ui is a copy-into-your-codebase component collection (not an npm package).
  CLI 3.0 (Aug 2025) added an MCP server — use it to install components: never
  hallucinate component APIs from training data.
- Unified Radix UI package (Feb 2026) simplified dependency graphs. New "Sera" style
  (Mar 2026) is a typography-first option.
- Install: `npx shadcn@latest init` then `npx shadcn@latest add <component>`.

## Common gotchas / failure modes

- **Stale-cache silent breakage (Next.js):** `fetch()` defaults to `force-cache` in
  the App Router. Dashboards that expect fresh data must pass `{ cache: 'no-store' }`.
  This is the #1 source of "my data is stale" bugs in App Router migrations.
- **Screenshot-only UI verification:** Screenshots are expensive, lossy for LLMs, and
  miss structural regressions. Always verify with the a11y tree first.
- **`useEffect` for data fetching:** In App Router, data belongs in async Server
  Components or TanStack Query — not `useEffect`. `useEffect`-driven fetching causes
  layout shifts and misses SSR hydration.
- **Forgetting `'use client'` boundaries:** Making a leaf interactive forces all its
  ancestors to ship JS. Keep Client Components as small and deep as possible.
- **Ignoring empty/error/loading states:** A component is not done until all three
  states are designed and tested — especially loading skeletons (CLS risk).
- **Hand-rolling shadcn primitives:** Component APIs change between shadcn releases.
  Always add via the CLI or MCP server; never copy-paste from memory.
- **Over-long CLAUDE.md:** Compliance falls off a cliff past ~200 lines. Keep each
  section tight; prune aggressively.

## Version-sensitive notes

- **Next.js 15 → 16 (2025–2026):** Turbopack is now stable and default. Partial
  Prerendering (PPR) graduated from experimental. `unstable_cache` is now `cache()`.
  Review caching semantics when upgrading.
- **Remix → React Router v7 (merged 2025):** `loader`/`action` API is unchanged but
  the package is now `react-router`. Import paths changed. Remix 3 is a separate
  evolution — do not conflate the two.
- **Svelte 5 runes (stable 2025):** `$state`, `$derived`, `$effect` replace the
  `let`/`$:` syntax. SvelteKit 2 requires Svelte 5 for new projects; migration guide
  available at svelte.dev.
- **axe-core ≥ 4.5:** Required for WCAG 2.2 rules (touch target size, focus
  appearance). Older versions silently skip 2.2 checks.
- **Playwright MCP (`@playwright/mcp`):** Released by Microsoft in early 2025. Prefer
  over raw Playwright for agent use — it exposes structured a11y snapshots natively.
- **shadcn CLI 3.0 (Aug 2025):** `package.json#imports` support added. MCP server
  available. Unified Radix package (`@radix-ui/react-*` → `radix-ui`) is opt-in.

## Cited links

- https://nextjs.org/docs/app — **Next.js App Router docs** — canonical reference for
  Server Components, Server Actions, caching, and routing patterns.
- https://web.dev/articles/defining-core-web-vitals-thresholds — **Core Web Vitals
  threshold definitions** — explains why LCP/INP/CLS thresholds are set where they are
  and how the 75th-percentile methodology works.
- https://playwright.dev/docs/accessibility-testing — **Playwright accessibility
  testing docs** — covers `locator.ariaSnapshot()`, axe-core integration, and the
  recommended a11y verification workflow.
- https://ui.shadcn.com/docs/changelog — **shadcn/ui changelog** — track CLI 3.0,
  MCP server, Unified Radix, and new styles as they ship.
- https://github.com/dequelabs/axe-core — **axe-core repository** — WCAG 2.2 rule
  list, how to run audits programmatically, and integration with Playwright/Cypress.
- https://pockit.tools/blog/nextjs-vs-remix-vs-astro-vs-sveltekit-2026-comparison/ —
  **Framework decision guide 2026** — practical adopt-if / skip-if for Next.js, Remix,
  Astro, and SvelteKit based on project type.
- https://developers.google.com/search/docs/appearance/core-web-vitals — **Google
  Search & Core Web Vitals** — official guidance on how CWV affects search ranking and
  how to measure field data via CrUX.
