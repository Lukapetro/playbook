# PROTOCOL

The invariants of the orchestrator → implementer workflow. They hold in every
project. Anything project-specific (gate commands, reviewer chain, paths) lives
in that project's `AGENTS.md` bindings block, never here.

## 1. Roles

**Orchestrator.** Holds the plan across sessions. Prioritizes, decides what the
next work item is, writes the work order, and verifies the end state once the
implementer reports back. Never writes production code. Never merges on the
strength of a report alone.

**Implementer.** Takes exactly one work item, in a fresh session, with the work
order as its only context. Delivers a PR plus a handoff report. Does not expand
scope, does not pick up adjacent work it happens to notice — it records such
findings under Discoveries and moves on.

**Human.** Makes the decisions the agents are not allowed to make: product
direction, architecture, trade-offs with money or risk attached. Pastes work
orders. Owns billing, infrastructure, and credentials.

**Merger.** Merges the PR. May be a human other than the implementer, and in
practice usually is. The merger is the last gate: if the handoff does not match
the diff, the PR does not merge.

## 2. Principles

**Single writer at any moment.** One agent writes to a repository at a time.
Everything else is reading.

**Parallel sessions only on file-disjoint work.** Two implementers may run at
once only if the sets of files they will touch do not intersect. If you cannot
state the two file sets up front, the work is not disjoint.

**Review capacity is the scarce resource.** Not agent time, not tokens. Size
work items so the resulting diff is reviewable in one sitting. A work order that
produces an unreviewable PR is a badly written work order.

**Exploratory and design work never goes in a work order.** Work orders describe
work whose shape is already known. If the answer requires investigation, run the
investigation as its own session with its own output (a document, an ADR), then
write the work order from what it found.

**Repeated agent mistakes are fixed in the harness, never by longer prompts.**
When an agent makes the same mistake twice, the fix goes into `AGENTS.md`, a CI
check, or a hook. Prompts are not a durable medium: they are rewritten every
session and they get skimmed. The harness is not.

**The orchestrator never accepts a handoff report at face value.** Every claim
in a report is a hypothesis until re-run. The orchestrator verifies the end
state with reproducible commands — the same gate commands, on the same SHA — and
reads the diff. A report is evidence about the implementer, not about the code.

## 3. Enforcement ladder

Three rungs, in increasing cost and increasing reliability:

1. **Advisory** — say it in the prompt or the work order. Cheap, immediate, and
   forgotten by the next session.
2. **Repo policy** — write it into `AGENTS.md` or project docs. Survives
   sessions, still depends on the agent reading and honoring it.
3. **Deterministic** — a CI check, a git hook, a required status. Cannot be
   skipped, cannot be misread, costs the most to build and to maintain.

**Escalate one rung only after an observed failure.** Not in anticipation. A
deterministic check written for a mistake nobody has made yet is maintenance
burden bought with imaginary evidence. When the same failure crosses a rung
twice, move it up one — never two at once.

## 4. Work order template

Seven sections, in this order. The full skeleton is in
[`templates/work-order.md`](templates/work-order.md).

1. **CONTEXT** — what the implementer needs to know and cannot derive from the
   repository. The session is fresh: assume nothing carries over.
2. **OBJECTIVE** — the outcome, in one paragraph. Not a task list.
3. **BOUNDARIES** — what is in scope, and an explicit **FORBIDDEN ACTIONS**
   list. Name the repositories, files, and operations that are off limits.
   "Don't touch anything else" is not a boundary; a named list is.
4. **DONE WHEN** — executable postconditions. Each one is a command a third
   party can run, with the expected result. If a criterion cannot be checked by
   running something, rewrite it until it can.
5. **PROCEDURE & AUTHORIZATIONS** — the operations this work order authorizes:
   creating branches, pushing, opening PRs, creating remote resources. An
   operation not listed here is not authorized.
6. **IF SOMETHING DOESN'T ADD UP** — the standing instruction, verbatim in
   every work order: if the evidence contradicts the mandate, **stop and
   report; do not silently adapt**. If a design decision outside the mandate is
   required, **report back; do not improvise**.
7. **HANDOFF** — what the handoff must contain, and where it goes (the PR body).

## 5. Handoff report

The implementer ends by writing a handoff into the PR body. The canonical
heading is exactly:

```
## Handoff
```

Seven fields, all required, all present even when the answer is "nothing". The
skeleton is in [`templates/handoff.md`](templates/handoff.md); the CI check in
[`ci/check-handoff.sh`](ci/check-handoff.sh) enforces the heading and the field
labels.

| Field | Content |
| --- | --- |
| **Outcome** | What now exists that did not before. One paragraph. |
| **Gates** | Every gate command run, verbatim, with its numbers — test counts, error counts, exit status. A gate that was not run is stated as not run. |
| **Simplify** | What the simplification pass found. `nothing` is a valid, expected answer. |
| **Review** | Findings per reviewer, each marked founded or unfounded, how each founded one was closed, and whether the final SHA is covered by review: yes/no. |
| **Discoveries** | Out-of-scope findings, as backlog candidates. Not fixed in this PR. |
| **Deviations** | Every departure from the work order, with the reason. `none` is valid. |
| **State left** | Branch name, whether the state file was updated, whether the worktree is clean. |

Two rules about the fields. *Gates* carry numbers, not adjectives: "passing" is
not a gate report, "412 tests, 0 failures" is. *Review* distinguishes findings
that were real from findings that were not — an implementer that marks every
review comment as founded is not reviewing, it is complying.

## 6. Retro metrics

The orchestrator tracks four numbers per merged PR. They measure the protocol,
not the implementer.

| Metric | What it means when it rises |
| --- | --- |
| **Spec failure** | The work order was wrong or underspecified. Orchestrator's fault. Fix the template or the level of detail. |
| **Report/reality mismatch** | The handoff claimed something the diff or the gates contradict. Escalate the claim to a deterministic check. |
| **Pushes per PR** | Work items are too large, or the gates are not runnable locally. |
| **Post-merge fixes** | Review or gates are missing a class of defect. Add the check, do not add prose. |

**Prune template fields that never produce signal.** A field that is `nothing`
in twenty consecutive handoffs is ceremony. Remove it, here and in the
templates, and remove it from the CI check in the same change.
