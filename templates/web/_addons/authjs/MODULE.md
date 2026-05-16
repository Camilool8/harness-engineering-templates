# Module: web/addon/authjs

> Config: `domain.addons` · Depends on: none (pairs with `nextjs`, `drizzle`, `fullstack-app`)

**What it does.** Installs the `using-authjs` skill that teaches the agent
Auth.js v5 (NextAuth) conventions: provider configuration via environment
variable inference, session access in Server Components vs Client Components,
protecting routes via middleware, and the security invariants around tokens
and secrets.

## Adopt if
- You need OAuth, magic-link, or credentials authentication in a Next.js App
  Router project (sub-domain: `fullstack-app`).
- You want a standards-compliant session layer without writing JWTs by hand.
- You are using Drizzle and need the Drizzle adapter for Auth.js.

## Skip if
- You are building a pure API service — handle auth at the gateway or with
  a dedicated auth service.
- You need fine-grained RBAC or enterprise SSO beyond what Auth.js providers
  cover — consider a dedicated IAM service.

## Dependencies
- `next-auth@5` (or `@auth/nextjs` for the App Router integration).
- Optional: `@auth/drizzle-adapter` if persisting sessions to the database.
- `AUTH_SECRET` environment variable (generated with `npx auth secret`).

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `authjs` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Delete `.claude/skills/using-authjs/`.
- Remove the `## Addon — Auth.js` section from `CLAUDE.md`.

## Files
- `files/.claude/skills/using-authjs/SKILL.md` — provider setup, session access
  patterns, middleware route protection, token security rules, and the no-log-tokens
  invariant.
