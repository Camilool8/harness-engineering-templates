# Module: web/addon/nextjs

> Config: `domain.addons` · Depends on: none (pairs with `tailwind-shadcn`, `drizzle`, `authjs`)

**What it does.** Installs the `using-nextjs-app-router` skill that teaches the agent
the App Router mental model: Server Components by default, Client Components only
when browser APIs or interactivity are required, Server Actions for all mutations,
and the `fetch`-based data-fetching cache rather than `useEffect` for data.

## Adopt if
- You are building a fullstack Next.js application (sub-domain: `fullstack-app`).
- You need server-side rendering, static generation, or edge functions in a
  React application.
- You want colocated data fetching without a separate API layer.

## Skip if
- You are building a purely client-side SPA with an external API — use `vite-spa`
  instead; mixing both in the same project is valid only for a hybrid monorepo.
- Your framework is Remix, Astro, or SvelteKit — those have their own conventions
  the generic Next.js skill does not cover.

## Dependencies
- Next.js 15+ (`app/` directory present).
- Node.js 18+.
- TypeScript strongly recommended.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `nextjs` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Delete `.claude/skills/using-nextjs-app-router/`.
- Remove the `## Addon — Next.js App Router` section from `CLAUDE.md`.

## Files
- `files/.claude/skills/using-nextjs-app-router/SKILL.md` — App Router
  conventions: Server vs Client Components, Server Actions, caching, routing,
  and the rule against `useEffect` for data fetching.
