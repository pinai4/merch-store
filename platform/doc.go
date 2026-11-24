// Package platform is the root of the cross-service infrastructure libraries:
// logging, configuration, graceful shutdown, auth middleware, gRPC helpers,
// Kafka and outbox wrappers, migrations, OpenTelemetry and testcontainers
// helpers. Each library lives in its own subpackage.
//
// platform contains no business logic and must not import the shared module.
// Services may import platform; platform never imports a service.
package platform
