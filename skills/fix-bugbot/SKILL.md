---
name: fix-bugbot
description: Verify review-bot findings (CodeRabbit, Greptile, Claude Review, Cursor Bugbot) on a PR, fix the real ones, commit, push and reply on each thread.
disable-model-invocation: true
argument-hint: "<PR number, or nothing for the current branch>"
---

# Fix Bugbot

Handle review-bot comments on a PR end-to-end: fetch, verify each finding against the current code, fix what is real, commit, push, react, and report. Invoking this skill is the authorization to commit and push the resulting fixes on the PR branch; it is never the authorization to merge.

Read the `AGENTS.md` bindings first: the gates to run, the commit convention, the language of PR prose. If the repository documents its own procedure (`docs/agent-workflows/fix-review-findings.md` or a pointer from `AGENTS.md`), it overrides this one.

Four reviewers can leave findings, and all four must be collected: **CodeRabbit** (`coderabbitai[bot]` — on repos that gate the merge on it, this is the main and sometimes the only reviewer), **Greptile** (external), **Claude Review** (the `claude[bot]` workflow) and **Cursor Bugbot**.

Two of them go quiet without saying so, and silence is not the same as "nothing found": Bugbot reports "usage limit reached" instead of reviewing, and CodeRabbit posts its rate-limit notice while its commit status still reads `success` — see step 2b.

## Workflow

### 1. Resolve the PR and branch

- PR number from the argument if given, otherwise `gh pr view --json number,headRefName` on the current branch.
- Never stash, reset, restore, or checkout another person's changes. If the current worktree cannot safely switch to the PR branch, ask the user or create a separate worktree from the PR branch.
- Unrelated untracked files cannot enter the commit when files are staged by name. Leave them untouched.

### 2. Fetch the bot findings

Inline review comments (the main source). **The filter must include `coderabbit` and `claude`**. A filter missing one of them returns an empty list that looks exactly like "no findings" — on 2026-08-06 a run against a PR with four CodeRabbit findings reported nothing to do, because the pattern omitted `coderabbit`:

```sh
gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate \
  --jq '.[] | select(.user.login | test("bugbot|cursor|greptile|claude|coderabbit"; "i")) | {id, path, line, created_at, body}'
```

Bots can also leave PR-level findings outside inline comments — check both:

```sh
gh api repos/{owner}/{repo}/issues/<n>/comments --jq '.[] | select(.user.login | test("bugbot|cursor|greptile|claude|coderabbit"; "i")) | .body'
gh api repos/{owner}/{repo}/pulls/<n>/reviews --jq '.[] | select(.user.login | test("bugbot|cursor|greptile|claude|coderabbit"; "i")) | .body'
```

When a filtered fetch comes back empty, re-run it **without** the `select(...)` before concluding there is nothing to do. An unexpected bot login is indistinguishable from silence, and this is the cheapest way to tell them apart.

Deduplicate already-handled findings: Bugbot bodies carry a `<!-- BUGBOT_BUG_ID: ... -->` marker; Greptile and CodeRabbit have no marker, so dedup by thread — a finding is handled if a previous reply in its thread reports the outcome (see step 6). No bot resolves its own outdated comments, so absent a reply, always check whether the described issue still exists in the code before treating it as new.

### 2b. Establish which commit was actually reviewed

Before reporting "nothing found", check that a review happened at all on the current head:

```sh
gh pr checks <n>          # a "Review rate limited" description next to a passing check = nobody reviewed
gh pr view <n> --json headRefOid --jq .headRefOid
```

CodeRabbit publishes its commit status as `success` even when it reviewed nothing, with the description `Review rate limited`; its PR comment then says how long until the next included review. A repo may carry a gate workflow that reads the description and turns that into an honest red — if the gate is red while CI is green, that is the signal, not a failure to fix.

Two consequences, both worth stating in the final report:

- Findings you *do* see may belong to an **earlier commit**. CodeRabbit's comment lists the range it reviewed ("Reviewing files that changed between `<sha>` and `<sha>`") — check it before assuming the latest push was covered.
- After pushing fixes, the new head is unreviewed again. Say so plainly rather than implying the PR is ready: a rate-limited reviewer means the merge stays blocked until `@coderabbitai review` (posted as a PR comment once the budget frees up) lands a real review on the final SHA.

### 3. Verify each finding one by one

NEVER blind-fix. For every finding, read the code at `path:line` and trace the failure scenario:

