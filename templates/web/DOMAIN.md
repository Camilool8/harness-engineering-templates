# Web domain pack

Curated harness content for teams building web products: frontend apps, full-stack
platforms, API services, design systems, and distributed backends.

## Sub-domain decision guide

| Sub-domain | Adopt if… |
|---|---|
| `design-system` | you are building a shared component library or token set consumed by ≥2 apps; published via npm; stability and semver matter |
| `frontend-app` | you are building a client app (SPA or SSG) that consumes APIs it does not own; backend is a separate service or third-party |
| `fullstack-app` | you own both frontend and backend in one deployable; Server Actions / server routes span the same repo |
| `api-service` | you are building one HTTP service with no UI; schema-first (OpenAPI or tRPC); consumed by other teams or apps |
| `distributed-backend` | you are building ≥2 cooperating services; consumer-driven contracts, messaging/events, and service boundaries are first-class concerns |

## Addons

Addons are composable extras declared in `domain.addons` of your config.
Available: `nextjs`, `vite-spa`, `tailwind-shadcn`, `drizzle`, `authjs`, `playwright-e2e`, `sentry-observability`.
See each addon's `MODULE.md` for adopt-if / skip-if guidance.

## Assemble

```bash
# pick a sub-domain as the assemble unit
./assemble.sh web/frontend-app/harness.config.yml ./my-app
./assemble.sh web/fullstack-app/harness.config.yml ./my-platform
./assemble.sh web/api-service/harness.config.yml ./my-api
```

## Reference material

- `templates/web/references.md` — curated web-platform dossier (refresh quarterly)
- `docs/HARNESS_ENGINEERING.md §1` — engineering guide for the web domain
