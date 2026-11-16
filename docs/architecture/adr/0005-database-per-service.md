# 0005. Database per service

Status: accepted

## Context

Shared tables couple services and block independent work.

## Decision

Each service owns its data. One PostgreSQL instance per environment hosts a separate database and DB user per service; migrations live in the owning service. Other services get data through gRPC or events and keep snapshots where needed (orders stores price, title and shipping address at order time).

`cart` uses only Redis. `catalog` adds a Redis cache and MinIO for images (uploaded via presigned URLs). Catalog search uses PostgreSQL filters and full-text search. Money is stored as integer cents in a single currency.

## Consequences

- No cross-service joins; admin views are composed from per-service admin RPCs.
- Consistency between services is eventual and handled by the saga.
- A dedicated search engine or a `customers` service can be added later without reshaping existing data.