- **Real** → fix it, staying strictly within the finding's scope (no drive-by refactors).
- **Not real / outdated / by design** → skip and record the reason for the final report.

When a finding hinges on how a library/framework API behaves (ORM conflict handling, streaming, auth flows, …), don't rely on memory. Evidence, strongest first:

1. **Run the flow and look.** A throwaway test that exercises the real code path against the test database and dumps the table settles the question outright. Use it whenever the claim is "X ends up stored in Y".
2. **Read the installed source** under `node_modules/<pkg>/dist/**`, and cite file and symbol in the reply. This beats the docs: it is the exact version running here, and option names mislead — better-auth's `updateEmailWithoutVerification: false` means the opposite of what it sounds like.
3. **Current documentation**, through context7 when available or the web otherwise, for intent and recommended usage that the source does not state.

Skip all three when the finding is plain logic with no library surface.

This cuts both ways, and both ways are valuable: evidence can confirm the finding and shape the fix, or refute it — and a refutation citing file and symbol is worth far more in the thread than "we think it's fine".

Two failure modes seen repeatedly, worth checking explicitly:

- **The guard already exists, in the library.** Before accepting "there is no check for X", look for it in the dependency too, not only in our code.
- **Right instinct, wrong premise.** A finding can be worth acting on for a reason different from the one it gives. Say so plainly in the reply instead of accepting or rejecting wholesale — fix the real issue, and correct the stated premise.

### 4. Verify the fixes

- Run every gate in the bindings' table, verbatim, from the directory it
  names. Keep the numbers.
- If a fixed bug had no test that would have caught it, add one alongside
  the fix, at the seam the bug lives at.
- Run the simplification pass on the diff: call the Skill tool with
  "simplify".

**Read the exit code, never filtered output.** Run verification commands directly; do not pipe them through `tail` or another command that can mask failure.

### 5. Commit and push

- One commit for all the fixes, following the bindings' commit convention. No attribution trailers unless the bindings allow them.
- `git push`.

### 6. Reply on each handled thread

Document the outcome on the PR so threads are self-explanatory and future runs can dedup, in the language the bindings set for PR prose. One line is enough when you simply fixed it; a refusal or a partial acceptance needs the reasoning, with the file and symbol that settle it — per step 3 that argument is the most valuable thing in the thread.

```sh
gh api repos/{owner}/{repo}/pulls/<n>/comments/<comment-id>/replies \
  -f body='fixed in <short-sha>'          # or: 'unfounded: <reason>'
```

Replies carry apostrophes and backticks, and `-f body='…'` breaks on the first one. For anything longer than a few words, write the body to a file in the scratchpad and pass it by reference — `gh` reads `@path` and no quoting applies:

```sh
gh api repos/{owner}/{repo}/pulls/<n>/comments/<comment-id>/replies -F body=@reply.txt
```

For PR-level findings (no inline thread), one summary comment via `gh pr comment <n> --body-file <path>` covering all of them.

### 7. React on each Greptile finding (👍 / 👎)

Greptile's own docs call reactions "the primary way Greptile learns your preferences" — the reply text alone does **not** train it. So every verified finding gets one, matching the outcome you just wrote in the thread:

```sh
gh api -X POST repos/{owner}/{repo}/pulls/comments/<comment-id>/reactions -f content='+1'   # founded
gh api -X POST repos/{owner}/{repo}/pulls/comments/<comment-id>/reactions -f content='-1'   # wrong premise
```

👍 when the finding was real (including "real for a different reason than stated" — the instinct was right). 👎 only when the premise was wrong, and the thread reply must already explain why.

Only for Greptile, and skip the step entirely when it left no findings. `claude[bot]` is a stateless workflow and learns nothing from reactions; for CodeRabbit the reply text in the thread is what carries, so spend the effort there (step 6) rather than on a 👍.

### 8. Restore and report

- If a separate worktree was created in step 1, leave the original worktree untouched and report the worktree path.
- Final report per finding, one of three outcomes: **fixed** (one-line description), **partly fixed** (what you took, what you refused, why — the "right instinct, wrong premise" case from step 3 lands here and is common), or **unfounded** (reason). Lead with the count: "N findings: X fixed, Y partly, Z unfounded". If the PR carries a `## Handoff`, update its Review field to match.
- State plainly which reviewers were silent and why — rate-limited is not the same as clean — and whether the final SHA is covered by a real review. A report that omits this reads as "ready to merge" when it is not.
