# Web domain pack

Curated harness content for teams building web products: frontend apps, full-stack platforms, API services, design systems, and distributed backends.

> **Status: curated three-layer pack.** The other eleven domains ship as v1 thin recipes today; curating them into three-layer packs is part of the maintainer roadmap.

## Sub-domain decision guide

| Sub-domain | Adopt if… |
|---|---|
| [`design-system`](design-system/) | You are building a shared component library or token set consumed by ≥2 apps; published via npm; stability and semver matter. |
| [`frontend-app`](frontend-app/) | You are building a client app (SPA or SSG) that consumes APIs it does not own; backend is a separate service or third-party. |
| [`fullstack-app`](fullstack-app/) | You own both frontend and backend in one deployable; Server Actions / server routes span the same repo. |
| [`api-service`](api-service/) | You are building one HTTP service with no UI; schema-first (OpenAPI or tRPC); consumed by other teams or apps. |
| [`distributed-backend`](distributed-backend/) | You are building ≥2 cooperating services; consumer-driven contracts, messaging / events, and service boundaries are first-class concerns. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance and the curated agent team.

## Addons

Addons are composable extras declared in `domain.addons` of your config. The sub-domain configs ship sensible defaults; override as needed.

| Addon | Pairs with | Purpose |
|---|---|---|
| `vite-spa` | `frontend-app` | Default: Vite + React SPA with client routing. |
| `nextjs` | `frontend-app`, `fullstack-app` | Next.js App Router; SSG, ISR, or hybrid rendering. |
| `astro` | `frontend-app`, `fullstack-app` | Astro static + island architecture for content-heavy sites. |
| `tailwind-shadcn` | most sub-domains | Default: Tailwind utilities + shadcn/ui component collection. |
| `drizzle` | `fullstack-app`, `api-service` | Drizzle ORM; type-safe SQL migrations. |
| `sanity-cms` | `frontend-app`, `fullstack-app` | Sanity headless CMS integration. |
| `authjs` | `frontend-app`, `fullstack-app` | Auth.js (NextAuth) credentials + OAuth. |
| `playwright-e2e` | any UI sub-domain | Page-Object E2E tests against the dev server. |
| `sentry-observability` | any | Sentry error monitoring + session replay. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`_addons/`](_addons/).

## Assemble

The sub-domain config is the assemble unit. Pass it directly to `assemble.sh`:

```bash
./assemble.sh web/frontend-app/harness.config.yml ./my-app
./assemble.sh web/fullstack-app/harness.config.yml ./my-platform
./assemble.sh web/api-service/harness.config.yml ./my-api
./assemble.sh web/design-system/harness.config.yml ./my-design-system
./assemble.sh web/distributed-backend/harness.config.yml ./my-services
```

## See also

- [`docs/how-to/pick-a-recipe.md`](../../docs/how-to/pick-a-recipe.md) — decision flow including the sub-domain choice.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain and addon catalog.
- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §1 — engineering guide for the web domain.
- [`references.md`](references.md) — curated web-platform dossier (refresh quarterly).
