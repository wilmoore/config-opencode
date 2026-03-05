# 004. Maintain Session Handoff Metadata Integrity

Date: 2026-03-04

## Status

Accepted

## Context

Per-session handoff snapshots rely on both `index.json` and the markdown files under
`doc/.plan/session-handoff/sessions/`. Acknowledging or dismissing a snapshot through the
CLI updated the JSON index but left the markdown files stale. Trigger metadata was
also dropped whenever the plugin refreshed an entry, producing confusing
`Trigger: undefined` headers.

## Decision

Normalize the session handoff helpers and CLI so every metadata change goes through
`collectRepoState`/`applyMetadata`, keeps the trigger in place, and rewrites the
markdown snapshot after `ack` and `dismiss`. The CLI now emits a single
`updatedAt` timestamp per operation and persists acknowledgement/dismissal details
before refreshing the ledger.

## Consequences

- ✅ Snapshot files match their `index.json` counterparts, so authors can trust the
  on-disk checklist without cross-referencing raw JSON.
- ✅ CLI output now shows accurate trigger information, making it easier to trace
  which workflow captured a snapshot.
- ⚠️ Each CLI invocation performs additional filesystem writes, marginally
  increasing runtime (still negligible compared to user time).

## Alternatives Considered

1. **Leave markdown stale** – rejected because it forces manual edits and confuses
   handoffs.
2. **Store status-only JSON** – rejected to preserve the human-friendly markdown
   source of truth.

## Related

- Planning: `.plan/.done/fix-session-handoff-message-ux/`
