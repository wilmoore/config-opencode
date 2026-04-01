---
description: "Import a PRD/spec into doc/.plan and extract backlog items"
agent: build
---

## Context

Import spec: $ARGUMENTS

## Purpose

Persist a spec/PRD into `doc/.plan/specs/` and extract structured items into `doc/.plan/backlog.json`.

## Your Task

### Step 1: Accept input

- If `$ARGUMENTS` is a file path, read that file.
- If `$ARGUMENTS` looks like pasted markdown, use it as-is.
- If empty, ask the user to paste the spec content.

### Step 2: Spec metadata

- Title: first H1 if present, else first non-empty line.
- Spec index path: `doc/.plan/specs/index.json` (create if missing with `{"lastSequence": 0, "specs": []}`).
- Next spec number: increment `lastSequence` and format as 3 digits.
- Spec id: `spec-<NNN>`.
- Filename: `<spec-id>-<slugified-title>.md`.

### Step 3: Store raw spec (atomic write)

- Ensure `doc/.plan/specs/` exists.
- Write to temp file then rename.
- Preserve content losslessly.

### Step 4: Update spec index

Append spec entry:

```json
{
  "id": "spec-001",
  "title": "<title>",
  "filename": "spec-001-<slug>.md",
  "source": "clipboard|file",
  "importedAt": "<ISO 8601>",
  "extractedItems": { "epics": 0, "stories": 0 }
}
```

### Step 5: Parse for structured items

Extract epics and stories conservatively using the legacy detection rules (H2 epics, "As a" stories, etc.). Attach acceptance criteria to the nearest story.

If MoSCoW markers are present, capture:

- `phase`: `must|should|could|wont`
- `phaseSource`: `explicit`

### Step 6: Deduplicate + add to backlog

- Backlog path: `doc/.plan/backlog.json` (create if missing with `{"lastSequence": 0, "items": []}`).
- Fingerprint format:
  - epics: `spec|<spec-id>|epic|<hash>`
  - stories: `spec|<spec-id>|story|<hash>`
- Hash input: normalize `title + "\n" + first 200 chars of description`.
- If a fingerprint already exists, skip inserting that item.

New extracted items should be inserted as:

- `category`: `feature`
- `severity`: `medium` (unless you infer otherwise)
- `source`: `/pro:spec.import`
- `sourceSpec`: `<spec-id>`
- `status`: `open`

### Step 7: Report summary

Print:

- Spec id/title
- File path saved
- Counts of epics/stories extracted
- Added vs skipped (deduped)
- Suggest `/pro:spec` and `/pro:backlog`.

No branch creation.
