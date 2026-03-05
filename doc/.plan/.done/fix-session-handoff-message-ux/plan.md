# Plan: Fix Session Handoff Message UX

## Goals

1. Preserve CLI-authored snapshot metadata so triggers and timestamps stay accurate.
2. Regenerate markdown files whenever statuses change to keep per-session checklists trustworthy.
3. Validate that ack/dismiss/write flows update both the index and ledger in real time.

## Tasks

1. Update `opencode/pro/lib/session-handoff.mjs` so `createSnapshotEntry` and `applyMetadata` carry trigger metadata forward safely.
2. Extend `bin/session-handoff.mjs` ack/dismiss handlers to stamp `updatedAt`, persist acknowledgements/dismissals, and rewrite snapshot files.
3. Exercise the CLI end-to-end to confirm ledger/index updates without manual edits.

## Verification

1. `node bin/session-handoff.mjs write --trigger "dev.session"`
2. `node bin/session-handoff.mjs ack <id> --note "verification"`
3. `node bin/session-handoff.mjs dismiss <id> --reason "verification"`

## Related ADRs

- doc/decisions/004-maintain-session-handoff-metadata.md
