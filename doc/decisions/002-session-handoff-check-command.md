# 002. Add Manual Session Handoff Verification Command

Date: 2026-03-03

## Status

Accepted

## Context

The session handoff plugin writes per-session snapshots on lifecycle events,
but there was no explicit command to refresh or verify those files at the exact
moment a developer stops working. We needed a deterministic workflow to ensure
the ledger stays current before ending a session.

## Decision

Introduce `/pro:session.handoff` (formerly `.check`), a command that guides the
developer through listing outstanding snapshots, acknowledging or dismissing
them, and finally creating a fresh entry via the helper CLI. It mirrors the
plugin output but can be run manually any time.

## Consequences

- ✅ Developers can confidently end sessions knowing the outstanding snapshots are
  acknowledged, dismissed, or refreshed.
- ✅ Provides a repeatable fallback even if the plugin fails to trigger.
- ⚠️ Adds another command + helper script to maintain, but the logic is
  straightforward and reduces risk.

## Alternatives Considered

1. **Rely solely on plugin events** – rejected because idle timers might not run
   before shutdown, leading to stale instructions.
2. **Automate via git hooks** – rejected because the workflow needs to be
   editor-agnostic and user-driven.

## Related

- Planning: `.plan/.done/feat-continue-ccplugins-port/`
