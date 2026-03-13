---
description: "Find stale rules by scanning for ReviewBy stamps"
agent: plan
---

## Context

Rules go stale. This command helps detect and clean up expired guidance.

## Your Task

1. Scan the current repository for `ReviewBy:` stamps in:
   - `doc/rules/`
   - `doc/decisions/`
   - `AGENTS.md`
   - `CLAUDE.md`

   Expected stamp format: `ReviewBy: YYYY-MM-DD` (ISO 8601 date), e.g. `ReviewBy: 2026-12-31`.
2. Report items whose ReviewBy date is in the past.
3. For each stale item, recommend one of:
   - update (still correct; refresh date)
   - deprecate (document replacement)
   - delete (if safe)
4. If there are no ReviewBy stamps, recommend adding them going forward and suggest using `/rules:propose`.
