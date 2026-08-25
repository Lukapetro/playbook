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

### Three things you never do

- Paste a ticket into a prompt. The ticket URL is the prompt.
- Merge from an agent session. The agent stops at "PR open and green".
- Let a session hold the plan. It lives on the tracker; `itaca.yml` says only what is next.

## Skills, by when you reach for them

Two sets, one machine install ([`INSTALL.md`](INSTALL.md) §A): the
`mattpocock-skills` plugin, and this repository's `skills/`. Most days start
with the main flow.

**01 Getting started** — once per repo, then whenever you are lost.
Start with `/setup-matt-pocock-skills`.

| Skill | From | What it does |
| --- | --- | --- |
| `/setup-matt-pocock-skills` | plugin | Set up one repo so the other skills know how it works: GitHub as tracker, labels, glossary layout. |
| `/ask-matt` | plugin | Find out which skill fits the situation you are in. |

**02 The main flow** — the idea → merge spine, in order.
Start with `/grill-with-docs`.

| Skill | From | What it does |
| --- | --- | --- |
| `/grill-with-docs` | plugin | Get interviewed about the idea, in rounds; the glossary and the decisions get written as you answer. |
| `/to-spec` | plugin | Turn the agreed conversation into one spec issue. |
| `/to-tickets` | plugin | Split the spec into tickets an agent can build, each declaring what blocks it. |
| `/implement-ticket` | playbook | Build one ticket in a fresh session, test-first, through the gates, into a PR with a handoff. |
| `/verify-pr` | playbook | Re-run the gates on that PR, read the diff against the ticket, label, leave the verdict. |

**03 Shaping** — answer an open question so the flow can continue.
Start with `/prototype`.

| Skill | From | What it does |
| --- | --- | --- |
| `/prototype` | plugin | Answer a design question with code you then delete. |
| `/research` | plugin | Get a cited answer from primary sources, read by a background agent while you keep working. |

**04 Upkeep** — when something is broken or stuck.
Start with `/diagnosing-bugs`.

| Skill | From | What it does |
| --- | --- | --- |
| `/diagnosing-bugs` | plugin | A hard bug, a flake, a regression: build a loop that goes red first, then fix. |
| `/fix-bugbot` | playbook | Verify the review bots' findings on a PR, fix the real ones, reply on each thread. |
| `/resolving-merge-conflicts` | plugin | Resolve a merge or rebase conflict hunk by hunk, by intent. |
| `bash scripts/retro.sh` | playbook | Every ten merged PRs: the four numbers that say whether the protocol is failing. |

**05 Productivity** — session hygiene.
Start with `/wait-what`.

| Skill | From | What it does |
| --- | --- | --- |
| `/wait-what` | plugin | The last message did not land: get it re-pitched in plain words. |
| `/handoff` | plugin | Move the work to another machine, harness or person. Only when something travels. |

**06 Reference** — the agent reaches for these on its own; you can too.

| Skill | From | What it does |
| --- | --- | --- |
| `/grilling` | plugin | The interview itself, with no wrapper around it. |
| `/domain-modeling` | plugin | Sharpen a term, record a decision in `docs/adr/`, keep `CONTEXT.md` a glossary. |
| `/codebase-design` | plugin | The deep-module vocabulary: module, interface, seam, depth. |
| `/tdd` | plugin | Red, green, one slice at a time, only at agreed seams. |
| `/simplify` | playbook | The pass over the whole diff before the push. |
| `/writing-for-agents` | plugin | How to write skills, `AGENTS.md` and any doc an agent reads. |

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
