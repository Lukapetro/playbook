# itaca v2 — state convention

itaca is the per-repo state file: what an agent must know about a project
before it can do anything useful, committed next to the code.

**v2 is a breaking change from v1.** v1 mixed hot state (`status.phase`,
`status.next`) with an append-only narrative log (`status.log`, up to 20
entries) in a single file. In practice the log grew until the file stopped
being readable at a glance — which is the only job the file has.

**Revision of 2026-08-25.** The first v2 kept a `journal/` directory and a
`done` list beside the hot state. Both duplicated a home that already existed:
the record of a session is its PR, the changelog is git and the tracker. On the
first project that ran v2 for two weeks the file reached 331 lines against a
cap of 60, `done` held 23 items against a cap of 5, and the journal held 47
files against a decay threshold of 20. The duplicates are gone; the caps are
now a CI check (`ci/check-itaca.sh`), per the enforcement ladder.

## 1. `itaca.yml` — hot state only

**Hard cap: 60 lines**, enforced. If the file does not fit, the content does
not belong in it. No history, no log, no decision records, no backlog — each of
those has a home below.

```yaml
version: 2
state:
  goal: Ship the v2 importer behind a flag
  doing:
    - Importer CSV parser — #142
    - Flag wiring in settings — #145
  blockers:
    - Staging S3 bucket credentials not provisioned
  next_safe_action: Dispatch #147 (parser timings on fixtures/large.csv)
  assumptions:
    - Source files are always UTF-8; unverified against customer exports
updated: 2026-08-25
```

### Fields

| Field | Meaning |
| --- | --- |
| `version` | Always `2`. |
| `state.goal` | One line: the outcome currently pursued. Not the mission of the project — the thing being worked toward right now. |
| `state.doing` | Work items in flight, each with its ticket or PR reference. Empty list if nothing is in flight. |
| `state.blockers` | Hard blockers only — things that make the next action impossible. Not risks, not annoyances. |
| `state.next_safe_action` | The single next action that is safe to take without asking anyone. One line. This is the field a fresh session reads first. |
| `state.assumptions` | Unverified assumptions that would invalidate work in flight if false. Removed once verified. |
| `updated` | `YYYY-MM-DD`, the day the state was last touched. |

Schema: [`schema-v2.json`](schema-v2.json). List caps, enforced by the schema
and by the check: `doing` ≤ 3, `blockers` ≤ 3, `assumptions` ≤ 5. Hitting a
cap means the state is being used as a backlog; move the overflow to the
tracker, not into the file.

The tracker URL is not in the file: `gh` infers it from the clone. The
vocabulary and decision homes are fixed by the protocol (`CONTEXT.md`,
`docs/adr/`), so they are not pointers here either.

## 2. Where everything else lives

| What | Home | Written by |
| --- | --- | --- |
| The plan: spec, tickets, blocking edges, what is done | The issue tracker | Shaping session (`/to-spec`, `/to-tickets`), orchestrator |
| The record of a session: what was done, how it was verified, what was found | The PR body, `## Handoff` | Implementer |
| The project's vocabulary | `CONTEXT.md`, glossary only | `/domain-modeling`, inside shaping |
| Hard-to-reverse decisions | `docs/adr/NNNN-slug.md` | `/domain-modeling`, inside shaping |
| Assumptions that would invalidate work in flight | `itaca.yml` (≤ 5) | Whoever finds one; whoever verifies it removes it |

**ADRs** follow the format and the threshold of
[`domain-modeling`](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md):
one is written only when the decision is hard to reverse, surprising without
context, and the result of a real trade-off. Most sessions write none. An ADR
is never edited once accepted, except to mark it superseded by a later one.

**`CONTEXT.md`** follows
[`CONTEXT-FORMAT.md`](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/CONTEXT-FORMAT.md):
one term, one or two sentences, the words to avoid. No implementation detail,
ever; the moment it absorbs one it stops being a glossary.

There is no journal. A session that changed nothing worth a PR leaves a
comment on the ticket it worked on, or nothing.

## 3. Migration

### From the first v2 (journal + `done`)

One commit, no code:

1. Delete `state.done` and `links` from `itaca.yml`; move anything in
   `decisions` worth keeping to `docs/adr/` (most of it is not: a decision that
   is not hard to reverse does not need a record).
2. Trim `state.assumptions` to the five that would invalidate work in flight;
   the rest are either verified (delete) or risks (tracker).
3. Delete `journal/`. Git history keeps every file. If an entry records a
   decision that meets the ADR threshold, write the ADR first.
4. Run `bash ci/check-itaca.sh itaca.yml` until it passes.

### From v1

| v1 | v2 |
| --- | --- |
| `version: 1` | `version: 2` |
| `status.phase` | fold into `state.goal` |
| `status.next` | `state.next_safe_action` |
| `status.updated` | `updated` |
| `status.commit` | dropped — git knows |
| `status.log[]` | dropped — git history keeps the file; decisions that meet the ADR threshold become ADRs |
| `links[]` (title/url pairs) | dropped — dashboards belong in the README or in `itaca`'s machine registry |
| `name`, `description` | dropped — the README says what the project is |
| `overrides.disable` | dropped — v2 derives nothing, so there is nothing to suppress |

After migration: `itaca.yml` is under 60 lines and contains no history. If it
does not, the migration is not finished.

## 4. CLI

**Specification only. Nothing in this repository implements it.** The
reference implementation is [Lukapetro/itaca](https://github.com/Lukapetro/itaca).

| Command | Behaviour |
| --- | --- |
| `itaca context` | Print hot state as compact text on stdout. Intended for a `SessionStart` hook, so an agent opens a fresh session already knowing `goal`, `doing`, `blockers`, `next_safe_action`, `assumptions`. Exit non-zero if `itaca.yml` is missing or not v2. |
| `itaca check` | Same checks as `ci/check-itaca.sh`, for a `Stop` hook. |
| `itaca handoff` | Print the `## Handoff` skeleton on stdout, seven fields, ready to paste into a PR body. |
| `itaca init-protocol` | Scaffold the playbook files into a repository: `ci/check-handoff.sh`, `ci/check-itaca.sh`, `.github/workflows/protocol.yml`, an empty `itaca.yml` v2, `docs/protocol/`, and the bindings block appended to `AGENTS.md`. Idempotent on the `## Agent protocol bindings` heading. |
