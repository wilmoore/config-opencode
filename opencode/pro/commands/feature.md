---
description: "Starting something new? Plan your approach with guided questions, then create a feature branch and implement"
agent: build
---

## Context

Let's plan and implement: $ARGUMENTS

If `$ARGUMENTS` is empty, ask for a short feature description before proceeding.

## Your Task

**CRITICAL: Branch creation is mandatory and must happen first. Never perform investigation, code reading, or changes until the branch exists. This is a non-negotiable safety invariant per ADR-017.**

0. **Immediate branch creation (first action)**
   - If current directory is not a git repository, run this bootstrap flow first:
     - `git init`
     - `git add .`
     - `git commit -m "Initial commit"` (only if there is no commit yet)
     - Ask whether to create a GitHub remote now:
       - Recommended: `gh repo create --source=. --push`
       - Alternative: skip and continue local-only
   - Generate a `feat/` branch name from the feature description and create it.
     - Example: `add dark mode toggle` -> `feat/add-dark-mode-toggle`
   - Do not proceed until branch creation succeeds.
1. Enter plan mode and explicitly announce that you are in planning first.
2. Check ADRs for related decisions:
   - Search `doc/decisions/` for relevant prior decisions.
   - Summarize relevant ADRs before proposing changes.
   - Do not contradict prior ADRs without explicitly acknowledging trade-offs.
3. Confirm and document requirements and scope.
4. Ask clarifying questions until design and approach are mutually clear.
5. Add this work to backlog as `in-progress`:
   - Ensure `doc/.plan/backlog.json` exists; if missing create:
     ```json
     {"lastSequence": 0, "items": []}
     ```
   - Increment `lastSequence` and append:
     ```json
     {
       "id": <next sequence>,
       "title": "<brief title from requirements>",
       "description": "<full description>",
       "category": "feature",
       "severity": "medium",
       "fingerprint": "feature|<id>|<slugified-title>",
       "source": "/pro:feature",
       "sourceBranch": "<branch name>",
       "createdAt": "<ISO 8601 timestamp>",
       "status": "in-progress"
     }
     ```
6. Store planning notes and todos in `${ProjectRoot}/doc/.plan/${BranchName}` where branch slashes are replaced with dashes.
   - Example: `feat/add-dark-mode` -> `doc/.plan/feat-add-dark-mode/`
7. Outline detailed implementation steps.
8. Implement the feature and document changes.
9. Run:
   - `coderabbit --prompt-only`
10. Document known issues not addressed in this pass:
   - Preferred: `/pro:backlog.add <description>`
   - If unavailable, append directly to `doc/.plan/backlog.json` with:
     - `source` set to `/pro:feature`
     - `sourceBranch` set to current branch

## Debugging During Implementation

Per ADR-063, when bugs arise during feature work:

- Check existing logs at `${XDG_STATE_HOME:-$HOME/.local/state}/<app-name>/` before running programs.
- Treat logs as authoritative; execution is a last resort.
- Do not add application-level file logging; use stdout/stderr.

## Browser Verification

For web apps, prefer Playwright MCP (if available) over screenshots for:

- visual verification and UI state inspection
- console log and error analysis
- network request inspection

## Definition of Done

See project instruction files inside the project root only (`AGENTS.md`, `CLAUDE.md`, or `.claude/CLAUDE.md`).

Do not glob or search outside the project directory for instruction files (ignore any global `AGENTS.md`/`CLAUDE.md`).

- All feature requirements are met.
- Verified by both user and assistant.
- No known errors, bugs, or warnings introduced by this work.
