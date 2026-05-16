## Addon — Astro

Astro is server-first and ships **zero client JavaScript by default**. Keep it
that way — only hydrate what genuinely needs interactivity.

**Components & hydration:**
- `.astro` components render to HTML at build/request time and ship no JS.
- Use a framework component (React/Vue/Svelte/Solid) only for an interactive
  island, with a hydration directive: `client:load` (immediately),
  `client:idle` (when the main thread is idle), `client:visible` (when scrolled
  into view — prefer this below the fold), `client:only="react"` (skip SSR).
- No directive = static HTML, no JS. That is the goal for most of the page.
- `server:defer` makes a component a server island — defer slow or personalized
  server work so the rest of the page streams immediately.

**Content:**
- Manage structured content (blog, docs, products) with content collections in
  `src/content.config.ts` — a Zod schema for type-safety plus a `loader` for the
  source (local files or a remote API/CMS). Query with `getCollection`.

**Rendering mode:**
- `output: 'static'` (default) prerenders every route. Use `output: 'server'`
  with an adapter only when request-time rendering or endpoints are needed; a
  single route can opt back in with `export const prerender = true`.

**Do not:**
- Do not add a `client:*` directive to a component with no interactivity.
- Do not reach for Astro when every screen is a stateful app — that is a SPA.
- Keep secrets server-side; only `PUBLIC_`-prefixed env vars reach the client.
