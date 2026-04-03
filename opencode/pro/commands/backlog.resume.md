---
description: "Resume in-progress work or recommend the next backlog item"
agent: build
---

## Context

What's next? $ARGUMENTS

## Your Task

Treat this as a new-session entrypoint.

Canonical sources:

- Backlog: `doc/.plan/backlog.json` (fallback read: `.plan/backlog.json`)
- Session handoff index (optional tie-breaker): `doc/.plan/session-handoff/index.json`

Session handoff index schema (optional):

- File: `doc/.plan/session-handoff/index.json`
- Shape: `{ "version": <number>, "sessions": [ ... ] }`
- Each session is an object containing (minimum):
  - `id`: string
  - `branch`: string
  - `status`: string (expect `pending`; other values like `acknowledged`/`dismissed` may exist)
  - timestamps like `createdAt`/`updatedAt` may exist

Tie-break rule: use the newest session with `status: "pending"` and prefer its `branch` when recommending which in-progress item to resume.

### Step 1: Load backlog

- If no backlog exists, tell the user and suggest `/pro:backlog.add`.

### Step 2: Resume in-progress items (if any)

1. Filter items with `status: "in-progress"`.
2. If exactly one exists:
   - Recommend it and resume it.
3. If multiple exist:
   - Determine a recommended default:
     - If `doc/.plan/session-handoff/index.json` exists and has any `pending` sessions, pick the newest pending session and use its `branch` value.
     - If any in-progress item has `sourceBranch` matching that `branch`, mark it as the recommended default.
   - Present a numbered list of in-progress items and ask which to resume.
   - Per user preference: prompt for a choice, but clearly label the recommended default.

### Step 3: Switch to the work branch

For the chosen item:

- Determine branch name:
  - Prefer `item.sourceBranch`.
  - If missing, ask the user.
- Switch:
  - If branch exists locally: `git checkout <branch>`
  - Else if branch exists on origin: create tracking branch and checkout
  - Else: warn that the branch does not exist and ask whether to:
    - recreate it (`git checkout -b <branch>`), or
    - set the item back to `open`

### Step 4: Restore context

- Show:
  - backlog item id/title
  - branch name
  - working tree status
  - recent commits (`git log --oneline -10`)
- If planning docs exist under `doc/.plan/<branch-slug>/`, read and summarize them.

### Step 5: If no in-progress items

- Recommend the next item:
  - Filter `status: "open"`
  - Sort by severity then createdAt
- Present a short list and ask whether to start it.
- If yes, follow `/pro:backlog` branch creation + backlog update flow.
