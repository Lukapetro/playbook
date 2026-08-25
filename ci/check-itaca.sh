#!/usr/bin/env bash
#
# check-itaca.sh — verify an itaca.yml v2 file holds hot state only.
#
# Usage: bash ci/check-itaca.sh [path-to-itaca.yml]   (default: itaca.yml)
#
# Exits 0 when the file is v2, under 60 lines, carries only the fields of
# itaca/SPEC-V2.md §1, and stays under the list caps (doing 3, blockers 3,
# assumptions 5). Exits non-zero otherwise, printing every violation.
#
# Requires python3 with PyYAML (present on GitHub runners). Fails loudly when
# it is missing: a check that silently degrades is worse than no check.

set -euo pipefail

file="${1:-itaca.yml}"
[ -f "$file" ] || { printf 'check-itaca: file not found: %s\n' "$file" >&2; exit 1; }

python3 - "$file" <<'PY'
import re, sys

path = sys.argv[1]
try:
    import yaml
except ImportError:
    print("check-itaca: python3 with PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(2)

MAX_LINES = 60
CAPS = {"doing": 3, "blockers": 3, "assumptions": 5}
TOP = {"version", "state", "updated"}
STATE = {"goal", "doing", "blockers", "next_safe_action", "assumptions"}

errors = []
with open(path, encoding="utf-8") as fh:
    text = fh.read()
lines = text.count("\n") + (0 if text.endswith("\n") else 1)
if lines > MAX_LINES:
    errors.append(f"{lines} lines; the cap is {MAX_LINES}. Hot state only: the plan goes to the tracker, decisions to docs/adr/")

try:
    doc = yaml.safe_load(text)
except yaml.YAMLError as exc:
    print(f"check-itaca: not valid YAML: {exc}", file=sys.stderr)
    sys.exit(1)

if not isinstance(doc, dict):
    print("check-itaca: top level must be a mapping", file=sys.stderr)
    sys.exit(1)

if doc.get("version") != 2:
    errors.append(f"version must be 2, found {doc.get('version')!r}")
for key in sorted(set(doc) - TOP):
    errors.append(f"unknown top-level key '{key}' (allowed: version, state, updated)")
for key in sorted(TOP - set(doc)):
    errors.append(f"missing top-level key '{key}'")

updated = doc.get("updated")
if updated is not None and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(updated)):
    errors.append(f"updated must be YYYY-MM-DD, found {updated!r}")

state = doc.get("state")
if not isinstance(state, dict):
    errors.append("state must be a mapping")
    state = {}
for key in sorted(set(state) - STATE):
    errors.append(f"unknown state key '{key}' (allowed: {', '.join(sorted(STATE))})")
for key in ("goal", "next_safe_action"):
    value = state.get(key)
    if not isinstance(value, str) or not value.strip():
        errors.append(f"state.{key} is required and must be a non-empty string")
for key, cap in CAPS.items():
    value = state.get(key, [])
    if value is None:
        value = []
    if not isinstance(value, list):
        errors.append(f"state.{key} must be a list")
    elif len(value) > cap:
        errors.append(f"state.{key} has {len(value)} items; the cap is {cap}. Overflow belongs in the tracker")

if errors:
    print(f"check-itaca: {path} violates itaca v2:", file=sys.stderr)
    for e in errors:
        print(f"  - {e}", file=sys.stderr)
    print("See itaca/SPEC-V2.md §1.", file=sys.stderr)
    sys.exit(1)

print(f"check-itaca: OK — {path} is itaca v2, {lines} lines, within caps.")
PY
