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
