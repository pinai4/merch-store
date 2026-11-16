# 0010. Taskfile as the task runner

Status: accepted

## Context

Developers need one entry point for code generation, linting, tests, migrations and environment startup. The candidates were Make and Task.

## Decision

Use Task. The root `Taskfile.yml` includes one task file per service, giving namespaced commands such as `task catalog:test`. Tool versions are pinned in the repository.

## Consequences

- Readable YAML, built-in task listing, `.env` loading and checksum-based skipping.
- Task is an extra binary to install locally and in CI.
- Make remains a low-cost fallback if the team prefers it.
