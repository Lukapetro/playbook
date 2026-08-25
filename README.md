# playbook

The operating manual for agent-driven projects.

I run several projects with the same workflow: a **shaping** session turns an
idea into a spec and tickets, an **implementer** agent executes exactly one
ticket per fresh session and delivers a PR plus a handoff report, an
**orchestrator** session verifies the result and picks the next ticket, and a
human decides and merges. That protocol used to live scattered across per-repo
docs and ad-hoc prompts, which meant it drifted: every project ended up with a
slightly different version, and improvements learned in one never reached the
others.

This repository is its canonical, portable home.

## The four pieces

**1. The protocol — [`PROTOCOL.md`](PROTOCOL.md).** The invariants. Roles, the
principles that constrain how work is split, the three kinds of session, the
enforcement ladder (advisory → repo policy → deterministic), the ticket
structure, the handoff report, and the retro metrics that tell you when the
protocol itself is failing. Universal: nothing project-specific ever goes here.

**2. The skills.** The protocol runs on two skill sets installed once per
machine: [mattpocock/skills](https://github.com/mattpocock/skills) for the
shaping half (grilling, glossary, spec, tickets, TDD, review) and this
repository's `skills/` for the two agent sessions (`implement-ticket`,
`verify-pr`) plus `simplify` and `fix-bugbot`. Neither set is copied into a
project. `PROTOCOL.md` §8 names exactly which skills the protocol uses.

**3. Per-project bindings — [`templates/agents-bindings.md`](templates/agents-bindings.md).**
Everything the protocol deliberately leaves open: which commands are the gates,
who reviews, who merges, what an implementer is authorized to push, which
language the code and docs are written in. Pasted into each repository's
`AGENTS.md` and filled in there. The protocol says "run the gates"; the
bindings say what the gates are.

**4. The state — [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md).** A fresh session
starts with no memory. `itaca.yml` gives it one: hot state and only hot state
(goal, in flight, blockers, the next safe action, unverified assumptions),
under 60 lines, checked in CI. The plan lives in the tracker, the vocabulary in
`CONTEXT.md`, the decisions in `docs/adr/`, the record of each session in its
PR. One home per fact.

Protocol tells the agent how to work. Skills make it do so. Bindings tell it
how to work *here*. itaca tells it where things stand.

## Day to day

One loop, three kinds of session. Everything you type is a slash command;
everything the agent needs is already in the repository or on the tracker, so
no session starts by pasting context.

**1. Shape** — you and the agent, one session, one idea.

```
/grill-with-docs      describe the idea; answer each round by number ("Q1 yes, Q2 the second option")
/to-spec              the conversation becomes one issue
/to-tickets           the spec becomes tickets with blocking edges
```

Before closing: read each ticket against `docs/protocol/ticket.md`. Runnable
**Done when**, named **Forbidden actions**, then the `ready-for-agent` label.
The glossary (`CONTEXT.md`) and the decisions (`docs/adr/`) were written while
you were answering; you did not have to.

**2. Implement** — the agent alone, a fresh session per ticket.

```
/implement-ticket <issue url>     builds test-first, runs the gates, simplifies, reviews, opens the PR
/fix-bugbot <pr>                  only if the review bots left findings
/clear                            the ticket is done; nothing here matters to the next one
```

**3. Verify and merge** — you and the agent.

```
/verify-pr <pr>       re-runs the gates on that SHA, reads the diff against the ticket, labels, verdict
```

Then you merge. The next session opens on `itaca context`: `next_safe_action`
names the next frontier ticket (back to 2) or the next patch of fog (back
to 1).

Every ten merged PRs: `bash scripts/retro.sh`. The number that rises names
the rung to climb; nothing else changes the protocol.

### When something else happens

| Situation | Type |
| --- | --- |
| A hard bug, a flake, a regression | `/diagnosing-bugs` |
| A design question that needs running code to answer | `/prototype` |
| Reading legwork you want done while you keep working | `/research` |
| The agent's last message did not land | `/wait-what` |
| Moving this work to another machine, harness or person | `/handoff` |
| A fuzzy term, or a decision worth an ADR, outside a shaping session | `/domain-modeling` |
| A merge or rebase conflict | `/resolving-merge-conflicts` |
| Nothing fits | `/ask-matt` |

### Three things you never do

- Paste a ticket into a prompt. The ticket URL is the prompt.
- Merge from an agent session. The agent stops at "PR open and green".
- Let a session hold the plan. It lives on the tracker; `itaca.yml` says only what is next.

## Contents

| Path | What it is |
| --- | --- |
| [`PROTOCOL.md`](PROTOCOL.md) | The invariants. Read this first. |
| [`INSTALL.md`](INSTALL.md) | Installing the protocol on a project. |
| [`templates/ticket.md`](templates/ticket.md) | Paste-ready ticket body, five sections. |
| [`templates/handoff.md`](templates/handoff.md) | Paste-ready `## Handoff` PR section, seven fields. |
| [`templates/agents-bindings.md`](templates/agents-bindings.md) | The per-project block for `AGENTS.md`. |
| [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md) | itaca v2: state file, where everything else lives, migration, CLI. |
| [`itaca/schema-v2.json`](itaca/schema-v2.json) | JSON Schema for `itaca.yml` v2. |
| [`skills/`](skills/) | `implement-ticket`, `verify-pr`, `simplify`, `fix-bugbot`. Installed with `npx skills add Lukapetro/playbook`. |
| [`scripts/retro.sh`](scripts/retro.sh) | The four retro metrics over the last N merged PRs. |
| [`ci/check-handoff.sh`](ci/check-handoff.sh) | Dependency-free check: PR body carries a conforming handoff. |
| [`ci/check-itaca.sh`](ci/check-itaca.sh) | Check: `itaca.yml` is v2, under 60 lines, within caps. |
| [`ci/protocol.yml`](ci/protocol.yml) | Copy-in GitHub Actions workflow that runs both checks. |
| [`ci/fixtures/`](ci/fixtures/) | Passing and failing PR bodies and state files. |
| [`ci/test-check-handoff.sh`](ci/test-check-handoff.sh), [`ci/test-check-itaca.sh`](ci/test-check-itaca.sh) | Test runners for the checks. |

## Scope

Documents, skills as Markdown files, two bash checks, one JSON Schema, one
workflow file. No dependencies beyond `gh` and a `python3` with PyYAML for the
state check; no build step, no package manager.

The itaca CLI described in [`SPEC-V2.md`](itaca/SPEC-V2.md) §4 is **specified
here, implemented elsewhere**.

## Using it

```bash
bash ci/test-check-handoff.sh && bash ci/test-check-itaca.sh   # verify the CI checks still work
```

To install on a project, follow [`INSTALL.md`](INSTALL.md).
