# Architecture Decision Records

Each record is short: context, decision, consequences. New decisions get the next number; a superseded record is kept and marked as such.

| # | Decision |
|---|---|
| [0001](0001-monorepo-with-shared-and-platform-modules.md) | Monorepo with per-service modules plus `shared` and `platform` |
| [0002](0002-inventory-as-separate-service.md) | Inventory is a separate service |
| [0003](0003-orchestrated-order-saga.md) | Order saga is orchestrated by `orders` |
| [0004](0004-envoy-grpc-json-transcoding.md) | Envoy with gRPC-JSON transcoding as the API gateway |
| [0005](0005-database-per-service.md) | Database per service |
| [0006](0006-kafka-messaging-conventions.md) | Kafka messaging conventions |
| [0007](0007-stripe-hosted-checkout.md) | Stripe Hosted Checkout with webhooks as source of truth |
| [0008](0008-authentication-model.md) | Authentication and authorization model |
| [0009](0009-local-and-cluster-deployment.md) | Compose for infrastructure, Helm for Kind and staging |
| [0010](0010-taskfile.md) | Taskfile as the task runner |
| [0011](0011-envoy-in-local-compose.md) | Envoy runs in local compose (amends 0009) |
