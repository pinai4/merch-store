---
name: git-pr
description: 'Use this skill when the user wants to open a GitHub pull request for the current branch, or types "/git-pr". The skill compares the branch with main, writes a Conventional Commits title and a description from the commits and their diff, shows the draft for approval, pushes the branch, and runs gh pr create against main. Do not use it to make commits, merge, review, or edit an existing pull request.'
license: MIT
compatibility: 'Requires Git and the GitHub CLI (gh), authenticated for the repository.'
disable-model-invocation: true
---

# GitHub Pull Request with Conventional Titles

Open a pull request from the current branch into `main` with the `gh` CLI. Get the title and the description from the commits that the branch adds to `main`.

## Title Format

The title follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/), the same format as a commit subject. With a squash merge, the title becomes the commit on `main`.

```text
<type>(<scope>): <summary>
```

- Use the types of the repository. Without a repository list, use `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Write the summary in the imperative mood: "add", not "added" or "adds". Do not put a period at the end.
- Keep the title at 72 characters or less.
- Put `!` before the colon if any commit is a breaking change: it has `!` in its subject or a `BREAKING CHANGE:` footer.

Pick the parts from the commits:

- **One commit**: Use its subject as the title.
- **More than one commit**: Describe the whole change, not the last commit.
  - **Type**: The type of the main change. If the commits mix types, the most significant one wins: `feat`, then `fix`, then `perf`, then `refactor`, then the others. Do not pick `feat` only because one small commit is a feature; pick the type that a release note would use.
  - **Scope**: The scope that the commits share. If they touch different scopes, use the main one or omit the scope.
  - **Summary**: One line that covers all the commits.

## Description Format

Fill in [pull_request_template.md](./pull_request_template.md) from this skill folder. If the repository has its own template, use it instead. GitHub looks for it in these places:

- `.github/pull_request_template.md`
- `pull_request_template.md` in the root
- `docs/pull_request_template.md`
- The same names in uppercase, or a `PULL_REQUEST_TEMPLATE/` folder in any of these places.

Rules for the description:

- Write it in English.
- Remove the HTML comments of the template.
- Remove the optional sections that have no content. Do not write "None" or "N/A" in them.
- Get the content from the commit messages and the diff. Do not invent motivation, issue numbers, or test results.
- **Changes**: Group by area or by type. Merge small related commits into one bullet. Do not list fixup commits, such as a typo fix to code that the same branch adds.
- **Related issues**: Take the issue references from the commit footers (`Closes: #12`, `Refs: #34`) and from the branch name (`123-add-cart`, `feat/123-cart`). Write closing references as `Closes #12`.
- **Testing**: Name the tests that the commits add or change. If you ran checks in this session, name them and their result. If nothing is known, write "Not tested."

## Workflow

### 1. Check the starting state

Run each command alone:

```bash
gh auth status
git rev-parse --abbrev-ref HEAD
git status --porcelain
git fetch origin main
```

Stop and tell the user if:

- `gh` is not authenticated. Suggest `! gh auth login`.
- The current branch is `main`, or `HEAD` is detached. Pull requests come from a feature branch.

If `git status --porcelain` shows changes, tell the user that uncommitted changes do not go into the pull request. Ask whether to continue or to commit them first.

### 2. Check for an existing pull request

```bash
gh pr list --head <branch> --base main --state open --json number,url,title
```

If a pull request is open for the branch, give its URL and stop. Do not create a second one.

### 3. Read the repository rules

- A pull request template, in the places listed above.
- `CONTRIBUTING.md`, and `CLAUDE.md` or `AGENTS.md`. Look for rules about titles, descriptions, and the language.
- A commitlint configuration, for example `commitlint.config.js` or `.commitlintrc.json`, for the list of types.

If a repository rule is different from this skill, use the repository rule.

### 4. Examine the commits

```bash
git log --reverse --format='%h %s%n%b%n---' origin/main..HEAD
git diff --stat origin/main...HEAD
git diff origin/main...HEAD
```

If `origin/main..HEAD` has no commits, stop and tell the user that the branch has nothing to merge.

If the diff is large, read the commit messages and the `--stat` output first. Then read only the parts of the diff that you need to describe the change.

If the branch is behind `origin/main` (`git rev-list --count HEAD..origin/main` is not `0`), mention it in the reply. Do not rebase or merge.

### 5. Write the draft and confirm

Write the title and the description. Show them to the user, with the base and the head branch and the number of commits:

```text
main ← <branch> (N commits)

Title: <title>

<description>
```

Wait for the user to approve it or to ask for changes. Do not push or create the pull request before that.

### 6. Push the branch

Check whether the branch has an upstream and whether it is ahead of it:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u}
git status -sb
```

- No upstream: `git push -u origin <branch>`.
- Ahead of the upstream: `git push`.
- Up to date: Do not push.

If the push is rejected because the remote branch has other commits, stop and tell the user. Do not force push. Do not pull, rebase, or merge.

### 7. Create the pull request

Write the description to a temporary file outside the repository, then pass it with `--body-file`. This keeps the Markdown intact in any shell.

```bash
gh pr create --base main --head <branch> --title "<title>" --body-file <file>
```

Add `--draft` only if the user asks for a draft. Add reviewers, labels, or assignees only if the user asks for them.

### 8. Make sure that the pull request is correct

```bash
gh pr view --json number,url,title,baseRefName,headRefName,isDraft
```

Give the user the URL of the pull request. Delete the temporary file.

## Safety Rules

- Do not change the Git configuration or the `gh` configuration.
- Do not force push. Do not push to `main`.
- Do not make commits, amend, rebase, or merge. To commit changes, the user can run the `git-commit` skill.
- Do not merge the pull request, approve it, or enable auto-merge.
- Do not put secrets from the diff into the description, for example tokens, passwords, or private keys.
