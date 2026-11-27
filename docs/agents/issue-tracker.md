# Issue tracker: GitHub

Work is planned and tracked in this repository's GitHub Issues and in the project board [Merch Store Roadmap](https://github.com/users/pinai4/projects/1). Use the `gh` CLI for all operations. This document is the single source of the conventions; follow it when creating, splitting or working on issues.

## Hierarchy

| Level | GitHub object | Represents | Example |
|---|---|---|---|
| Phase | Milestone | One phase of [§13 Implementation phases](../architecture/README.md#13-implementation-phases) | `Phase 1: Walking skeleton` |
| Sub-phase | Issue with label `type: epic` | A part of a phase, described as a PRD | `Epic 1.1: Repository foundation and CI` |
| Task | Sub-issue of an epic | One pull request | `Initialize Go workspace` |

- Every epic and task belongs to the milestone of its phase.
- Tasks are linked to their epic as **native sub-issues** (`--parent`). Do not keep a manual task list with checkboxes in the epic body; GitHub shows sub-issues and their progress automatically.
- Planning is rolling-wave: all phases exist as milestones, epics are written for the current phase, and tasks only for the epics about to start. Split the next epic into tasks when the previous ones are nearly done.

## Milestones

- Title: `Phase <n>: <name>`, matching §13.
- Description: one or two sentences with the goal and the exit criterion, then `See docs/architecture/README.md §13.`
  Example: `Fake carrier and shipment statuses. Done when: the order reaches DELIVERED. See docs/architecture/README.md §13.`
- No due dates.
- Close the milestone when the phase's end-to-end check passes in Kind and all its issues are closed.

## Epics

- Title: `Epic <phase>.<n>: <name>`. The number gives the order in lists.
- Labels: `type: epic` and the `area:` labels it touches.
- Body: a technical PRD with these sections (the Epic issue form provides them):
  1. **Goal** — what the sub-phase delivers and why.
  2. **Context** — links to README sections and ADRs; planning decisions that apply.
  3. **Scope** — in scope and out of scope.
  4. **Requirements** — numbered, testable statements. User stories only where there is user-visible behaviour.
  5. **Acceptance criteria** — checkboxes that are verified before the epic is closed.
  6. **Dependencies** — one-line summary; the source of truth is the native relationships.
  7. **Open questions** — decisions left to a task, and which task makes them.
- Links in issue bodies are absolute URLs to `blob/main`, because relative links do not resolve in issues.
- Close the epic when all its sub-issues are closed and its acceptance criteria are checked.

## Tasks

- **Size rule:** one task = one pull request, mergeable into `main` on its own with green CI, about 0.5–2 days of work. A task estimated as `L` is split.
- Title: imperative, no prefixes (`Add golangci-lint config with depguard rules`). Type and area are labels, not title text.
- Labels: one `type:` label (`type: feature`, `type: chore` or `type: docs`; `bug` for defects) and one or more `area:` labels.
- Body sections (the task issue forms provide them):
  1. **Context** — one or two sentences, starting with `Part of #<epic>`.
  2. **Task** — the concrete changes.
  3. **Acceptance criteria** — checkboxes.
  4. **Out of scope** — related work, linked to the issues that own it.
  5. **References** — files, README sections, ADRs.
- Tasks are not assigned in advance. Whoever starts a task assigns it to themselves.

## Labels

| Label | Meaning |
|---|---|
| `type: epic` | Sub-phase with a PRD; parent of tasks |
| `type: feature` | New user-facing or API capability |
| `type: chore` | Tooling, build, CI or maintenance |
| `type: docs` | Documentation only |
| `bug` | Something does not work as specified |
| `area: repo` | Repository-wide tooling and conventions (workspace, Taskfile, templates, CODEOWNERS, agent configuration: `.claude/`, `CLAUDE.md`, `docs/agents/`) |
| `area: ci` | GitHub Actions workflows and checks |
| `area: platform` | `platform` module |
| `area: shared` | `shared` module: contracts and generated code |
| `area: catalog` | `catalog` service |
| `area: web` | Next.js apps and web packages |
| `area: deploy` | compose, Envoy, Keycloak, Helm, Kind |

When a new service gets its first issue, add `area: <service>` (see [Tracker setup](#tracker-setup)). `area:` labels follow the `CODEOWNERS` areas. GitHub's default labels are kept.

## Dependencies

- Use native relationships only: `--blocked-by` / `--blocking`. Do not write "Blocked by #12" in the body.
- Record dependencies at both levels: between tasks, and between epics.
- A task may be blocked by a task of another epic (for example, an Envoy route task blocked by the descriptor set task).
- A task is ready to start when every issue blocking it is closed.

## Project board

Project: [Merch Store Roadmap](https://github.com/users/pinai4/projects/1). Every epic and task is on the board.

| Field | Values | Meaning |
|---|---|---|
| Status | Todo | Ready to be picked up (or waiting on blockers) |
| | In progress | Someone is working on it |
| | In review | Pull request open |
| | Done | Merged or closed |
| Size | XS | Under half a day |
| | S | About a day |
| | M | Up to two days |
| | L | Too big for one PR: split it |

Size is set for tasks, not for epics.

| View | Layout | Shows |
|---|---|---|
| Tasks board | Board, columns by Status | Tasks only (filter `-label:"type: epic"`) |
| By milestone | Table, grouped by Milestone | Epics and tasks |
| Outside roadmap | Table | Issues without a milestone (filter `no:milestone`) |

## Working on a task

To run this process with an AI agent, with a plan checkpoint before any change and a review checkpoint before anything is committed, invoke `/implement-issue <issue number or URL>` (`.claude/skills/implement-issue/`). The skill is invoked only by hand.

1. **Pick.** On *Tasks board*, take a task in Todo whose blockers are all closed (the issue page shows "Blocked by"). Work in phase order.
2. **Start.** Assign yourself and move the task to **In progress**.
3. **Branch** from up-to-date `main`: `<type>/<issue>-<slug>`, where `<type>` is a Conventional Commits type, for example `docs/11-tracker-conventions` or `chore/12-go-workspace`.
4. **Commit** with Conventional Commits messages (`type(scope): summary`).
5. **Open a PR** into `main`:
   - title in Conventional Commits form; it becomes the squash commit message;
   - body from the PR template with `Closes #<issue>`, which links the PR and closes the issue on merge;
   - move the task to **In review**.
6. **Merge** with squash once the required checks are green. The issue closes, the board moves it to **Done** and the branch is deleted.
7. **Close the epic** when its last task is closed and its acceptance criteria are checked. **Close the milestone** when the phase's end-to-end check passes.

If a task turns out bigger than planned, split it: create the extra sub-issues on the same epic, move relationships, and keep the original task to the part being done.

## Work outside the roadmap

Maintenance, tooling, agent configuration and urgent fixes that belong to no phase.

- **No milestone.** A milestone is a goal that gets closed; ongoing maintenance never is. Do not create a standing "Maintenance" milestone.
- **No parent** in the usual case. Create an epic without a milestone only for a larger, coherent piece of such work, with its own PRD.
- **Labels** as for any task: `type: chore`, `type: docs`, `type: feature` or `bug`, plus `area:` labels. Agent configuration (`.claude/`, `CLAUDE.md`, `docs/agents/`) is `area: repo`.
- **Board:** such issues are added automatically and follow the same statuses. The *Outside roadmap* view lists them.
- **Branch, commits and PR** follow [Working on a task](#working-on-a-task), for example `chore/23-implement-issue-skill` and `chore(claude): add implement-issue skill`.
- **A bug** that blocks the current phase gets that phase's milestone and the relevant "blocked by" relationships instead.
- **PR without an issue** is acceptable only for trivial changes: under about half an hour and with no decision to record, such as a typo or a harmless version bump. Everything else starts with an issue.

## Commands

The repository is inferred from `git remote -v`; `gh` does this automatically inside a clone. Use a heredoc or `--body-file` for multi-line bodies.

```sh
# Milestones
gh api repos/:owner/:repo/milestones -f title="Phase 2: Cart" -f description="..."

# Epic
gh issue create --title "Epic 2.1: ..." --body-file epic.md \
  --milestone "Phase 2: Cart" --label "type: epic,area: cart"

# Task as a sub-issue, with dependencies
gh issue create --title "Add ..." --body-file task.md \
  --milestone "Phase 2: Cart" --label "type: chore,area: cart" \
  --parent <epic> --blocked-by <n>,<m>

# Change relationships later
gh issue edit <n> --parent <epic>
gh issue edit <n> --add-blocked-by <m> --remove-blocked-by <k>

# Read and list
gh issue view <n> --comments
gh issue list --state open --json number,title,labels,milestone \
  --jq '.[] | {number, title, labels: [.labels[].name], milestone: .milestone.title}'

# Labels, comments, closing
gh issue edit <n> --add-label "..." --remove-label "..."
gh issue comment <n> --body "..."
gh issue close <n> --comment "..."

# Project board: add an issue and set fields (needs the `project` scope: gh auth refresh -s project)
gh project item-add 1 --owner pinai4 --url https://github.com/pinai4/merch-store/issues/<n>
gh project field-list 1 --owner pinai4 --format json     # field ids and option ids
gh project item-list 1 --owner pinai4 --format json      # item ids
gh project item-edit --project-id <project-id> --id <item-id> \
  --field-id <field-id> --single-select-option-id <option-id>
```

New sub-issues of an epic that is on the board are added to the board automatically.

## Tracker setup

GitHub settings that are not stored as files in the repository. Keep this section in sync when a setting changes; it is enough to recreate the setup by hand.

### Labels

Created with `gh label create "<name>" --color <colour> --description "<description>"`.

| Name | Colour | Description |
|---|---|---|
| `type: epic` | `3E4B9E` | Sub-phase with a PRD; parent of tasks |
| `type: feature` | `1D76DB` | New user-facing or API capability |
| `type: chore` | `C5DEF5` | Tooling, build, CI or maintenance |
| `type: docs` | `0075CA` | Documentation only |
| `area: repo` | `EDEDED` | Repository-wide tooling and conventions |
| `area: ci` | `BFD4F2` | GitHub Actions workflows and checks |
| `area: platform` | `FBCA04` | platform module |
| `area: shared` | `F9D0C4` | shared module: contracts and generated code |
| `area: catalog` | `0E8A16` | catalog service |
| `area: web` | `D4C5F9` | Next.js apps and web packages |
| `area: deploy` | `C2E0C6` | compose, Envoy, Keycloak, Helm, Kind |

### Milestones

Eight milestones `Phase 1` … `Phase 8` as described in [Milestones](#milestones), without due dates.

### Project "Merch Store Roadmap"

- User project #1 owned by `pinai4`, linked to this repository (Project → Settings → Manage access / or `gh project link`).
- Fields: built-in **Status** with options Todo, In progress, In review, Done (in that order); single-select **Size** with options XS, S, M, L.
- Views: *Tasks board* (Board layout, column field Status, filter `-label:"type: epic"`); *By milestone* (Table layout, Group by Milestone); *Outside roadmap* (Table layout, filter `no:milestone`).
- Built-in workflows (Project → ⋯ → Workflows), all enabled:

  | Workflow | Sets |
  |---|---|
  | Item added to project | Status: Todo |
  | Pull request linked to issue | Status: In review |
  | Item closed | Status: Done |
  | Pull request merged | Status: Done |
  | Auto-close issue | closes the issue when Status becomes Done |
  | Auto-add sub-issues to project | adds sub-issues of items on the board |
  | Auto-add to project | repository `merch-store`, filter `is:issue is:open` |

### Repository settings

- Pull requests: only **squash merge** allowed; default squash commit message is the **pull request title**; **automatically delete head branches**.
- Ruleset `main-branch-ruleset` (Settings → Rules → Rulesets), target: default branch, enforcement active, no bypass actors:
  - restrict deletions; block force pushes; require linear history;
  - require a pull request before merging, required approvals: 0 (single maintainer; raise to 1 when a second developer joins);
  - require status checks to pass: `go-ci` (workflow `go`) and `pr-title` (workflow `pr-title`), both with source GitHub Actions; branches do not have to be up to date before merging. `contracts` is added by #21.
