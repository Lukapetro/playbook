Adds the CSV importer behind the `importer_v2` flag.

Closes #142.

## Handoff

**Outcome:** The streaming CSV parser now handles quoted newlines and fails
loudly on malformed rows instead of dropping them. Wired behind the
`importer_v2` flag, off in production.

**Gates:**

- `pnpm lint` → 0 errors, 0 warnings
- `pnpm typecheck` → 0 errors
- `pnpm test` → 412 tests, 412 passed, 0 failed
- `pnpm build` → exit 0

**Simplify:** Collapsed two near-identical row validators into one; no other
findings.

**Review:**

- code-review: unchecked index in `parseRow` — founded — fixed in a1b2c3d
- code-review: "flag should default on" — unfounded — rollout is staged, see
  ADR 0007
- Final SHA covered by review: yes (a1b2c3d)

**Discoveries:** The v1 importer silently drops rows with unbalanced quotes;
worth a backlog item to quantify how many production imports were affected.

**Deviations:** none

**State left:** branch `feat/importer-v2`; state file updated: yes; worktree
clean: yes
