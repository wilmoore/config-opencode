---
description: "Need a lightweight operational workflow? Create an isolated branch, execute quickly, and finish with optional commit/push"
agent: build
---

## Context

Let's run an operational workflow task: $ARGUMENTS

If `$ARGUMENTS` is empty, ask for a short task description before proceeding.

## What is /pro:ops?

`/pro:ops` is for work that is not quite a feature and not quite a chore. Typical examples:

- Dashboard status updates
- CRM record maintenance
- Agent/executive repo operations
- Opportunity pipeline updates
- Workflow-specific repository housekeeping with minimal or no code edits

This command keeps branch isolation and safety, but removes heavy code-centric defaults.

## Your Task

**CRITICAL: Branch creation is mandatory and must happen first. Never perform investigation, code reading, or changes until the branch exists.**

### 0) Immediate branch creation (first action)

- If current directory is not a git repository, bootstrap:
  - `git init`
  - `git add .`
  - `git commit -m "Initial commit"` (only when no commit exists)
- Create an `ops/` branch from the task description.
  - Example: `update q2 opportunities board` -> `ops/update-q2-opportunities-board`
- Do not proceed until branch creation succeeds.

### 1) Enter planning mode first

- Announce planning mode.
- Confirm intended workflow outcome and success criteria in 2-5 bullets.

### 2) Respect project-scoped instructions

- Use only project-local guidance (`AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md`, `doc/decisions/*`, `doc/rules/*`).
- Do not search outside the project root.

### 3) Execute the operational task with minimal overhead

- Prefer the shortest safe path to completion.
- Avoid code-heavy rituals by default:
  - no mandatory broad test suites
  - no mandatory coderabbit
  - no mandatory PR flow
- Run only checks directly relevant to the requested operation.

### 4) Decide close-out path from git diff

After execution, inspect `git status` and follow exactly one path:

1. **No changes**
   - Report: "No repository changes were required."
   - Keep branch for traceability unless user asks to delete it.

2. **Changes present, local only**
   - Stage relevant files.
   - Commit with concise message focused on intent.
   - Stop after local commit.

3. **Changes present, ship now**
   - Stage and commit.
   - Push branch (`git push -u origin <branch>`).
   - Create PR only if user explicitly requests it.

### 5) Capture lightweight planning artifact

- Write short notes to `doc/.plan/<branch-slug>/plan.md` including:
  - task summary
  - actions taken
  - outcome path chosen (no changes/local commit/pushed)
  - any deferred follow-ups

### 6) Track follow-up gaps

- If issues are discovered but not handled:
  - Preferred: `/pro:backlog.add <description>`
  - Fallback: append to `doc/.plan/backlog.json` with:
    - `source`: `/pro:ops`
    - `sourceBranch`: current branch

## Definition of Done

- Task outcome is reached with minimum safe effort.
- Branch isolation preserved.
- If changes exist, they are clearly committed (and pushed only when requested).
- If no changes exist, no-op completion is explicitly documented.
