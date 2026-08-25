---
name: simplify
description: Simplification pass over a whole diff after implementation and tests are green and before the push. Use when the user asks to simplify, clean up or refine recently written code, or when an implementation skill reaches its simplify step.
---

Improve clarity and consistency of the diff without changing behaviour,
public contract or scope. The code that is reviewed, tested and pushed must
be the same code.

If the repository documents its own procedure (`docs/agent-workflows/simplify.md`
or a pointer from `AGENTS.md`), read it first: it overrides this one.

## Procedure

1. Read the entire diff against the base branch, not only the last files
   touched. `git diff <base>...HEAD`.
2. Load the rules `AGENTS.md` points at for every path in the diff.
3. For each hunk, ask: is there accidental complexity here that a reader
   would have to work around? Remove it: dead branches, duplicated logic,
   an abstraction with one caller, a name that does not say what it holds,
   a comment restating the code, nesting that a guard clause flattens, a
   nested ternary where a `switch` reads.
4. Prefer the minimal edit. No new abstractions, no compatibility layers, no
   speculative generality. Explicit beats compact.
5. Touch nothing outside the diff. Never overwrite another person's changes
   in the worktree.
6. Re-run the tests that cover every file you changed. Type checker too.
7. Read the whole diff once more. If a change made it harder to debug or to
   extend, revert that change.

Done when the diff reads as if written once, on purpose, and the tests are
green. Report what was simplified in one paragraph, or `nothing`: both are
valid outcomes, and `nothing` is expected often.
