# Module: web/addon/vite-spa

> Config: `domain.addons` · Depends on: none (pairs with `tailwind-shadcn`, `authjs`, `playwright-e2e`)

**What it does.** Installs the `using-vite-spa` skill that teaches the agent
client-only SPA conventions with Vite: project structure, environment variables
(`VITE_` prefix), HMR expectations, the React plugin, routing with
React Router, and build output configuration.

## Adopt if
- You are building a pure client-side SPA (sub-domain: `frontend-app`).
- The backend is an external API you do not own — Vite gives you a clean
  boundary: `src/` is entirely client code.
- You want instant HMR and the fastest cold-start dev server available.

## Skip if
- You need server-side rendering or server-driven routing — use `nextjs` instead.
- You are building a fullstack app that owns the backend — `nextjs` or another
  meta-framework is the better fit.
- You are using SvelteKit, Astro, or Nuxt; those have first-party Vite integrations
  with conventions that differ from this skill.

## Dependencies
- Vite 6+ (via `npm create vite@latest` or `npm create vite-react-ts`).
- Node.js 18+.
- `@vitejs/plugin-react` (or `-swc` variant) for React projects.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `vite-spa` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Delete `.claude/skills/using-vite-spa/`.
- Remove the `## Addon — Vite SPA` section from `CLAUDE.md`.

## Files
- `files/.claude/skills/using-vite-spa/SKILL.md` — SPA conventions: project
  structure, env vars, routing, proxy config, and build output.
