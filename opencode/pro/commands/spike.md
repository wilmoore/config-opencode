---
description: "Time-boxed exploration to reduce uncertainty (creates a spike branch)"
agent: build
---

## Context

Let's explore: $ARGUMENTS

## Your Task

**CRITICAL: Branch creation is mandatory and must happen first. Never perform investigation, code reading, or changes until the branch exists.**

0. Immediately create a `spike/` branch from the description.
   - Example: `explore redis caching options` -> `spike/explore-redis-caching-options`

1. Enter planning
   - Announce planning mode.
   - Clarify:
     - What uncertainty are we reducing?
     - What does success look like?
     - Time-box (default: 60 minutes).

2. Add to backlog as in-progress
   - Backlog file: `doc/.plan/backlog.json` (create if missing with `{"lastSequence": 0, "items": []}`).
   - Append a new item:
     - `category`: `spike`
     - `severity`: `medium`
     - `source`: `/pro:spike`
     - `sourceBranch`: spike branch name
     - `status`: `in-progress`

3. Create minimal planning dir
   - `doc/.plan/<branch-slug>/` (slashes -> dashes)
   - Create `plan.md` containing:
     - time-box
     - hypotheses
     - questions to answer
     - how results will be captured

4. Explore
   - Prefer reading docs/logs over running programs.
   - Capture findings incrementally.

5. Findings (optional)
   - Ask whether to write `doc/.plan/<branch-slug>/findings.md`.
