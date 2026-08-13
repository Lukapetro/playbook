# playbook

The operating manual for agent-driven projects.

I run several projects with the same workflow: an **orchestrator** agent plans
and writes work orders, an **implementer** agent executes exactly one of them
per fresh session and delivers a PR plus a handoff report, and a human decides
and merges. That protocol used to live scattered across per-repo docs and
ad-hoc prompts, which meant it drifted: every project ended up with a slightly
different version, and improvements learned in one never reached the others.

This repository is its canonical, portable home.

## The three pieces

**1. The protocol — [`PROTOCOL.md`](PROTOCOL.md).** The invariants. Roles, the
principles that constrain how work is split, the enforcement ladder (advisory →
repo policy → deterministic), the work-order structure, the handoff report, and
the retro metrics that tell you when the protocol itself is failing. Universal:
nothing project-specific ever goes here.

**2. Per-project bindings — [`templates/agents-bindings.md`](templates/agents-bindings.md).**
Everything the protocol deliberately leaves open: which commands are the gates,
where the state file lives, who reviews, who merges, what an implementer is
authorized to push, which language the code and docs are written in. Pasted
into each repository's `AGENTS.md` and filled in there. The protocol says
"run the gates"; the bindings say what the gates are.

**3. The state — [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md).** A fresh session
starts with no memory. itaca is the per-repo state file that gives it one:
`itaca.yml` holds hot state and only hot state (goal, in flight, blockers, the
next safe action, unverified assumptions), narrative goes to `journal/`, and
decisions go to ADRs under `docs/decisions/`. v2 is a breaking change from
[v1](https://github.com/Lukapetro/itaca), which mixed all three in one file
until it stopped being readable at a glance.

Protocol tells the agent how to work. Bindings tell it how to work *here*.
itaca tells it where things stand.

## Contents

| Path | What it is |
| --- | --- |
| [`PROTOCOL.md`](PROTOCOL.md) | The invariants. Read this first. |
| [`INSTALL.md`](INSTALL.md) | Installing the protocol on a project, ~10 minutes. |
| [`templates/work-order.md`](templates/work-order.md) | Paste-ready work order, seven sections. |
| [`templates/handoff.md`](templates/handoff.md) | Paste-ready `## Handoff` PR section, seven fields. |
| [`templates/agents-bindings.md`](templates/agents-bindings.md) | The per-project block for `AGENTS.md`. |
| [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md) | itaca v2: state file, journal, ADRs, migration, CLI roadmap. |
| [`itaca/schema-v2.json`](itaca/schema-v2.json) | JSON Schema for `itaca.yml` v2. |
| [`ci/check-handoff.sh`](ci/check-handoff.sh) | Dependency-free check: PR body carries a conforming handoff. |
| [`ci/handoff.yml`](ci/handoff.yml) | Copy-in GitHub Actions workflow that runs the check. |
| [`ci/fixtures/`](ci/fixtures/) | Passing and failing PR bodies. |
| [`ci/test-check-handoff.sh`](ci/test-check-handoff.sh) | Test runner for the check. |

## Scope

Documents, one bash script, one JSON Schema, one workflow file. No
dependencies, no build step, no package manager.

The itaca CLI described in [`SPEC-V2.md`](itaca/SPEC-V2.md) §5 is **specified
here, implemented elsewhere**. Same for hooks, skills and plugins: this
repository defines the protocol, it does not ship tooling.

## Using it

```bash
bash ci/test-check-handoff.sh   # verify the CI check still works
```

To install on a project, follow [`INSTALL.md`](INSTALL.md).
