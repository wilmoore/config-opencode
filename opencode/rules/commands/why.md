---
description: "Explain why a rule exists by tracing provenance and ADRs"
agent: plan
---

## Context

Explain "why" a rule/policy exists and where it came from.

Input: $ARGUMENTS

## Your Task

1. Ask for the rule reference if missing (path, excerpt, or behavior).
2. Search the current repository for provenance stamps and links:
   - `Source:`
   - `Added:`
   - `Owner:`
   - `ReviewBy:`
   - ADR links under `doc/decisions/`
3. Return:
   - the originating source (ADR/file/link) if found
   - the intent (what problem it was meant to prevent)
   - current applicability (is it stale?)
4. If provenance is missing, propose a minimal provenance stamp and where to add it.
