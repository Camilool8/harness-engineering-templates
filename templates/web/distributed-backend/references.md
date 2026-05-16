# Web — distributed-backend reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

### Service boundaries and design

- **Bounded context, not technical layer.** A microservice boundary follows a domain
  bounded context (DDD), not a technical tier. If two services need to share a
  database table to function, they are one service.
- **One service per deployment unit.** Each service has its own CI/CD pipeline,
  its own data store, and deploys independently. A shared deploy step that rebuilds
  multiple services defeats the purpose.
- Design service APIs (HTTP or event) as public contracts from day one — internal
  services break integration the same way public APIs do. Apply the same schema-first
  discipline as `api-service`.
- Use the **strangler fig** pattern to extract microservices from a monolith: route
  traffic to the new service while the monolith remains the fallback, then remove
  the monolith path once the new service is proven.

### Consumer-driven contracts with Pact

- **Pact** is the standard for consumer-driven contract testing. The consumer writes
  a contract (Pact file) that defines what it expects from the provider. The provider
  runs the Pact verifier in CI to confirm it still satisfies every consumer.
- Run Pact verification on every provider change and on every consumer change that
  touches the contract. Block merges on contract failures.
- Publish Pact files and verification results to a **Pact Broker** (or PactFlow)
  so the full consumer-provider matrix is visible. Use `can-i-deploy` before every
  production release.
- For event-driven services, use **AsyncAPI** + Pact message contracts to define
  the event schema that consumers expect.

### Messaging and event patterns

- **Idempotent consumers:** every message handler must tolerate receiving the same
  message more than once (at-least-once delivery is the default in Kafka, SQS, etc.).
  Use a deduplication key (message ID stored in a DB set or Redis) to skip duplicates.
- **Outbox pattern:** for reliable event publishing, write the event to an outbox
  table in the same DB transaction as the business mutation, then relay it to the
  broker asynchronously. Never publish directly to a broker inside a DB transaction.
- **Dead-letter queues (DLQ):** every queue or topic subscription must have a DLQ
  with alerting. A message that fails after N retries must not be silently discarded.
- **Event schema evolution:** use a schema registry (Confluent, AWS Glue) for Avro
  or Protobuf schemas. Forward-compatible changes (add optional field) are safe;
  breaking changes (remove field, change type) require a new schema version and
  a migration period.

### Observability in distributed systems

- **Distributed tracing** (OpenTelemetry → Jaeger/Tempo) is mandatory: every request
  and every message carries a `trace-id` from entry point to all downstream services.
  Without tracing, debugging production failures in a multi-service system is
  practically impossible.
- **Structured logging:** every service logs JSON to stdout with `trace_id`,
  `span_id`, `service`, `level`, and `message`. Log aggregation (Loki, CloudWatch)
  consumes and indexes these fields.
- **RED metrics** (Rate, Errors, Duration) per service endpoint and per queue
  consumer are the minimum SLI baseline. Expose them via Prometheus `/metrics` or
  an OTel metric exporter.

### Inter-service security

- **mTLS** for synchronous service-to-service HTTP/gRPC: both caller and callee
  present certificates. Use a service mesh (Linkerd, Istio) or a PKI sidecar
  to automate certificate rotation.
- **Short-lived JWTs** for service accounts: issue tokens with a 5-minute TTL
  from an internal auth server. Do not share the same JWT secret across services.
- **Network policy:** in Kubernetes, default-deny all ingress/egress; allow only
  the specific service-to-service paths required. Treat lateral movement as a
  threat model.

## Common gotchas / failure modes

- **Distributed monolith:** services that share a database or deploy together are
  a distributed monolith — they have the operational complexity of microservices
  with none of the independence benefits. Fix the coupling first.
- **Synchronous chains:** a chain of 5 synchronous HTTP calls with 99.9 % uptime
  each gives 99.5 % composite uptime. Long synchronous chains should be replaced
  with async messaging where possible.
- **Missing idempotency keys:** a consumer that processes a message twice without
  deduplication causes double payments, double notifications, or double records.
- **Schema evolution breaking consumers:** adding a required field to an event
  schema without a migration period breaks all consumers simultaneously. Always
  add fields as optional with a default.
- **No DLQ monitoring:** a silent DLQ fills up and nobody notices until a
  downstream report shows missing data days later.

## Version-sensitive notes

- **Pact 12.x (2025):** the V4 Pact specification supports message interactions
  and plugin-based transports (Avro, Protobuf). Use `pact-js` v13 for the
  latest Node.js consumer/provider API.
- **OpenTelemetry (stable 2024–):** `@opentelemetry/sdk-node` is stable. The
  Metrics and Logs signals are stable; use `@opentelemetry/auto-instrumentations-node`
  to instrument Express, Fastify, and Kafka clients automatically.
- **Kafka clients — KafkaJS vs Confluent:** KafkaJS is community-maintained and
  stable. Confluent's `@confluentinc/kafka-javascript` (2024) offers the official
  Confluent client for Node.js. Prefer KafkaJS for community ecosystem;
  Confluent for Confluent Cloud features (Schema Registry, exactly-once).
- **Kubernetes NetworkPolicy:** in K8s 1.30+, use `NetworkPolicy` with
  `policyTypes: [Ingress, Egress]`; the `default-deny-all` pattern requires an
  explicit policy for each allowed path.

## Cited links

- https://docs.pact.io — **Pact docs** — consumer-driven contracts, provider
  verification, Pact Broker, `can-i-deploy`, and message contracts for async services.
- https://opentelemetry.io/docs — **OpenTelemetry docs** — distributed tracing,
  metrics, and logging; Node.js SDK setup and auto-instrumentation.
- https://www.asyncapi.com/docs — **AsyncAPI docs** — event-driven API schema
  specification; covers Kafka, AMQP, WebSocket, and message contract definition.
- https://martinfowler.com/articles/microservices.html — **Martin Fowler — Microservices**
  — the canonical definition of bounded contexts, independent deployment, and
  service design principles.
- https://microservices.io/patterns — **Microservices.io patterns** — comprehensive
  catalogue of patterns: Saga, Outbox, CQRS, API Gateway, Circuit Breaker, and more.
- https://www.cncf.io/projects/linkerd — **Linkerd docs** — lightweight service mesh
  for mTLS, observability, and traffic management in Kubernetes.
- https://developer.confluent.io/patterns — **Confluent event streaming patterns**
  — Kafka-specific patterns: Outbox, DLQ, Schema Registry, exactly-once semantics.
