# Web — fullstack-app sub-domain

A single deployable that owns both the frontend and the backend.
The development loop spans client components, server actions/templates, and the
data access layer — all in one repository. There is no external API contract:
the server is the typed boundary.

## Adopt if

- You own both frontend and backend in one deployable (e.g., Next.js App Router,
  SvelteKit, Nuxt, Remix).
- Server Actions or server-rendered templates are your mutation primitives —
  there is no separate REST/GraphQL API between your own client and server.
- Auth and data access live in the same codebase and deploy together.
- The primary concerns are seamless client-server data flow, auth integration,
  and safe data-access patterns.

## Skip if

- The backend is a separate service or third-party → use `frontend-app`.
- You are building a shared component library → use `design-system`.
- You have no UI and are building a pure HTTP service → use `api-service`.
- You need independently deployable microservices → use `distributed-backend`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `nextjs` | Default: Next.js App Router with Server Components and Server Actions |
| `tailwind-shadcn` | Default: Tailwind utility classes + shadcn/ui component collection |
| `drizzle` | Default: Drizzle ORM with typed schema and expand-contract migrations |
| `authjs` | Default: Auth.js session handling with OAuth or credentials providers |
| `playwright-e2e` | Add for page-object E2E tests against the running dev server |
| `sentry-observability` | Add when error monitoring and session replay are required |

## Agent team

| Agent | Role |
|---|---|
| `fullstack-architect` | Read-only; plans the full client-to-database loop: routes, Server Actions, data schema, auth boundaries, and acceptance criteria |
| `fullstack-implementer` | Read-write; implements UI components and Server Actions bounded to named files; runs the test suite |
| `data-layer-implementer` | Read-write; implements schema changes, migrations, and data access functions — must not run destructive SQL |
| `security-auditor` | Read-only; audits auth flows, data access patterns, and Server Action inputs for OWASP Top 10 and supply-chain issues |
| `design-critic` | Shared; reviews rendered UI for visual hierarchy, spacing, and UX quality |
| `accessibility-auditor` | Shared; WCAG 2.2 AA audit via axe-core; blocks "done" on any violation |
