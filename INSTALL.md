# INSTALL

Installing the protocol on a project. Target: **10 minutes**, once, per
project. Everything is copy-in — there is nothing to depend on and nothing to
keep up to date automatically.

Assumes `PLAYBOOK` points at a clone of this repository:

```bash
export PLAYBOOK=~/workspace/playbook
cd /path/to/your/project
```

## 1. Copy the CI check (2 min)

```bash
mkdir -p ci .github/workflows
cp "$PLAYBOOK/ci/check-handoff.sh" ci/
cp "$PLAYBOOK/ci/test-check-handoff.sh" ci/
cp -r "$PLAYBOOK/ci/fixtures" ci/
cp "$PLAYBOOK/ci/handoff.yml" .github/workflows/handoff.yml
chmod +x ci/check-handoff.sh ci/test-check-handoff.sh
bash ci/test-check-handoff.sh   # expect: 6 passed, 0 failed
```

The workflow is **copied, not referenced**. Reusable workflows hosted in a
private repository are not reliably available on free plans, and a protocol
check that silently stops running is worse than no check at all.

The fixtures and the test runner are optional — copy them if you want the check
to stay verifiable inside the project. Skip them and the workflow still works.

## 2. Copy the templates (1 min)

```bash
mkdir -p docs/protocol
cp "$PLAYBOOK/templates/work-order.md" docs/protocol/
cp "$PLAYBOOK/templates/handoff.md" docs/protocol/
```

Do **not** copy `PROTOCOL.md` into the project. It lives in one place; the
project links to it. Copies drift.

## 3. Fill in the bindings block (4 min)

This is the only step that takes thought.

```bash
cat "$PLAYBOOK/templates/agents-bindings.md" >> AGENTS.md
```

Then open `AGENTS.md`, delete the explanatory preamble above the `---`, and
fill every REQUIRED field: gate commands, state file location, reviewer chain,
commit/push authorizations, language conventions, merger. Delete OPTIONAL
fields that do not apply — do not leave them blank.

Sanity check before moving on: run each gate command exactly as written, from
the directory the block says to run it from. A gate command that does not run
copy-pasted is a bug in the bindings, and it will surface as a false handoff.

## 4. Create the state files (2 min)

```bash
mkdir -p journal docs/decisions
```

Create `itaca.yml` at the repo root:

```yaml
version: 2
state:
  goal: <the outcome currently pursued, one line>
  doing: []
  done: []
  blockers: []
  next_safe_action: <the single next action that is safe to take>
  assumptions: []
decisions: docs/decisions/
links:
  journal: journal/
updated: <YYYY-MM-DD>
```

Rules that matter from day one: hot state only, hard cap ~60 lines, no prose
log. Full field reference in [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md); schema in
[`itaca/schema-v2.json`](itaca/schema-v2.json).

Migrating a project that already has an itaca v1 file? Follow
[`itaca/SPEC-V2.md`](itaca/SPEC-V2.md) §4 — it is a mechanical mapping plus one
pass to extract decisions into ADRs.

## 5. Board link (1 min, optional)

If the project is tracked on Linear or another board, add it in two places:

- `itaca.yml` → `links.board`
- the bindings block → **Board** section

Skip entirely if there is no board. An empty pointer is worse than no pointer.

## 6. Verify

- [ ] `bash ci/test-check-handoff.sh` → 6 passed, 0 failed
- [ ] every REQUIRED bindings field filled; every unused OPTIONAL one deleted
- [ ] every gate command runs copy-pasted, from the stated directory
- [ ] `itaca.yml` is valid YAML, under 60 lines, `version: 2`
- [ ] `journal/` and `docs/decisions/` exist and are committed
- [ ] the first PR after this one carries a `## Handoff` section and the
      `handoff` check goes green

Commit it as one change:

```bash
git add -A && git commit -m "chore: install agent protocol (playbook)"
```

## Keeping in sync

There is no update mechanism, by design. When `PROTOCOL.md` or a template
changes here in a way that matters, re-copy the affected file into the projects
that need it. The bindings block never gets re-copied — it is project-owned
from the moment it is filled in.
