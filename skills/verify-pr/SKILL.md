---
name: verify-pr
description: Verify an implementer's PR against its ticket and its handoff as the orchestrator. Re-run the gates on the head SHA in a separate worktree, read the diff against the ticket, apply the retro labels, leave a verdict.
disable-model-invocation: true
argument-hint: "<PR number or URL>"
---

The orchestrator never accepts a handoff at face value. Every claim in it is
a hypothesis until re-run. This skill re-runs them. Invoking it is the
authorization to apply labels and comment on the PR; it is never the
authorization to merge.

## 1. Resolve

- `gh pr view <n> --json number,title,body,headRefOid,headRefName,baseRefName,commits,closingIssuesReferences,labels`
- The ticket is the closing issue reference. No ticket: the PR is outside the
  protocol, say so and stop.
- `gh issue view <ticket> --comments` for the ticket body.
- The handoff is the `## Handoff` section of the PR body. Missing or
  incomplete: the PR is not ready; leave the verdict and stop.

## 2. Check out the head, elsewhere

`git worktree add <scratch path> <headRefOid>`. Never switch the current
worktree; never stash or reset anything. Every command below runs inside the
new worktree.

## 3. Re-run the gates

Every command in the `AGENTS.md` bindings' gates table, verbatim, on that
SHA. Compare each result with the handoff's **Gates** field, number by
number. A gate the handoff reports as run with numbers you cannot reproduce,
or a gate it omits that fails, is a **report/reality mismatch**.

## 4. Read the diff against the ticket

`gh pr diff <n>`. Answer each question with evidence from the diff, not from
the handoff:

- Does the diff deliver **What to build**, and nothing the ticket did not ask?
- Does it stay inside **Boundaries**? Is every **Forbidden action** untouched?
- Do the **Done when** commands run and return what the ticket says? Run them.
- Is every departure from the ticket listed under **Deviations**? An
  undeclared departure is a mismatch.
- Does the **Review** field match reality: did the reviewers the bindings name
  actually review this head SHA? Check the artefacts, not the check colour.

Then judge the ticket itself. If the implementer had to stop, deviate or
guess because the ticket was wrong or underspecified, that is a
**spec failure**: shaping's fault, not the implementer's.

## 5. Label

Create the labels on first use, then apply what applies:

```sh
gh label create retro:spec-failure   --color B60205 --description "Ticket was wrong or underspecified" --force
gh label create retro:mismatch       --color D93F0B --description "Handoff contradicted by diff or gates" --force
gh label create retro:post-merge-fix --color FBCA04 --description "Repairs a merged PR; body names which" --force
gh pr edit <n> --add-label retro:mismatch
```

A PR that repairs an already-merged PR gets `retro:post-merge-fix` here, and
its body must name the PR it repairs.

## 6. State

If the PR changes `itaca.yml`, check it against the caps (60 lines,
`doing` ≤ 3, `blockers` ≤ 3, `assumptions` ≤ 5) and check that
`next_safe_action` is the action that follows this merge. If it is wrong or
missing and the implementer session has ended, push one commit to the PR
branch that fixes only that file, and say so in the verdict.

## 7. Verdict

One comment on the PR, `gh pr comment <n> --body-file <path>`:

- **Ready for merge** or **Not ready**, first line.
- Gates: reproduced / not reproduced, with the numbers that differed.
- Ticket: delivered / partial / off-ticket, with the evidence.
- Labels applied, and why.
- What the merger should look at first.

Remove the worktree (`git worktree remove <path>`). Report the verdict to the
user. Do not merge.
