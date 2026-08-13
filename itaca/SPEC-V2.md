# itaca v2 — state convention

itaca is the per-repo state file: what an agent must know about a project
before it can do anything useful, committed next to the code.

**v2 is a breaking change from v1.** v1 mixed hot state (`status.phase`,
`status.next`) with an append-only narrative log (`status.log`, up to 20
entries) in a single file. In practice the log grew until the file stopped
being readable at a glance — which is the only job the file has. v2 splits the
two: `itaca.yml` holds hot state and nothing else, narrative moves to
`journal/`, and decisions move to ADRs under `docs/decisions/`.

## 1. `itaca.yml` — hot state only

**Hard cap: ~60 lines.** If the file does not fit, the content does not belong
in it. No prose log, no history, no decision records — those have their own
homes below.

```yaml
version: 2
state:
  goal: Ship the v2 importer behind a flag
  doing:
    - Importer CSV parser — PR #142
    - Flag wiring in settings — PR #145
  done:
    - Schema migration landed — PR #138
    - Fixture corpus checked in — PR #139
  blockers:
    - Staging S3 bucket credentials not provisioned
  next_safe_action: Run the parser against fixtures/large.csv and record timings
  assumptions:
    - Source files are always UTF-8; unverified against customer exports
decisions: docs/decisions/
links:
  board: https://linear.app/acme/project/importer
  journal: journal/
updated: 2026-08-13
```

### Fields

| Field | Meaning |
| --- | --- |
| `version` | Always `2`. |
| `state.goal` | One line: the outcome currently pursued. Not the mission of the project — the thing being worked toward right now. |
| `state.doing` | Work items in flight, each with its PR reference. Empty list if nothing is in flight. |
| `state.done` | Last ~5 completed items. Pruned aggressively: this is a short-term memory aid, not a changelog. Git history is the changelog. |
| `state.blockers` | Hard blockers only — things that make the next action impossible. Not risks, not annoyances. |
| `state.next_safe_action` | The single next action that is safe to take without asking anyone. One line. This is the field a fresh session reads first. |
| `state.assumptions` | Unverified assumptions that would invalidate work in flight if false. Removed once verified. |
| `decisions` | Pointer only, conventionally `docs/decisions/`. Decisions themselves never live in this file. |
| `links.board` | OPTIONAL — tracker URL. |
| `links.journal` | Journal directory, conventionally `journal/`. |
| `updated` | `YYYY-MM-DD`, the day the state was last touched. |

Schema: [`schema-v2.json`](schema-v2.json).

List caps, enforced by the schema: `doing` ≤ 3, `done` ≤ 5, `blockers` ≤ 3,
`assumptions` ≤ 5. Hitting a cap means the state is being used as a backlog;
move the overflow to the board, not into the file.

## 2. `journal/` — narrative

One markdown file per significant session, named `YYYY-MM-DD-slug.md`. A
session that changed nothing worth explaining gets no file.

```markdown
---
date: 2026-08-13
scope: importer parser
prs: [142, 145]
---

Started from the fixture corpus. The streaming parser choked on quoted
newlines, which the v1 importer silently dropped — see PR #142 for the
reproduction. Chose to fail loudly instead of matching v1 behaviour; the
customer-facing consequence is written up in ADR 0007.

Left the flag off in production. Next session should run the timing pass
before widening the rollout.
```

Frontmatter: `date` (required), `scope` (required, a few words), `prs`
(optional list). Body: prose. Why, not what — the diff already says what.

### Decay rule

When `journal/` exceeds **20 files**, or entries are older than **60 days**,
compress the oldest into **one paragraph each** in `journal/ARCHIVE.md` and
delete the originals. Git history preserves the full text; the working tree
stays readable. Run the compression as its own commit, never mixed with code.

## 3. ADRs — `docs/decisions/NNNN-slug.md`

Zero-padded four-digit sequence, e.g. `0007-fail-on-quoted-newlines.md`.

```markdown
# 0007 — Fail on quoted newlines instead of dropping rows

**Status:** accepted

## Context
<the forces: what was true, what was constrained, what was unknown>

## Decision
<what was decided, in the active voice>

## Consequences
<what this makes easy, what it makes hard, what it commits us to>
```

`Status` is either `accepted` or `superseded-by NNNN`.

**Append-only.** An ADR is never edited after it is accepted — except to change
its `Status` line to `superseded-by NNNN`. Changing your mind means writing a
new ADR that supersedes the old one. The record of what you believed and when
is the point.

## 4. Migration from v1

Mechanical, one commit:

| v1 | v2 |
| --- | --- |
| `version: 1` | `version: 2` |
| `status.phase` | fold into `state.goal` |
| `status.next` | `state.next_safe_action` |
| `status.updated` | `updated` |
| `status.commit` | dropped — git knows |
| `status.log[]` | one `journal/YYYY-MM-DD-slug.md` per entry, using the entry's `date`; the note becomes the body |
| `links[]` (title/url pairs) | `links.board` if a tracker, otherwise drop or move into the README |
| `name`, `description` | dropped — the README says what the project is |
| `overrides.disable` | dropped — v2 derives nothing, so there is nothing to suppress |

Then read the new journal files and extract any decision they record into an
ADR under `docs/decisions/`, numbered from `0001` in chronological order. The
journal entry keeps the narrative; the ADR gets the decision.

After migration: `itaca.yml` should be under 60 lines and contain no history.
If it does not, the migration is not finished.

## 5. CLI v2 roadmap

**Specification only. Nothing in this repository implements it.**

| Command | Behaviour |
| --- | --- |
| `itaca context` | Print hot state as compact text on stdout. Intended for a `SessionStart` hook, so an agent opens a fresh session already knowing `goal`, `doing`, `blockers`, `next_safe_action`, `assumptions`. Exit non-zero if `itaca.yml` is missing or not v2. |
| `itaca journal add <slug>` | Create `journal/YYYY-MM-DD-<slug>.md` with the frontmatter pre-filled, open it in `$EDITOR`. |
| `itaca handoff` | Print the `## Handoff` skeleton on stdout, seven fields, ready to paste into a PR body. |
| `itaca decay` | Apply the §2 decay rule: compress journal entries past the thresholds into `journal/ARCHIVE.md` and delete the originals. Dry-run by default. |
| `itaca init-protocol` | Scaffold the playbook files into a repository: templates, `ci/check-handoff.sh`, `ci/handoff.yml`, an empty `itaca.yml` v2, `journal/`, `docs/decisions/`, and the bindings block appended to `AGENTS.md`. |
