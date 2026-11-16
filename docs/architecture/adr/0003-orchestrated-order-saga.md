# 0003. Order saga is orchestrated by `orders`

Status: accepted

## Context

Placing an order spans inventory, payments and shipping. The process can be coordinated by choreography (services react to each other's events) or by an orchestrator.

## Decision

`orders` orchestrates the saga. It owns the order state machine (`PENDING → RESERVED → AWAITING_PAYMENT → PAID → SHIPPED → DELIVERED`, terminal `CANCELLED` and `REFUNDED`), sends commands over Kafka and reacts to reply events. Each step has a deadline stored with the order; a background worker compensates overdue orders, reconciling with Stripe before cancelling an order in the payment step.

Checkout is asynchronous for the client: `POST /orders` with an idempotency key returns the order in `PENDING`; further progress arrives over SSE.

## Consequences

- The whole process is readable in one place and compensations are explicit.
- `orders` is coupled to the command contracts of the participating services.
- Participants stay simple: handle a command, emit an event.
