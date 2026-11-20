# 0009. Compose for infrastructure, Helm for Kind and staging

Status: accepted. Amended by [0011](0011-envoy-in-local-compose.md).

## Context

The specification asks for docker-compose and Kubernetes (Kind, staging). Maintaining two complete deployments of the whole system doubles configuration work.

## Decision

- docker-compose runs infrastructure only (Postgres, Redis, Kafka, Keycloak, MinIO, Mailpit); services run from the host for a fast loop.
- Kind runs the whole system from the same Helm charts as staging: one generic chart for Go services with values per service and environment, simple single-replica charts for infrastructure (Kafka in KRaft mode).
- Staging is any Kubernetes cluster reachable from GitHub Actions through a kubeconfig secret. CI builds changed services, pushes images to GHCR and runs `helm upgrade`.
- Configuration is environment variables only; secrets are Kubernetes Secrets fed from GitHub Secrets.

## Consequences

- One set of manifests for every cluster environment.
- Operators (Strimzi, CloudNativePG), GitOps (Argo CD) and a secrets manager are deliberate later steps.
- The document is not tied to a cloud provider.
