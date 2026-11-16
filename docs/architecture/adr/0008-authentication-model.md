# 0008. Authentication and authorization model

Status: accepted

## Context

Keycloak is the identity provider. We need a consistent model for browsers, the gateway, services and background work.

## Decision

- One realm `merch`, kept as a JSON export in the repository and imported at startup. Clients `marketplace` and `admin`, one confidential client per service, roles `customer` and `admin`.
- Web apps use Authorization Code + PKCE through Auth.js. Tokens stay server-side in an encrypted httpOnly cookie; API calls and the SSE stream go through the Next.js server.
- Envoy validates JWTs on protected routes and forwards the token; each service verifies signature and roles again with `platform` middleware.
- Background calls use client-credentials tokens.
- Guests get an anonymous session id and a Redis cart; login is required at checkout, where the guest cart is merged into the user cart.
- Admin functions are separate gRPC services per owning service, guarded by the `admin` role.

## Consequences

- No tokens in browser JavaScript.
- Defense in depth without a service mesh or mTLS.
- Realm changes are reviewed as code.
