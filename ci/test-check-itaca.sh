#!/usr/bin/env bash
#
# Test runner for ci/check-itaca.sh.
#
# Usage: bash ci/test-check-itaca.sh
# Exits 0 if every fixture produces its expected exit status.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$here/check-itaca.sh"
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
    printf 'PASS  %-30s expected %-3s got exit %d\n' "$fixture" "$expectation" "$status"
  else
    fail=$((fail + 1))
    printf 'FAIL  %-30s expected %-3s got exit %d\n' "$fixture" "$expectation" "$status"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

expect ok  itaca-valid.yml
expect ok  itaca-valid-minimal.yml
expect bad itaca-invalid-caps.yml
expect bad itaca-invalid-keys.yml
expect bad itaca-invalid-version.yml
expect bad itaca-invalid-too-long.yml

if bash "$script" "$fixtures/does-not-exist.yml" >/dev/null 2>&1; then
  fail=$((fail + 1)); printf 'FAIL  %-30s expected bad got exit 0\n' "(missing file)"
else
  pass=$((pass + 1)); printf 'PASS  %-30s expected bad got non-zero\n' "(missing file)"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
