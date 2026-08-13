# Project bindings block

The protocol is universal; the bindings are not. Paste this block into the
project's `AGENTS.md` and fill it in. Every field is marked REQUIRED or
OPTIONAL — an OPTIONAL field that does not apply is deleted, not left blank.

An implementer reads `PROTOCOL.md` for the rules and this block for the values.
If a value is not here, it is not defined for this project.

---

## Agent protocol bindings

This project follows the [playbook protocol](https://github.com/Lukapetro/playbook).
Values below are project-specific and override nothing in `PROTOCOL.md`.

### Gates — REQUIRED

Commands that must pass before a PR is opened. Run them all; report each with
its numbers under **Gates** in the handoff.

| Gate | Command |
| --- | --- |
| Lint | `<command>` |
| Types | `<command>` |
| Unit tests | `<command>` |
| Build | `<command>` |
| <other> | `<command>` |

- Gates run from: `<repo root / subdirectory>` — REQUIRED
- Gates that may be skipped, and when: `<none>` — OPTIONAL

### State file — REQUIRED

- Location: `itaca.yml` (repo root)
- Format: itaca v2 — see [`itaca/SPEC-V2.md`](../itaca/SPEC-V2.md)
- Journal: `journal/` — one file per significant session
- Decisions: `docs/decisions/` — ADRs, append-only
- Who updates it: the implementer, in the same PR as the work — REQUIRED

### Reviewer chain — REQUIRED

Reviewers run in this order before the PR is opened; findings are reported per
reviewer under **Review** in the handoff.

1. `<reviewer / command / agent>` — <what it covers>
2. `<reviewer / command / agent>` — <what it covers>

- Re-review required after the last commit: yes / no — REQUIRED
- Human reviewer: `<name>` — OPTIONAL

### Commit and push authorization — REQUIRED

- Branch naming: `<pattern>`
- Commit titles: `<convention>`
- Attribution footers/trailers: `<allowed / forbidden>`
- May the implementer push without asking: yes / no
- May the implementer open the PR: yes / no
- May the implementer force-push: `<no / only to its own branch before review>`
- Base branch: `<main>`

### Language conventions — REQUIRED

- Code, identifiers, comments: `<language>`
- Docs and READMEs: `<language>`
- Commit messages and PR text: `<language>`
- User-facing strings: `<language>`

### Merger — REQUIRED

- Who merges: `<name / role>` — never the implementer unless stated here
- Merge method: `<squash / merge / rebase>`
- Required checks before merge: `<list>`

### Board — OPTIONAL

- Tracker: `<Linear / GitHub Projects / none>`
- Project or team: `<link>`
- Issue reference required in the PR title: yes / no
