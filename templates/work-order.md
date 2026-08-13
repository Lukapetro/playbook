# Work order — <title>

> Paste-ready skeleton. Seven sections, in this order. Delete the angle-bracket
> placeholders and the quoted guidance before sending. See
> [`../PROTOCOL.md`](../PROTOCOL.md) §4.

## CONTEXT

> What the implementer cannot derive from the repository. The session is fresh:
> nothing carries over from previous sessions or conversations.

<Why this work exists. Which project, which state it is in, what already
happened that matters. Links to specs, ADRs, prior PRs.>

## OBJECTIVE

> The outcome, one paragraph. Not a task list — the task list is the
> implementer's job.

<What must be true when this is done.>

## BOUNDARIES

In scope:

- <files, directories, or subsystems this work may modify>

### FORBIDDEN ACTIONS

- Do NOT <named repository / directory / file that must not be touched>
- Do NOT <operation that must not happen: merging, deploying, rotating keys,
  making a repo public, adding dependencies, ...>
- Do NOT <scope expansion the implementer is likely to be tempted by>

## DONE WHEN

> Executable postconditions. Each line is a command plus its expected result.
> If a criterion cannot be checked by running something, rewrite it.

- `<command>` exits 0
- `<command>` reports <expected numbers>
- `<gh / git command>` shows <expected state>

## PROCEDURE & AUTHORIZATIONS

This work order authorizes:

- <creating branch `<name>`; committing; pushing; opening a PR toward `<base>`>
- <creating remote resources, if any — name them>

Not authorized unless listed above: merging, deploying, force-pushing,
rewriting published history, adding dependencies, touching other repositories.

Conventions:

- Commit titles: <convention, e.g. Conventional Commits>
- <attribution / footer rules>
- <language conventions for code, docs, and PR text>

## IF SOMETHING DOESN'T ADD UP

If the evidence contradicts this mandate — the repository is not in the state
described, a command does not exist, an instruction is impossible or
self-contradictory — **stop and report. Do not silently adapt.**

If a design decision outside this mandate is required, **report back. Do not
improvise.**

Report by writing what you found in the Handoff section and leaving the
decision to the orchestrator.

## HANDOFF

Write the handoff into the PR body, under the exact heading `## Handoff`, with
all seven fields: Outcome, Gates, Simplify, Review, Discoveries, Deviations,
State left. Skeleton: [`handoff.md`](handoff.md).

Stop when the PR is open and green. Do not merge.
