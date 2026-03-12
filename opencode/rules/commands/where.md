---
description: "Recommend where a new rule should live (command vs plugin vs ADR vs docs)"
agent: plan
---

## Context

Diagnose a rules/policy problem and recommend the best placement for the fix.

Input: $ARGUMENTS (brief description of the rules/policy problem, with 1 example)

Example:

`/rules:where agent keeps ignoring our safety invariant during feature work`

## Your Task

1. Ask 2-4 short questions to clarify:
   - what failure mode is happening (ignored rule, stale policy, unclear provenance, etc.)
   - who needs to follow it (you only vs team)
   - whether it must be enforced or is guidance
   - how long it should live (permanent vs time-boxed)

2. Recommend a placement, in this preference order:
   1) command (workflow/spec)
   2) plugin/enforcement (guardrail)
   3) ADR (`doc/decisions/*`) for trade-offs/decisions
   4) lightweight policy doc (`doc/rules/*`)
   5) reluctantly: `AGENTS.md` (constitutional invariants only)

3. Output a short recommendation with:
   - recommended location + why
   - what would change if placed elsewhere
   - a suggested filename/path (e.g. `doc/rules/<slug>.md` or `doc/decisions/NNN-<slug>.md`)
