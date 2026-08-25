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

### Tracker — REQUIRED

- Issues, specs and tickets: GitHub Issues of this repository, through `gh`
  (details in `docs/agents/issue-tracker.md`, written by
  `/setup-matt-pocock-skills`)
- Ticket labels: `ready-for-agent` marks a ticket the frontier may dispatch;
  `retro:spec-failure`, `retro:mismatch`, `retro:post-merge-fix` are applied by
  `/verify-pr` only
- Blocking: native issue dependencies

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

### State — REQUIRED

- Hot state: `itaca.yml` at the repo root, itaca v2, under 60 lines — see
  [`itaca/SPEC-V2.md`](https://github.com/Lukapetro/playbook/blob/main/itaca/SPEC-V2.md)
- Vocabulary: `CONTEXT.md` at the repo root, glossary only
- Decisions: `docs/adr/`, one file per hard-to-reverse decision
- Who updates `itaca.yml`: the implementer, in the same PR as the work

### Reviewer chain — REQUIRED

Reviewers run on the PR before it is declared ready; findings are reported per
reviewer under **Review** in the handoff. `/code-review` (Standards + Spec)
always runs first, locally, before the push.

1. `<reviewer / bot>` — <what it covers>
2. `<reviewer / bot>` — <what it covers>

- Re-review required after the last commit: yes / no — REQUIRED
- Human reviewer: `<name>` — OPTIONAL

### Standing rules for implementers — REQUIRED

These hold for every ticket and are never repeated in a ticket.

- Branch naming: `<pattern>`
- Commit titles: `<convention>`
- Attribution footers/trailers: `<allowed / forbidden>`
- Commits reference the ticket: `Closes #<n>` in the PR body — REQUIRED
- May the implementer push without asking: yes / no
- May the implementer open the PR: yes / no
- May the implementer force-push: `<no / only to its own branch before review>`
- Base branch: `<main>`
- Not authorized unless a ticket names it: merging, deploying, rewriting
  published history, adding dependencies, creating remote resources, touching
  other repositories
- If the evidence contradicts the ticket — the repository is not in the state
  described, a command does not exist, an instruction is impossible or
  self-contradictory — stop and report in the handoff. Do not silently adapt.
  If a design decision outside the ticket is required, report back. Do not
  improvise.
- The PR body ends with `## Handoff`, seven fields, skeleton in
  [`templates/handoff.md`](https://github.com/Lukapetro/playbook/blob/main/templates/handoff.md)

### Language conventions — REQUIRED

- Code, identifiers, comments: `<language>`
- Docs and READMEs: `<language>`
- Commit messages and PR text: `<language>`
- User-facing strings: `<language>`

### Merger — REQUIRED

- Who merges: `<name / role>` — never the implementer unless stated here
- Merge method: `<squash / merge / rebase>`
- Required checks before merge: `<list>`
