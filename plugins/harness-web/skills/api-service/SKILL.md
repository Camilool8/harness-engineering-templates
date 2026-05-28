---
name: web-api-service
description: Conventions for a schema-first standalone HTTP API service with no UI. Use when .claude/HARNESS.toml selects web/api-service, or when building a REST/GraphQL service where the OpenAPI/AsyncAPI schema is the committed source of truth, with contract tests, request validation, and OWASP API Top 10 auth.
---

# Web — api-service

### Schema first
- The OpenAPI schema (`openapi.yaml`) is committed and reviewed before any
  handler code is written. If the schema is not approved, implementation
  does not start.
- The schema is the source of truth. When the schema and implementation
  disagree, the schema wins — fix the implementation, not the schema,
  unless the schema has a genuine error.
- Every breaking change (removed endpoint, renamed field, changed type)
  requires a new API version path (`/v2/`) or a major version bump.
  Additive changes (new optional field, new endpoint) are non-breaking.

### One service, no UI
- This service has no frontend. Do not add HTML rendering, templates,
  or static file serving. The only output is JSON (or the negotiated
  content type) and HTTP status codes.
- This service owns its own data store. It does not share a database
  table with another service. If another service needs the same data,
  it calls this service's API.

### Request validation and errors
- Every request body, query param, and path param is validated with Zod
  (or equivalent) at the handler boundary. Invalid input returns 400 with
  a structured error body — never a 500.
- Use RFC 9457 (`application/problem+json`) for all error responses:
  `type`, `title`, `status`, `detail`. Never leak stack traces or internal
  error messages in production.
- Log internally with a correlation ID (from `X-Correlation-ID` header or
  generated); return the correlation ID in the error response body.

### Auth and authorization
- Validate JWTs on every request: signature, `iss`, `aud`, `exp`, `nbf`.
  Reject invalid or expired tokens with 401.
- Authorization is code, not configuration: check the claim or role in
  the handler or a middleware that runs before the handler. 403 for
  insufficient permissions.
- Rate-limit every public endpoint. Return 429 with `Retry-After`.

### Contract compliance
- After every handler change, run the contract tests (Schemathesis, Dredd,
  or Pact provider verification) in CI. A contract test failure blocks merge.
- The `contract-reviewer` agent reviews every PR that touches a handler to
  confirm no schema drift has been introduced.

### Done criteria
- An endpoint is not done until: schema is updated, handler passes contract
  tests, input validation is in place, auth/z check is implemented, and the
  `api-security-auditor` has reviewed for OWASP API Top 10.
