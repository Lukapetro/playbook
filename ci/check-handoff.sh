#!/usr/bin/env bash
#
# check-handoff.sh — verify a PR body contains a conforming handoff report.
#
# Usage: bash ci/check-handoff.sh <path-to-pr-body-file>
#
# Exits 0 when the body contains a "## Handoff" section carrying all seven
# field labels defined in PROTOCOL.md §5. Exits non-zero otherwise, printing
# what is missing.
#
# Dependency-free: bash + coreutils only. No jq, no node, no python.

set -euo pipefail

REQUIRED_FIELDS=(
  "Outcome"
  "Gates"
  "Simplify"
  "Review"
  "Discoveries"
  "Deviations"
  "State left"
)

fail() {
  printf 'check-handoff: %s\n' "$1" >&2
  exit 1
}

[ "$#" -eq 1 ] || fail "usage: check-handoff.sh <path-to-pr-body-file>"

body_file="$1"
[ -f "$body_file" ] || fail "file not found: $body_file"

# Normalise CRLF: GitHub event payloads carry Windows line endings.
body="$(tr -d '\r' < "$body_file")"

# Extract the "## Handoff" section: from the heading up to the next heading of
# level 1 or 2, or end of file.
section="$(
  printf '%s\n' "$body" | awk '
    /^##[[:space:]]+Handoff[[:space:]]*$/ { inside = 1; found = 1; next }
    inside && /^#{1,2}[[:space:]]/        { inside = 0 }
    inside                                { print }
    END { if (!found) exit 1 }
  '
)" || fail 'no "## Handoff" section found in the PR body (heading must be exactly "## Handoff")'

missing=()
for field in "${REQUIRED_FIELDS[@]}"; do
  # Match the label at the start of a line, tolerating list markers, bold
  # markers and any casing: "- **State left:**", "State left:", "**Gates**:".
  if ! printf '%s\n' "$section" \
    | grep -Eiq "^[[:space:]]*([-*+][[:space:]]+)?\**[[:space:]]*${field}[[:space:]]*\**[[:space:]]*:"; then
    missing+=("$field")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  printf 'check-handoff: "## Handoff" section is missing required field(s):\n' >&2
  for field in "${missing[@]}"; do
    printf '  - %s\n' "$field" >&2
  done
  printf 'See templates/handoff.md for the skeleton.\n' >&2
  exit 1
fi

printf 'check-handoff: OK — "## Handoff" present with all %d fields.\n' "${#REQUIRED_FIELDS[@]}"
