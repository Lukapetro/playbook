# Skills

The playbook's own skills: the two agent sessions of `PROTOCOL.md` §3, the
simplification pass, and the review-bot procedure. Installed once per machine
with [skills.sh](https://skills.sh), never copied into a project:

```bash
npx skills@latest add Lukapetro/playbook
```

They compose with the `mattpocock-skills` plugin (`tdd`, `code-review`,
`grilling`, …); `PROTOCOL.md` §8 lists which ones the protocol uses.

## User-invoked

Only the human fires these: each one writes to a remote.

- **[implement-ticket](./implement-ticket/SKILL.md)**: implement one ticket in this session, test-first at its seams, through the gates, simplified, reviewed, delivered as a PR with a handoff.
- **[verify-pr](./verify-pr/SKILL.md)**: verify an implementer's PR as the orchestrator: re-run the gates on the head SHA, read the diff against the ticket, apply the retro labels, leave a verdict.
- **[fix-bugbot](./fix-bugbot/SKILL.md)**: verify review-bot findings on a PR, fix the real ones, commit, push, reply on each thread.

## Model-invoked

- **[simplify](./simplify/SKILL.md)**: the simplification pass over a whole diff, after tests are green and before the push.

## Scripts

- **[`scripts/retro.sh`](../scripts/retro.sh)**: the four retro metrics over the last N merged PRs.
