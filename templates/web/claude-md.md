## Web stack rules

<!-- Fill the stack lockdown for YOUR framework. The example below is Next.js
     App Router; replace wholesale for Nuxt / SvelteKit / Astro / Remix. -->

### Stack lockdown

- App Router only. Never generate Pages Router patterns.
- Server Components by default. Add `'use client'` ONLY for state, browser
  APIs, or event handlers.
- Mutations via Server Actions, never a client-side `fetch` to `/api`.
- Data fetching: async Server Components > TanStack Query > SWR.
  **No `useEffect` for data fetching.**
- Forms: Server Actions; avoid controlled inputs unless genuinely needed.

### Styling and components

- Tailwind only. Never hand-roll a button, modal, or input.
- Pull shadcn/ui components through the shadcn MCP — do not hallucinate
  component APIs from memory; the MCP serves the current version.

### Verification

- After any UI change, run the `verifying-web-ui` skill: accessibility-tree
  snapshot first, then axe-core (WCAG), then the Lighthouse budget.
  Screenshots only on a flagged visual diff.
- A WCAG violation or an over-budget Core Web Vital blocks "done".

### Never do

- Never verify UI with screenshots as the primary signal — use the a11y tree.
- Never introduce `useEffect`-driven data fetching.
- Never keep CLAUDE.md over ~200 lines — prune; compliance falls off a cliff.
