---
description: "Found a bug? Capture repro steps, document severity, and fix it on a dedicated branch"
agent: build
---

## Context

Let's investigate and fix: $ARGUMENTS

## Bug Details Capture

Before planning the fix, gather the following information through guided prompts:

1. **Steps to Reproduce** - Ordered, copy-pastable steps that reliably trigger the bug
2. **Expected Behavior** - What should happen when following those steps
3. **Actual Behavior** - What actually happens (error messages, incorrect output, etc.)
4. **Environment** - Relevant context (environment, browser, device, OS, commit/branch)
5. **Severity** - Impact level (blocks work, degraded experience, minor annoyance)

## Your Task

**CRITICAL: Branch creation is MANDATORY and must happen FIRST. Never perform any application code investigation, code reading, or changes until the branch exists (ADR-017). Documentation review such as ADR lookups is allowed as soon as the branch exists because it is part of planning, not code execution.**

0. **IMMEDIATELY create branch** - Generate a `fix/` branch name from the initial bug description
   (`$ARGUMENTS`) and create it. Do NOT proceed to any other step until this is complete.
   Example: "login button broken" → `fix/login-button-broken`
1. Enter **plan mode** (announce this) and immediately review ADRs for related decisions. Search `doc/decisions/` for prior decisions tied to this area, summarize what applies, and explicitly cite any ADRs you need to challenge before changing course. This ADR review is part of planning and is the only permitted doc lookup before touching code.
2. Capture bug details via the guided prompts above. Ask each question interactively.
3. **Add to backlog as in-progress** - This enables `/pro:backlog.resume` to pick up where you left off:
   - Ensure `doc/.plan/backlog.json` exists (create with `{"lastSequence": 0, "items": []}` if not)
   - Map severity from bug details: "blocks work" → critical, "degraded experience" → high, "minor annoyance" → low
   - Increment `lastSequence` and add item:
     ```json
     {
       "id": <next sequence>,
       "title": "<brief title from bug description>",
       "description": "<full bug details including repro steps>",
       "category": "bug",
       "severity": "<mapped from bug details>",
       "fingerprint": "bug|<id>|<slugified-title>",
       "source": "/pro:bug",
       "sourceBranch": "<branch name>",
       "createdAt": "<ISO 8601 timestamp>",
       "status": "in-progress"
     }
     ```
4. Store all planning notes, bug details, and related documentation here: `${ProjectRoot}/doc/.plan/${BranchName}` with the following branch naming strategy: `fix/pattern-matcher-tests-static-rule` >> `fix-pattern-matcher-tests-static-rule`.
5. **Investigate root cause** - Gather empirical evidence, trace code paths, identify where the bug originates. Do not proceed to implementation until the root cause is understood.
   - **Per ADR-063:** Check for existing logs at `${XDG_STATE_HOME:-$HOME/.local/state}/<app-name>/` before asking to run the program. Logs are authoritative artifacts—execution is a last resort.
6. Outline fix implementation steps.
7. Implement the fix and document changes.
8. **Verify fix** - Confirm the reproduction steps no longer trigger the bug.
9. `> coderabbit --prompt-only`
10. Document any related issues discovered that won't be addressed here:
    - Use `/pro:backlog.add <description>` to add items to the backlog
    - Set `source` to `/pro:bug` and `sourceBranch` to current branch

## Browser Verification

For web applications, use Playwright MCP (if available) rather than screenshots for:
- Visual verification and UI state inspection
- Console log and error analysis
- Network request inspection

## Definition of Done
> SEE: @claude.md

- Bug no longer reproduces using the original reproduction steps.
- Root cause is documented in planning notes.
- Fix does not introduce regressions.
- Verified by both user and assistant.
- No errors, bugs, or warnings.
