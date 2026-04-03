---
description: "Destroy a work branch and its planning docs (irreversible)"
agent: build
---

## Your Task

Completely destroy the current branch and associated planning docs.

Safety requirement:

- Require explicit user confirmation by having them type `RMRF`.
- If they do not confirm exactly, abort with no changes.

Canonical plan root is `doc/.plan/` (read legacy `.plan/` only as fallback).

### Steps

1. Detect current branch; if on `main`/`master`, stop.
2. Show a destruction preview:
   - recent commits
   - uncommitted changes
   - planning docs present under `doc/.plan/<branch-slug>/` or `doc/.plan/.parked/<branch-slug>/`
   - matching backlog items
3. Confirm `RMRF`.
4. If uncommitted changes exist, refuse to proceed and instruct the user to commit or stash first (then rerun). This command does not silently discard work.
5. Switch to `main`.
6. Remove planning docs dirs (active + parked) from BOTH locations if present:
   - `doc/.plan/<branch-slug>/` and `doc/.plan/.parked/<branch-slug>/`
   - legacy fallback: `.plan/<branch-slug>/` and `.plan/.parked/<branch-slug>/`
7. Update matching backlog items:
   - set `status: "aborted"`
   - set `completedAt: <ISO 8601>`
   - set `resolution: "aborted via /pro:branch.rmrf"`
   - remove `parkedAt`/`planningDocs` if present
8. Commit backlog change on `main`.
9. Delete local branch; ask before deleting remote.
10. Print a summary.
