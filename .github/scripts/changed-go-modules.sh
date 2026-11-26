#!/usr/bin/env bash
# Selects the go.work modules that CI lints and tests (.github/workflows/go.yml).
#
# Reads changed file paths, one per line and relative to the repository root,
# from stdin. Prints the selected module directories as a compact JSON array,
# for example ["platform","shared"], or [] when no Go module is affected.
# With --all, prints every module and ignores stdin.
#
# A module is selected when a file inside its directory changed. A change in
# one of the GLOBAL paths below selects every module: platform and shared are
# imported by every service, and the rest defines how every module is built,
# linted or tested.
#
# Run from the repository root. Needs go and jq.
set -euo pipefail

GLOBAL_DIRS=(platform/ shared/ tools/)
GLOBAL_FILES=(
  go.work
  go.work.sum
  .golangci.yml
  .tool-versions
  Taskfile.yml
  .github/workflows/go.yml
  .github/scripts/changed-go-modules.sh
)

mapfile -t modules < <(go work edit -json | jq -r '.Use[].DiskPath | sub("^\\./"; "")')

emit() {
  jq -cn '$ARGS.positional' --args "$@"
}

if [[ ${1:-} == --all ]]; then
  emit "${modules[@]}"
  exit 0
fi

declare -A selected=()
while IFS= read -r file; do
  [[ -n $file ]] || continue
  for dir in "${GLOBAL_DIRS[@]}"; do
    if [[ $file == "$dir"* ]]; then
      emit "${modules[@]}"
      exit 0
    fi
  done
  for global in "${GLOBAL_FILES[@]}"; do
    if [[ $file == "$global" ]]; then
      emit "${modules[@]}"
      exit 0
    fi
  done
  for module in "${modules[@]}"; do
    if [[ $file == "$module/"* ]]; then
      selected[$module]=1
    fi
  done
done

# Keep the go.work order so the output is stable.
result=()
for module in "${modules[@]}"; do
  if [[ -n ${selected[$module]:-} ]]; then
    result+=("$module")
  fi
done
emit "${result[@]}"
