#!/usr/bin/env bash
# Checks that a pull request title follows Conventional Commits
# (.github/workflows/pr-title.yml). The title becomes the squash commit message.
#
# Usage: check-pr-title.sh "<title>"
#
# Accepted form: type(scope)!: summary
#   type     one of TYPES below;
#   scope    optional, lowercase letters, digits and hyphens;
#   !        optional, marks a breaking change;
#   summary  not empty, starts with a non-space character.
set -euo pipefail

TYPES='feat|fix|docs|chore|refactor|test|ci|build|perf'
PATTERN="^(${TYPES})(\([a-z0-9-]+\))?!?: [^[:space:]].*\$"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 \"<title>\"" >&2
  exit 2
fi

title=$1

if [[ $title =~ $PATTERN ]]; then
  echo "PR title is valid: $title"
  exit 0
fi

cat >&2 <<MSG
PR title does not follow Conventional Commits: $title

Expected: type(scope): summary
  type   ${TYPES//|/, }
  scope  optional, lowercase letters, digits and hyphens
  !      optional after the type or scope, marks a breaking change
Example: chore(repo): add codeowners
MSG
exit 1
