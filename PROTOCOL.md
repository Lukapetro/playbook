# PROTOCOL

The invariants of the shaping → implementer → orchestrator workflow. They hold
in every project. Anything project-specific (gate commands, reviewer chain,
labels, paths) lives in that project's `AGENTS.md` bindings block, never here.

## 1. Roles

**Orchestrator.** Decides what the next work item is, hands it to an
implementer, and verifies the end state once the implementer reports back.
Reads the plan from the issue tracker and the hot state from `itaca.yml`; it
never holds the plan in its own context, because a context ends and a tracker
does not. Never writes production code. Never merges on the strength of a
report alone.

**Implementer.** Takes exactly one ticket, in a fresh session, with the ticket
as its only context. Delivers a PR plus a handoff report. Does not expand
scope, does not pick up adjacent work it happens to notice — it records such
findings under Discoveries and moves on.

**Human.** Makes the decisions the agents are not allowed to make: product
direction, architecture, trade-offs with money or risk attached. Answers the
grilling. Owns billing, infrastructure, and credentials.

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
tickets so the resulting diff is reviewable in one sitting. A ticket that
produces an unreviewable PR is a badly written ticket.

**Shaping never goes in a ticket.** A ticket describes work whose shape is
already known. Finding the shape — what to build, where the seams are, which
words mean what — is a shaping session (§3), and its output is the spec and
the tickets. A question that needs investigation is a shaping session or a
research task, never a line in a ticket.

**Facts to the agent, decisions to the human.** Anything that can be looked up
(the filesystem, the docs, the tracker) is the agent's job to find. Anything
that is a choice is the human's job to make. An agent that answers its own
decisions has broken the protocol.

**One home per fact.** The plan lives in the tracker. Hot state lives in
`itaca.yml`. Vocabulary lives in `CONTEXT.md`. Hard-to-reverse decisions live
in `docs/adr/`. The record of a session lives in its PR. Nothing is written in
two of these; when it is, one copy is already stale.

**Repeated agent mistakes are fixed in the harness, never by longer prompts.**
When an agent makes the same mistake twice, the fix goes into `AGENTS.md`, a
skill, a CI check, or a hook. Prompts are not a durable medium: they are
rewritten every session and they get skimmed. The harness is not.

**The orchestrator never accepts a handoff report at face value.** Every claim
in a report is a hypothesis until re-run. The orchestrator verifies the end
state with reproducible commands — the same gate commands, on the same SHA —
and reads the diff against the ticket. A report is evidence about the
implementer, not about the code.

## 3. Sessions

Three kinds of session. Each one starts with an empty context; what it needs
comes from the tracker, `itaca.yml`, `CONTEXT.md` and the repository, never
from a previous session's memory.

### Shaping

Human and agent, in conversation. Input: an idea, or the next patch of fog
named by `next_safe_action`.

1. `/grill-with-docs` — the agent interviews the human in rounds until every
   branch of the design tree is settled. Facts are fetched by the agent;
   decisions are put to the human. Terms are sharpened into `CONTEXT.md` and
   hard-to-reverse choices into `docs/adr/` as they land, never afterwards.
   When a question needs a runnable answer, detour through `/prototype`; when
   it needs reading, dispatch `/research` and carry on.
2. `/to-spec` — the conversation becomes one spec issue on the tracker. No new
   questions: it records what was decided.
3. `/to-tickets` — the spec becomes tracer-bullet tickets, each a vertical
   slice that fits one fresh session, each declaring what blocks it.
4. Review every ticket against §5 before the session ends. A ticket without an
   executable **Done when** or a named **Forbidden actions** list is not ready
   and does not carry the `ready-for-agent` label.

Steps 1 to 3 stay in one context window: the spec and the tickets are written
from the reasoning, not from a summary of it. If the window approaches the
smart zone (~150k tokens) before the tickets are out, the scope was too big —
split the effort, don't push on degraded.

