# How to pick a plugin pack and sub-domain

You are starting a new project and need to choose which plugin pack to install and which sub-domain to initialise. This guide walks you through the decision in three questions.

The marketplace ships four curated domain packs: `harness-web`, `harness-data`, `harness-devops`, `harness-mobile`. Each has sub-domains (and most have addons). Installing any pack pulls in `harness-base` — the four non-negotiable hooks — automatically. If your work does not fit a domain pack, you can install `harness-base` indirectly through the closest pack and skip its sub-domain gates, or use the base-only [eject path](../reference/eject.md).

Add the marketplace once before any of the steps below:

```
/plugin marketplace add Camilool8/harness-engineering-templates
```

---

## Question 1 — Which pack?

Pick the closest match. When two fit, pick the one with the *stricter* domain gates — they are easier to relax than to add.

| Your project is… | Install | Headline gates |
|---|---|---|
| A website, SPA, SSR app, SaaS, or API service | `harness-web` | accessibility-tree verify loop, lint+type PostToolUse |
| Data analysis, ML training, or an LLM/RAG application | `harness-data` | unbounded-SQL block, leakage / p-hacking sentinels, audit-logged warehouse query, eval ≠ code |
| Infrastructure-as-code, CI/CD, Kubernetes, cloud platform | `harness-devops` | plan-before-apply, kubectl context guard, OIDC-only, cosign tlog required |
| iOS / Android / React Native / Flutter app | `harness-mobile` | simulator-in-the-loop, audit-logged mobile build, block-static-store-creds, 5.1.2(i) AI disclosure |
| None of the above | any pack, then skip its `init` | the four base non-negotiables, no domain gates |

Install your pack with:

```
/plugin install harness-<domain>@harness-engineering
```

Full plugin catalog: [`reference/plugins.md`](../reference/plugins.md). Full domain catalog: [`reference/domains.md`](../reference/domains.md). If your domain isn't covered, contributions of new packs are welcome — see [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

---

## Question 2 — Which sub-domain?

After installing, run the pack's `init` command. It presents the sub-domains, asks which fits, and writes your choice into `.claude/HARNESS.toml`:

```
/harness-<domain>:init
```

You do **not** edit a YAML file to pick a sub-domain — `init` owns the `[<domain>] subdomain = "…"` line in `.claude/HARNESS.toml`. (Editing a config to select a sub-domain is the eject path; see the note at the end.)

Continue to the matching question below to choose your answer before running `init`:

- **`harness-web`** → question 3
- **`harness-data`** → question 4
- **`harness-devops`** → its four sub-domains are `infrastructure`, `kubernetes-platform`, `cicd-platform`, `observability-sre` (see [`templates/devops/DOMAIN.md`](../../templates/devops/DOMAIN.md))
- **`harness-mobile`** → question 5

---

## Question 3 — Which web sub-domain?

The `harness-web` pack has five sub-domains. Each is a distinct deliverable shape.

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

Then initialise:

```
/plugin install harness-web@harness-engineering
/harness-web:init        # choose your sub-domain when prompted
```

---

## Question 4 — Which data sub-domain?

**Data work?** Pick the sub-domain that matches your deliverable shape:

- A notebook explaining a question → `data-analyst-notebook`
- A trained model + eval suite → `ml-pipeline`
- An LLM product → `llm-app`
- dbt models with contracts + semantic layer → `analytics-engineering`

```
/plugin install harness-data@harness-engineering
/harness-data:init
```

See [`templates/data/DOMAIN.md`](../../templates/data/DOMAIN.md) for the full decision guide.

---

## Question 5 — Which mobile sub-domain?

Pick by **team composition and platform targets**, not by framework popularity.

- **JS / TS team, cross-platform iOS + Android** → `react-native-expo`. Deepest AI-tooling MCP coverage in 2026 (XcodeBuildMCP + Expo MCP + Sentry MCP + Firebase MCP, all OAuth-first); OTA JS updates via EAS Update.
- **Native team, iOS-only or iOS-first** → `native-ios`. Foundation Models, App Intents, deep Apple Intelligence integration.
- **Native team, Android-only or Android-first** → `native-android`. Gemini Nano / AICore, foreground services, Photo Picker.
- **Design-led cross-platform with heavy custom animation** → `flutter-app`. Impeller renderer; Riverpod state.

```
/plugin install harness-mobile@harness-engineering
/harness-mobile:init
```

If you need shared business logic with platform-native UI per OS, build with `native-ios` + `native-android` and document the shared layer manually; the Kotlin Multiplatform sub-domain is a v2 graduation target.

See [`templates/mobile/DOMAIN.md`](../../templates/mobile/DOMAIN.md) for the full decision guide.

---

## Question 6 — Which addons?

Addons are *optional* extras curated under each domain pack. In the plugin flow, the sub-domain skills know their default addon set and will pull the right conventions in as you work; you add an addon's MCP snippet or scaffolding when you actually adopt it. The web pack's addons:

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

Install the pack and run `init`. That is the whole flow:

```
/plugin install harness-<domain>@harness-engineering
/harness-<domain>:init
```

Open [`getting-started.md`](../tutorials/getting-started.md) for a step-by-step walk-through of what happens after, including watching a hook fire.

---

## Eject path

If you want committed `.claude/` artifacts in your repo instead of installed plugins, the bash assembler produces the same content from the mirrored `templates/` tree. The equivalent of "install `harness-web`, init `frontend-app`" is one command:

```bash
./templates/assemble.sh templates/web/frontend-app/harness.config.yml ./my-project
```

Here the sub-domain choice is the config path you pass, and opt-in disciplines are config booleans rather than `HARNESS.toml` flags. See [`reference/eject.md`](../reference/eject.md) and [`reference/harness-config.md`](../reference/harness-config.md).

---

## See also

- [`reference/plugins.md`](../reference/plugins.md) — the plugin catalog and `HARNESS.toml` flags.
- [`reference/domains.md`](../reference/domains.md) — full domain catalog.
- [`customize-modules.md`](customize-modules.md) — arm opt-in hooks, set permissions, wire MCP servers.
- [`reference/eject.md`](../reference/eject.md) — the assembler, for committed artifacts.
