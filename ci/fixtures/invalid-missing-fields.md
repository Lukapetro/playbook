Adds the CSV importer behind the `importer_v2` flag.

## Handoff

**Outcome:** The streaming CSV parser now handles quoted newlines.

**Gates:**

- `pnpm test` → 412 tests, 412 passed, 0 failed

**Simplify:** nothing

**Review:**

- code-review: no findings
- Final SHA covered by review: yes (a1b2c3d)

<!-- Discoveries, Deviations and State left are missing: this must not pass. -->
