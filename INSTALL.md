# INSTALL

Two things get installed: the **skills**, once per machine, and the
**protocol**, once per project. Nothing depends on anything; nothing updates
behind your back except the plugin, which is the point of using it.

## A. Once per machine (5 min)

```bash
claude plugins install mattpocock-skills        # shaping half, read-only, auto-updating
npx skills@latest add Lukapetro/playbook --all  # implement-ticket, verify-pr, simplify, fix-bugbot
```

Pick one route for Matt's skills, never both: the plugin, or
`npx skills add mattpocock/skills`. Installing both gives you every skill
twice. The playbook's own skills come only through `npx skills`; re-run the
command to pull updates.

## B. Once per project (10 min)

Assumes `PLAYBOOK` points at a clone of this repository:

```bash
export PLAYBOOK=~/dev/playbook
cd /path/to/your/project
```

### 1. Copy the CI checks (2 min)

```bash
mkdir -p ci .github/workflows docs/protocol
cp "$PLAYBOOK/ci/check-handoff.sh" "$PLAYBOOK/ci/check-itaca.sh" ci/
cp "$PLAYBOOK/ci/protocol.yml" .github/workflows/protocol.yml
cp "$PLAYBOOK/templates/ticket.md" "$PLAYBOOK/templates/handoff.md" docs/protocol/
chmod +x ci/check-handoff.sh ci/check-itaca.sh
```

The workflow is **copied, not referenced**. Reusable workflows hosted in a
private repository are not reliably available on free plans, and a protocol
check that silently stops running is worse than no check at all.

Do **not** copy `PROTOCOL.md` into the project. It lives in one place; the
project links to it. Copies drift.

### 2. Labels (1 min)

```bash
gh label create ready-for-agent      --color 0E8A16 --description "Ticket the frontier may dispatch" --force
gh label create retro:spec-failure   --color B60205 --description "Ticket was wrong or underspecified" --force
gh label create retro:mismatch       --color D93F0B --description "Handoff contradicted by diff or gates" --force
gh label create retro:post-merge-fix --color FBCA04 --description "Repairs a merged PR; body names which" --force
```

### 3. Configure the shaping skills (2 min)

In an agent session inside the project, run `/setup-matt-pocock-skills`.
Answer: **GitHub** as the issue tracker, **yes** to the default triage
labels, **single context** for the domain docs. It writes
`docs/agents/issue-tracker.md` and `docs/agents/domain.md`, which
`to-spec`, `to-tickets` and `code-review` read.

### 4. Fill in the bindings block (4 min)

This is the only step that takes thought.

```bash
cat "$PLAYBOOK/templates/agents-bindings.md" >> AGENTS.md
```

Then open `AGENTS.md`, delete the explanatory preamble above the `---`, and
fill every REQUIRED field: gate commands, reviewer chain, standing rules,
language conventions, merger. Delete OPTIONAL fields that do not apply — do
not leave them blank.

Sanity check before moving on: run each gate command exactly as written, from
the directory the block says to run it from. A gate command that does not run
copy-pasted is a bug in the bindings, and it will surface as a false handoff.

### 5. Create the state file (1 min)

Create `itaca.yml` at the repo root:

```yaml
version: 2
state:
  goal: <the outcome currently pursued, one line>
  doing: []
  blockers: []
  next_safe_action: <the single next action that is safe to take>
  assumptions: []
updated: <YYYY-MM-DD>
```

```bash
bash ci/check-itaca.sh itaca.yml   # expect: OK
```

Hot state only, 60 lines, no log, no backlog: the check enforces it. Full
field reference in [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md). `CONTEXT.md` and
`docs/adr/` are created lazily by the first shaping session that has
something to write in them.

Migrating a project that already has an itaca v1 file, or a first-v2 file with
a journal? Follow [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md) §3.

### 6. Verify

- [ ] `bash ci/check-itaca.sh itaca.yml` → OK
- [ ] every REQUIRED bindings field filled; every unused OPTIONAL one deleted
- [ ] every gate command runs copy-pasted, from the stated directory
- [ ] the four labels exist (`gh label list`)
- [ ] `docs/agents/issue-tracker.md` names GitHub
- [ ] the first PR after this one carries a `## Handoff` section and both
      `protocol` jobs go green

Commit it as one change:

```bash
git add -A && git commit -m "chore: install agent protocol (playbook)"
```

## Keeping in sync

Skills update through their installers (`claude plugins update`,
`npx skills update`). The copy-in files (`ci/`, `docs/protocol/`,
`.github/workflows/protocol.yml`) have no update mechanism, by design: when
one changes here in a way that matters, re-copy it. The bindings block never
gets re-copied — it is project-owned from the moment it is filled in.
