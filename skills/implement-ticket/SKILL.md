---
name: implement-ticket
description: Implement one ticket from the issue tracker in this session, test-first at its seams, through the gates, simplified, reviewed, and delivered as a PR with a handoff.
disable-model-invocation: true
argument-hint: "<issue number or URL>"
---

Implement exactly one ticket. Invoking this skill is the authorization to
create the branch, commit, push and open the PR that the repository's
`AGENTS.md` bindings describe. It is never the authorization to merge.

The bindings block in `AGENTS.md` holds the gates, the standing rules
(branch pattern, commit convention, what is not authorized) and the language
conventions. Read it before anything else; every step below refers to it.

## 1. Take the ticket

- Resolve the argument to an issue: `gh issue view <n> --comments`.
- Read everything the **Context** section points at: the spec issue, the
  `CONTEXT.md` terms, the ADRs, the prior PRs. Use the glossary's words in
  code, tests and prose.
- If the ticket is unassigned, claim it: `gh issue edit <n> --add-assignee @me`.

**Not ready, do not start** when any of these holds: **Done when** has no
runnable command, **Forbidden actions** is missing, the repository is not in
the state the ticket describes, a command it names does not exist, or two
instructions contradict each other. Comment on the issue with what you found
and stop. Adapting silently is the one failure this protocol cannot recover
from.

## 2. Branch

From the base branch, named by the bindings' pattern. Never touch another
person's changes in the worktree: if it is not clean, stop and say so.

## 3. Build

Call the Skill tool with "tdd". The seams are the ones **Done when** names;
no test at a seam the ticket did not agree. One slice at a time: red, green,
type checker, next slice. The full suite once, at the end.

Stay inside **Boundaries**. Anything adjacent you notice goes into the
handoff under Discoveries, not into the diff. A design decision the ticket
does not cover is reported, not improvised.

Done when every **Done when** command runs and returns what the ticket says.

## 4. Gates

Run every command in the bindings' gates table, verbatim, from the directory
it names. Keep the numbers: tests run, failures, errors, exit status. Read
exit codes, never filtered output. A gate you cannot run (missing binary,
missing credential) is reported as not run, with the reason.

## 5. Simplify

Call the Skill tool with "simplify" on the whole diff against the base branch.
Re-run the affected tests. The code that is reviewed, tested and pushed must
be the same code.

## 6. Review

Call the Skill tool with "code-review": fixed point is the base branch, the
spec is this ticket. Fix every founded finding, on both axes; record the
unfounded ones with the reason. Re-run the gates if anything changed.

## 7. State

If the bindings say the implementer updates `itaca.yml`: move this ticket
out of `doing` and write the `next_safe_action` that follows from it, under
the caps. Nothing else in that file.

## 8. Deliver

Commit per the bindings' convention, no attribution trailers unless allowed.
Push. Open the PR against the base branch with:

- a short description of what changed and why,
- `Closes #<n>`,
- the `## Handoff` section: seven fields, all present, numbers not
  adjectives, Review distinguishing founded from unfounded, Deviations
  naming every departure from the ticket. Skeleton in
  `docs/protocol/handoff.md` if the project carries it, otherwise in
  [templates/handoff.md](https://github.com/Lukapetro/playbook/blob/main/templates/handoff.md).

Stop when the PR is open and its checks are green. Report the PR URL and the
handoff. Do not merge.
