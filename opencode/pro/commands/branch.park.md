---
description: "Pause a work branch and preserve planning docs for later"
agent: build
---

## Your Task

Pause work on the current branch and preserve planning docs for later resumption.

Canonical plan root is `doc/.plan/` (read legacy `.plan/` only as fallback).

### Step 1: Detect branch

- Get current branch: `git branch --show-current`
- If on `main`/`master`: stop with guidance.

### Step 2: Working tree triage

- If there are uncommitted changes, ask the user to choose one:
  - create a WIP commit
  - stash
  - cancel parking

Do not discard changes automatically.

### Step 3: Move planning docs

- Branch slug: replace `/` with `-`.
- If `doc/.plan/<branch-slug>/` exists, move it to `doc/.plan/.parked/<branch-slug>/`.

### Step 4: Update backlog items

- Read `doc/.plan/backlog.json`.
- Find items whose `sourceBranch` matches the current branch.
- For each matching item:
  - set `status: "open"`
  - set `parkedAt: <ISO 8601>`
  - set `planningDocs: "doc/.plan/.parked/<branch-slug>/"`

### Step 5: Commit on main

- Switch to `main`.
- Commit the backlog update and parked docs.

### Step 6: Delete the parked branch

- Delete local branch.
- If remote branch exists, ask before deleting it.

### Step 7: Report summary

Print the parked location and how to resume via `/pro:backlog.resume`.
