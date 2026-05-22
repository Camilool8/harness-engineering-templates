# How to pick a recipe

You are starting a new project and need to choose which recipe to assemble. This guide walks you through the decision in three questions.

If you do not know yet what you are building, use `generic` and switch recipes later — the friction cost is one re-run of `assemble.sh` against the new config.

---

## Question 1 — Which domain?

Pick the closest match. When two fit, pick the one with the *stricter* domain gates — they are easier to relax than to add.

| Your project is… | Recipe | Headline gates |
|---|---|---|
| A website, SPA, SSR app, SaaS, or API service | `web` (three-layer pack) | accessibility-tree verify loop, lint+type PostToolUse |
| Data analysis, ML training, or an LLM/RAG application | `data` | unbounded-SQL block, leakage / p-hacking sentinels, eval ≠ code |
| Infrastructure-as-code, CI/CD, Kubernetes, cloud platform | `devops/<sub>` (three-layer pack — see [`templates/devops/DOMAIN.md`](../../templates/devops/DOMAIN.md)) | plan-before-apply, kubectl context guard, OIDC-only, cosign tlog required |
| Trading, accounting, payments, anything regulated as financial | `finance` | paper-by-default, two-key, immutable audit, double-entry |
| iOS / Android / React Native / Flutter app | `mobile` | simulator-in-the-loop, structured build logs |
| A game (Unity, Unreal, Godot, custom engine) | `game` | hot-reload + screenshot loop, asset-GUID awareness |
| Firmware, IoT, embedded Linux | `embedded` | never-flash-without-dry-run, HIL gate |
| Scientific computing, reproducible research, manuscripts | `scientific` | pinned-env reproducibility, manuscript pipeline |
| Offensive or defensive security work | `security` | engagement-scope authorization gate, red / blue separation |
| Content, marketing copy, brand-voice writing | `content` | brand-voice guard, schema.org validation |
| Customer support, ops automation, refund flows | `ops` | refund threshold gate, drafter ≠ publisher |
| Not sure yet | `generic` | base only — graduate later |

Full catalog: [`reference/domains.md`](../reference/domains.md).

---

## Question 2 — Three-layer or thin recipe?

Today **`web/`** and **`devops/`** are three-layer packs. The other ten domains are v1 thin recipes — they work, they pass tests, they install domain-specific gates, but they have no sub-domains, no addons, and no curated agent teams yet.

**If you picked `web/`**, continue to question 3.

**If you picked anything else**, you have a single recipe to assemble:

```bash
./templates/assemble.sh templates/<domain>/harness.config.yml ./my-project
```

You can still pick and discard cross-cutting modules (memory, progress, methodology, orchestration, safety, HITL) by editing the recipe's `harness.config.yml` first. See [`customize-modules.md`](customize-modules.md).

---

## Question 3 — Which web sub-domain?

The `web/` pack has five sub-domains. Each is a distinct deliverable shape.

| Sub-domain | Adopt if… |
|---|---|
| **`design-system`** | You are building a shared component library or token set consumed by ≥2 apps. Published via npm. Stability and semver matter. |
| **`frontend-app`** | You are building a client app (SPA or SSG) that consumes APIs it does not own. Backend is a separate service or third-party. |
| **`fullstack-app`** | You own both frontend and backend in one deployable. Server Actions / server routes span the same repo. |
| **`api-service`** | You are building one HTTP service with no UI. Schema-first (OpenAPI or tRPC). Consumed by other teams or apps. |
| **`distributed-backend`** | You are building ≥2 cooperating services. Consumer-driven contracts, messaging / events, and service boundaries are first-class concerns. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance. Browse:

- [`templates/web/design-system/SUBDOMAIN.md`](../../templates/web/design-system/SUBDOMAIN.md)
- [`templates/web/frontend-app/SUBDOMAIN.md`](../../templates/web/frontend-app/SUBDOMAIN.md)
- [`templates/web/fullstack-app/SUBDOMAIN.md`](../../templates/web/fullstack-app/SUBDOMAIN.md)
- [`templates/web/api-service/SUBDOMAIN.md`](../../templates/web/api-service/SUBDOMAIN.md)
- [`templates/web/distributed-backend/SUBDOMAIN.md`](../../templates/web/distributed-backend/SUBDOMAIN.md)

Then assemble:

```bash
./templates/assemble.sh templates/web/<sub-domain>/harness.config.yml ./my-project
```

---

## Question 4 — Which addons?

Addons are *optional* extras. The sub-domain config pre-fills a sensible default list under `domain.addons`. You can edit the list before assembling.

| Addon | Pairs with | When to add |
|---|---|---|
| `vite-spa` | `frontend-app` | Default: Vite + React SPA with client routing. |
| `nextjs` | `frontend-app`, `fullstack-app` | When you need SSG, ISR, or hybrid rendering. |
| `astro` | `frontend-app`, `fullstack-app` | Content-heavy sites; island architecture. |
| `tailwind-shadcn` | most sub-domains | Default: Tailwind + shadcn/ui. |
| `drizzle` | `fullstack-app`, `api-service` | Type-safe SQL with migrations. |
| `sanity-cms` | `frontend-app`, `fullstack-app` | Headless CMS for editorial content. |
| `authjs` | `frontend-app`, `fullstack-app` | Auth.js (NextAuth) credentials + OAuth. |
| `playwright-e2e` | any UI sub-domain | Page-Object E2E tests against the dev server. |
| `sentry-observability` | any | Sentry error monitoring + session replay. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`templates/web/_addons/`](../../templates/web/_addons/).

---

## After picking

You have your config path and (optionally) your addon list. Edit `templates/<your-config-path>/harness.config.yml` if you want to change a default, then assemble:

```bash
./templates/assemble.sh templates/<your-config-path>/harness.config.yml ./my-project
```

Open [`getting-started.md`](../tutorials/getting-started.md) from step 4 onward if you want a walk-through of what happens next.

---

## See also

- [`reference/harness-config.md`](../reference/harness-config.md) — every config key.
- [`reference/domains.md`](../reference/domains.md) — full domain catalog.
- [`customize-modules.md`](customize-modules.md) — change a recipe's defaults, including for v1 thin recipes.
