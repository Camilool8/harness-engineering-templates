# Web — api-service reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### Schema-first API design

- **OpenAPI 3.1** is the standard for REST API contracts. Write the schema first
  (`openapi.yaml` or `openapi.json`) and commit it before writing any handler code.
  Use `openapi-ts` or `orval` to generate TypeScript types from the schema for both
  server routes and client SDKs.
- Treat the OpenAPI schema as a public API: a field rename, a type change, or a
  removed endpoint is a breaking change requiring a major version bump or a new API
  version path (`/v2/`).
- Validate requests and responses at runtime using the schema — tools like
  `@hono/zod-openapi`, `typebox`, or `@fastify/swagger` generate both the OpenAPI
  spec and runtime validators from a single type definition.
- Use `schemathesis` or `Dredd` for contract testing: run the schema against the
  live server to catch handler deviations automatically in CI.

### Request validation and error contracts

- **Zod** or **TypeBox** at the handler level: every request body, query param, and
  path param is parsed through a typed schema. An invalid input returns 400 with a
  structured error body — never a 500.
- Standardise error responses across all endpoints. The API problem format
  (RFC 9457 / `application/problem+json`) is the IETF standard: `type`, `title`,
  `status`, `detail`, `instance`. Adopt it across the service.
- Never leak stack traces or internal error messages in production responses. Log
  internally with a correlation ID; return the correlation ID to the caller for
  support tracing.

### Authentication and authorization

- Use JWTs (RS256 or ES256) signed by a dedicated auth server — never HS256 with a
  shared secret in a multi-service environment. Validate the signature, `iss`, `aud`,
  `exp`, and `nbf` claims on every request.
- For service-to-service auth, use mTLS or short-lived JWTs issued by a service
  account. Do not reuse user-facing tokens for inter-service calls.
- Authorization is code, not configuration: check the claim or role in the handler
  or a middleware that runs before the handler. Reject at the boundary, not deep in
  a service function.
- Rate-limit every public endpoint. Use a token bucket or sliding window algorithm.
  Return `429 Too Many Requests` with a `Retry-After` header.

### OWASP API Security Top 10

1. **Broken Object-Level Authorization (BOLA):** always verify that the requesting
   user is authorized to access the specific object, not just the resource type.
2. **Broken Authentication:** use short-lived tokens, validate all claims, and
   rotate secrets on suspected compromise.
3. **Broken Object Property Level Authorization:** never return more fields than the
   caller is authorized to see — use response allowlists, not blocklists.
4. **Unrestricted Resource Consumption:** enforce pagination, rate limits, and
   maximum page sizes on every collection endpoint.
5. **Broken Function Level Authorization:** treat every HTTP method on every route
   as requiring an explicit authorization check.

### TypeScript API frameworks

- **Hono** (2024–) is the rising standard for lightweight, edge-compatible APIs.
  `@hono/zod-openapi` generates the OpenAPI schema and Zod validators from one
  route definition.
- **Fastify** remains the choice for high-throughput Node.js APIs requiring
  full-featured plugin architecture (lifecycle hooks, DI containers, serialization).
- **tRPC v11** (2025–) is the right choice when the caller is a TypeScript client
  you control (fullstack-app or a known consumer) and you want end-to-end type safety
  without a REST contract.

## Common gotchas / failure modes

- **Schema drift:** the OpenAPI schema diverges from the running implementation over
  time. Only automated contract tests (Schemathesis, Dredd) running in CI catch this.
- **Over-permissive CORS:** `Access-Control-Allow-Origin: *` on an authenticated
  API is a security misconfiguration. Allowlist known origins explicitly.
- **Missing pagination on collection endpoints:** returning unbounded lists causes
  memory exhaustion under load. Default page size + maximum page size are required.
- **Logging sensitive request data:** logging full request bodies in development and
  forgetting to redact in production leaks credentials and PII.
- **Skipping idempotency on mutations:** POST endpoints that trigger payments, sends,
  or other irreversible actions need an idempotency key to prevent duplicate execution.

## Version-sensitive notes

- **OpenAPI 3.1 (2021–):** aligned with JSON Schema 2020-12. `nullable` is removed;
  use `type: ['string', 'null']` instead. Discriminated unions via `oneOf`/`anyOf`
  with `discriminator` are improved.
- **Hono 4.x (2024–):** `@hono/zod-openapi` is stable; the `OpenAPIHono` class
  generates the spec automatically from typed route definitions.
- **tRPC v11 (2025):** supports React Query v5 and `useSuspenseQuery`. Adapters
  for Hono, Fastify, and Cloudflare Workers are stable.
- **Zod 3.x:** `.openapi()` method via `zod-openapi` or `@asteasolutions/zod-to-openapi`
  extends Zod schemas with OpenAPI metadata without changing runtime behaviour.

## Cited links

- https://swagger.io/specification — **OpenAPI 3.1 specification** — authoritative
  reference for schema syntax, components, security schemes, and response objects.
- https://hono.dev/docs — **Hono docs** — lightweight API framework with built-in
  OpenAPI + Zod integration, edge runtime support, and middleware ecosystem.
- https://schemathesis.readthedocs.io — **Schemathesis docs** — property-based
  contract testing against a running API from an OpenAPI schema; CI integration.
- https://owasp.org/API-Security — **OWASP API Security Top 10** — canonical
  checklist for API-specific vulnerabilities with mitigation guidance.
- https://www.rfc-editor.org/rfc/rfc9457 — **RFC 9457 — Problem Details for HTTP APIs**
  — the IETF standard error response format (`application/problem+json`).
- https://trpc.io/docs — **tRPC v11 docs** — end-to-end type-safe APIs for
  TypeScript consumers; v11 React Query integration and Hono adapter.
- https://zod.dev — **Zod docs** — schema definition and runtime validation; the
  standard for request body and query param validation in TypeScript APIs.
