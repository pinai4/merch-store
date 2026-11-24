# Merch Store

An online merchandise shop built as a set of Go microservices with a Next.js frontend. A pet project that follows the structure and process of a team-developed product.

**Status:** design complete, phase 1 (walking skeleton) in progress.

## Stack

Go · gRPC · Kafka · PostgreSQL · Redis · Keycloak · Envoy · Next.js · Stripe · Kubernetes (Kind, Helm)

## Getting started

Prerequisites:

- **Go**, any recent release. The exact toolchain is pinned by the `toolchain` directive in [`go.work`](go.work); with the default `GOTOOLCHAIN=auto`, Go downloads it on first use.
- **[Task](https://taskfile.dev) v3**, at least the version pinned in [`.tool-versions`](.tool-versions):
  `go install github.com/go-task/task/v3/cmd/task@v<version>`
- `curl`, used to download pinned binaries.

Then, from the repository root:

```sh
task tools   # install pinned binaries into .bin/ and check the environment
task lint    # golangci-lint in every Go module
task test    # go test in every Go module
task --list  # all available tasks
```

Other tools are not installed globally: `golangci-lint` lives in the gitignored `.bin/` at the version from `.tool-versions`, and Go tools run with `go tool` at the versions from `tools/go.mod`. After a version changes in `.tool-versions`, run `task tools` again.

## Documentation

- [Architecture](docs/architecture/README.md)
- [Architecture decisions](docs/architecture/adr/README.md)
