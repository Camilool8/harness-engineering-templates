# Web — fullstack-app reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### Next.js App Router and Server Components

- **Server Components by default.** Every component is a Server Component
  unless it adds `"use client"` — meaning it renders on the server, has no
  client-side JS, and can await data directly. Reserve `"use client"` for
  components that need browser APIs, event handlers, or React state/effects.
- **Server Actions for mutations.** Mark async functions with `"use server"` to
  create Server Actions. Call them from forms (`action={myServerAction}`) or
  from Client Components. They replace API routes for same-app mutations.
- Never use `useEffect` for data fetching in a Next.js App Router app — await
  data in Server Components or use Route Handlers for client-side SWR/TanStack
  Query patterns.
- Use `<Suspense>` boundaries around async Server Components to stream partial
  UI to the client without blocking the full page render.

### Auth with Auth.js (NextAuth v5)

- **Auth.js v5** (beta stable 2025) is the recommended auth layer for Next.js
  App Router. Configuration moves to `auth.ts` at the project root with a
  unified `handlers`, `auth`, `signIn`, `signOut` export.
- Protect routes with middleware (`middleware.ts`) using `auth()` — never rely
  solely on client-side redirect. Server Components can also call `auth()` to
  read the session.
- Never log session tokens or JWTs. Store secrets in environment variables
  (`.env.local`) and verify they are in `.gitignore`.
- Use database sessions (Drizzle adapter) rather than JWT-only sessions when
  you need server-side session invalidation.

### Data access with Drizzle ORM

- **Schema as the source of truth.** Define your schema in `db/schema.ts` using
  Drizzle's typed schema DSL. The schema drives TypeScript types, migrations, and
  query builders.
- Use the expand-contract pattern for migrations: add a new column (expand), deploy,
  backfill, then drop the old column (contract) in a second migration. Never drop
  a column in the same migration that adds its replacement.
- Never run `drizzle-kit drop` or raw `DROP TABLE` without a migration PR reviewed
  by at least one human. Destructive DDL is a blocking change.
- Use `db.transaction()` for multi-step mutations. If a Server Action modifies
  more than one table, it belongs in a transaction.

### Server Action patterns

- Validate all inputs with Zod at the start of every Server Action — treat every
  caller as untrusted, even a form rendered by your own Server Component.
- Return typed results (`{ data, error }`) rather than throwing — throwing from
  a Server Action gives the client an opaque error in production.
- Rate-limit Server Actions that mutate sensitive resources (auth, payments) using
  a request-count check against Redis or an in-memory store.
- Prefer server-side redirects (`redirect()` from `next/navigation`) over
  client-side navigation after a successful mutation.

### Deployment and environment

- Next.js App Router applications deploy optimally on Vercel but are fully portable
  to any Node.js runtime via `next start` or the standalone output mode.
- Use `next.config.ts` (TypeScript config, stable in Next.js 15+) for type-safe
  configuration. Avoid `next.config.js` in new projects.
- Environment variables for server-only secrets must not have the `NEXT_PUBLIC_`
  prefix — that prefix opts a variable into the client bundle.

## Common gotchas / failure modes

- **Mixing Server and Client Component imports:** a Server Component cannot import
  a Client Component that uses a browser API at the top level — the import itself
  triggers the browser API. Use dynamic imports with `ssr: false` for truly browser-
  only code.
- **Forgetting `"use client"` on event handlers:** adding `onClick` to a Server
  Component silently fails in development and errors in production builds.
- **Unvalidated Server Action inputs:** a Server Action called from a form can be
  invoked directly via fetch — always validate with Zod, never trust form data.
- **Session read in Client Components via API:** calling an API route to read the
  session in a Client Component causes a waterfall. Read the session in the Server
  Component and pass it down as a prop.
- **Drizzle migration conflicts:** running migrations in parallel (e.g., two
  concurrent deployments) can cause migration table lock contention. Use a deploy
  step that runs migrations before the new instance starts.

## Version-sensitive notes

- **Next.js 15 (2024–):** `fetch` caching defaults changed — `fetch` is no longer
  cached by default. Use `{ cache: 'force-cache' }` explicitly or `unstable_cache`
  for data that should be cached across requests.
- **Auth.js v5 (2025):** `next-auth` package renamed to `next-auth` v5 beta;
  config moves to `auth.ts`. The v4 `[...nextauth].ts` API route pattern is
  replaced by `handlers` exported from `auth.ts`.
- **Drizzle ORM 0.30+ (2024–):** `drizzle-kit` commands are now `drizzle-kit generate`,
  `drizzle-kit migrate`, `drizzle-kit push` (dev only). `push` should not be used
  in production.
- **React 19 (2024–):** Server Actions are stable; `useActionState` replaces the
  experimental `useFormState`. `use()` can unwrap promises in Client Components.

## Cited links

- https://nextjs.org/docs/app — **Next.js App Router docs** — Server Components,
  Server Actions, Layouts, Suspense streaming, caching, and deployment options.
- https://authjs.dev/getting-started — **Auth.js v5 docs** — configuration,
  providers, middleware protection, database adapters, and session management.
- https://orm.drizzle.team/docs/overview — **Drizzle ORM docs** — schema definition,
  query builder, migrations with drizzle-kit, and transaction patterns.
- https://zod.dev — **Zod docs** — TypeScript-first schema validation; critical for
  validating Server Action inputs and API boundary data.
- https://react.dev/reference/rsc/server-actions — **React Server Actions reference**
  — canonical documentation for `"use server"`, progressive enhancement, and action
  composition patterns.
- https://vercel.com/docs/frameworks/nextjs — **Vercel + Next.js deployment docs**
  — Edge Runtime, Image Optimization, ISR, and environment variable management.
- https://www.owasp.org/index.php/OWASP_Top_Ten — **OWASP Top 10** — the
  authoritative checklist for web application security; relevant to Server Action
  input validation, auth, and session management.
