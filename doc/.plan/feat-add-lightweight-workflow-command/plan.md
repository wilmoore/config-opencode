# Plan: Lightweight Non-Coding Workflow Command

## Planning Mode

Working in planning-first mode before implementation.

## Problem

`/pro:feature` and `/pro:chore` are optimized for code-heavy work. Some repos and tasks are operational workflows (dashboards, CRM updates, status changes, executive/agent maintenance) where:

- branch isolation is still desirable
- changes may be minimal or zero
- full heavy workflow steps (deep code review/test cadence) are unnecessary by default

## Relevant ADRs

- `doc/decisions/005-standardize-plan-root.md`
  - Planning artifacts must be stored under `doc/.plan/`.
- `doc/decisions/008-project-scoped-instruction-discovery.md`
  - Command guidance must remain project-scoped and avoid global instruction discovery.
- `doc/decisions/006-plan-by-default-safety-rail.md`
  - Keep plan-first behavior and explicit safety rails in command design.

## Agreed Scope

Add a new command under `opencode/pro/commands/` that provides a streamlined workflow for non-coding operational tasks.

Default behavior:

- create a branch first
- run a short planning pass
- execute focused workflow task
- avoid heavy feature/chore requirements unless code changes demand them
- handle no-change runs as successful outcomes

## Design Decisions

1. Command name: `/pro:ops`
2. Branch prefix: `ops/`
3. Keep mandatory branch-first invariant from ADR-017 style command safety language.
4. Do not require tests, coderabbit, or PR creation by default.
5. If no file changes exist, explicitly close with a no-op success path.
6. If changes exist, provide fast commit/push flow.

## Implementation Steps

1. Add `opencode/pro/commands/ops.md` with streamlined operational workflow.
2. Include explicit branch-first step and project-scoped instruction usage.
3. Include decision table for outcomes:
   - no changes
   - local commit only
   - commit + push
4. Validate file style consistency with existing `/pro:*` commands.

## Notes

- This command intentionally overlaps with feature/chore safety rails but trims heavy implementation overhead for operational tasks.
