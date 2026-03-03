# 002. Add Manual Session Handoff Verification Command

Date: 2026-03-03

## Status

Accepted

## Context

The session handoff plugin writes `.plan/session-handoff.md` on lifecycle
events, but there was no explicit command to refresh or verify that file at the
exact moment a developer stops working. We needed a deterministic workflow to
ensure the snapshot is current before ending a session.

## Decision

Introduce `/pro:session.handoff.check`, a command that gathers git metadata and
backlog state, rewrites `.plan/session-handoff.md`, and confirms the timestamp is
fresh. It mirrors the plugin output but can be run manually any time.

## Consequences

- ✅ Developers can confidently end sessions knowing the resume instructions are
  up to date.
- ✅ Provides a repeatable fallback even if the plugin fails to trigger.
- ⚠️ Adds another command to maintain, but its logic is straightforward and
  reduces risk.

## Alternatives Considered

1. **Rely solely on plugin events** – rejected because idle timers might not run
   before shutdown, leading to stale instructions.
2. **Automate via git hooks** – rejected because the workflow needs to be
   editor-agnostic and user-driven.

## Related

- Planning: `.plan/.done/feat-continue-ccplugins-port/`
