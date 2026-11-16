# 0001. Monorepo with per-service modules plus `shared` and `platform`

Status: accepted

## Context

The project must look and behave like a team-developed product, and several developers should be able to work in parallel. A polyrepo adds contract-versioning and release overhead that a small team does not need.

## Decision

Use one repository with independent Go modules joined by `go.work`:

- `services/<name>` — one module per service;
- `shared` — API contracts (proto and OpenAPI sources) and the Go code generated from them;
- `platform` — cross-service infrastructure libraries (logger, closer, auth middleware, Kafka wrappers, migrator, testcontainers helpers).

Dependency rules: a service imports only `shared` and `platform`; `platform` has no business logic and does not import `shared`. Rules are enforced with `depguard`; ownership with `CODEOWNERS`. Modules are not tagged; builds resolve them through `go.work` / `replace`.

## Consequences

- Contract and library changes land atomically with their consumers.
- CI must be path-filtered to avoid rebuilding everything.
- A breaking change in `platform` or `shared` affects all services at once, so `buf breaking` and review by code owners are mandatory.