### Implementer

Agent alone, fresh context. Input: one ticket, through `/implement-ticket`.

1. Read the ticket and everything it points at. If the repository is not in
   the state the ticket describes, a command does not exist, or an instruction
   is impossible or self-contradictory: **stop and report. Do not silently
   adapt.** If a design decision outside the ticket is required: **report
   back. Do not improvise.**
2. Build test-first at the seams the ticket names (`/tdd`). One slice at a
   time; the type checker after every slice; the full suite once at the end.
3. Run every gate from the bindings and keep the numbers.
4. Simplify the whole diff (`/simplify`). The code reviewed, tested and pushed
   must be the same code.
5. `/code-review` against the base branch: **Standards** (the repository's
   rules) and **Spec** (does the diff do what the ticket asked, and nothing
   else). Fix what is founded; record what is not.
6. Open the PR with the `## Handoff` section (§6). Stop when the PR is open
   and its checks are green. Do not merge.

### Orchestrator

Human and agent. Input: `itaca context` plus the **frontier** — the tickets
labelled `ready-for-agent` with no open blocker and no assignee.

The session does exactly one of:

- **Shape.** The frontier is empty or the next item is fog: open a shaping
  session.
- **Dispatch.** Hand the first frontier ticket to an implementer. The ticket
  URL is the whole prompt: `/implement-ticket <url>` in a fresh session. The
  orchestrator claims the ticket by assigning it first, so a parallel session
  skips it.
- **Verify.** A PR is up: `/verify-pr`. Re-run the gates on the PR's head SHA,
  read the diff against the ticket and the handoff, apply the retro labels
  (§7), update `itaca.yml`. Then hand the PR to the merger.

### Phase boundaries

A phase ends when you think "ok, we're done with that". Only there do you
choose what to do with the context, in this order, first yes wins:
**continue** (the next phase needs this one verbatim, and there is room);
**`/clear`** (nothing here matters to what's next); **`/handoff`** (something
is travelling: a new harness, a new directory, a colleague); **subagent** (the
next task runs unattended); **`/compact`** (everything else — the default,
not the first reach). Mid-phase there is no decision: continue, or split the
remainder into subagents. The reasoning is in
[mattpocock/skills, PHASE-BOUNDARIES.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/ask-matt/PHASE-BOUNDARIES.md).

## 4. Enforcement ladder

Three rungs, in increasing cost and increasing reliability:

1. **Advisory** — say it in the prompt or the ticket. Cheap, immediate, and
   forgotten by the next session.
2. **Repo policy** — write it into `AGENTS.md`, a skill, or project docs.
   Survives sessions, still depends on the agent reading and honoring it.
3. **Deterministic** — a CI check, a git hook, a permission rule, a required
   status. Cannot be skipped, cannot be misread, costs the most to build and
   to maintain.

**Escalate one rung only after an observed failure.** Not in anticipation. A
deterministic check written for a mistake nobody has made yet is maintenance
burden bought with imaginary evidence. When the same failure crosses a rung
twice, move it up one — never two at once.

The rule applies to this protocol too. A cap that is written down and
exceeded has failed at rung two; the next PR gives it a check.

## 5. Ticket

A ticket is the unit of work and the implementer's only context. Five
sections, in this order. The full skeleton is in
[`templates/ticket.md`](templates/ticket.md); `/to-tickets` produces the
first draft, the shaping session brings it to this shape.

1. **Context** — what the implementer needs and cannot derive from the
   repository: the spec issue, the `CONTEXT.md` terms involved, the ADRs in
   the area, the prior PRs that matter. Pointers, never copies.
2. **What to build** — the end-to-end behaviour this ticket makes work, from
   the user's perspective. Not a task list, not a layer.
3. **Boundaries** — what is in scope (directories, subsystems), and an
   explicit **Forbidden actions** list. "Don't touch anything else" is not a
   boundary; a named list is. Any authorization beyond the standing ones in
   the bindings (a remote resource to create, a dependency to add) is named
   here or does not exist.
