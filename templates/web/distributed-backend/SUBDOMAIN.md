# Web — distributed-backend sub-domain

A set of independently deployable microservices that communicate over
messaging infrastructure (queues, topics, event buses) and/or synchronous
HTTP/gRPC calls.
Each change is bounded to a single service. Consumer-driven contracts are
the integration safety net.

## Adopt if

- You are building or evolving a microservice architecture where services
  deploy independently.
- Services communicate via events/messages (Kafka, RabbitMQ, SQS, NATS) or
  synchronous HTTP/gRPC with explicit contracts.
- You need consumer-driven contract testing (Pact) to prevent integration
  breakage without end-to-end tests.
- The primary concerns are service boundaries, contract stability, event schema
  evolution, and eventual consistency.

## Skip if

- You own both frontend and backend in one deployable → use `fullstack-app`.
- You are building a single API service with no messaging → use `api-service`.
- You have a frontend → use `frontend-app` or `fullstack-app`.

## Addons that pair well

| Addon | When to add |
|---|---|
| `sentry-observability` | Add when distributed tracing and error aggregation across services are required |
| `openapi-rest` | Add when one or more services expose REST APIs (when the addon is available) |

## Agent team

| Agent | Role |
|---|---|
| `service-architect` | Read-only; designs service boundaries, messaging contracts, event schemas, and API surface — one service per design session |
| `service-implementer` | Read-write; implements changes bounded to ONE service per invocation; never edits another service's internals directly |
| `contract-reviewer` | Read-only; verifies consumer-driven contracts (Pact) are updated when a provider changes its API or event schema |
| `integration-tester` | Read-write on test files only; writes and runs integration and contract tests using Bash and test-file edits |
| `security-auditor` | Read-only; audits inter-service auth (mTLS, JWT), event payload validation, and network policy for OWASP issues |
| `design-critic` | Shared; reviews API and event schema design for consistency and developer ergonomics |
| `accessibility-auditor` | Shared; flags any documentation or developer-portal surface for WCAG issues |
