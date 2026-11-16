# 0004. Envoy with gRPC-JSON transcoding as the API gateway

Status: accepted

## Context

Services speak gRPC; browsers and Next.js need an HTTP API. Options were gRPC-Web, a dedicated Go BFF, or transcoding at the gateway.

## Decision

Envoy is the single entry point. It transcodes REST/JSON to gRPC using HTTP annotations in the proto files, validates Keycloak JWTs and routes by host to the API, both web apps and Keycloak. Configuration is static. OpenAPI and the JS client are generated from proto. Page-level aggregation is done by the Next.js server side, so there is no separate BFF service.

Hand-written OpenAPI exists only for the Stripe webhook and the SSE endpoint.

## Consequences

- Proto is the single source of truth for external and internal contracts.
- The proto descriptor set must be rebuilt and shipped to Envoy when contracts change.
- No second ingress controller to operate; rate limiting can be added at Envoy later.
