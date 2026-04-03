---
description: "Track something for later? Add an item to the backlog"
agent: build
---

## Context

Add to backlog: $ARGUMENTS

## Your Task

Add a new item to the backlog file at `doc/.plan/backlog.json`.

1. Parse the description
   - The full argument string after `/pro:backlog.add` is the item description.
   - Generate a concise title (first sentence or first ~80 chars).

2. Ask for category and severity
   - Category: `security|bug|tests|feature|debt|i18n|spike|chore`
   - Severity: `critical|high|medium|low`

3. Ensure backlog exists
   - Ensure `doc/.plan/` exists.
   - If `doc/.plan/backlog.json` is missing, create it with:

```json
{"lastSequence": 0, "items": []}
```

4. Append the item
   - Read `doc/.plan/backlog.json`.
   - Increment `lastSequence` and use it as the new `id`.
   - Set:
     - `fingerprint`: `manual|<id>|<slugified-title>`
     - `source`: `manual`
     - `sourceBranch`: current git branch name (or `unknown` if not in a git repo)
     - `createdAt`: ISO 8601 timestamp
     - `status`: `open`

5. Write and confirm
   - Write the updated JSON back to `doc/.plan/backlog.json`.
   - Print: `Added to backlog #<id>: <title>`
