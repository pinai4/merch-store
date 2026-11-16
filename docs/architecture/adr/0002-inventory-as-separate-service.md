# 0002. Inventory is a separate service

Status: accepted

## Context

Stock could live inside `catalog`. The two have different profiles: catalog is read-heavy and cacheable; stock is transactional and contended.

## Decision

Create a dedicated `inventory` service that owns stock levels per SKU and reservations with a TTL. Stock is reserved when the order is created, before payment; payment commits the reservation, failure or expiry releases it. Overselling is prevented by an atomic conditional `UPDATE ... WHERE available >= qty` in one transaction per order.

## Consequences

- Catalog can be cached aggressively without stale-stock risks in the write path.
- Checkout becomes a distributed transaction and needs a saga (see 0003).
- The product model is `Product → Variant (SKU)`; the SKU is the shared identifier across catalog, cart, orders and inventory.
