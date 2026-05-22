# Reference: domain catalog

Every domain pack under [`templates/`](../../templates/). Pick the closest match to your project; the recipe pre-fills the manifest and adds the domain-specific hooks and skills.

Two shapes today:

- **Three-layer pack** — domain → sub-domain → addons. `web/` and `devops/` ship this layout. The sub-domain config is the assemble unit.
- **v1 thin recipe** — a single `harness.config.yml` plus a `files/` tree. Ten of the twelve domains ship this shape today, pending curation into three-layer packs.

---

## The full catalog

| Domain | Status | Recipe path | Headline gates |
|---|---|---|---|
| **web** | curated (3-layer) | [`templates/web/<sub>/harness.config.yml`](../../templates/web/) | accessibility-tree verify loop, lint+type PostToolUse |
| **data** | v1 thin | [`templates/data/harness.config.yml`](../../templates/data/) | unbounded-SQL block, leakage / p-hacking sentinels, eval ≠ code |
| **devops** | curated (3-layer) | [`templates/devops/<sub>/harness.config.yml`](../../templates/devops/) | plan-before-apply, kubectl context guard, OIDC-only, cosign tlog required |
| **finance** | v1 thin | [`templates/finance/harness.config.yml`](../../templates/finance/) | paper-by-default, two-key, immutable audit, double-entry |
| **mobile** | v1 thin | [`templates/mobile/harness.config.yml`](../../templates/mobile/) | simulator-in-the-loop, structured build logs |
| **game** | v1 thin | [`templates/game/harness.config.yml`](../../templates/game/) | hot-reload + screenshot loop, asset-GUID awareness |
| **embedded** | v1 thin | [`templates/embedded/harness.config.yml`](../../templates/embedded/) | never-flash-without-dry-run, HIL gate |
| **scientific** | v1 thin | [`templates/scientific/harness.config.yml`](../../templates/scientific/) | pinned-env reproducibility, manuscript pipeline |
| **security** | v1 thin | [`templates/security/harness.config.yml`](../../templates/security/) | engagement-scope authorization gate, red / blue separation |
| **content** | v1 thin | [`templates/content/harness.config.yml`](../../templates/content/) | brand-voice guard, schema.org validation |
| **ops** | v1 thin | [`templates/ops/harness.config.yml`](../../templates/ops/) | refund threshold gate, drafter ≠ publisher |
| **generic** | base-only | [`templates/generic/harness.config.yml`](../../templates/generic/) | none beyond `_base`. Start here if unsure. |

`generic` is intentionally not a domain pack — it ships base-only and is not slated for graduation to three-layer.

---

## The `web/` pack (curated)

The reference for the three-layer shape. Five sub-domains today:

| Sub-domain | Adopt if… | Assemble |
|---|---|---|
| [`design-system`](../../templates/web/design-system/) | Shared component library or token set consumed by ≥2 apps; published via npm; stability and semver matter. | `./assemble.sh web/design-system/harness.config.yml .` |
| [`frontend-app`](../../templates/web/frontend-app/) | Client app (SPA or SSG) that consumes APIs it does not own; backend is separate or third-party. | `./assemble.sh web/frontend-app/harness.config.yml .` |
| [`fullstack-app`](../../templates/web/fullstack-app/) | You own both frontend and backend in one deployable; Server Actions / server routes span the same repo. | `./assemble.sh web/fullstack-app/harness.config.yml .` |
| [`api-service`](../../templates/web/api-service/) | One HTTP service with no UI; schema-first (OpenAPI or tRPC); consumed by other teams or apps. | `./assemble.sh web/api-service/harness.config.yml .` |
| [`distributed-backend`](../../templates/web/distributed-backend/) | ≥2 cooperating services; consumer-driven contracts, messaging/events, service boundaries are first-class. | `./assemble.sh web/distributed-backend/harness.config.yml .` |

### `web/` addons

Composable extras declared in `domain.addons`. Each is a module-shaped directory under [`templates/web/_addons/<addon>/`](../../templates/web/_addons/).

