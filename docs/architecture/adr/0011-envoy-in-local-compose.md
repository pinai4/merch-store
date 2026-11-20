# 0011. Envoy runs in local compose

Status: accepted. Amends [0009](0009-local-and-cluster-deployment.md).

## Context

ADR 0009 puts only infrastructure into docker-compose and runs services from the host. Envoy is not listed there, but locally the web apps and the browser need the same entry point as in the cluster: gRPC-JSON transcoding, JWT validation and host-based routing (ADR 0004). Without Envoy the local loop would need a different API path from the one used in Kind and staging.

## Decision

- Envoy is part of the local compose stack, next to Postgres, Redis, Kafka, Keycloak, MinIO and Mailpit.
- Go services and Next.js apps still run from the host. Envoy reaches them through `host.docker.internal` (mapped to the host gateway on Linux).
- Routing and filters are the same as in the cluster; the static configuration differs only in upstream cluster addresses.
- Everything else in ADR 0009 is unchanged.

## Consequences

- The browser, the web apps and the end-to-end path use the gateway in every environment, so transcoding and JWT problems show up locally.
- Envoy configuration is maintained for two upstream layouts (host and cluster); the shared part must not be duplicated.
- The Keycloak issuer URL must be the same for the browser, Envoy and the services, otherwise token validation fails locally.
- The proto descriptor set must be mounted into the compose Envoy, not only shipped to the cluster.
