---
description: "Run through all MUST items in the backlog (single branch, iterative workflow)"
agent: build
---

## Context

MVP workflow: $ARGUMENTS

## Purpose

Work through MUST-scope backlog items systematically in a single branch.

Notes:

- This command prefers `phase: must` when present.
- If `phase` is missing, it may infer MUST from severity (`critical`/`high`).

## Your Task

1. Read `doc/.plan/backlog.json` (fallback read `.plan/backlog.json`).
2. Identify MVP items:
   - Include if `phase === "must"`, OR if `phase` is missing and `severity` is `critical`/`high`.
   - Exclude items whose `status` is not `open`.
3. If an MVP batch is already in progress (items with `mvpBatch: true` and `status: "in-progress"`):
   - Report progress and instruct user to run `/pro:backlog.resume`.
   - Stop.
4. Create a branch `mvp/<project-slug>` (derive slug from directory name).
5. Mark all MVP items as `in-progress` and add:
   - `mvpBatch: true`
   - `mvpBatchStartedAt`: timestamp
   - `sourceBranch`: mvp branch
6. Iterate items in ID order:
   - For each item: plan briefly, implement, verify, then mark completed:
     - `status: completed`
     - `completedAt`: timestamp
     - remove `mvpBatch`
   - Commit after each item with a clear message.
7. When complete, print a summary and suggest `/pro:pr`.

Safety:

- If you need user input mid-run, stop and hand back to the user instead of guessing.
