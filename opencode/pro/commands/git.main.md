---
description: "Standardize default branch to main (safe, confirm-first)"
agent: build
---

## Your Task

Safely rename a repository's default branch to `main`.

Flow:

1. Inspect:
   - current branch
   - detached HEAD
   - uncommitted changes
   - whether `main` already exists
   - remote default branch (if origin exists)
2. Hard-stop on unsafe conditions (dirty tree, detached HEAD, main already exists).
3. If already on `main` and it is the default, no-op.
4. Require explicit confirmation phrase before any rename.
5. Execute:
   - local rename
   - if origin exists: push `main`, update GitHub default via `gh api`, delete old remote branch
6. Verify and report.
