# Module: web/addon/astro

> Config: `domain.addons` · Depends on: none (pairs with `tailwind-shadcn`, `sanity-cms`, `sentry-observability`)

**What it does.** Installs the `using-astro` skill that teaches the agent Astro's
islands architecture: zero-JavaScript-by-default static rendering, opt-in partial
hydration via `client:*` directives, server islands (`server:defer`), content
collections with schema validation, and SSR output modes with adapters.

## Adopt if
- You are building a content-focused site — marketing, docs, blog, portfolio —
  where most pages are static and only pockets need interactivity.
- You want zero client JavaScript by default and to ship framework components
  (React/Vue/Svelte/Solid) only as hydrated islands.
- Sub-domains: `frontend-app` (content-driven SSG/SPA) or `fullstack-app`
  (Astro with `output: 'server'` and server endpoints).

## Skip if
- Every screen is highly interactive (dashboard, editor, realtime app) — a full
  SPA framework (`vite-spa`) or `nextjs` fits better; Astro's island model adds
  overhead with no payoff there.
- You specifically need React Server Components — use `nextjs`.

## Dependencies
- Astro 5+ (Astro 6 current). Node.js 18+.
- An adapter (`@astrojs/node`, `@astrojs/vercel`, `@astrojs/cloudflare`) only
  when using `output: 'server'`.
- Framework integrations (`@astrojs/react`, etc.) only for hydrated islands.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `astro` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Delete `.claude/skills/using-astro/`.
- Remove the `## Addon — Astro` section from `CLAUDE.md`.

## Files
- `files/.claude/skills/using-astro/SKILL.md` — islands and hydration
  directives, server islands, content collections, output modes and adapters,
  and project structure.
