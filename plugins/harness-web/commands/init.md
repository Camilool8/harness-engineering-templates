---
name: init
description: Select a Harness Web sub-domain and write the .claude/HARNESS.toml marker so the matching skills and hooks activate.
---
You are initializing the Harness Web pack for this project.
1. Ask which sub-domain fits, presenting these options (one line each from their SUBDOMAIN.md adopt-if):
   - **api-service** — a schema-first standalone REST or GraphQL API service with no frontend; the OpenAPI/AsyncAPI spec is committed before any handler code.
   - **design-system** — a shared React/Vue/Svelte component library consumed by two or more apps, published with semver discipline and developed in Storybook.
   - **distributed-backend** — independently deployable microservices that communicate over messaging or HTTP/gRPC, kept safe by consumer-driven contract tests.
   - **frontend-app** — a client-side SPA or SSG that consumes APIs it does not own; the network boundary is typed and mocked at the client.
   - **fullstack-app** — a single deployable that owns both frontend and backend (Next.js App Router, SvelteKit, Nuxt, Remix); the server is the typed boundary.
2. Write (creating if absent) to ${CLAUDE_PROJECT_DIR}/.claude/HARNESS.toml, MERGING (never overwrite other tables):

   [web]
   subdomain = "<choice>"
3. Confirm the selection and name the skills/hooks now armed. Do not edit the project's CLAUDE.md.
