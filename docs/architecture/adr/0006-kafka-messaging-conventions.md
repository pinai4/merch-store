# 0006. Kafka messaging conventions

Status: accepted

## Context

State transitions crossing service boundaries go through Kafka. Without shared conventions each service would invent its own format and guarantees.

## Decision

- Messages are protobuf; schemas live in `shared`. No Schema Registry.
- Event topics are named after the owning service (`orders.events`, `payments.events`, `inventory.events`, `shipping.events`, `catalog.events`); the orchestrator sends commands to `<service>.commands`.
- Partition key is `order_id` for order-related topics.
- Delivery is at-least-once: transactional outbox on the producer side, idempotent consumers with a processed-messages table.
- Unprocessable messages go to a `<topic>.dlq` topic.
- The outbox and consumer helpers are implemented once in `platform`.

## Consequences

- Every Postgres-backed service carries outbox and processed-messages tables.
- Schema compatibility is guarded by `buf breaking` instead of a registry.
- Per-order ordering is guaranteed; global ordering is not.