4. **Done when** — executable postconditions, each a command a third party can
   run with its expected result, plus the seams the tests go at. If a
   criterion cannot be checked by running something, rewrite it until it can.
5. **Blocked by** — the tickets that gate this one, as the tracker's native
   blocking links. "None" is valid.

Three properties, all required: it is a **vertical slice** (every layer of the
change, demoable on its own), it **fits one fresh context window**, and it
**carries no file paths or line numbers** in *What to build* — they go stale
before the ticket is picked up. Prefactoring is its own ticket, and comes
first. A wide mechanical refactor does not fit a slice: sequence it as
expand → migrate → contract, each step a ticket blocked by the previous one.

The rules every ticket used to repeat — what the implementer may push, how to
report, what to do when something doesn't add up — are written once, in the
bindings block and in §3. A ticket that restates them is caching the harness.

## 6. Handoff report

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
| **Review** | Findings per reviewer, `/code-review` axes included, each marked founded or unfounded, how each founded one was closed, and whether the final SHA is covered by review: yes/no. |
| **Discoveries** | Out-of-scope findings, as backlog candidates. Not fixed in this PR. |
| **Deviations** | Every departure from the ticket, with the reason. `none` is valid. |
| **State left** | Branch name, whether `itaca.yml` was updated, whether the worktree is clean. |

Two rules about the fields. *Gates* carry numbers, not adjectives: "passing" is
not a gate report, "412 tests, 0 failures" is. *Review* distinguishes findings
that were real from findings that were not — an implementer that marks every
review comment as founded is not reviewing, it is complying.

## 7. Retro metrics

Four numbers per merged PR. They measure the protocol, not the implementer,
and none of them is counted by hand: three are labels the orchestrator applies
during `/verify-pr`, one is derived from git.

| Metric | Recorded as | What it means when it rises |
| --- | --- | --- |
| **Spec failure** | label `retro:spec-failure` on the PR | The ticket was wrong or underspecified. Shaping's fault. Fix the template or the level of detail. |
| **Report/reality mismatch** | label `retro:mismatch` on the PR | The handoff claimed something the diff or the gates contradict. Escalate the claim to a deterministic check. |
| **Pushes per PR** | the PR's commit count | Tickets are too large, or the gates are not runnable locally. |
| **Post-merge fixes** | label `retro:post-merge-fix` on the *fixing* PR, whose body names the PR it repairs | Review or gates are missing a class of defect. Add the check, do not add prose. |

`scripts/retro.sh` prints the four numbers over the last N merged PRs. Read
them every ten PRs; the metric that rises names the rung to climb.

**Prune template fields that never produce signal.** A field that is `nothing`
in twenty consecutive handoffs is ceremony. Remove it, here and in the
templates, and remove it from the CI check in the same change.

## 8. Skills

The protocol is executed through two skill sets, installed once per machine,
never copied into a project:

- **[mattpocock/skills](https://github.com/mattpocock/skills)**, as the
  `mattpocock-skills` plugin. The protocol uses `grill-with-docs`, `to-spec`,
  `to-tickets`, `code-review` and `handoff` (user-invoked), and `grilling`,
  `domain-modeling`, `tdd`, `diagnosing-bugs`, `codebase-design`,
  `writing-for-agents`, `research` and `prototype` (model-invoked). The other
  skills in the plugin are not part of the protocol.
- **This repository's `skills/`**: `implement-ticket` and `verify-pr` run the
  two agent sessions of §3; `simplify` is the pass of §3 step 4; `fix-bugbot`
  handles review-bot findings on an open PR.

One rule governs both sets: **a skill that writes to a remote** — pushes,
opens a PR, applies labels, posts comments — **is user-invoked**. Only the
human fires it, and no other skill can.
