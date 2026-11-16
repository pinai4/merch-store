# 0007. Stripe Hosted Checkout with webhooks as source of truth

Status: accepted

## Context

Stripe offers a hosted Checkout page or Payment Intents with embedded Elements.

## Decision

Use Hosted Checkout in test mode. `payments` creates a Checkout Session on command from `orders`, receives webhooks, verifies their signature, deduplicates by Stripe event id and publishes payment events. Webhooks, not the browser redirect, decide the payment status. `payments` keeps its own ledger of payments, refunds and received webhooks; the admin panel reads from it. Refunds are supported for admin cancellation of a paid, not yet shipped order.

The shipping address is collected on our own checkout page and stored with the order.

## Consequences

- Card data never enters the system.
- Local development needs the Stripe CLI to forward webhooks.
- Session lifetime (about 30 minutes) defines the stock reservation TTL.
