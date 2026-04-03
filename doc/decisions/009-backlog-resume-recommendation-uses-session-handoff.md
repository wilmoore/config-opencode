# 009. /pro:backlog.resume Recommends a Default Using Session Handoff

Date: 2026-03-26

## Status

Accepted

## Context

`/pro:backlog.resume` is intended to be the "new session entrypoint": start a
fresh session and immediately resume the right work.

When there are multiple backlog items with `status: "in-progress"`, choosing a
resume target is ambiguous. We want a recommendation that is:

- cheap (no extra tooling required)
- aligned with what the user was last doing
- compatible with existing safety rails and planning artifacts

This repo already maintains a session handoff ledger under
`doc/.plan/session-handoff/`.

## Decision

When multiple `in-progress` backlog items exist, `/pro:backlog.resume` will:

1. Look for `doc/.plan/session-handoff/index.json`.
2. If it contains pending snapshots, pick the newest pending snapshot and use
   its `branch` value as the recommended default.
3. Prompt the user to choose which item to resume, but clearly label the
   recommendation (do not auto-resume).

## Consequences

- ✅ Resumes are biased toward the most recently captured work context.
- ✅ Users retain control (prompt-first) while still getting a smart default.
- ✅ Integrates with existing session-handoff tooling without introducing new
  state files.
- ⚠️ If the handoff index is missing or contains no pending entries, the
  recommendation falls back to backlog ordering.

## Alternatives Considered

1. **Always prompt without any recommendation** – rejected because it adds
   friction at session start.
2. **Auto-resume the recommended branch** – rejected due to safety and to keep
   the user in control when ambiguity exists.

## Related

- ADR-003: `doc/decisions/003-adopt-per-session-handoff-ledger.md`
- ADR-004: `doc/decisions/004-maintain-session-handoff-metadata.md`
- Planning: `doc/.plan/.done/feat-port-pro-backlog-spec-spike/`
