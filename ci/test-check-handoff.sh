#!/usr/bin/env bash
#
# Test runner for ci/check-handoff.sh. Dependency-free bash.
#
# Usage: bash ci/test-check-handoff.sh
# Exits 0 if every fixture produces its expected exit status.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$here/check-handoff.sh"
fixtures="$here/fixtures"

pass=0
fail=0

expect() {
  local expectation="$1" fixture="$2" out status
  out="$(bash "$script" "$fixtures/$fixture" 2>&1)"
  status=$?

  case "$expectation" in
    ok)  if [ "$status" -eq 0 ]; then ok=1; else ok=0; fi ;;
    bad) if [ "$status" -ne 0 ]; then ok=1; else ok=0; fi ;;
    *)   printf 'test: unknown expectation %s\n' "$expectation" >&2; exit 2 ;;
  esac

  if [ "$ok" -eq 1 ]; then
    pass=$((pass + 1))
    printf 'PASS  %-28s expected %-3s got exit %d\n' "$fixture" "$expectation" "$status"
  else
    fail=$((fail + 1))
    printf 'FAIL  %-28s expected %-3s got exit %d\n' "$fixture" "$expectation" "$status"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

expect ok  valid.md
expect ok  valid-terse.md
expect bad invalid-no-section.md
expect bad invalid-missing-fields.md

# The script itself must reject bad invocations.
if bash "$script" >/dev/null 2>&1; then
  fail=$((fail + 1)); printf 'FAIL  %-28s expected bad got exit 0\n' "(no argument)"
else
  pass=$((pass + 1)); printf 'PASS  %-28s expected bad got non-zero\n' "(no argument)"
fi

if bash "$script" "$fixtures/does-not-exist.md" >/dev/null 2>&1; then
  fail=$((fail + 1)); printf 'FAIL  %-28s expected bad got exit 0\n' "(missing file)"
else
  pass=$((pass + 1)); printf 'PASS  %-28s expected bad got non-zero\n' "(missing file)"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
