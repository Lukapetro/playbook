# Ticket — <title>

> Paste-ready skeleton for the body of a ticket on the issue tracker. Five
> sections, in this order. `/to-tickets` drafts the first three fields; the
> shaping session fills the rest before the ticket gets `ready-for-agent`.
> Delete the angle-bracket placeholders and the quoted guidance. See
> [`../PROTOCOL.md`](../PROTOCOL.md) §5.

## Context

> Pointers the implementer cannot derive from the repository. The session is
> fresh: nothing carries over. Pointers, never copies.

- Spec: #<n>
- Terms (`CONTEXT.md`): <term>, <term>
- Decisions in this area: <ADR-NNNN>
- Prior work: #<PR>

## What to build

> The end-to-end behaviour this ticket makes work, from the user's
> perspective. Not a task list, not a layer, no file paths.

<What is true for a user when this is done.>

## Boundaries

In scope:

- <directory, subsystem, or module this ticket may change>

Forbidden actions:

- Do NOT <named directory / file / repository that must not be touched>
- Do NOT <operation: adding dependencies, touching migrations, deploying, ...>
- Do NOT <the scope expansion the implementer is likely to be tempted by>

> Anything beyond the standing authorizations in `AGENTS.md` (a remote
> resource to create, a dependency to add) is named here or does not exist:

Additionally authorized: <none>

## Done when

> Executable postconditions: a command plus its expected result. If a
> criterion cannot be checked by running something, rewrite it until it can.

- `<command>` exits 0
- `<command>` reports <expected numbers>
- Tests at the seam `<interface>` cover <behaviour>

## Blocked by

<#n, #m as native blocking links, or "None (can start immediately)">
