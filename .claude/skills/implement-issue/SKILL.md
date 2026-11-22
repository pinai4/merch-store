---
name: implement-issue
description: 'Implement one GitHub issue of this repository end to end, with two checkpoints: a plan before any change and a review before anything is committed or published. Takes an issue number or URL. Run after a merge with the same issue to clean up.'
argument-hint: '<issue number or URL>'
license: MIT
compatibility: 'Requires Git and the GitHub CLI (gh), authenticated with the repo and project scopes.'
disable-model-invocation: true
---

# Implement a GitHub Issue

Take one issue from the plan to an open pull request. The process, the conventions and the `gh` commands are defined in [`docs/agents/issue-tracker.md`](../../../docs/agents/issue-tracker.md), section "Working on a task". Read that document first; this skill adds the order of steps and two checkpoints where the user decides.

The argument is an issue number (`12`) or URL (`https://github.com/<owner>/<repo>/issues/12`). Take the number from it. If there is no argument, ask for one.

## Checkpoints

- **Checkpoint 0 — plan.** Before any file, branch, issue or board change.
- **Checkpoint 1 — review.** After the change is made and checked, before any commit, push or pull request.

At a checkpoint, show the content listed for it, then stop and wait. Continue only after the user approves. If the user asks for changes, make them and show the checkpoint again. Nothing leaves the working tree before checkpoint 1 is approved.

## Workflow

### 1. Load the issue

```bash
gh issue view <n> --json number,title,state,body,labels,milestone,assignees,url
gh api graphql -f query='{repository(owner:"<owner>",name:"<repo>"){issue(number:<n>){
  parent{number title body}
  blockedBy(first:20){nodes{number title state}}
  closedByPullRequestsReferences(first:5){nodes{number state merged}}}}}'
```

Decide the kind of issue:

- **Roadmap task:** has a milestone and a parent epic. Read the epic: its scope, requirements and open questions apply to the task.
- **Outside the roadmap:** no milestone and no parent (see "Work outside the roadmap" in the conventions).
- **Bug:** label `bug`, body from the Bug form (what happened, expected behaviour, steps to reproduce).

Read every README section, ADR and file listed in the issue's Context and References. For an issue outside the roadmap, find the relevant sections yourself when the change touches architecture, contracts, messaging or deployment.

### 2. Check the starting state

Stop and tell the user, without trying to fix it, if:

- The issue is closed. If a merged pull request closed it, offer the post-merge step instead.
- The issue is blocked: an issue in `blockedBy` is still open. Name the open blockers.
- `git status --porcelain` shows changes. Name the files.
- The current branch is not `main`, or `main` differs from `origin/main` after `git fetch origin main`.
- The issue is a task or a bug without acceptance criteria. In this case continue to checkpoint 0 and propose the criteria there.

### 3. Checkpoint 0: plan

Show:

- The kind of issue and the context that was read (epic, README sections, ADRs).
- The files to create and to change, with one line each on what changes.
- For each acceptance criterion: how it will be met and how it will be verified.
- For a bug: how the problem is reproduced first, and the test that fails before the fix and passes after it.
- Open questions of the parent epic that this task decides, with a proposed answer.
- Anything unclear in the issue, as questions with a recommended answer.
- Proposed acceptance criteria, if the issue has none. After approval, add them to the issue body.
- The branch name: `<type>/<n>-<slug>`. The type comes from the label: `type: feature` → `feat`, `type: chore` → `chore`, `type: docs` → `docs`, `bug` → `fix`.

If the work looks larger than one pull request of about two days (Size `L`), say so and propose a split instead of a plan: new sub-issues of the same epic, or separate issues outside the roadmap, with their dependencies. Create them only after approval.

### 4. Start the work

After approval:

1. Assign the issue to the user: `gh issue edit <n> --add-assignee @me`.
2. Set Status to **In progress** on the project board (commands in the conventions document).
3. Create the branch from `main`: `git switch -c <branch>`.

### 5. Implement

- Stay inside the approved plan. If the plan has to change, or the work grows beyond one pull request, stop and explain before going on.
- Follow `CLAUDE.md`. An architectural change updates `docs/architecture/README.md`; a significant decision adds an ADR.
- Add or update the tests that the acceptance criteria need.

### 6. Verify

- Run the checks that exist in the repository: `task lint` and `task test` when the Taskfile provides them, plus the checks of the touched modules. If a check does not exist yet, say so; do not invent results.
- Go through every acceptance criterion and record how it was verified, or why it can only be verified after the merge.

### 7. Checkpoint 1: review

Show:

- `git status --short` and `git diff --stat`. The user reviews the full diff in the IDE.
- The checks that ran and their results, including failures.
- Each acceptance criterion: met / how verified, or not yet verifiable and why.
- The commit plan: for each commit, its files and its Conventional Commits message. One commit per logical change.
- The pull request draft: title, base and head branch, and the description filled from the repository template (`.github/pull_request_template.md`), including `Closes #<n>`. Follow the "Title Format" and "Description Format" sections of [`git-pr`](../git-pr/SKILL.md).

### 8. Commit, push and open the pull request

After approval:

1. Make the planned commits with the `git-commit` skill, one logical change at a time.
2. Open the pull request by following the workflow of [`git-pr`](../git-pr/SKILL.md), steps 1–8. The draft approval of its step 5 was given at checkpoint 1: do not ask again, unless the title or description changed after the approval.
3. Make sure Status is **In review** on the project board. The board workflow for linked pull requests usually sets it; set it if it did not.

### 9. Report

Give the pull request URL and list every change made in GitHub during the run: assignee, Status changes, issue body edits, created issues, the pull request. Remind the user that merging is theirs.

## After the merge

When the skill runs for an issue that a merged pull request closed:

1. `git switch main` and `git pull --ff-only`.
2. Delete the local branch with `git branch -d <branch>`. If Git refuses because the branch is not merged, stop and ask; do not use `-D`.
3. Offer to tick the acceptance criteria in the closed issue that were verified.
4. Roadmap task: if all sub-issues of the parent epic are closed, show the epic's acceptance criteria and offer to close it. If all issues of the milestone are closed, remind the user that the milestone closes when the phase's end-to-end check passes.

Close nothing without the user's approval.

## Safety rules

- Do not merge, approve or enable auto-merge on the pull request. Merging is the user's step.
- Do not push to `main`. Do not force push.
- Do not change issues other than the one being implemented, except issues the user approved at a checkpoint.
- Do not change the Git or `gh` configuration, repository settings, rulesets or the project's fields and views.
- Do not commit secrets, for example `.env` files, credentials or private keys. `CLAUDE.local.md` is personal and stays untracked.
