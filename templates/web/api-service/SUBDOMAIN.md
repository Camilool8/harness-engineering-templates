# Web — api-service sub-domain

A schema-first HTTP API service with no UI.
The OpenAPI/AsyncAPI schema is the source of truth — implementation is
derived from the schema, not the reverse. The service owns its own data
and is consumed by one or more clients via a stable typed contract.

## Adopt if

- You are building a standalone REST or GraphQL API service with no frontend.
- You follow a schema-first workflow: the spec is agreed and committed before
  any handler code is written.
- You need formal contract tests (Pact, Dredd, Schemathesis) to verify that
  the implementation matches the schema.
- The primary concerns are schema stability, input validation, auth/z, and
  OWASP API Top 10 compliance.

## Skip if

- You own both frontend and backend in one deployable → use `fullstack-app`.
- You are building multiple independently deployable services → use
  `distributed-backend`.
- You have a UI → use `frontend-app` or `fullstack-app`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `openapi-rest` | Add when the OpenAPI REST addon is available (Phase 6); provides typed route generation and contract testing tooling |
| `sentry-observability` | Add when error/performance monitoring is required in production |

## Agent team

| Agent | Role |
|---|---|
| `api-architect` | Read-only; designs the OpenAPI schema, resource model, auth/z strategy, and error contract before any handler is written |
| `api-implementer` | Read-write; implements handlers, middleware, and validation bounded to files named in the architect's plan |
| `contract-reviewer` | Read-only; verifies that the implementation matches the OpenAPI schema and that no breaking changes are introduced without a version bump |
| `api-security-auditor` | Read-only; audits every endpoint for OWASP API Top 10: broken auth, excessive data exposure, injection, rate limiting |
| `design-critic` | Shared; reviews API design for consistency, naming, and developer ergonomics |
| `accessibility-auditor` | Shared; flags any documentation surface (OpenAPI UI, developer portal) for WCAG issues |
