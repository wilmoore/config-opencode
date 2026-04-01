---
description: "View imported specs and trace extracted backlog items"
agent: build
---

## Context

$ARGUMENTS

## Purpose

Read-only visibility into imported specifications stored under `doc/.plan/specs/`.

## Your Task

1. Read spec index
   - Path: `doc/.plan/specs/index.json`
   - If missing: tell the user no specs have been imported and suggest `/pro:spec.import`.

2. Display mode
   - If `$ARGUMENTS` is empty: show summary view for all specs.
   - If `$ARGUMENTS` contains a spec id like `spec-001`: show detailed view.

3. Summary view
   - Print a table: id, title, extracted stories count, importedAt.

4. Detailed view
   - Read the spec markdown file from `doc/.plan/specs/<filename>`.
   - Find related backlog items in `doc/.plan/backlog.json`:
     - `item.sourceSpec === <spec-id>`, OR
     - `item.fingerprint` starts with `spec|<spec-id>|`.
   - Print the related items table (id/title/status/category).
   - Show the spec content (first ~50 lines) and offer to show more.

No side effects.