| Addon | Pairs with | Purpose |
|---|---|---|
| `vite-spa` | `frontend-app` | Vite + React SPA defaults; TanStack Router or React Router. |
| `nextjs` | `frontend-app`, `fullstack-app` | Next.js App Router; SSG, ISR, or hybrid rendering. |
| `astro` | `frontend-app`, `fullstack-app` | Astro static + island architecture for content-heavy sites. |
| `tailwind-shadcn` | `frontend-app`, `fullstack-app`, `design-system` | Tailwind utilities + shadcn/ui component collection. |
| `drizzle` | `fullstack-app`, `api-service` | Drizzle ORM; type-safe SQL migrations. |
| `sanity-cms` | `frontend-app`, `fullstack-app` | Sanity headless CMS integration. |
| `authjs` | `frontend-app`, `fullstack-app` | Auth.js (NextAuth) credentials + OAuth flows. |
| `playwright-e2e` | any sub-domain with a UI | Playwright + Page Object E2E tests against the dev server. |
| `sentry-observability` | any | Sentry error monitoring + session replay. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance.

---

## The `devops/` pack (curated)

Four sub-domains, partitioned by deliverable shape — what you ship:

| Sub-domain | Adopt if… | Assemble |
|---|---|---|
| [`infrastructure`](../../templates/devops/infrastructure/) | Cloud resources via IaC — reusable modules and/or operated environments. Workflow shape is selected by addon. | `./assemble.sh devops/infrastructure/harness.config.yml .` |
| [`kubernetes-platform`](../../templates/devops/kubernetes-platform/) | A cluster (or fleet) + GitOps + addons + paved-path manifests for app teams. | `./assemble.sh devops/kubernetes-platform/harness.config.yml .` |
| [`cicd-platform`](../../templates/devops/cicd-platform/) | Reusable workflows / pipeline templates / release engineering / supply-chain attestation. | `./assemble.sh devops/cicd-platform/harness.config.yml .` |
| [`observability-sre`](../../templates/devops/observability-sre/) | Telemetry, dashboards, alerts, SLOs/error budgets, on-call automation; agents reach prod via MCP. | `./assemble.sh devops/observability-sre/harness.config.yml .` |

### `devops/` addons

Fifteen addons in the initial set, grouped by category:

| Category | Addons |
|---|---|
| Cloud | `aws` · `azure` · `gcp` |
| IaC | `terraform` · `pulumi` |
| Workflow-shape | `reusable-modules` · `multi-env-state` |
| CI/CD | `github-actions` · `azure-devops` · `gitlab-ci` |
| Kubernetes | `argo-cd` · `kyverno` |
| Observability | `opentelemetry` · `datadog` |
| Supply chain | `sigstore-cosign` |

Three shared agents install with any devops sub-domain: `incident-commander`, `supply-chain-auditor`, `cost-auditor`. Additional specialists arrive via the sub-domain and via addons that contribute agents (e.g. `argo-cd` ships `gitops-promoter`; `kyverno` ships `policy-author`).

---

## The v1 thin recipes

Ten domains ship as thin recipes today. They are functionally complete — they assemble, they pass tests, and they install the domain's gating hooks — but they have not yet been curated into the three-layer shape:

- One `harness.config.yml` at the recipe root.
- One `claude-md.md` snippet.
- A `files/` tree with domain-specific hooks and skills.
- No `DOMAIN.md`, no sub-domains, no `_addons/`.

Each recipe's `README.md` documents what it picks, what gates it adds, and what anti-patterns it prevents. See:

- [`templates/data/README.md`](../../templates/data/README.md) — data & ML
- [`templates/finance/README.md`](../../templates/finance/README.md) — quant, trading, accounting
- [`templates/mobile/README.md`](../../templates/mobile/README.md) — iOS / Android / React Native
- [`templates/game/README.md`](../../templates/game/README.md) — game dev
- [`templates/embedded/README.md`](../../templates/embedded/README.md) — firmware / IoT
- [`templates/scientific/README.md`](../../templates/scientific/README.md) — research & manuscripts
- [`templates/security/README.md`](../../templates/security/README.md) — offensive + defensive security
- [`templates/content/README.md`](../../templates/content/README.md) — content & marketing
- [`templates/ops/README.md`](../../templates/ops/README.md) — customer support & ops
- [`templates/generic/README.md`](../../templates/generic/README.md) — base-only starter

Curating a thin recipe into a three-layer pack is part of the maintainer roadmap; external contributions add modules, addons, and sub-domains inside an already-curated pack rather than driving pack-shape evolution.

---

## See also

- [`how-to/pick-a-recipe.md`](../how-to/pick-a-recipe.md) — decision flow for "which recipe fits my project".
- [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) — the master reference with per-domain depth.
- [`reference/harness-config.md`](harness-config.md) — the manifest each recipe pre-fills.
- [`reference/modules.md`](modules.md) — the cross-cutting modules each recipe layers on top of `_base`.
