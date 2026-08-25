# Handoff skeleton

Paste this into the PR body. The heading must be exactly `## Handoff` — the CI
check in [`../ci/check-handoff.sh`](../ci/check-handoff.sh) looks for that
string and for all seven field labels. Every field is required; `nothing` and
`none` are valid answers, silence is not.

---

## Handoff

**Outcome:** <what now exists that did not before, one paragraph>

**Gates:**

- `<command>` → <numbers: tests run, failures, errors, exit status>
- `<command>` → <numbers>
- <gate not run, and why>

**Simplify:** <what the simplification pass found and what was changed, or
`nothing`>

**Review:**

- code-review / Standards: <finding> — founded / unfounded — <how it was closed>
- code-review / Spec: <finding> — founded / unfounded — <how it was closed>
- <reviewer>: <finding> — founded / unfounded — <how it was closed>
- Final SHA covered by review: yes / no (<SHA>)

**Discoveries:** <out-of-scope findings, as backlog candidates — not fixed
here>, or `none`

**Deviations:** <every departure from the ticket, with the reason>, or
`none`

**State left:** branch `<name>`; `itaca.yml` updated: yes / no; worktree clean:
yes / no
