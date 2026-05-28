---
name: web-distributed-backend
description: Conventions for independently deployable microservices over messaging or HTTP/gRPC. Use when .claude/HARNESS.toml selects web/distributed-backend, or when working on a microservice architecture with consumer-driven contracts (Pact), the Outbox pattern, idempotent consumers, DLQs, and mTLS inter-service auth.
---

# Web — distributed-backend

### One service per change
- Every implementation task is bounded to ONE service. The `service-implementer`
  agent must not edit another service's source files in the same invocation.
  Cross-service coordination is a separate, explicit task.
- Each service deploys independently. A change that requires two services to
  deploy together is a design problem — fix the coupling, do not coordinate deploys.

### Service boundaries and contracts
- A service owns its data store exclusively. It does not share a database table
  or schema with another service. If another service needs data, it calls this
  service's published API or subscribes to its events.
- Service APIs (REST, gRPC, events) are public contracts from day one. Apply
  schema-first discipline: define the contract before implementing it.
- Consumer-driven contracts (Pact) protect every integration point. When a
  provider changes its API or event schema, the `contract-reviewer` agent
  verifies that existing Pact files still pass before the change ships.

### Messaging and event discipline
- All event producers use the Outbox pattern: write the event to the outbox
  table in the same DB transaction as the business mutation; relay asynchronously.
  Never publish directly to a broker inside a DB transaction.
- Every message consumer is idempotent. Store the message ID and skip duplicates.
  At-least-once delivery is the default — assume duplicates will arrive.
- Every queue or topic subscription has a Dead Letter Queue (DLQ) with alerting.
  A message that fails after retries goes to the DLQ, not into the void.

### Observability
- Every service propagates the `traceparent` header (W3C Trace Context) on all
  outbound calls and message publishes. Never drop the trace context.
- Log structured JSON with `trace_id`, `span_id`, `service`, `level`, `message`.
- Expose RED metrics (Rate, Errors, Duration) per endpoint and per consumer.

### Security
- Inter-service HTTP and gRPC use mTLS. A service that accepts unauthenticated
  internal traffic is a misconfiguration.
- Service-account JWTs have a maximum TTL of 15 minutes. Rotate and re-issue;
  do not extend expiry.

### Done criteria
- A service change is not done until: the Pact provider verification passes,
  integration tests are green, the DLQ and idempotency checks are in place,
  and the `security-auditor` has reviewed the inter-service auth.
