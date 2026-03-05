# Plan: Automate Session Handoff Snapshots

## Goals

1. Replace the static `.plan/session-handoff.md` workflow with per-session snapshots that persist until acknowledged or dismissed.
2. Extend repo automation so command installs auto-discover every `opencode/pro/commands/*.md` file and retire the slash namespace fallback.
3. Keep session visibility high with CLI helpers, prompts, and documentation updates so future sessions immediately know what remains.

## Tasks

1. Update the Makefile so install/uninstall/doctor/status iterate over the real command list instead of the hand-maintained trio, and remove `NS=slash` logic plus help text.
2. Build a session handoff helper module + CLI that can list snapshots, write new ones, and acknowledge or dismiss pending entries.
3. Rework the session-handoff plugin to write per-session files (with a ledger/index), emit a status prompt for outstanding sessions, and keep `.plan/session-handoff.md` as a summary ledger.
4. Refresh `/pro:session.handoff` instructions (and related docs) so users know how to list, complete, and create snapshots via the new CLI commands.
5. Add ignores for session handoff artifacts so git status stays clean while still keeping backlog/plan artifacts tracked.

## Verification

1. `make doctor`, `make uninstall`, and `make install` succeed and install all command files without manual updates.
2. Starting a new OpenCode session writes a new snapshot, logs outstanding entries exactly once, and updates the ledger.
3. `node bin/session-handoff.mjs list|ack|dismiss|write` update both the index and ledger immediately.
4. `/pro:session.handoff` command text matches the new workflow and points to the CLI helpers.
5. `make status` reports every linked command and shows the plugin link.

## Related ADRs

- doc/decisions/002-session-handoff-check-command.md
- doc/decisions/003-adopt-per-session-handoff-ledger.md
