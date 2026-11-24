// Package tools pins the Go development tools used by the repository, such as
// buf and the protoc plugins. Tools are declared with tool directives in this
// module's go.mod and run with "go tool <name>", so local runs and CI use the
// same versions.
//
// This module exports no code and is not imported by any other module.
package tools
