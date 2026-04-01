---
description: "High-level project status dashboard from backlog + git"
agent: build
---

## Your Task

Show a roadmap dashboard based on `doc/.plan/backlog.json` and git/GitHub context.

Data sources:

- Backlog: `doc/.plan/backlog.json` (fallback read `.plan/backlog.json`)
- Open PRs (optional): `gh pr list --state open`
- Recent merged PRs (optional): `gh pr list --state merged --limit 10`

Dashboard sections:

- In progress: backlog items with `status: in-progress` + current branch
- Recently completed: items with `status: completed` (and also accept legacy `resolved`)
- Backlog: items with `status: open`, grouped by category
- Blocked: items with `status: blocked` (if present)

Write a timestamped markdown report to the temp dir and print its path.
