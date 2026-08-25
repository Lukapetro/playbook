# INSTALL

Two things get installed: the **skills**, once per machine, and the
**protocol**, once per project, with one command. Nothing depends on anything; nothing updates
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

## B. Once per project (1 command + 4 min)

From the project's root, with the playbook cloned anywhere:

```bash
bash ~/dev/playbook/install.sh
```

It does, idempotently:

1. copies `ci/check-handoff.sh`, `ci/check-itaca.sh` and
   `.github/workflows/protocol.yml` (copied, not referenced: reusable
   workflows in a private repository are not reliably available on free
   plans, and a protocol check that silently stops running is worse than no
   check);
2. creates the labels `ready-for-agent`, `retro:spec-failure`,
   `retro:mismatch`, `retro:post-merge-fix`;
3. writes `docs/agents/issue-tracker.md`, `domain.md`, `triage-labels.md`
   from the installed `mattpocock-skills` plugin — the same files
   `/setup-matt-pocock-skills` writes, with the answers this protocol fixes
   (GitHub, default labels, single context), so you never run it;
4. appends the `## Agent skills` and `## Agent protocol bindings` blocks to
   `AGENTS.md` (created if missing, with `CLAUDE.md` → `@AGENTS.md`);
5. creates `itaca.yml` and runs `ci/check-itaca.sh` on it.

Then the one step that takes thought: open `AGENTS.md` and fill every
REQUIRED field of the bindings block — gate commands, reviewer chain,
standing rules, language conventions, merger. Delete the OPTIONAL fields that
do not apply; do not leave them blank. Run each gate command exactly as
written, from the directory the block names: a gate that does not run
copy-pasted is a bug in the bindings, and it will surface as a false handoff.

Commit it as one change:

```bash
git add -A && git commit -m "chore: install agent protocol (playbook)"
```

The first PR after this one carries a `## Handoff` section and both
`protocol` jobs go green.

`PROTOCOL.md` is never copied into the project. It lives in one place; the
project links to it. Copies drift. The same goes for the templates: skills
and docs link to `templates/ticket.md` and `templates/handoff.md` here.

Migrating a project that already has an itaca v1 file, or a first-v2 file with
a journal? The script leaves the existing `itaca.yml` alone and reports what
the check finds; follow [`itaca/SPEC-V2.md`](itaca/SPEC-V2.md) §3.

## Keeping in sync

Skills update through their installers (`claude plugins update`,
`npx skills update`). The copy-in files (`ci/`, `.github/workflows/protocol.yml`)
update by re-running `install.sh`, which refreshes them and touches nothing
else. The bindings block never gets re-copied — it is project-owned from the
moment it is filled in.
