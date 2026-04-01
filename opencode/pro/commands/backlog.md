---
description: "Pick backlog items to work on and start a branch"
agent: build
---

## Context

Ready to work on: $ARGUMENTS

## Your Task

Use `doc/.plan/backlog.json` to select one or more open items, create a branch, mark them in-progress, and start planning.

### Step 1: Read backlog

- Prefer `doc/.plan/backlog.json`.
- If missing, fall back to `.plan/backlog.json` (read-only compatibility).
- If neither exists, tell the user there is no backlog yet and suggest `/pro:backlog.add <description>`.

### Step 2: If work is already in progress

- If any backlog items have `status: "in-progress"`, show them.
- Offer options:
  - Resume (run `/pro:backlog.resume`)
  - Start new work anyway
  - Mark an item blocked (if you support `blocked` in this repo) or revert it to `open`

### Step 3: Present selectable open items

- Only show items with `status: "open"`.
- If items have `phase`, group/sort by phase (must > should > could > wont).
- Otherwise, sort by severity (critical > high > medium > low) then by `createdAt` (oldest first).

Because OpenCode command UX is plain text, present a numbered list with:

- `#<id> [<category>] [<severity>] <title>`

Ask the user to reply with one or more item IDs to work on (comma-separated).

### Step 4: Create a branch

Generate a descriptive branch name based on selected items:

- Security/bug/tests: `fix/...`
- Spike: `spike/...`
- Feature: `feat/...`
- Chore/i18n: `chore/...`
- Debt: `refactor/...`

Rules:

- Lowercase
- Dash-separated
- Keep the slug short (<= ~50 chars)

Create and switch to the branch.

### Step 5: Update backlog + planning dir

- Update each selected item:
  - `status`: `in-progress`
  - `sourceBranch`: the new branch name
- Write backlog changes to `doc/.plan/backlog.json`.

Create planning dir:

- `doc/.plan/<branch-slug>/` where slashes become dashes
- Create at least `plan.md` describing goals/acceptance and a short next-steps checklist.

### Step 6: Enter planning

Explicitly announce you are in planning mode and begin the plan.
