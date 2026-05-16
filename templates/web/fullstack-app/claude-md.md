## Web — fullstack-app

### No network boundary
- There is no separate API between the client and the server — they are one
  deployable. Use Server Components for data reads and Server Actions for
  mutations. Do not add a REST API route to call your own server.
- Server Actions are the typed boundary between client and server. Validate
  every input with Zod at the start of every Server Action — treat the caller
  as untrusted even when the form is rendered by your own Server Component.

### Data access
- Data access lives in the `data-layer-implementer` scope: schema, migrations,
  and typed query functions. The fullstack-implementer calls these functions
  and never writes raw SQL directly.
- Expand-contract migrations only. Never drop a column in the same migration
  that adds its replacement. Never run destructive DDL without a migration PR
  reviewed by a human.
- Wrap multi-step mutations in a `db.transaction()`. A Server Action that
  touches more than one table must be transactional.

### Auth
- Protect routes in `middleware.ts` using `auth()`. Never rely solely on a
  client-side redirect to secure a page — the server check is the real guard.
- Never log session tokens, JWTs, or OAuth secrets. Secrets live in env
  variables and are never committed to the repository.
- Use database sessions when server-side session invalidation is required.
  JWT-only sessions cannot be revoked before expiry.

### Client/server component boundary
- Default to Server Components. Add `"use client"` only when the component
  needs browser APIs, event handlers, or React state/effects.
- Never import a browser-only library (e.g., `window`, `document`) at the
  top level of a Server Component — it will fail at render time.
- Pass the session and any server-fetched data down as props from the Server
  Component into Client Components. Do not call an API route to re-read the
  session on the client.

### Verification loop
1. Run `npm run test` — Server Action and component tests must pass.
2. Run the Playwright E2E suite (if configured) against the dev server.
3. Run axe-core on every new or changed route — zero violations required.
4. Check Lighthouse budget: LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1.

### Done criteria
- A feature is not done until the Server Action is validated, the UI renders
  correct loading/error/empty states, auth is enforced server-side, and
  the test suite is green.
