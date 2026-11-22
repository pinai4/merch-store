# Merch Store

Go microservices monorepo with a Next.js frontend. Design is in docs/architecture/README.md — read it before any change that touches service boundaries, contracts, messaging, or deployment.

## Rules

- Frontend is JavaScript only. Do not introduce TypeScript.
- A service imports only `shared` and `platform`, never another service. `platform` does not import `shared`.
- Code, comments, commit messages and docs are in English.
- An architectural change updates docs/architecture/README.md in the same PR. A significant decision gets a new ADR in docs/architecture/adr/; accepted ADRs are not edited, they are superseded.

## Agent skills

### Issue tracker

Issues are tracked in this repo's GitHub Issues (via the `gh` CLI). See `docs/agents/issue-tracker.md`.

When working on an issue, follow "Working on a task" in `docs/agents/issue-tracker.md`.
